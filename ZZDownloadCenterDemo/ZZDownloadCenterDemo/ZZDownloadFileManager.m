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
@property (nonatomic, strong)NSURL *cachedDictionaryURL;
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

- (BOOL)exitUnFinishedTaskForURL:(NSURL *)url{
    NSMutableString *tempString = [NSMutableString stringWithString:self.diskCachePath];
    [tempString appendString:[NSString stringWithFormat:@"/%@",url.absoluteString.MD5]];
    NSArray *components = [url.absoluteString componentsSeparatedByString:@"."];
    if (components.count) {
        [tempString appendString:[NSString stringWithFormat:@".%@",components.lastObject]];
    }
   return [[NSFileManager defaultManager] fileExistsAtPath:tempString];
}

- (long long) lengthOfFile:(NSURL *)url{
    if (![self exitUnFinishedTaskForURL:url]) {
        return 0;
    }
    
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

- (NSURL *)cachedDictionaryURL{
    if (!_cachedDictionaryURL) {
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *dictPath = [NSString stringWithFormat:@"%@/%@",cachePath,cachedDictionary];
        _cachedDictionaryURL = [NSURL fileURLWithPath:dictPath];
        _cachedDictionaryURL= [_cachedDictionaryURL URLByAppendingPathExtension:@"plist"];
    }
    return _cachedDictionaryURL;
}

- (NSMutableDictionary *)cacheDict{
    if (!_cacheDict) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfURL:self.cachedDictionaryURL];
        if (dict) {
            _cacheDict = dict;
        }else{
            _cacheDict = [[NSMutableDictionary alloc] init];
        }
    }
    return _cacheDict;
}

- (void)diskCacheURL:(NSURL *)netURL withLocalURL:(NSURL *)localURL{
    NSArray *components = [localURL.absoluteString componentsSeparatedByString:@"/"];
    if (components.count) {
        NSString *resultString = components.lastObject;
        [self.cacheDict setObject:resultString forKey:netURL.absoluteString.MD5];
        [self.cacheDict writeToURL:self.cachedDictionaryURL atomically:YES];
    }
}

- (NSURL *)cachedLocalURLForNetURL:(NSURL *)netURL{
    NSString *string = [self.cacheDict objectForKey:netURL.absoluteString.MD5];
    if (string) {
        NSString *resultString = [NSString stringWithFormat:@"%@/%@",self.diskCachePath,string];
        NSURL *url = [NSURL fileURLWithPath:resultString];
        return url;
    }
    return nil;
}

@end
