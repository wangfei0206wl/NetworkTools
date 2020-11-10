//
//  WFNetworkPingService.m
//  NetworkTools
//
//  Created by 王飞 on 2020/11/10.
//  Copyright © 2020 wang. All rights reserved.
//

#import "WFNetworkPingService.h"
#include <netdb.h>
#include <sys/socket.h>
#import "SimplePing.h"
#import "XPNetworkPingItem.h"

@interface WFNetworkPingService ()

// 操作回调
@property (nonatomic, copy) void(^operationBlock)(NSString *operation);
// ping结束回调
@property (nonatomic, copy) void(^stopBlock)();
// ping类
@property (nonatomic, strong) SimplePing *pinger;
// 定时器
@property (nonatomic, strong) NSTimer *timer;
// ping记录集
@property (nonatomic, strong) NSMutableArray<XPNetworkPingItem *> *arrPingItems;

// 目标host
@property (nonatomic, strong) NSString *host;
// 目标ip地址
@property (nonatomic, strong) NSString *ip;
// 当前ICMP序列
@property (nonatomic, assign) NSInteger curSequenceNumber;
// 当前ping状态
@property (nonatomic, assign) BOOL bPinging;
// ping超时最大时长(點认500毫秒)
@property (nonatomic, assign) double timeoutMilSeconds;

// 开始时间
@property (nonatomic, strong) NSDate *startDate;
// 结束时间
@property (nonatomic, strong) NSDate *endDate;
// 输出信息集(单次dns)
@property (nonatomic, strong) NSMutableArray *arrDatas;

@end

@implementation WFNetworkPingService
 
- (void)startWithHost:(NSString *)host
       operationBlock:(void(^)(NSString *operation))operationBlock
            stopBlock:(void(^)(void))stopBlock {
    self.ip = @"";
    self.host = host;
    self.operationBlock = operationBlock;
    self.stopBlock = stopBlock;
    self.bPinging = YES;
    self.timeoutMilSeconds = 500;
    self.startDate = [NSDate date];
    [self.arrPingItems removeAllObjects];
    self.arrDatas = [NSMutableArray array];
    
    self.pinger = [[SimplePing alloc] initWithHostName:host];
    self.pinger.delegate = (id<SimplePingDelegate>)self;
    [self.pinger start];
}

- (void)stop {
    [self.pinger stop];
    [self stopPingTimer];
    
    self.bPinging = NO;
    self.endDate = [NSDate date];
    
    if (self.arrPingItems.count > 0) {
        NSString *statistics = [XPNetworkPingItem statisticsWithItems:self.arrPingItems];
        
        [self.arrDatas addObject:statistics];
        if (self.operationBlock) {
            self.operationBlock(statistics);
        }
    }
    if (self.stopBlock) {
        self.stopBlock();
    }
}

- (BOOL)isPinging {
    return self.bPinging;
}

- (NSTimeInterval)tts {
    if (self.startDate && self.endDate) {
        return [self.endDate timeIntervalSinceDate:self.startDate];
    }
    return 0;
}

- (NSString *)testData {
    return [self.arrDatas componentsJoinedByString:@""];
}

#pragma mark - SimplePingDelegate

- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    NSData *packet = [self.pinger packetWithPingData:nil]; // 发送的ICMP包
    NSUInteger dataLength = packet.length - sizeof(ICMPHeader); // 发送的payload大小(不包含ICMP头部字节数)
    
    self.ip = [self displayAddressWithData:address];
    [self handlePingOperation:XPPingStatusStart sequence:0 dataLength:dataLength responseTime:0 timeToLive:0 errorDesc:nil];
    [self startSendPingOperation];
    
    // 这里设置一下ping超时
    [self performSelector:@selector(handlePingTimeout) withObject:nil afterDelay:(self.timeoutMilSeconds / 1000)];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(handlePingTimeout) object:nil];
    
    NSString *errorDesc = [self shortErrorFromError:error];
    
    [self handlePingOperation:XPPingStatusError sequence:0 dataLength:0 responseTime:0 timeToLive:0 errorDesc:errorDesc];
    [self handlePingOperation:XPPingStatusFinish sequence:0 dataLength:0 responseTime:0 timeToLive:0 errorDesc:nil];
    [self stop];
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    self.curSequenceNumber = sequenceNumber;
}

- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(handlePingTimeout) object:nil];
    
    NSString *errorDesc = [self shortErrorFromError:error];
    
    self.curSequenceNumber = sequenceNumber;
    [self handlePingOperation:XPPingStatusSendPacketFail sequence:sequenceNumber dataLength:0 responseTime:0 timeToLive:0 errorDesc:errorDesc];
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber timeToLive:(NSInteger)timeToLive timeElapsed:(NSTimeInterval)timeElapsed {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(handlePingTimeout) object:nil];
    
    [self handlePingOperation:XPPingStatusReceivePacket sequence:sequenceNumber dataLength:packet.length responseTime:(timeElapsed * 1000) timeToLive:timeToLive errorDesc:nil];
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(handlePingTimeout) object:nil];
    
    [self handlePingOperation:XPPingStatusReceiveUnexpectedPacket sequence:self.curSequenceNumber dataLength:packet.length responseTime:0 timeToLive:0 errorDesc:nil];
}

#pragma mark - private

- (void)startSendPingOperation {
    /*
     开始发送ICMP
     需要先发送一个ICMP，再启动timer定时发送ICMP
     */
    [self sendPing];
    [self startPingTimer];
}

- (void)startPingTimer {
    // 启动ping定时器(用于定时发送ICMP)
    [self stopPingTimer];
    
    // 每隔1s发送一次ICMP
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(sendPing)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)stopPingTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)sendPing {
    [self.pinger sendPingWithData:nil];
}

- (void)handlePingTimeout {
    // 处理发送ICMP包时超时
    [self handlePingOperation:XPPingStatusTimeout sequence:self.curSequenceNumber dataLength:0 responseTime:0 timeToLive:0 errorDesc:nil];
}

- (void)handlePingOperation:(XPPingStatus)status
                   sequence:(NSInteger)sequence
                 dataLength:(NSUInteger)dataLength
               responseTime:(double)responseTime
                 timeToLive:(NSInteger)timeToLive
                  errorDesc:(NSString *)errorDesc {
    XPNetworkPingItem *pingItem = [[XPNetworkPingItem alloc] init];
    
    pingItem.host = (status == XPPingStatusStart)?[self getHostNameByHost:self.host]:self.host;
    pingItem.ip = self.ip;
    pingItem.status = status;
    pingItem.sequence = sequence;
    pingItem.dataLength = dataLength;
    pingItem.responseTime = responseTime;
    pingItem.timeToLive = timeToLive;
    pingItem.errorDesc = errorDesc;
    
    if (status == XPPingStatusReceivePacket || status == XPPingStatusTimeout) {
        // 这里只收集发送成功及发送超时的ICMP，其他不作为统计使用
        [self.arrPingItems addObject:pingItem];
    }
    
    NSString *description = [pingItem description];
    
    [self.arrDatas addObject:description];
    if (self.operationBlock) {
        self.operationBlock(description);
    }
}

- (NSMutableArray *)arrPingItems {
    if (!_arrPingItems) {
        _arrPingItems = [NSMutableArray array];
    }
    return _arrPingItems;
}

- (NSString *)displayAddressWithData:(NSData *)data {
    int err = 0;
    NSString *result = nil;
    char hostStr[NI_MAXHOST];
    
    if (data != nil) {
        err = getnameinfo(data.bytes, (socklen_t)data.length, hostStr, sizeof(hostStr), NULL, 0, NI_NUMERICHOST);
        if (err == 0) {
            result = @(hostStr);
        }
    }
    
    if (result == nil) {
        result = @"?";
    }
    
    return result;
}

- (NSString *)getHostNameByHost:(NSString *)host {
    const char *hostString = [host cStringUsingEncoding:NSASCIIStringEncoding];
    struct hostent *hptr;
    
    hptr = gethostbyname(hostString);
    
    if (hptr != NULL) {
        return [NSString stringWithCString:hptr->h_name encoding:NSUTF8StringEncoding];
    } else {
        return host;
    }
}

- (NSString *)shortErrorFromError:(NSError *)error {
    NSString *result = nil;
    NSNumber *failureNum;
    int failure;
    const char * failureStr;
    
    assert(error != nil);
    
    // Handle DNS errors as a special case.
    
    if ( [error.domain isEqual:(NSString *)kCFErrorDomainCFNetwork] && (error.code == kCFHostErrorUnknown) ) {
        failureNum = error.userInfo[(id) kCFGetAddrInfoFailureKey];
        if ( [failureNum isKindOfClass:[NSNumber class]] ) {
            failure = failureNum.intValue;
            if (failure != 0) {
                failureStr = gai_strerror(failure);
                if (failureStr != NULL) {
                    result = @(failureStr);
                }
            }
        }
    }
    
    // Otherwise try various properties of the error object.
    if (result == nil) {
        result = error.localizedFailureReason;
    }
    if (result == nil) {
        result = error.localizedDescription;
    }
    assert(result != nil);
    return result;
}

@end
