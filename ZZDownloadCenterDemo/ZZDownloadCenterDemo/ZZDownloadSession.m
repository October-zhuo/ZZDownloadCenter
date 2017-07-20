//
//  ZZDownloadSession.m
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/18.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZZDownloadSession.h"
#import "ZZDownloadSessionHelper.h"

@implementation ZZDownloadSession
+ (NSURLSession *)backgroundSession{
    static NSURLSession *session;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ZZDownloadSessionHelper *sessionHelper = [ZZDownloadSessionHelper sharedHelper];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:[NSUUID UUID].UUIDString];
        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:sessionHelper delegateQueue:delegateQueue];
    });
    return session;
}
@end
