//
//  ZZDownloadOperation.h
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/6.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ZZDownloadConfiguration;

extern NSString * _Nonnull const filePathName;

@interface ZZDownloadOperation : NSOperation
@property (nonatomic, copy)NSURL * _Nullable filePath;
@property (nonatomic, copy)void(^ _Nullable configStream)(NSUInteger taskID, NSURL * _Nonnull originURL);

- (instancetype _Nullable )initWithRequest:(nonnull NSURLRequest *)request
                        session:(NSURLSession * _Nonnull)session
                     targetPath:(nonnull NSURL *)filePath;
@end
