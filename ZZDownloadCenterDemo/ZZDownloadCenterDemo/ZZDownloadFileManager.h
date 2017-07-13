//
//  ZZDownloadFileManager.h
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/6.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZDownloadFileManager : NSObject
+ (instancetype)sharedManager;
- (NSURL *)tempLocalURLWithURL:(NSURL *)url;
- (BOOL)exitUnFinishedTaskForURL:(NSURL *)url;
- (long long) lengthOfFile:(NSURL *)url;
- (BOOL)removeLocalFileWithURL:(NSURL *)netURL;

- (void)diskCacheURL:(NSURL *)netURL withLocalURL:(NSURL *)localURL;
- (NSURL *)cachedLocalURLForNetURL:(NSURL *)netURL;
@end
