//
//  DownloadViewModel.h
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/13.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadViewModel : NSObject
- (void)fetchData;
@property (nonatomic, strong, readonly)NSMutableArray *dataArray;
@end
