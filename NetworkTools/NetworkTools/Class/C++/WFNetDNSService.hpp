//
//  WFNetDNSService.hpp
//  NetworkTools
//
//  Created by 王飞 on 2018/12/11.
//  Copyright © 2018 wang. All rights reserved.
//

#ifndef WFNetDNSService_hpp
#define WFNetDNSService_hpp

#include "WFNetBaseService.hpp"

using namespace std;

class WFNetDNSService: public WFNetBaseService {
public:
    WFNetDNSService();
    ~WFNetDNSService();

    void start(string hostName);
    void stop();
};

#endif /* WFNetDNSService_hpp */
