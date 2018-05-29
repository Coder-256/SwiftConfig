//
//  check_active.h
//  SwiftConfig
//
//  Created by Jacob on 5/27/18.
//  Copyright © 2018 Jacob Greenfield. All rights reserved.
//

#ifndef check_active_h
#define check_active_h

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <net/if.h>
#include <net/if_media.h>
#include <sys/ioctl.h>
#include <sys/sockio.h>

bool check_active(const char *interface);

#endif /* check_active_h */
