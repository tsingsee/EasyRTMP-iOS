//
//  AudioUnitPlayback.h
//  iMyCamera
//
//  Created by cs on 15/10/16.
//  Copyright © 2015年 MacBook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

typedef void (^AudioManagerOutputBlock)(SInt16 *outData, UInt32 numFrames, UInt32 numChannels);

/**
 音频播放Audio Unit
 */
@interface AudioManager : NSObject

+ (AudioManager *) sharedInstance;

@property (nonatomic, copy) AudioManagerOutputBlock outputBlock;

@property (nonatomic, readonly) BOOL playing;
@property (nonatomic, weak) id source;
@property (nonatomic) float sampleRate;
@property (nonatomic) int channel;

- (BOOL) activateAudioSession;
- (void) deactivateAudioSession;

- (void)pause;
- (BOOL)play;
- (void)stop;

@end
