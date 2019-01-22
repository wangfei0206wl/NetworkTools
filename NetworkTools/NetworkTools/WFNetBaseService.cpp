//
//  WFNetBaseService.cpp
//  NetworkTools
//
//  Created by 王飞 on 2018/12/11.
//  Copyright © 2018 wang. All rights reserved.
//

#include "WFNetBaseService.hpp"

WFNetBaseService::WFNetBaseService() {
    cout<<"create WFNetBaseService obj"<<endl;
}

WFNetBaseService::~WFNetBaseService() {
    cout<<"delete WFNetBaseService obj"<<endl;
}

void WFNetBaseService::start(string hostName) {
    m_sHostName = hostName;
    m_bRunning = true;
    
    cout<<"start WFNetBaseService obj"<<endl;
}

void WFNetBaseService::stop() {
    m_bRunning = false;
    
    cout<<"stop WFNetBaseService obj"<<endl;
}

bool WFNetBaseService::isRunning() {
    return m_bRunning;
}
