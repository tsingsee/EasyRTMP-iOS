//
//  CameraEncoder.m
//  EasyCapture
//
//  Created by phylony on 9/11/16.
//  Copyright © 2016 phylony. All rights reserved.
//

#import "CameraEncoder.h"
#include <pthread.h>
#import "URLTool.h"

static CameraEncoder *selfClass = nil;

@interface CameraEncoder () {
    Easy_I32 isActivated;
    Easy_RTMP_Handle handle;
    
    CGSize temp_outputSize;
    
    dispatch_queue_t encodeQueue;
    
    dispatch_source_t _timer;
    
    pthread_mutex_t releaseLock;
}

@property (nonatomic, strong) H264HWEncoder *h264Encoder;
@property (nonatomic, strong) AACEncoder *aacEncoder;

@property (nonatomic, assign) int sendFrameLength;

@end

@implementation CameraEncoder

- (void) setOutputSize:(CGSize)outputSize {
    _outputSize = outputSize;
    
    temp_outputSize = CGSizeMake(_outputSize.width, _outputSize.height);
}

- (void) setOrientation:(AVCaptureVideoOrientation)orientation {
    _orientation = orientation;
    
    if (_videoConnection) {
        _videoConnection.videoOrientation = self.orientation;
    }
}

- (void)initCameraWithOutputSize:(CGSize)size {
    self.outputSize = size;
    
    pthread_mutex_init(&releaseLock, 0);
    
    self.h264Encoder = [[H264HWEncoder alloc] init];
    self.h264Encoder.delegate = self;
    
#if TARGET_OS_IPHONE
    self.aacEncoder = [[AACEncoder alloc] init];
    self.aacEncoder.delegate = self;
#endif
    
    _running = NO;
    
    [self activate];
    
    _encodeVideoQueue = dispatch_queue_create("encodeVideoQueue", DISPATCH_QUEUE_SERIAL);
    _encodeAudioQueue = dispatch_queue_create("encodeAudioQueue", DISPATCH_QUEUE_SERIAL);
    
    CMSimpleQueueCreate(kCFAllocatorDefault, 2, &vbuffQueue);
    CMSimpleQueueCreate(kCFAllocatorDefault, 2, &abuffQueue);
    
    _videoCaptureSession = [[AVCaptureSession alloc] init];
    [self setupAudioCapture];
    [self setupVideoCapture];
    
    encodeQueue = dispatch_queue_create("encodeQueue", NULL);
    selfClass = self;
}

- (void) activate {
    // 激活授权码
    if (EasyRTMP_Activate("7939703779662B32734B77414B694A5A707433527550644659584E35556C524E55434E58444661672B376A67523246326157346D516D466962334E68514449774D545A4659584E355247467964326C75564756686257566863336B3D") == 0) {
        if (_delegate) {
            [_delegate getConnectStatus:@"激活成功" isFist:1];
        }
    } else {
        [_delegate getConnectStatus:@"激活失败" isFist:1];
    }
}

- (void)dealloc {
#if TARGET_OS_IPHONE
    [self.h264Encoder invalidate];
#endif
    _running = NO;
    
    pthread_mutex_destroy(&releaseLock);
}

#pragma mark - 设置音频采集配置

- (void)setupAudioCapture {
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc]initWithDevice:audioDevice error:&error];
    
    if (error) {
        NSLog(@"Error getting audio input device:%@",error.description);
    }
    
    if ([self.videoCaptureSession canAddInput:audioInput]) {
        [self.videoCaptureSession addInput:audioInput];
    }
    
    self.AudioQueue = dispatch_queue_create("Audio Capture Queue", DISPATCH_QUEUE_SERIAL);
    AVCaptureAudioDataOutput *audioOutput = [AVCaptureAudioDataOutput new];
    
    [audioOutput setSampleBufferDelegate:self queue:self.AudioQueue];
    
    if ([self.videoCaptureSession canAddOutput:audioOutput]) {
        [self.videoCaptureSession addOutput:audioOutput];
    }
    self.audioConnection = [audioOutput connectionWithMediaType:AVMediaTypeAudio];
}

#pragma mark - 设置视频采集配置

- (void)setupVideoCapture {
    NSString *resolution = [URLTool gainResolition];
    if ([resolution isEqualToString:@"480*640"]) {
        if ([self.videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
            self.videoCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
        }
    } else if ([resolution isEqualToString:@"720*1280"]) {
        if ([self.videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            self.videoCaptureSession.sessionPreset = AVCaptureSessionPreset1280x720;
        }
    } else if ([resolution isEqualToString:@"1080*1920"]) {
        if ([self.videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            self.videoCaptureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        }
    } else if ([resolution isEqualToString:@"288*352"]) {
        if ([self.videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset352x288]) {
            self.videoCaptureSession.sessionPreset = AVCaptureSessionPreset352x288;
        }
    }
    
    // 设置采集的 Video 和 Audio 格式，这两个是分开设置的，也就是说，你可以只采集视频。
    // 配置采集输入源(摄像头)
    
    NSError *error = nil;
    // 获得一个采集设备, 例如前置/后置摄像头
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
//    videoDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
//    videoDevice.position = AVCaptureDevicePositionBack;
    
    // 用设备初始化一个采集的输入对象
    AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    if (error) {
        NSLog(@"Error getting video input device:%@",error.description);
    }
    if ([self.videoCaptureSession canAddInput:videoInput]) {
        [self.videoCaptureSession addInput:videoInput];
    }
    
    // 配置采集输出,即我们取得视频图像的接口
    _videoQueue = dispatch_queue_create("Video Capture Queue", DISPATCH_QUEUE_SERIAL);
    _videoOutput = [AVCaptureVideoDataOutput new];
    [_videoOutput setSampleBufferDelegate:self queue:_videoQueue];
    
    // 配置输出视频图像格式
    NSDictionary *captureSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    _videoOutput.videoSettings = captureSettings;
    _videoOutput.alwaysDiscardsLateVideoFrames = YES;
    if ([self.videoCaptureSession canAddOutput:_videoOutput]) {
        [self.videoCaptureSession addOutput:_videoOutput];
    }
    // 设置采集图像的方向,如果不设置，采集回来的图形会是旋转90度的
    _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    _videoConnection.videoOrientation = self.orientation;
    // 保存Connection,用于SampleBufferDelegate中判断数据来源(video or audio?)
    _videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    _videoConnection = [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    
    // 将当前硬件采集视频图像显示到屏幕
    // 添加预览
    self.previewLayer = [AVCaptureVideoPreviewLayer  layerWithSession:self.videoCaptureSession];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
}

#pragma mark - public method

- (void)swapFrontAndBackCameras {
    // Assume the session is already _running
    NSArray *inputs = self.videoCaptureSession.inputs;
    for (AVCaptureDeviceInput *input in inputs) {
        AVCaptureDevice *device = input.device;
        if ([device hasMediaType:AVMediaTypeVideo]) {
            AVCaptureDevicePosition position = device.position;
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            CATransition *animation = [CATransition animation];
            animation.duration = .5f;
            animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            animation.type = @"oglFlip";
            
            if (position == AVCaptureDevicePositionFront) {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
                animation.subtype = kCATransitionFromLeft;// 动画翻转方向
            } else {
                newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
                animation.subtype = kCATransitionFromRight;// 动画翻转方向
            }
            
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            [self.previewLayer addAnimation:animation forKey:nil];
            
            // beginConfiguration ensures that pending changes are not applied immediately
            [self.videoCaptureSession beginConfiguration];
            [self.videoCaptureSession removeInput:input];
            if ([self.videoCaptureSession canAddInput:newInput]) {
                [self.videoCaptureSession addInput:newInput];
            } else {
                [self.videoCaptureSession addInput:input];
            }
            [self.videoCaptureSession removeOutput:_videoOutput];
            
            AVCaptureVideoDataOutput *  new_videoOutput = [AVCaptureVideoDataOutput new];
            _videoOutput = new_videoOutput;
            [new_videoOutput setSampleBufferDelegate:self queue:_videoQueue];
            // 配置输出视频图像格式
            NSDictionary *captureSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
            new_videoOutput.videoSettings = captureSettings;
            new_videoOutput.alwaysDiscardsLateVideoFrames = YES;
            if ([self.videoCaptureSession canAddOutput:new_videoOutput]) {
                [self.videoCaptureSession addOutput:new_videoOutput];
            }
            // 设置采集图像的方向,如果不设置，采集回来的图形会是旋转90度的
            _videoConnection = [new_videoOutput connectionWithMediaType:AVMediaTypeVideo];
            _videoConnection.videoOrientation = self.orientation;
            // 保存Connection,用于SampleBufferDelegate中判断数据来源(video or audio?)
            _videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            _videoConnection = [new_videoOutput connectionWithMediaType:AVMediaTypeVideo];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.videoCaptureSession commitConfiguration];
            break;
        }
    }
}

- (void)swapResolution {
    [self.videoCaptureSession beginConfiguration];
    
    NSString *resolution = [URLTool gainResolition];
    if ([resolution isEqualToString:@"480*640"]){
        if ([self.videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
            self.videoCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;
        }
    }else if ([resolution isEqualToString:@"720*1280"]){
        if ([self.videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
            self.videoCaptureSession.sessionPreset = AVCaptureSessionPreset1280x720;
        }
    }else if ([resolution isEqualToString:@"1080*1920"]){
        if ([self.videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset1920x1080]) {
            self.videoCaptureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        }
    }else if ([resolution isEqualToString:@"288*352"]){
        if ([self.videoCaptureSession canSetSessionPreset:AVCaptureSessionPreset352x288]) {
            self.videoCaptureSession.sessionPreset = AVCaptureSessionPreset352x288;
        }
    }
    
    [self.videoCaptureSession commitConfiguration];
}

- (void)changeCameraStatus {
    NSArray *inputs = self.videoCaptureSession.inputs;
    
    if (![URLTool gainOnlyAudio]) {
        if (inputs.count < 2) {
            AVCaptureDevice *newCamera = nil;
            AVCaptureDeviceInput *newInput = nil;
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
            
//            [self.previewLayer addAnimation:animation forKey:nil];
            [self.videoCaptureSession beginConfiguration];
//            [self.videoCaptureSession removeInput:input];
            
            if ([self.videoCaptureSession canAddInput:newInput]) {
                [self.videoCaptureSession addInput:newInput];
            }
//            [self.videoCaptureSession removeOutput:_videoOutput];
            
            AVCaptureVideoDataOutput *  new_videoOutput = [AVCaptureVideoDataOutput new];
            _videoOutput = new_videoOutput;
            [new_videoOutput setSampleBufferDelegate:self queue:_videoQueue];
            
            // 配置输出视频图像格式
            NSDictionary *captureSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
            new_videoOutput.videoSettings = captureSettings;
            new_videoOutput.alwaysDiscardsLateVideoFrames = YES;
            if ([self.videoCaptureSession canAddOutput:new_videoOutput]) {
                [self.videoCaptureSession addOutput:new_videoOutput];
            }
            
            // 设置采集图像的方向,如果不设置，采集回来的图形会是旋转90度的
            _videoConnection = [new_videoOutput connectionWithMediaType:AVMediaTypeVideo];
            _videoConnection.videoOrientation = self.orientation;
            // 保存Connection,用于SampleBufferDelegate中判断数据来源(video or audio?)
            _videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
            _videoConnection = [new_videoOutput connectionWithMediaType:AVMediaTypeVideo];
            
            // Changes take effect once the outermost commitConfiguration is invoked.
            [self.videoCaptureSession commitConfiguration];
        }
    } else {
        for (AVCaptureDeviceInput *input in inputs ) {
            AVCaptureDevice *device = input.device;
            if ( [device hasMediaType:AVMediaTypeVideo] ) {
                [self.videoCaptureSession beginConfiguration];
                [self.videoCaptureSession removeInput:input];
                [self.videoCaptureSession removeOutput:_videoOutput];
                [self.videoCaptureSession commitConfiguration];
            }
        }
    }
}

#pragma mark - private method

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices )
        if ( device.position == position )
            return device;
    
    return nil;
}

#pragma mark - 推流流程

- (void)startCapture {
    [self.videoCaptureSession startRunning];
}

- (void) startCamera:(NSString *)hostUrl {
    if (handle) {
        return;
    }
    
    if (_outputSize.width == 0) {
        _outputSize = CGSizeMake(temp_outputSize.width, temp_outputSize.height);
    }
    
    if (handle == NULL) {
        handle = EasyRTMP_Create();
        EasyRTMP_SetCallback(handle, easyPusher_Callback, "123");
    }
    
    EASY_MEDIA_INFO_T mediainfo;
    memset(&mediainfo, 0, sizeof(EASY_MEDIA_INFO_T));
    mediainfo.u32VideoCodec = EASY_SDK_VIDEO_CODEC_H264;
    if (![URLTool gainOnlyAudio]) {
        mediainfo.u32VideoFps = 20;
    } else {
        mediainfo.u32VideoFps = ~0; //~0只传音频
    }
    
    mediainfo.u32AudioCodec = EASY_SDK_AUDIO_CODEC_AAC;// SDK output Audio PCMA
    mediainfo.u32AudioSamplerate = 44100;
    mediainfo.u32AudioChannel = 2;
    mediainfo.u32AudioBitsPerSample = 16;
    
    EasyRTMP_Connect(handle, [hostUrl cStringUsingEncoding:NSUTF8StringEncoding]);
    EasyRTMP_InitMetadata(handle, &mediainfo, 1024);
}

- (void) stopCamera {
    if (handle == NULL) {
        return;
    }
    
    _running = NO;
    [self.h264Encoder invalidate];
    
    // EasyRTMP_Release完成后，才能继续
    pthread_mutex_lock(&releaseLock);
    
    EasyRTMP_Release(handle);
    handle = NULL;
    
    pthread_mutex_unlock(&releaseLock);
}

#pragma mark - 连接状态回调

int easyPusher_Callback(int _id, char *pBuf, EASY_RTMP_STATE_T _state, void *_userptr) {
    if (_state == EASY_RTMP_STATE_CONNECTING) {
        if (selfClass.delegate) {
            [selfClass.delegate getConnectStatus:@"连接中" isFist:0];
            NSLog(@"连接中");
        }
    } else if (_state == EASY_RTMP_STATE_CONNECTED) {
        if (selfClass.delegate) {
            [selfClass.delegate getConnectStatus:@"连接成功" isFist:0];
            NSLog(@"连接成功");
            selfClass.running = YES;
        }
    } else if (_state == EASY_RTMP_STATE_CONNECT_FAILED) {
        if (selfClass.delegate) {
            [selfClass.delegate getConnectStatus:@"连接失败" isFist:0];
            NSLog(@"连接失败");
        }
    } else if (_state == EASY_RTMP_STATE_CONNECT_ABORT) {
        if (selfClass.delegate) {
            [selfClass.delegate getConnectStatus:@"连接异常中断" isFist:0];
            NSLog(@"连接异常中断");
        }
    } else if (_state == EASY_RTMP_STATE_PUSHING) {
        if (selfClass.delegate) {
            [selfClass.delegate getConnectStatus:@"推流中" isFist:0];
            NSLog(@"推流中");
        }
    } else if (_state == EASY_RTMP_STATE_DISCONNECTED) {
        if (selfClass.delegate) {
            [selfClass.delegate getConnectStatus:@"断开连接" isFist:0];
            NSLog(@"断开连接");
        }
    }
    
    return 0;
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate

-(void) captureOutput:(AVCaptureOutput*)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection*)connection {
    CFRetain(sampleBuffer);
    
    if (!_running) {
        CFRelease(sampleBuffer);
    } else {
        if(connection == self.videoConnection) {
            if (_running) {
                dispatch_async(encodeQueue, ^{
                    if (![URLTool gainOnlyAudio]) {
                        [self.h264Encoder encode:sampleBuffer size:self.outputSize];
                    } else {
                        [self.h264Encoder encode:sampleBuffer size:self.outputSize];
                    }
                    
                    // 输出尺寸置空，则不需要再初始化VTCompressionSessionRef
                    self.outputSize = CGSizeMake(0, 0);
                    
                    CFRelease(sampleBuffer);
                });
            }
        } else if(connection == self.audioConnection) {
            if (_running) {
                dispatch_async(encodeQueue, ^{
                    [self.aacEncoder encode:sampleBuffer];
                    
                    CFRelease(sampleBuffer);
                });
            }
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    NSLog(@"drop frame");
}

#pragma mark - H264HWEncoderDelegate declare

- (void)gotH264EncodedData:(NSData *)packet keyFrame:(BOOL)keyFrame timestamp:(CMTime)timestamp error:(NSError*)error {
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
    
    if(_running) {
        int result = EasyRTMP_SendPacket(handle, &frame);
        if (result == 0) {
            [self sendPacket:frame.u32AVFrameLen];
        }
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
    
    if(_running) {
        int result = EasyRTMP_SendPacket(handle, &frame);
        if (result == 0) {
            [self sendPacket:frame.u32AVFrameLen];
        }
    }
}

#endif

- (void) sendPacket:(unsigned int)u32AVFrameLen {
    self.sendFrameLength += u32AVFrameLen;
    
    if (!_timer) {
        NSTimeInterval period = 1.0; // 设置时间间隔
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0);
        dispatch_source_set_event_handler(_timer, ^{
            [self.delegate sendPacketFrameLength:self.sendFrameLength / 1];
            self.sendFrameLength = 0;
        });
        
        dispatch_resume(_timer);
    }
}

@end
