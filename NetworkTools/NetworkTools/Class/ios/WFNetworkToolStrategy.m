//
//  WFNetworkToolStrategy.m
//  NetworkTools
//
//  Created by 王飞 on 2020/11/10.
//  Copyright © 2020 wang. All rights reserved.
//

#import "WFNetworkToolStrategy.h"

// ping操作超时时长(单位: 秒)
#define kPingTimeoutSeconds     (30)
// route trace操作超时时长(单位: 秒)
#define kRouteTimeoutSeconds    (60)
// dns探测操作超时时长(单位: 秒)
#define kDNSTimeoutSeconds      (30)

@interface WFNetworkToolStrategy ()

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
    }
    
    return self;
}

- (void)startWithHost:(NSString *)host
       operationBlock:(void(^)(NSString *operation))operationBlock
            stopBlock:(void(^)())stopBlock {
    
}

- (void)stop {
    
}

- (BOOL)isStarting {
    BOOL bStarting = NO;
    
    return bStarting;
}

- (NSTimeInterval)tts {
    NSTimeInterval interval = 0;
    
    return interval;
}

- (NSString *)testData {
    NSString *data = nil;
    
    return data;
}

@end
