//
//  ZZDownloadCenter.m
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/6.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZZDownloadCenter.h"
#import "ZZDownloadSessionHelper.h"
#import "ZZDownloadOperation.h"
#import "ZZDownloadFileManager.h"

@interface ZZDownloadCenter()
@property (nonatomic, strong)NSOperationQueue *downloadQueue;
@property (nonatomic, strong)NSURLSession *downloadSession;
@property (nonatomic, strong)NSMutableDictionary *operationBlockDict;
@property (nonatomic, strong)NSMutableDictionary *operationDict;
@property (nonatomic, strong)ZZDownloadSessionHelper *sessionHelper;
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
        _downloadQueue = [[NSOperationQueue alloc] init];
        _operationBlockDict = [[NSMutableDictionary alloc] init];
        _operationDict = [[NSMutableDictionary alloc] init];
        _sessionHelper = [ZZDownloadSessionHelper sharedHelper];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSOperationQueue *delegateQueue = [[NSOperationQueue alloc] init];
        _downloadSession = [NSURLSession sessionWithConfiguration:configuration delegate:_sessionHelper delegateQueue:delegateQueue];
        [self dealHelperCallback];
    }
    return self;
}

- (void)dealHelperCallback{
    __weak __typeof__(self)weakself = self;
    [_sessionHelper setDownloadResultBlock:^(NSURL *originURL, NSURL *localFilePath, NSError * error){
        __typeof__(self)strongself = weakself;
        NSArray *blockArray = [strongself.operationBlockDict objectForKey:originURL.absoluteString];
        completionBlock finishBlock = blockArray[1];
        if (error) {
            finishBlock(nil, error);
        }else{
            finishBlock(localFilePath, nil);
            [[ZZDownloadFileManager sharedManager] diskCacheURL:originURL withLocalURL:localFilePath];
        }
        [strongself.operationDict removeObjectForKey:originURL.absoluteString];
        [strongself.operationBlockDict removeObjectForKey:originURL.absoluteString];
    }];
    
    [_sessionHelper setDownloadProgressBlock:^(NSURL *originURL, float progress){
        __typeof__(self)strongself = weakself;
        NSArray *blockArray = [strongself.operationBlockDict objectForKey:originURL.absoluteString];
        progressBlock myProgressBlock = blockArray.firstObject;
        myProgressBlock(progress);
    }];
}


- (id)downloadWithURL:(NSURL *)url configuration:(ZZDownloadConfiguration *)configuration progres:(progressBlock)progress completion:(completionBlock)completion{
    NSAssert([url isKindOfClass: [NSURL class]], @"必须输入有效的URL");
    
    //1. 检查表中有没有
    NSURL *cachedURL = [[ZZDownloadFileManager sharedManager] cachedLocalURLForNetURL:url];
    if (cachedURL) {
        completion(cachedURL,nil);
        return nil;
    }
    //2. 检查是否正在下载
    ZZDownloadOperation *tempOperation = [self.operationDict objectForKey:url.absoluteString];
    if (tempOperation) {
        return tempOperation;
    }
    //3. 检查硬盘中是否有残存
    long long length = 0;
    if ([[ZZDownloadFileManager sharedManager] exitUnFinishedTaskForURL:url]) {
       length = [[ZZDownloadFileManager sharedManager] lengthOfFile:url];
    }
    //4. 硬盘中有残存的未完成的任务，就开始断点续传。否则就开始新任务。
    NSArray *array = @[progress,completion];
    [self.operationBlockDict setObject:array forKey:url.absoluteString];
    NSURL *targetPath = [[ZZDownloadFileManager sharedManager] tempLocalURLWithURL:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if (length > 0) {
        [request setValue:[NSString stringWithFormat:@"Bytes=%lld-",length] forHTTPHeaderField:@"Range"];
    }
    ZZDownloadOperation *operation = [[ZZDownloadOperation alloc] initWithRequest:request session:self.downloadSession targetPath:targetPath];
    __weak __typeof__(self) weakSelf = self;
    [operation setConfigStream:^(NSOutputStream *stream, NSUInteger taskID, NSURL *originURL){
        __typeof__(self) strongSelf = weakSelf;
        [strongSelf.sessionHelper addStream:(stream) forTaskID:taskID originURL:originURL];
    }];
    [self.operationDict setObject:operation forKey:url.absoluteString];
    [self.downloadQueue addOperation:operation];
    return operation;
}
@end
