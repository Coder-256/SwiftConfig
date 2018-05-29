//
//  check_active.c
//  SwiftConfig
//
//  Created by Jacob on 5/27/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

#include "check_active.h"

bool check_active(const char *interface) {
    // Credit: https://opensource.apple.com/source/network_cmds/network_cmds-543/ifconfig.tproj/ifmedia.c.auto.html
    int s;
    if ((s = socket(AF_INET, SOCK_DGRAM, 0)) < 0)
        return false;
    
    struct ifmediareq ifmr;
    
    memset(&ifmr, 0, sizeof(ifmr));
    strncpy(ifmr.ifm_name, interface, sizeof(ifmr.ifm_name));
    
    if (ioctl(s, SIOCGIFMEDIA, (caddr_t)&ifmr) < 0)
        return false;
    
    int flags = IFM_AVALID | IFM_ACTIVE;
    return (ifmr.ifm_status & flags) == flags;
}
