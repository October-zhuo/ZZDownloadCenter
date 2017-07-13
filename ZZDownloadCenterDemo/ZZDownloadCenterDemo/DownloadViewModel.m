//
//  DownloadViewModel.m
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/13.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "DownloadViewModel.h"
#import "DownloadModel.h"

NSString * const kDownloadURL = @"http://localhost:9000/list";

@interface DownloadViewModel()
@property (nonatomic, strong, readwrite)NSMutableArray *dataArray;
@end

@implementation DownloadViewModel

- (instancetype)init{
    if (self = [super init]) {
        self.dataArray = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)fetchData{
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithURL:[NSURL URLWithString:kDownloadURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            NSLog(@"ops, error:%@",error);
        }else{
            NSArray *resultArray  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:resultArray.count];
            for (int i = 0; i < resultArray.count; i++) {
                NSDictionary *objc = resultArray[i];
                DownloadModel *model = [[DownloadModel alloc] initWithDictionary:objc];
                [array addObject:model];
            }
            [[self mutableArrayValueForKey:@"dataArray"]  addObjectsFromArray:array];
        }
    }];
    [task resume];
}
@end
