//
//  WFNetUtility.cpp
//  NetworkTools
//
//  Created by 王飞 on 2018/12/12.
//  Copyright © 2018 wang. All rights reserved.
//

#include "WFNetUtility.hpp"
#include <netdb.h>
#include <arpa/inet.h>

bool isIPV6Net(const string ip_v4, string &out_ip) {
    bool is_v6 = false;
    
    struct addrinfo *res0;
    struct addrinfo hints;
    struct addrinfo *res;
    
    memset(&hints, 0, sizeof(hints));
    hints.ai_flags = 0;
    hints.ai_family = PF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    
    int n = 0;
    if ((n = getaddrinfo(ip_v4.c_str(), "http", &hints, &res0)) != 0) {
        printf("getaddrinfo error: %s\n", gai_strerror(n));
        return false;
    }
    
    struct sockaddr_in6 *addr6;
    struct sockaddr_in *addr;
    char ipbuf[32] = {'\0'};
    
    for (res = res0; res; res = res->ai_next) {
        if (res->ai_family == AF_INET6) {
            addr6 = (struct sockaddr_in6 *)res->ai_addr;
            inet_ntop(AF_INET6, &addr6->sin6_addr, ipbuf, sizeof(ipbuf));
            is_v6 = true;
        } else {
            addr = (struct sockaddr_in *)res->ai_addr;
            inet_ntop(AF_INET, &addr->sin_addr, ipbuf, sizeof(ipbuf));
        }
        break;
    }
    out_ip = ipbuf;
    
    return is_v6;
}

const string dnsWithHost(const string host) {
    struct hostent *hptr = gethostbyname(host.c_str());
    
    if (hptr != NULL) {
        for (char **pptr = hptr->h_addr_list; *pptr != NULL; pptr++) {
            char str[32];
            string ip = inet_ntop(hptr->h_addrtype, *pptr, str, sizeof(str));
            return ip;
        }
    }
    return NULL;
}
