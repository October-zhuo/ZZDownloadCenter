//
//  ZZDownloadOperation.m
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/6.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZZDownloadOperation.h"


NSString * const filePathName = @"filePathName";

@interface ZZDownloadOperation()<NSURLSessionDataDelegate>

@property (nonatomic, strong)NSURLRequest *request;
@property (nonatomic, strong)NSURLSessionDataTask *task;
@property (nonatomic, strong)NSURLSession *session;


@end

@implementation ZZDownloadOperation

@synthesize finished = _finished;
@synthesize executing = _executing;


- (instancetype)initWithRequest:(NSURLRequest *)request session:(NSURLSession *)session targetPath:(NSURL *)filePath{
    if (self = [super init]) {
        self.request = request;
        self.filePath = filePath;
        self.session = session;
    }
    return self;
}


- (BOOL)isConcurrent{
    return YES;
}

- (BOOL)isAsynchronous{
    return YES;
}

- (BOOL)isFinished{
    return _finished;
}

- (BOOL)isExecuting{
    return _executing;
}

- (void)start{
    if (self.isCancelled) {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    _executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
}

- (void)main{
    @autoreleasepool {
        @try {
            if (self.isCancelled) {
                return;
            }
#pragma mark - warning should session and task be hold?
            NSOutputStream *stream = [NSOutputStream outputStreamWithURL:_filePath append:YES];
            [stream setProperty:_filePath forKey:filePathName];
            _task = [self.session dataTaskWithRequest:_request];
            if(_configStream){
                _configStream(stream, _task.taskIdentifier, _filePath);
            }
            [_task resume];
        } @catch (NSException *exception) {
            
        }
    }
}

@end
