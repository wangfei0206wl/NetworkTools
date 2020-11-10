//
//  WFNetworkToolStrategy.h
//  NetworkTools
//
//  Created by 王飞 on 2020/11/10.
//  Copyright © 2020 wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WFNetworkToolHeader.h"

@interface WFNetworkToolStrategy : NSObject

/// 工具类型
@property (nonatomic, assign, readonly) XPNetworkToolType type;

/// 实例化对象
/// @param type 工具类型
- (instancetype)initWithType:(XPNetworkToolType)type;

/// 指定目标host进行网络操作
/// @param host 目标host
/// @param operationBlock 操作回调(用于返回操作日志信息)
/// @param stopBlock 停止操作的回调
- (void)startWithHost:(NSString *)host
       operationBlock:(void(^)(NSString *operation))operationBlock
            stopBlock:(void(^)(void))stopBlock;

/// 停止
- (void)stop;

/// 当前是否处于开始状态
- (BOOL)isStarting;

/// 单次服务的tts时长(单位:秒数)
- (NSTimeInterval)tts;

/// 单次服务的测试数据
- (NSString *)testData;

@end
