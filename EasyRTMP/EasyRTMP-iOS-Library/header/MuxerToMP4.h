//
//  MuxerToMP4.h
//  EasyPlayer
//
//  Created by leo on 2017/12/19.
//  Copyright © 2017年 cs. All rights reserved.
//

#ifndef MuxerToMP4_h
#define MuxerToMP4_h

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    int muxerToMP4(const char *in_filename_v, const char *in_filename_a, const char *out_filename);
    
#ifdef __cplusplus
}
#endif

#endif /* MuxerToMP4_h */
