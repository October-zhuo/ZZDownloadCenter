//
//  ZZDownloadCenter.m
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/6.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZZDownloadCenter.h"

@interface ZZDownloadCenter()
@property (nonatomic, strong)NSOperationQueue *downloadQueue;
@end

static ZZDownloadCenter *center;
@implementation ZZDownloadCenter

+ (instancetype)defaultCenter{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[self alloc] init];
    });
    return center;
}

- (instancetype)init{
    if (self = [super init]) {
        _downloadQueue = [[NSOperationQueue alloc] init];
        
    }
    return self;
}


- (id)downloadWithURL:(NSURL *)url configuration:(ZZDownloadConfiguration *)configuration progres:(progressBlock)progress completion:(completionBlock)completion{
    NSAssert([url isKindOfClass: [NSURL class]], @"必须输入有效的URL");
    
    return nil;
}
@end
