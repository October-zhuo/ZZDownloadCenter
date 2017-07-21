//
//  ZZDownloadCenter.m
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/6.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZZDownloadCenter.h"
#import "ZZDownloadSessionHelper.h"
#import "ZZDownloadSession.h"
#import "ZZDownloadFileManager.h"

@interface ZZDownloadCenter()
@property (nonatomic, strong)NSMutableDictionary *taskBlockDict;
@property (nonatomic, strong)NSMutableDictionary *taskDict;
@property (nonatomic, strong)NSURLSession *downloadSession;
@end

static ZZDownloadCenter *center;
@implementation ZZDownloadCenter

+ (instancetype)defaultCenter{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[self alloc] initBySelf];
    });
    return center;
}

- (instancetype)init{
    @throw [NSException exceptionWithName:@"ZZDownloadCenter init error" reason:@"You should not init ZZDownloadCenter by yourself. defaultCenter is the best choice." userInfo:nil];
}

- (instancetype)initBySelf{
    if (self = [super init]) {
        _taskBlockDict = [[NSMutableDictionary alloc] init];
        _taskDict = [[NSMutableDictionary alloc] init];
        _downloadSession = [ZZDownloadSession backgroundSession];
        [self dealHelperCallback];
    }
    return self;
}

- (void)dealHelperCallback{
    __weak __typeof__(self)weakself = self;
    [ [ZZDownloadSessionHelper sharedHelper] setDownloadResultBlock:^(NSURL *originURL, NSURL *localFilePath, NSError * error){
        __typeof__(self)strongself = weakself;
        NSArray *blockArray = [strongself.taskBlockDict objectForKey:originURL.absoluteString];
        completionBlock finishBlock = blockArray[1];
        if (error) {
            finishBlock(nil, error);
        }else{
            finishBlock(localFilePath, nil);
        }
        [strongself.taskDict removeObjectForKey:originURL.absoluteString];
        [strongself.taskBlockDict removeObjectForKey:originURL.absoluteString];
    }];
    
    [ [ZZDownloadSessionHelper sharedHelper] setDownloadProgressBlock:^(NSURL *originURL, float progress){
        __typeof__(self)strongself = weakself;
        NSArray *blockArray = [strongself.taskBlockDict objectForKey:originURL.absoluteString];
        progressBlock myProgressBlock = blockArray.firstObject;
        myProgressBlock(progress);
    }];
}


- (id)downloadWithURL:(NSURL *)url configuration:(ZZDownloadConfiguration *)configuration progres:(progressBlock)progress completion:(completionBlock)completion{
    NSAssert([url isKindOfClass: [NSURL class]], @"必须输入有效的URL");
    
    //1. 检查硬盘中有没有该资源
    NSURL *cachedURL = [[ZZDownloadFileManager sharedManager] cachedLocalURLForNetURL:url];
    if (cachedURL) {
        completion(cachedURL,nil);
        return nil;
    }
    //2. 检查是否正在下载
    NSURLSessionDownloadTask *processingTask = [self.taskDict objectForKey:url.absoluteString];
    if (processingTask) {
        return processingTask;
    }
    //3.开始下载
    NSArray *array = @[progress,completion];
    [self.taskBlockDict setObject:array forKey:url.absoluteString];
    NSURL *targetPath = [[ZZDownloadFileManager sharedManager] tempLocalURLWithURL:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    NSURLSessionDownloadTask *task = [self.downloadSession downloadTaskWithRequest:request];
    [self.taskDict setObject:task forKey:url.absoluteString];
    [[ZZDownloadSessionHelper sharedHelper] addTaskWithID:task.taskIdentifier originURL:url targetURL:targetPath];
    [task resume];
    return  task;
}
@end
