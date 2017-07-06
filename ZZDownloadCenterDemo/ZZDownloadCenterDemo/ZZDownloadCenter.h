//
//  ZZDownloadCenter.h
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/6.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ZZDownloadConfiguration;

typedef void(^progressBlock)(float progress);
typedef void(^completionBlock)(BOOL success, NSString *localUrlString, NSError *error);

@interface ZZDownloadCenter : NSObject

+ (instancetype)defaultCenter;

- (id)downloadWithURL:(NSURL *)url
                   configuration:(ZZDownloadConfiguration *)configuration
                              progres:(progressBlock)progress
                       completion:(completionBlock)completion;
@end
