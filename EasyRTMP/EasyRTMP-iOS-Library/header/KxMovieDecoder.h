//
//  KxMovieDecoder.h
//  kxmovie
//
//  Created by Kolyvan on 15.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#include "libavformat/avformat.h"
#include "libswscale/swscale.h"

extern NSString * kxmovieErrorDomain;

typedef enum {
    kxMovieErrorNone,
    kxMovieErrorOpenFile,
    kxMovieErrorStreamInfoNotFound,
    kxMovieErrorStreamNotFound,
    kxMovieErrorCodecNotFound,
    kxMovieErrorOpenCodec,
    kxMovieErrorAllocateFrame,
    kxMovieErroSetupScaler,
    kxMovieErroReSampler,
    kxMovieErroUnsupported
} kxMovieError;

typedef enum {
    KxMovieFrameTypeAudio,
    KxMovieFrameTypeVideo,
    KxMovieFrameTypeArtwork,
    KxMovieFrameTypeSubtitle
} KxMovieFrameType;

typedef enum {
    KxVideoFrameFormatRGB,
    KxVideoFrameFormatYUV
} KxVideoFrameFormat;


@interface KxMovieFrame : NSObject

@property (readonly, nonatomic) KxMovieFrameType type;
@property (nonatomic) CGFloat position;
@property (nonatomic) CGFloat duration;

@end


@interface KxAudioFrame : KxMovieFrame

@property (nonatomic, strong) NSData *samples;

@end


@interface KxVideoFrame : KxMovieFrame

@property (readonly, nonatomic) KxVideoFrameFormat format;
@property (nonatomic) NSUInteger width;
@property (nonatomic) NSUInteger height;

@end


@interface KxVideoFrameRGB : KxVideoFrame

@property (nonatomic) NSUInteger linesize;
@property (nonatomic, strong) NSData *rgb;
@property (nonatomic) BOOL hasAlpha;

- (UIImage *) asImage;

@end


@interface KxVideoFrameYUV : KxVideoFrame

// Y表示明亮度（Lumina nce或Luma）,U和V表示的则是色度（Chrominance或Chroma）
@property ( nonatomic, strong) NSData *luma;    // Y
@property ( nonatomic, strong) NSData *chromaB; // Cb
@property ( nonatomic, strong) NSData *chromaR; // Cr

+ (instancetype) handleVideoFrame:(AVFrame *)videoFrame videoCodecCtx:(AVCodecContext *)videoCodecCtx;

@end


@interface KxArtworkFrame : KxMovieFrame

@property (readonly, nonatomic, strong) NSData *picture;

- (UIImage *) asImage;

@end


@interface KxSubtitleFrame : KxMovieFrame

@property (readonly, nonatomic, strong) NSString *text;

@end
