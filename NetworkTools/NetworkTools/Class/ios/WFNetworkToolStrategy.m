//
//  WFNetworkToolStrategy.m
//  NetworkTools
//
//  Created by 王飞 on 2020/11/10.
//  Copyright © 2020 wang. All rights reserved.
//

#import "WFNetworkToolStrategy.h"
#import "WFNetworkPingService.h"
#import "WFNetworkDNSScanService.h"
#import "WFNetworkRouteTraceService.h"

// ping操作超时时长(单位: 秒)
#define kPingTimeoutSeconds     (30)
// route trace操作超时时长(单位: 秒)
#define kRouteTimeoutSeconds    (60)
// dns探测操作超时时长(单位: 秒)
#define kDNSTimeoutSeconds      (30)

@interface WFNetworkToolStrategy ()

// ping工具
@property (nonatomic, strong) WFNetworkPingService *pingService;
// route trace工具
@property (nonatomic, strong) WFNetworkRouteTraceService *routeService;
// dns工具
@property (nonatomic, strong) WFNetworkDNSScanService *dnsService;

// 工具类型
@property (nonatomic, assign, readwrite) XPNetworkToolType type;
// 操作唯一标识(以当前系统时间毫秒数)
@property (nonatomic, assign) long long identifier;

@end

@implementation WFNetworkToolStrategy

- (instancetype)initWithType:(XPNetworkToolType)type {
    self = [super init];
    
    if (self) {
        self.type = type;
        [self initSymbols];
    }
    
    return self;
}

- (void)startWithHost:(NSString *)host
       operationBlock:(void(^)(NSString *operation))operationBlock
            stopBlock:(void(^)(void))stopBlock {
    switch (self.type) {
        case XPNetworkToolTypePing:
            [self.pingService startWithHost:host operationBlock:operationBlock stopBlock:stopBlock];
            break;
        case XPNetworkToolTypeRouteTrace:
            [self.routeService startWithHost:host operationBlock:operationBlock stopBlock:stopBlock];
            break;
        case XPNetworkToolTypeDNSScan:
            [self.dnsService startWithHost:host operationBlock:operationBlock stopBlock:stopBlock];
            break;
        default:
            break;
    }
    
    [self addOperationTimeout];
}

- (void)stop {
    switch (self.type) {
        case XPNetworkToolTypePing:
            [self.pingService stop];
            break;
        case XPNetworkToolTypeRouteTrace:
            [self.routeService stop];
            break;
        case XPNetworkToolTypeDNSScan:
            [self.dnsService stop];
            break;
        default:
            break;
    }
}

- (BOOL)isStarting {
    BOOL bStarting = NO;
    
    switch (self.type) {
        case XPNetworkToolTypePing:
            bStarting = [self.pingService isPinging];
            break;
        case XPNetworkToolTypeRouteTrace:
            bStarting = [self.routeService isWorking];
            break;
        case XPNetworkToolTypeDNSScan:
            bStarting = [self.dnsService isWorking];
            break;
        default:
            break;
    }
    
    return bStarting;
}

- (NSTimeInterval)tts {
    NSTimeInterval interval = 0;
    
    switch (self.type) {
        case XPNetworkToolTypePing:
            interval = [self.pingService tts];
            break;
        case XPNetworkToolTypeRouteTrace:
            interval = [self.routeService tts];
            break;
        case XPNetworkToolTypeDNSScan:
            interval = [self.dnsService tts];
            break;
        default:
            break;
    }
    
    return interval;
}

- (NSString *)testData {
    NSString *data = nil;
    
    switch (self.type) {
        case XPNetworkToolTypePing:
            data = [self.pingService testData];
            break;
        case XPNetworkToolTypeRouteTrace:
            data = [self.routeService testData];
            break;
        case XPNetworkToolTypeDNSScan:
            data = [self.dnsService testData];
            break;
        default:
            break;
    }
    
    return data;
}

#pragma mark - private

- (void)initSymbols {
    switch (self.type) {
        case XPNetworkToolTypePing:
            self.pingService = [[WFNetworkPingService alloc] init];
            break;
        case XPNetworkToolTypeRouteTrace:
            self.routeService = [[WFNetworkRouteTraceService alloc] init];
            break;
        case XPNetworkToolTypeDNSScan:
            self.dnsService = [[WFNetworkDNSScanService alloc] init];
            break;
        default:
            break;
    }
}

- (void)addOperationTimeout {
    // 这里设置超时
    self.identifier = (long long)[[NSDate date] timeIntervalSince1970] * 1000;
    long long identifier = self.identifier;

    __weak typeof(self) weakSelf = self;
    dispatch_after([self operationTimeoutTime], dispatch_get_main_queue(), ^{
        // !!!这里注意一下identifier不能传self.identifier，详细见block实现原理
        [weakSelf handleOperationTimeout:identifier];
    });
}

- (void)handleOperationTimeout:(long long)identifier {
    if (identifier == self.identifier && [self isStarting]) {
        [self stop];
    }
}

- (dispatch_time_t)operationTimeoutTime {
    int seconds = 0;
    
    switch (self.type) {
        case XPNetworkToolTypePing:
            seconds = kPingTimeoutSeconds;
            break;
        case XPNetworkToolTypeRouteTrace:
            seconds = kRouteTimeoutSeconds;
            break;
        case XPNetworkToolTypeDNSScan:
            seconds = kDNSTimeoutSeconds;
            break;
        default:
            break;
    }
    return dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * seconds);
}

@end
