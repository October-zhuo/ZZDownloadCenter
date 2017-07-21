//
//  ZZDownloadFileManager.m
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/6.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ZZDownloadFileManager.h"
#import "NSString+Hash.h"

NSString * const tempFilePath = @"com.zhuo.ZZDownloadCenter";
NSString * const cachedDictionary= @"cachedDictionary";

static ZZDownloadFileManager *manager;

@interface ZZDownloadFileManager ()
@property (nonatomic, strong)NSString *diskCachePath;
@property (nonatomic, strong)NSMutableDictionary *cacheDict;
@end
@implementation ZZDownloadFileManager
+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] initBySelf];
    });
    return manager;
}

- (instancetype)init{
    @throw [NSException exceptionWithName:@"ZZDownloadFileManager init error" reason:@"You should not init ZZDownloadFileManager by youeself, sharedManager is the best choice." userInfo:nil];
}

- (instancetype)initBySelf{
    if (self = [super init]) {
        [self creatTempFilePathIfNeeded];
    }
    return self;
}

- (long long) lengthOfFile:(NSURL *)url{
    NSMutableString *file = [NSMutableString stringWithString:self.diskCachePath];
    [file appendString:[NSString stringWithFormat:@"/%@",url.absoluteString.MD5]];
    NSArray *components = [url.absoluteString componentsSeparatedByString:@"."];
    if (components.count) {
        [file appendString:[NSString stringWithFormat:@".%@",components.lastObject]];
    }
    
    NSDictionary *dict = [[NSFileManager defaultManager]attributesOfItemAtPath:file error:nil];
    long long length = [dict[NSFileSize] longLongValue];
    return  length;
}

- (BOOL)removeLocalFileWithURL:(NSURL *)netURL{
    NSMutableString *file = [NSMutableString stringWithString:self.diskCachePath];
    [file appendString:[NSString stringWithFormat:@"/%@",netURL.absoluteString.MD5]];
    NSArray *components = [netURL.absoluteString componentsSeparatedByString:@"."];
    if (components.count) {
        [file appendString:[NSString stringWithFormat:@".%@",components.lastObject]];
    }
    return [[NSFileManager defaultManager] removeItemAtPath:file error:NULL];
}

- (NSURL *)tempLocalURLWithURL:(NSURL *)url{
    
    NSURL *cachePathURL = [NSURL fileURLWithPath:_diskCachePath isDirectory:YES];
    cachePathURL = [cachePathURL URLByAppendingPathComponent:url.absoluteString.MD5];
    NSArray *components = [url.absoluteString componentsSeparatedByString:@"."];
    if (components.count) {
      cachePathURL = [cachePathURL URLByAppendingPathExtension:components.lastObject];
    }
    return cachePathURL;
}

- (void)creatTempFilePathIfNeeded{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.diskCachePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:self.diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

- (NSString *)diskCachePath{
    if (!_diskCachePath) {
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *filePath = [cachePath stringByAppendingString:[NSString stringWithFormat:@"/%@",tempFilePath]];
        _diskCachePath = filePath;
    }
    return _diskCachePath;
}

- (NSURL *)cachedLocalURLForNetURL:(NSURL *)netURL{
    NSURL *url = [self tempLocalURLWithURL:netURL];
    if([[NSFileManager defaultManager] fileExistsAtPath:url.relativePath]){
        return url;
    }else{
        return  nil;
    }
    return nil;
}

@end
