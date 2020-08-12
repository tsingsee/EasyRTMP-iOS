//
//  URLModel.h
//  EasyPlayerRTMP
//
//  Created by leo on 2019/4/27.
//  Copyright © 2019年 cs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EasyTypes.h"

NS_ASSUME_NONNULL_BEGIN

@interface URLModel : NSObject

@property (nonatomic, copy) NSString *url;  // 流地址

// 传输协议：TCP/UDP(EASY_RTP_CONNECT_TYPE：0x01，0x02)
@property (nonatomic, assign) EASY_RTP_CONNECT_TYPE transportMode;

// 发送保活包(心跳：0x00 不发送心跳， 0x01 OPTIONS， 0x02 GET_PARAMETER)
@property (nonatomic, assign) int sendOption;

// 是否启用硬解码
@property (nonatomic, assign) BOOL useHWDecoder;
// 音频开关
@property (nonatomic, assign) BOOL isAutoAudio;
// 是否自动播放音频
@property (nonatomic, assign) BOOL isAutoRecord;

//// 当前观看人数
//@property (nonatomic, copy) NSString *audienceNumber;

- (instancetype) initDefault;

@end

NS_ASSUME_NONNULL_END
