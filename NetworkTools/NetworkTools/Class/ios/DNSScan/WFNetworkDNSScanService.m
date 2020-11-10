//
//  WFNetworkDNSScanService.m
//  NetworkTools
//
//  Created by 王飞 on 2020/11/10.
//  Copyright © 2020 wang. All rights reserved.
//

#import "WFNetworkDNSScanService.h"

@implementation WFNetworkDNSScanService

- (void)startWithHost:(NSString *)host
       operationBlock:(void(^)(NSString *operation))operationBlock
            stopBlock:(void(^)(void))stopBlock {
    
}

- (void)stop {
    
}

- (BOOL)isWorking {
    return YES;
}

- (NSTimeInterval)tts {
    return 0;
}

- (NSString *)testData {
    return nil;
}

@end
