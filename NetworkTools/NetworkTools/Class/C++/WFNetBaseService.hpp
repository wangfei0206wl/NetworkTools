//
//  WFNetBaseService.hpp
//  NetworkTools
//
//  Created by 王飞 on 2018/12/11.
//  Copyright © 2018 wang. All rights reserved.
//

#ifndef WFNetBaseService_hpp
#define WFNetBaseService_hpp

#include <stdio.h>
#include <iostream>

using namespace std;

class WFNetBaseService {
protected:
    string m_sHostName;
    bool m_bRunning;
public:
    WFNetBaseService();
    ~WFNetBaseService();
    
    virtual void start(string hostName);
    virtual void stop();
    bool isRunning();
};

#endif /* WFNetBaseService_hpp */
