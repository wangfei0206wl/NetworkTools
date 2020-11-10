//
//  WFNetworkDNSScanService.h
//  NetworkTools
//
//  Created by 王飞 on 2020/11/10.
//  Copyright © 2020 wang. All rights reserved.
//

#import <Foundation/Foundation.h>

/// DNS探测服务类(提供了两种方案:apple api或gethostbyname，两者选其一即可)
@interface WFNetworkDNSScanService : NSObject

/**
 指定目标host进行DNS扫描
 
 @param host 目标host
 @param operationBlock 操作回调(用于返回DNS的日志信息)
 @param stopBlock 停止dns的回调
 */
- (void)startWithHost:(NSString *)host
       operationBlock:(void(^)(NSString *operation))operationBlock
            stopBlock:(void(^)(void))stopBlock;

/**
 停止DNS扫描
 */
- (void)stop;

/**
 是否处于DNS扫描状态

 @return YES: DNS扫描中; NO:未处于扫描中
 */
- (BOOL)isWorking;

/**
 此次DNS的时长(单位: 秒)
 
 @return tts时长
 */
- (NSTimeInterval)tts;

/**
 单次服务的测试数据
 
 @return 测试数据
 */
- (NSString *)testData;

@end
