//
//  Muxer.h
//  EasyPlayerRTMP
//
//  Created by leo on 2018/3/19.
//  Copyright © 2018年 cs. All rights reserved.
//

#ifndef Muxer_h
#define Muxer_h

#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif
    
    int muxer(const char *out_filename,
              int *stopRecord,
              int (*read_video_packet)(void *opaque, uint8_t *buf, int buf_size),
              int (*read_audio_packet)(void *opaque, uint8_t *buf, int buf_size));
    
#ifdef __cplusplus
}
#endif

#endif /* Muxer_h */
