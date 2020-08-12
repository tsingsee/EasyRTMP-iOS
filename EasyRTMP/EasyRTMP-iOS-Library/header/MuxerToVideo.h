//
//  MuxerToVideo.h
//  EasyPlayer
//
//  Created by leo on 2017/12/22.
//  Copyright © 2017年 cs. All rights reserved.
//

#ifndef MuxerToVideo_h
#define MuxerToVideo_h

#include <stdio.h>
#include "libavformat/avformat.h"

#ifdef __cplusplus
extern "C" {
#endif
    
    #pragma mark - Video
    
    // 算法类型
    typedef enum {
        Muxer_Video_Coder_MPEG4,
        Muxer_Video_Coder_H264
    }Muxer_Video_Coder;
    
    typedef enum {
        Muxer_Video_IDM_SW = 0,
        Muxer_Video_IDM_GLSL,
    }Muxer_Video_METHODE;
    
    // 创建参数
    typedef struct _Muxer_Video_CREATE_PARAM {
        int nMaxImgWidth;
        int nMaxImgHeight;
        Muxer_Video_Coder coderID;
        Muxer_Video_METHODE method;
    }Muxer_Video_CREATE_PARAM;
    
    // 解码参数
    typedef struct _Muxer_Video_PARAM {
        int nLen;
        unsigned char *pStream;
        int need_sps_head;
//        unsigned char *pImgRGB;     // 解码得出的RGB数据[in]
//        int nOutWidth;
//        int nOutHeight;
//        int nLineSize;
//        unsigned char *yuv[4];
//        int linsize[4];
    }Muxer_Video_PARAM;
    
    // 解码组件
    typedef struct _Muxer_Video_COMPONENT {
        AVCodec *avCodec;
        // 编码器上下文(存储该视频/音频流使用解码方式的相关数据)
        AVCodecContext *pCodecCtx;
        // 存储一帧解码后像素(采样)数据
        AVFrame *pFrame;
        
        // 主要用来对图像进行变化
        struct SwsContext *pImgConvertCtx;
        // RGB picture
        AVPicture picture;
        
        unsigned char * pNewStream;
        int newStreamLen;
        unsigned int uiOriginLen;
        unsigned int bScaleCreated;
    }Muxer_Video_COMPONENT;
    
    #pragma mark - audio
    
    typedef struct _Muxer_Audio_PARAM {
        AVCodec *avCodec;
        // 编码器上下文(存储该视频/音频流使用解码方式的相关数据)
        AVCodecContext *pCodecCtx;
        // 存储一帧解码后像素(采样)数据
        AVFrame *pFrame;
        // 重采样结构体
        struct SwrContext *au_convert_ctx;
        int out_buffer_size;
        uint8_t audio_buf[100 * 1024];// (uint8_t *)av_malloc(AVCODEC_MAX_AUDIO_FRAME_SIZE * 2);
    } Muxer_Audio_PARAM;
    
    typedef struct _Muxer_Audio_Handle {
        unsigned int code;
        void *pContext;
    } Muxer_Audio_Handle;
    
    #pragma mark - Video方法
    
    void *muxer_Video_COMPONENT_Create(Muxer_Video_CREATE_PARAM *pCreateParam);
    
    // 将h264流转换为AVPacket
    int convertVideoToAVPacket(const char *out_filename, void *recordHandle, Muxer_Video_PARAM *pDecodeParam);
    
    #pragma mark - Audio方法
    
    Muxer_Audio_Handle* muxer_Audio_Handle_Create(int code, int sample_rate, int channels, int sample_bit);
    
    // 将aac流转换为AVPacket
    int convertAudioToAVPacket(const char *out_filename, void *audioDecHandle, unsigned char *pData, int nLen);
    
#ifdef __cplusplus
}
#endif

#endif /* MuxerToVideo_h */
