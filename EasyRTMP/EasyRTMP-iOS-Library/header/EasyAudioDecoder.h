#ifndef _EasyAudioDecode_h
#define _EasyAudioDecode_h

#include "AACDecoder.h"

#ifdef __cplusplus
extern "C" {
#endif
    
typedef struct _HANDLE_ {
    unsigned int code;
    void *pContext;
} EasyAudioHandle;

// 创建音频解码器
EasyAudioHandle* EasyAudioDecodeCreate(int code, int sample_rate, int channels, int sample_bit);

// 解码一帧音频数据
int EasyAudioDecode(EasyAudioHandle* pHandle, unsigned char* buffer, int offset, int length, unsigned char* pcm_buffer, int* pcm_length);
    
// 关闭音频解码帧
void EasyAudioDecodeClose(EasyAudioHandle* pHandle);

#ifdef __cplusplus
}
#endif

#endif
