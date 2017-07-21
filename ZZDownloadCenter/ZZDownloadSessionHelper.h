//
//  ZZDownloadSession.h
//  ZZDownloadCenterDemo
//
//  Created by qdhl on 2017/7/8.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZDownloadSessionHelper : NSObject<NSURLSessionDownloadDelegate>

@property (nonatomic, copy)void(^downloadResultBlock)(NSURL *originURL, NSURL *localFilePath, NSError *error);
@property (nonatomic, copy)void(^downloadProgressBlock)(NSURL * originURL, float progress);
+ (instancetype)sharedHelper;
- (void)addTaskWithID:(NSUInteger)taskID originURL:(NSURL *)url targetURL:(NSURL *)localURL;
- (void)cacheCompletionHandler:(void (^)())completionHandler withID:(NSString *)identifier;
@end
