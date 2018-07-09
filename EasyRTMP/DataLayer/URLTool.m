//
//  URLTool.m
//  EasyRTMP
//
//  Created by mac on 2018/7/9.
//  Copyright © 2018年 phylony. All rights reserved.
//

#import "URLTool.h"

static NSString *ConfigUrlKey = @"ConfigUrl";
static NSString *ResolitionKey = @"resolition";
static NSString *OnlyAudioKey = @"OnlyAudioKey";

@implementation URLTool

#pragma mark - url

+ (void) saveURL:(NSString *)url {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:url forKey:ConfigUrlKey];
    [defaults synchronize];
}

+ (NSString *) gainURL {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *url = [defaults objectForKey:ConfigUrlKey];
    
    // 设置默认url
//    if (!url || [url containsString:@"rtmp://www.easydss.com/live"] || [url containsString:@"121.40.50.44/live"]) {
    if (!url || [url isEqualToString:@""]) {
        NSMutableString *randomNum = [[NSMutableString alloc] initWithString:@"rtmp://www.easydss.com:10085/live/stream_"];
        for (int i = 0; i < 6; i++) {
            int num = arc4random() % 10;
            [randomNum appendString:[NSString stringWithFormat:@"%d",num]];
        }
        [self saveURL:randomNum];
    }
    
    return url;
}

#pragma mark - resolition

+ (void) saveResolition:(NSString *)resolition {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:resolition forKey:ResolitionKey];
    [defaults synchronize];
}

+ (NSString *)gainResolition {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *resolition = [defaults objectForKey:ResolitionKey];
    
    // 设置默认分辨率
    if (!resolition || [resolition isEqualToString:@""]) {
        [self saveResolition:@"480*640"];
    }
    
    return resolition;
}

#pragma mark - only audio

+ (void) saveOnlyAudio:(BOOL) isAudio {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isAudio forKey:OnlyAudioKey];
    [defaults synchronize];
}

+ (BOOL) gainOnlyAudio {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:OnlyAudioKey];
}

@end
