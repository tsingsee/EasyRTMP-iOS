//
//  FolderUtil.m
//  EasyRTMP
//
//  Created by mac on 2018/7/24.
//  Copyright © 2018年 phylony. All rights reserved.
//

#import "FolderUtil.h"
#import "XCFileManager.h"

#define VIDEO_FOLDER @"videoFolder" //视频录制存放文件夹

@implementation FolderUtil

// 写入的视频路径
+ (NSString *)createVideoFilePath {
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4", [NSUUID UUID].UUIDString];
    NSString *path = [[self videoFolder] stringByAppendingPathComponent:videoName];
    return path;
}

// 存放视频的文件夹
+ (NSString *)videoFolder {
    NSString *cacheDir = [XCFileManager cachesDir];
    NSString *direc = [cacheDir stringByAppendingPathComponent:VIDEO_FOLDER];
    if (![XCFileManager isExistsAtPath:direc]) {
        [XCFileManager createDirectoryAtPath:direc];
    }
    
    return direc;
}

// 删除文件
+ (void) deleteFilePath:(NSString *)path {
    if ([XCFileManager isExistsAtPath:path]) {
        [XCFileManager removeItemAtPath:path];
    }
}

+ (NSArray *)listFilesInDirectoryAtPath:(NSString *)path {
    return [XCFileManager listFilesInDirectoryAtPath:path deep:YES];
}

@end
