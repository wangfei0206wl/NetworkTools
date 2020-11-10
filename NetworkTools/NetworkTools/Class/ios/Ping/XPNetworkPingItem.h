//
//  XPNetworkPingItem.h
//  pandora_p
//
//  Created by 王飞 on 2018/12/4.
//  Copyright © 2018 搜狗企业IT部. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 ping的状态定义

 - XPPingStatusStart: 开始ping
 - XPPingStatusSendPacketFail: 发送ping包失败
 - XPPingStatusReceivePacket: 接收response成功
 - XPPingStatusReceiveUnexpectedPacket: 接收到异常包
 - XPPingStatusTimeout: 发送ping超时
 - XPPingStatusError: ping错误
 - XPPingStatusFinish: ping结束
 */
typedef NS_ENUM(NSInteger, XPPingStatus) {
    XPPingStatusStart = 0,
    XPPingStatusSendPacketFail,
    XPPingStatusReceivePacket,
    XPPingStatusReceiveUnexpectedPacket,
    XPPingStatusTimeout,
    XPPingStatusError,
    XPPingStatusFinish,
};

/**
 小P的ping对应的item
 */
@interface XPNetworkPingItem : NSObject

// 目标原地址或域名
@property (nonatomic, strong) NSString *host;
// 目标ip地址
@property (nonatomic, strong) NSString *ip;
// 数据字节长度
@property (nonatomic, assign) NSUInteger dataLength;
// 响应时长(毫秒数)
@property (nonatomic, assign) double responseTime;
// ttl请求生命周期
@property (nonatomic, assign) NSInteger timeToLive;
// icmp的序列
@property (nonatomic, assign) NSInteger sequence;
// 错误信息
@property (nonatomic, strong) NSString *errorDesc;
// 状态
@property (nonatomic, assign) XPPingStatus status;

/**
 根据ping的item集合生成ping统计信息

 @param arrItems ping的item集合
 @return ping统计信息
 */
+ (NSString *)statisticsWithItems:(NSArray *)arrItems;

@end
