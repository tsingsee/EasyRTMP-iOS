
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KxMovieDecoder.h"

#include "EasyRTMPClientAPI.h"

/**
 获取RTSP流，解协议,解封装,再分别音视频解码
 */
@interface PlayerDataReader : NSObject

// 流媒体地址
@property (nonatomic, copy) NSString *url;
// 传输协议：TCP/UDP(EASY_RTP_CONNECT_TYPE：0x01，0x02)
@property (nonatomic, assign) EASY_RTP_CONNECT_TYPE transportMode;
// 发送保活包(心跳：0x00 不发送心跳， 0x01 OPTIONS， 0x02 GET_PARAMETER)
@property (nonatomic, assign) int sendOption;

@property (nonatomic, readonly) BOOL running;           // 播放中

@property (nonatomic, assign) BOOL enableAudio;
@property (nonatomic, assign) BOOL useHWDecoder;        // 是否启用硬解码

@property (nonatomic, copy) NSString *recordFilePath;   // 录像地址

// 获得媒体类型
@property (nonatomic, copy) void (^fetchMediaInfoSuccessBlock)(void);

// 获得解码后的音频帧／视频帧
@property (nonatomic, copy) void (^frameOutputBlock)(KxMovieFrame *frame, unsigned int length);

+ (void)startUp;

- (id)initWithUrl:(NSString *)url;
- (void)start;
- (void)stop;

- (EASY_MEDIA_INFO_T)mediaInfo;

@end
