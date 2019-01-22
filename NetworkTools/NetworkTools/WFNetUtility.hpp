//
//  WFNetUtility.hpp
//  NetworkTools
//
//  Created by 王飞 on 2018/12/12.
//  Copyright © 2018 wang. All rights reserved.
//

#ifndef WFNetUtility_hpp
#define WFNetUtility_hpp

#include <iostream>

using namespace std;

bool isIPV6Net(const string ip_v4, string &out_ip);
const string dnsWithHost(const string host);

#endif /* WFNetUtility_hpp */
