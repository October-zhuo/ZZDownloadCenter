//
//  ZZDownloadSession.m
//  ZZDownloadCenterDemo
//
//  Created by qdhl on 2017/7/8.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZZDownloadSessionHelper.h"
#import "ZZDownloadOperation.h"
#import "ZZDownloadFileManager.h"

@interface HelperObject : NSObject
@property (nonatomic, assign)NSUInteger taskID;
@property (nonatomic, assign)float expectLength;
@property (nonatomic, assign)float alreadDownloadLength;
@property (nonatomic, strong)NSURL *originURL;
@property (nonatomic, strong)NSURL *loaclURL;

- (instancetype)initWithTaskID:(NSUInteger)ID url:(NSURL *)originURL targetURL:(NSURL *)localURL;
@end

@implementation HelperObject
- (instancetype)initWithTaskID:(NSUInteger)ID url:(NSURL *)originURL targetURL:(NSURL *)localURL{
    if (self = [super init]) {
        self.taskID = ID;
        self.originURL = originURL;
        self.loaclURL = localURL;
        self.expectLength = 0;
        self.alreadDownloadLength = 0;
    }
    return self;
}
@end


@interface ZZDownloadSessionHelper()
@property (nonatomic, strong)NSMutableDictionary *taskDict;
@property (nonatomic, strong)NSMutableDictionary *completionHandlerDict;
@end

@implementation ZZDownloadSessionHelper

+ (instancetype)sharedHelper{
    static ZZDownloadSessionHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[self alloc] initBySelf];
    });
    return helper;
}

- (instancetype)init{
    @throw [NSException exceptionWithName:@"ZZDownloadSessionHelper init error" reason:@"You should not init ZZDownloadSessionHelper by yourself. sharedHelper is the best choice." userInfo:nil];
}

- (instancetype)initBySelf{
    if (self = [super init]) {
        _taskDict = [[NSMutableDictionary alloc] init];
        _completionHandlerDict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addTaskWithID:(NSUInteger)taskID originURL:(NSURL *)url targetURL:(NSURL *)localURL{
    HelperObject *obj = [[HelperObject alloc] initWithTaskID:taskID url:url targetURL:localURL];
    [self.taskDict setObject:obj forKey:@(taskID)];
}

- (void)cacheCompletionHandler:(void (^)())completionHandler withID:(NSString *)identifier{
    [self.completionHandlerDict setObject:[completionHandler copy] forKey:identifier];
}

#pragma mark - sessionTask delegate

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    HelperObject *obj = [self.taskDict objectForKey:@(task.taskIdentifier)];
    if (_downloadResultBlock) {
        if (error) {
            _downloadResultBlock(task.originalRequest.URL, nil, error);
        }else{
            NSURL *filePath = obj.loaclURL;
            _downloadResultBlock(task.originalRequest.URL, filePath, nil);
        }
    }

    [self.taskDict removeObjectForKey:@(task.taskIdentifier)];
}


- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session{
    NSString *idString = session.configuration.identifier;
    if (idString.length > 0) {
        if ([self.completionHandlerDict objectForKey:idString]) {
            void(^block)() =  [self.completionHandlerDict objectForKey:idString];
            block();
            [self.completionHandlerDict removeObjectForKey:idString];
        }
    }
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    HelperObject *obj = [self.taskDict objectForKey:@(downloadTask.taskIdentifier)];
    NSError *error;
    [[NSFileManager defaultManager] moveItemAtURL:location toURL:obj.loaclURL error:&error];
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    if (_downloadProgressBlock) {
         HelperObject *obj = [self.taskDict objectForKey:@(downloadTask.taskIdentifier)];
        _downloadProgressBlock(obj.originURL, (float)totalBytesWritten/(float)totalBytesExpectedToWrite);
    }
}
@end
