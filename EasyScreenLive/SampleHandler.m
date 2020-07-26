//
//  SampleHandler.m
//  EasyScreenLive
//
//  Created by leo on 2019/6/28.
//  Copyright © 2019 leo. All rights reserved.
//

#import "SampleHandler.h"
#import "X264Encoder.h"
#import "H264HWEncoder.h"
#import "AACEncoder.h"
#import "EasyRTMPAPI.h"

static NSString *ExtensionSuiteName = @"group.com.rtmp";
static NSString *ConfigUrlKey = @"ConfigUrl";

@interface SampleHandler()<H264HWEncoderDelegate, X264EncoderDelegate, AACEncoderDelegate> {
    Easy_Handle handle;
}

@property (nonatomic, strong) dispatch_queue_t encodeQueue;

@property (nonatomic, strong) X264Encoder *x264Encoder;
@property (nonatomic, strong) H264HWEncoder *h264Encoder;
@property (nonatomic, strong) AACEncoder *aacEncoder;

@property (nonatomic, assign) CGSize outputSize;

@end

@implementation SampleHandler

/**
 屏幕采集工作已经开始启动，在此方法中一般进行初始化工作
 */
- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    
    // 接入麦克风
    [[RPScreenRecorder sharedRecorder] setMicrophoneEnabled:YES];
    
    self.encodeQueue = dispatch_queue_create("EncodeQueue", NULL);
    
    CGFloat w = [[UIScreen mainScreen] bounds].size.width;
    CGFloat h = [[UIScreen mainScreen] bounds].size.height;
    self.outputSize = CGSizeMake(w, h);
    
    // 初始化硬编码
    self.h264Encoder = [[H264HWEncoder alloc] init];
    self.h264Encoder.delegate = self;
    
    [self initX264Encoder];
    
#if TARGET_OS_IPHONE
    self.aacEncoder = [[AACEncoder alloc] init];
    self.aacEncoder.delegate = self;
#endif
    
    int res = [self activate];
    if (res > 0) {
        NSString *url = [[[NSUserDefaults alloc] initWithSuiteName:ExtensionSuiteName] valueForKey:ConfigUrlKey];
        [self startCamera:url];
    }
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    [self teardown];
    [self.h264Encoder invalidate];
}

/**
 采集到数据的实时回调，此方法中的sampleBuffer数据结构中有视频和音频数据，我们通过相关推流方法将数据推送给服务器，即实现了录制和推流。
 */
- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo: { // 视频帧
            CFRetain(sampleBuffer);
            
            dispatch_async(self.encodeQueue, ^{
//                [self.x264Encoder encoding:sampleBuffer];
                [self.h264Encoder encode:sampleBuffer size:self.outputSize];
                CFRelease(sampleBuffer);
            });
        }
            break;
        case RPSampleBufferTypeAudioApp: {  // app音效
            
        }
            break;
        case RPSampleBufferTypeAudioMic: {  // 话筒
            CFRetain(sampleBuffer);
            
            dispatch_async(self.encodeQueue, ^{
                [self.aacEncoder encode:sampleBuffer];
                
                CFRelease(sampleBuffer);
            });
        }
            break;
        default:
            break;
    }
}

#pragma mark - x264

- (void)initX264Encoder {
    dispatch_sync(self.encodeQueue, ^{
        self.x264Encoder = [[X264Encoder alloc] initX264Encoder:self.outputSize frameRate:30 maxKeyframeInterval:25 bitrate:1024*1000 profileLevel:@"" width:_outputSize.width height:_outputSize.height];
        
        self.x264Encoder.delegate = self;
    });
}

- (void)teardown {
    dispatch_sync(self.encodeQueue, ^{
        [self.x264Encoder teardown];
    });
}

#pragma mark - X264EncoderDelegate

- (void)gotX264EncoderData:(NSData *)packet keyFrame:(BOOL)keyFrame timestamp:(CMTime)timestamp error:(NSError*)error {
    [self dealEncodedData:packet keyFrame:keyFrame timestamp:timestamp error:error];
}

#pragma mark - H264HWEncoderDelegate declare

- (void)gotH264EncodedData:(NSData *)packet keyFrame:(BOOL)keyFrame timestamp:(CMTime)timestamp error:(NSError*)error {
    [self dealEncodedData:packet keyFrame:keyFrame timestamp:timestamp error:error];
}

- (void) dealEncodedData:(NSData *)packet keyFrame:(BOOL)keyFrame timestamp:(CMTime)timestamp error:(NSError*)error {
    EASY_AV_Frame frame;
    frame.pBuffer = (void*) packet.bytes;
    
    if (frame.pBuffer == NULL) {
        return;
    }
    
    frame.u32AVFrameFlag = EASY_SDK_VIDEO_FRAME_FLAG;
    frame.u32AVFrameLen = (Easy_U32)packet.length;
    frame.u32TimestampSec = 0;
    frame.u32TimestampUsec = 0;
    frame.u32VFrameType = keyFrame ? EASY_SDK_VIDEO_FRAME_I : EASY_SDK_VIDEO_FRAME_P;
    
    int result = EasyRTMP_SendPacket(handle, &frame);
    if (result == 0) {
//        NSLog(@"video length：%u", frame.u32AVFrameLen);
    }
}

#if TARGET_OS_IPHONE
#pragma mark - AACEncoderDelegate declare

- (void)gotAACEncodedData:(NSData *)data timestamp:(CMTime)timestamp error:(NSError*)error {
    EASY_AV_Frame frame;
    frame.pBuffer = (void*)[data bytes];
    
    if (frame.pBuffer == NULL) {
        return;
    }
    
    frame.u32AVFrameLen = (Easy_U32)[data length];
    frame.u32VFrameType = EASY_SDK_AUDIO_CODEC_AAC;
    frame.u32AVFrameFlag = EASY_SDK_AUDIO_FRAME_FLAG;
    
    frame.u32TimestampSec= 0;//(Easy_U32)timestamp.value/timestamp.timescale;
    frame.u32TimestampUsec = 0;//timestamp.value%timestamp.timescale;
    
    int result = EasyRTMP_SendPacket(handle, &frame);
    if (result == 0) {
        NSLog(@"audio length：%u", frame.u32AVFrameLen);
    }
}

#endif

#pragma mark -

- (int) activate {
    // 激活授权码
    int res = EasyRTMP_Activate("79736C3665662B32734B7941725370636F3956524576644659584E35556C524E554C3558444661672F704C2B4947566863336B3D");
    NSLog(@"--->>> key剩余时间：%d", res);
    
    if (res > 0) {
        NSLog(@"激活成功");
    } else {
        NSLog(@"激活失败");
    }

    return res;
}

- (void) startCamera:(NSString *)hostUrl {
    NSLog(@"推流地址：%@", hostUrl);
    
    if (handle) {
        return;
    }
    
    if (handle == NULL) {
        handle = EasyRTMP_Create();
        EasyRTMP_SetCallback(handle, easyPusher_Callback, "123");
    }
    
    EASY_MEDIA_INFO_T mediainfo;
    memset(&mediainfo, 0, sizeof(EASY_MEDIA_INFO_T));
    mediainfo.u32VideoCodec = EASY_SDK_VIDEO_CODEC_H264;
    mediainfo.u32VideoFps = 20;
    mediainfo.u32AudioCodec = EASY_SDK_AUDIO_CODEC_AAC;// SDK output Audio PCMA
    mediainfo.u32AudioSamplerate = 44100;
    mediainfo.u32AudioChannel = 2;
    mediainfo.u32AudioBitsPerSample = 16;
    
    EasyRTMP_Connect(handle, [hostUrl cStringUsingEncoding:NSUTF8StringEncoding]);
    EasyRTMP_InitMetadata(handle, &mediainfo, 1024);
}

#pragma mark - 连接状态回调

int easyPusher_Callback(int _id, char *pBuf, EASY_RTMP_STATE_T _state, void *_userptr) {
    if (_state == EASY_RTMP_STATE_CONNECTING) {
        NSLog(@"连接中");
    } else if (_state == EASY_RTMP_STATE_CONNECTED) {
        NSLog(@"连接成功");
    } else if (_state == EASY_RTMP_STATE_CONNECT_FAILED) {
        NSLog(@"连接失败");
    } else if (_state == EASY_RTMP_STATE_CONNECT_ABORT) {
        NSLog(@"连接异常中断");
    } else if (_state == EASY_RTMP_STATE_PUSHING) {
        NSLog(@"推流中");
    } else if (_state == EASY_RTMP_STATE_DISCONNECTED) {
        NSLog(@"断开连接");
    }

    return 0;
}

@end
