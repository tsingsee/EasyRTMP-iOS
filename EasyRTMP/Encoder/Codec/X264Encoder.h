//
//  X264Encoder.h
//  EasyRTMP
//
//  Created by mac on 2019/4/24.
//  Copyright © 2019 phylony. All rights reserved.
//

#import <VideoToolbox/VideoToolbox.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol X264EncoderDelegate <NSObject>

@required
- (void)gotX264EncoderData:(NSData *)packet keyFrame:(BOOL)keyFrame timestamp:(CMTime)timestamp error:(NSError*)error;

@end

/**
 软编码
 */
@interface X264Encoder : NSObject

@property (weak, nonatomic) id<X264EncoderDelegate>  delegate;

@property (assign, nonatomic) CGSize videoSize;
@property (assign, nonatomic) CGFloat frameRate;
@property (assign, nonatomic) CGFloat maxKeyframeInterval;
@property (assign, nonatomic) CGFloat bitrate;
@property (strong, nonatomic) NSString *profileLevel;

- (instancetype)initX264Encoder:(CGSize)videoSize
                      frameRate:(NSUInteger)frameRate
            maxKeyframeInterval:(CGFloat)maxKeyframeInterval
                        bitrate:(NSUInteger)bitrate
                   profileLevel:(NSString *)profileLevel
                          width:(CGFloat) w
                          height:(CGFloat) h;

- (void)encoding:(CMSampleBufferRef)sample;

- (void)teardown;

@end

NS_ASSUME_NONNULL_END
