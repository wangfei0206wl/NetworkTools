//
//  WFNetworkToolHeader.h
//  NetworkTools
//
//  Created by 王飞 on 2020/11/10.
//  Copyright © 2020 wang. All rights reserved.
//

#ifndef WFNetworkToolHeader_h
#define WFNetworkToolHeader_h

/**
 网络工具类型定义
 
 - XPNetworkToolTypePing: ping工具(strategy支持)
 - XPNetworkToolTypeRouteTrace: route trace工具(strategy支持)
 - XPNetworkToolTypeDNSScan: dns扫描(strategy支持)
 */
typedef NS_ENUM(NSInteger, XPNetworkToolType) {
    XPNetworkToolTypePing = 0,
    XPNetworkToolTypeRouteTrace,
    XPNetworkToolTypeDNSScan,
};

// 网络测试行替换控制字符串
#define kXPStringLineReplaceCmd @"!!!###***"

#endif /* WFNetworkToolHeader_h */
