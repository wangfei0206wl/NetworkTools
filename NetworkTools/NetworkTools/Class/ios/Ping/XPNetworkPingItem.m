//
//  XPNetworkPingItem.m
//  pandora_p
//
//  Created by 王飞 on 2018/12/4.
//  Copyright © 2018 搜狗企业IT部. All rights reserved.
//

#import "XPNetworkPingItem.h"

@implementation XPNetworkPingItem

- (NSString *)description {
    NSString *destString = @"";
    
    switch (self.status) {
        case XPPingStatusStart:
            destString = [NSString stringWithFormat:@"PING %@ (%@): %ld data bytes\n\n",self.host, self.ip, (long)self.dataLength];
            break;
        case XPPingStatusReceivePacket:
            destString = [NSString stringWithFormat:@"%ld bytes from %@: icmp_seq=%ld ttl=%ld time=%.3f ms\n\n", (long)self.dataLength, self.ip, (long)self.sequence, (long)self.timeToLive, self.responseTime];
            break;
        case XPPingStatusTimeout:
            destString = [NSString stringWithFormat:@"Request timeout for icmp_seq %ld，ttl = %ld\n\n", (long)self.sequence,(long)self.timeToLive];
            break;
        case XPPingStatusSendPacketFail:
            destString = [NSString stringWithFormat:@"Fail to send packet to %@: icmp_seq=%ld\n\n", self.ip, (long)self.sequence];
            break;
        case XPPingStatusReceiveUnexpectedPacket:
            destString = [NSString stringWithFormat:@"Receive unexpected packet from %@: icmp_seq=%ld\n\n", self.ip, (long)self.sequence];
            break;
        case XPPingStatusError:
            destString = [NSString stringWithFormat:@"Can not ping to %@\n\n", self.host];
            break;
        default:
            break;
    }
    return destString;
}

+ (NSString *)statisticsWithItems:(NSArray *)arrItems {
    NSString *host = [arrItems.firstObject host];
    
    __block NSInteger receiveCount = 0;
    __block NSInteger allCount = 0;
    __block CGFloat minElapseTime = MAXFLOAT;
    __block CGFloat maxElapseTime = 0;
    __block CGFloat totalElapseTime = 0;
    __block CGFloat avgElapseTime = 0;
    
    [arrItems enumerateObjectsUsingBlock:^(XPNetworkPingItem *item, NSUInteger idx, BOOL *stop) {
        if (item.status != XPPingStatusFinish && item.status != XPPingStatusError) {
            allCount++;
            if (item.status == XPPingStatusReceivePacket) {
                totalElapseTime += item.responseTime;
                minElapseTime = (minElapseTime > item.responseTime)?item.responseTime:minElapseTime;
                maxElapseTime = (maxElapseTime < item.responseTime)?item.responseTime:maxElapseTime;
                receiveCount++;
            }
        }
    }];
    // 最小值及平均值处理
    minElapseTime = (minElapseTime == MAXFLOAT)?0:minElapseTime;
    avgElapseTime = (receiveCount == 0)?0:(totalElapseTime / receiveCount);
    
    NSMutableString *destString = [NSMutableString string];
    [destString appendFormat:@"--- %@ ping statistics ---\n", host];
    
    CGFloat lossPercent = (CGFloat)(allCount - receiveCount) / MAX(1.0, allCount) * 100;
    [destString appendFormat:@"%ld packets transmitted, %ld packets received, %.2f%% packet loss\n", (long)allCount, (long)receiveCount, lossPercent];
    [destString appendFormat:@"round-trip  min / avg / max = %.3f / %.3f / %.3f ms\n\n\n", minElapseTime, avgElapseTime, maxElapseTime];
    [destString stringByReplacingOccurrencesOfString:@".0%" withString:@"%"];
    
    return destString;
}

@end
