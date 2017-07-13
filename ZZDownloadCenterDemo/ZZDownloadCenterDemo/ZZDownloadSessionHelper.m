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
@property (nonatomic, strong)NSOutputStream *stream;
@property (nonatomic, assign)NSUInteger taskID;
@property (nonatomic, assign)float expectLength;
@property (nonatomic, assign)float alreadDownloadLength;
@property (nonatomic, strong)NSURL *originURL;

- (instancetype)initWithStream:(NSOutputStream *)stream taskID:(NSUInteger)ID url:(NSURL *)originURL;
@end

@implementation HelperObject
- (instancetype)initWithStream:(NSOutputStream *)stream taskID:(NSUInteger)ID url:(NSURL *)originURL{
    if (self = [super init]) {
        self.taskID = ID;
        self.originURL = originURL;
        self.stream = stream;
        self.expectLength = 0;
        self.alreadDownloadLength = 0;
    }
    return self;
}
@end


@interface ZZDownloadSessionHelper()
@property (nonatomic, strong)NSMutableDictionary *taskDict;
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
    }
    return self;
}

- (void)addStream:(NSOutputStream *)stream forTaskID:(NSUInteger)taskID originURL:(NSURL *)url{
    HelperObject *obj = [[HelperObject alloc] initWithStream:stream taskID:taskID url:url];
    [self.taskDict setObject:obj forKey:@(taskID)];
}
#pragma mark - sessionTask delegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler{
    HelperObject *obj = [self.taskDict objectForKey:@(dataTask.taskIdentifier)];
    obj.expectLength = response.expectedContentLength;
    long long length = [[ZZDownloadFileManager sharedManager] lengthOfFile:response.URL];
    //当本地残存的文件长度大于等于期望下载长度时，移除掉本地文件重进开始下载。
    if (length >= obj.expectLength) {
        [[ZZDownloadFileManager sharedManager] removeLocalFileWithURL:response.URL];
    }
    [obj.stream open];
    completionHandler(NSURLSessionResponseAllow);
}

/* Notification that a data task has become a download task.  No
 * future messages will be sent to the data task.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask{
    NSException *exception = [NSException exceptionWithName:@"YOU SHOULD NOTICE THAT" reason:@"dataTaskDidBecomeDownloadTask" userInfo:nil];
    @throw exception;
}

/*
 * Notification that a data task has become a bidirectional stream
 * task.  No future messages will be sent to the data task.  The newly
 * created streamTask will carry the original request and response as
 * properties.
 *
 * For requests that were pipelined, the stream object will only allow
 * reading, and the object will immediately issue a
 * -URLSession:writeClosedForStream:.  Pipelining can be disabled for
 * all requests in a session, or by the NSURLRequest
 * HTTPShouldUsePipelining property.
 *
 * The underlying connection is no longer considered part of the HTTP
 * connection cache and won't count against the total number of
 * connections per host.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didBecomeStreamTask:(NSURLSessionStreamTask *)streamTask{
    NSException *exception = [NSException exceptionWithName:@"YOU SHOULD NOTICE THAT" reason:@"didBecomeStreamTask" userInfo:nil];
    @throw exception;
}

/* Sent when data is available for the delegate to consume.  It is
 * assumed that the delegate will retain and not copy the data.  As
 * the data may be discontiguous, you should use
 * [NSData enumerateByteRangesUsingBlock:] to access it.
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data{
    //此处是往stream的buffer中写数据。类型应该是uint_8。不能直接写data对象。
    HelperObject *obj = [self.taskDict objectForKey:@(dataTask.taskIdentifier)];
    [obj.stream write:data.bytes maxLength:data.length];
    obj.alreadDownloadLength += data.length;
    if(_downloadProgressBlock){
        float progress = (1.0)*(obj.alreadDownloadLength/obj.expectLength);
        _downloadProgressBlock(dataTask.response.URL, progress);
    }
}

/* Invoke the completion routine with a valid NSCachedURLResponse to
 * allow the resulting data to be cached, or pass nil to prevent
 * caching. Note that there is no guarantee that caching will be
 * attempted for a given resource, and you should not rely on this
 * message to receive the resource data.
 */
#warning 这个代理方法作用？为什么不调用回调，完成的代理方法也不调用了。
//- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
// willCacheResponse:(NSCachedURLResponse *)proposedResponse
// completionHandler:(void (^)(NSCachedURLResponse * _Nullable cachedResponse))completionHandler{
//    
//}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error{
    HelperObject *obj = [self.taskDict objectForKey:@(task.taskIdentifier)];
    if (_downloadResultBlock) {
        if (error) {
            _downloadResultBlock(task.originalRequest.URL, nil, error);
        }else{
            NSURL *filePath = obj.originURL;
            _downloadResultBlock(task.originalRequest.URL, filePath, nil);
        }
    }
    [obj.stream close];
    [self.taskDict removeObjectForKey:@(task.taskIdentifier)];
}

@end
