//
//  WFNetworkRouteTraceService.h
//  NetworkTools
//
//  Created by 王飞 on 2020/11/10.
//  Copyright © 2020 wang. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 路由trace服务类
@interface WFNetworkRouteTraceService : NSObject

/**
 指定目标host进行路由探测
 
 @param host 目标host
 @param operationBlock 操作回调(用于返回route trace的日志信息)
 @param stopBlock 停止route trace的回调
 */
- (void)startWithHost:(NSString *)host
       operationBlock:(void(^)(NSString *operation))operationBlock
            stopBlock:(void(^)(void))stopBlock;

/**
 停止路由探测
 */
- (void)stop;

/**
 是否处于路由探测中

 @return YES: 路由探测中; NO: 未处于路由探测
 */
- (BOOL)isWorking;

/**
 此次route trace的时长(单位: 秒)
 
 @return tts时长
 */
- (NSTimeInterval)tts;

/**
 单次服务的测试数据
 
 @return 测试数据
 */
- (NSString *)testData;

@end

