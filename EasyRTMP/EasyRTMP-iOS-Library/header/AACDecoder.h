#ifndef _AACDecoder_h
#define _AACDecoder_h

#ifdef __cplusplus
extern "C" {
#endif
    
#include "libavformat/avformat.h"
#include "libswresample/swresample.h"
#include "libavcodec/avcodec.h"
    
    typedef struct AACDFFmpeg {
        AVCodec *avCodec;
        // 编码器上下文(存储该视频/音频流使用解码方式的相关数据)
        AVCodecContext *pCodecCtx;
        // 存储一帧解码后像素(采样)数据
        AVFrame *pFrame;
        // 重采样结构体
        struct SwrContext *au_convert_ctx;
        int out_buffer_size;
        uint8_t audio_buf[100 * 1024];// (uint8_t *)av_malloc(AVCODEC_MAX_AUDIO_FRAME_SIZE * 2);
    } AACDFFmpeg;
    
    // 创建aac解码器
    void *aac_decoder_create(enum AVCodecID codecid, int sample_rate, int channels, int bit_rate);
    
    // 解码一帧音频数据
    int aac_decode_frame(void *pParam, unsigned char *pData, int nLen, unsigned char *pPCM, unsigned int *outLen);
    
    // 关闭aac解码器
    void aac_decode_close(void *pParam);
    
#ifdef __cplusplus
}
#endif

#endif



