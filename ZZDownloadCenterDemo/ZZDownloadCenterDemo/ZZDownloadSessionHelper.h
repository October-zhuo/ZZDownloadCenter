//
//  ZZDownloadSession.h
//  ZZDownloadCenterDemo
//
//  Created by qdhl on 2017/7/8.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZDownloadSessionHelper : NSObject<NSURLSessionDataDelegate>

@property (nonatomic, copy)void(^downloadResultBlock)(NSURL *originURL, NSURL *localFilePath, NSError *error);
@property (nonatomic, copy)void(^downloadProgressBlock)(NSURL * originURL, float progress);
+ (instancetype)sharedHelper;
- (void)addStream:(NSOutputStream *)stream forTaskID:(NSUInteger)taskID originURL:(NSURL *)url;
@end
