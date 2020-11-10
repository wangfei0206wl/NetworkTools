//
//  WFNetworkPingService.h
//  NetworkTools
//
//  Created by 王飞 on 2020/11/10.
//  Copyright © 2020 wang. All rights reserved.
//

#import <Foundation/Foundation.h>

/// ping服务类
@interface WFNetworkPingService : NSObject

/**
 指定目标host进行ping

 @param host 目标host
 @param operationBlock 操作回调(用于返回ping的日志信息)
 @param stopBlock 停止ping的回调
 */
- (void)startWithHost:(NSString *)host
       operationBlock:(void(^)(NSString *operation))operationBlock
            stopBlock:(void(^)(void))stopBlock;

/**
 停止ping
 */
- (void)stop;

/**
 当前是否处于ping状态

 @return YES: 处于ping状态; NO: 当前没有ping
 */
- (BOOL)isPinging;

/**
 此次ping的时长(单位: 秒)

 @return tts时长
 */
- (NSTimeInterval)tts;

/**
 单次服务的测试数据
 
 @return 测试数据
 */
- (NSString *)testData;

@end
