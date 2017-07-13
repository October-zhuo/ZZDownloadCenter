//
//  DownloadModel.m
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/13.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "DownloadModel.h"

@implementation DownloadModel
- (instancetype)initWithDictionary:(NSDictionary *)dict{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end
