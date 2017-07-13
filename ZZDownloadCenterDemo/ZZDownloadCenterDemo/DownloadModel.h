//
//  DownloadModel.h
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/13.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadModel : NSObject
@property (nonatomic, strong)NSString *title;
@property (nonatomic, strong)NSString *fileID;

- (instancetype)initWithDictionary:(NSDictionary *)dict;
@end
