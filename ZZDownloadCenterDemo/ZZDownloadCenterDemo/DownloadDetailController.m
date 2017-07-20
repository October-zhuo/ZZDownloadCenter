//
//  DownloadDetailController.m
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/13.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "DownloadDetailController.h"
#import "DownloadModel.h"
#import "ZZDownloadCenter.h"

NSString *const kDownloadBaseUrl = @"http://localhost:9000/download";

@interface DownloadDetailController ()
@property (nonatomic, strong) DownloadModel  *model;
@property (nonatomic, strong)UILabel *urlLabel;
@property (nonatomic, strong)UIButton *downloadBtn;
@property (nonatomic, strong)UILabel *titleLabel;
@end

@implementation DownloadDetailController

- (instancetype)initWithModel:(DownloadModel *)model{
    if(self = [super  init] ){
        _model = model;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self sestupUI];
    self.titleLabel.text = self.model.name;
    self.urlLabel.text = [NSString stringWithFormat:@"%@/?name=%@",kDownloadBaseUrl,self.model.name];
}

- (void)didClickDownloadBtn{
    [[ZZDownloadCenter defaultCenter] downloadWithURL:[NSURL URLWithString:self.urlLabel.text] configuration:nil progres:^(float progress) {
        NSLog(@"%f",progress);
    } completion:^(NSURL *localURL, NSError *error) {
        if (error) {
            NSLog(@"download error -=-=-=--=-:%@",error);
        }else{
            NSLog(@"Where amazing happens! %@",localURL.absoluteString);
        }
    }];
}

- (void)sestupUI{
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (!_titleLabel) {
        _titleLabel = [[UILabel  alloc] initWithFrame:CGRectMake(10, 100, size.width - 20, 80)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_titleLabel];
    }
    
    if (!_urlLabel) {
        _urlLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 300, size.width - 20, 80)];
        _urlLabel.textAlignment = NSTextAlignmentCenter;
        _urlLabel.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:_urlLabel];
    }
    
    if (!_downloadBtn) {
        _downloadBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 500, 100, 60)];
        _downloadBtn.center = CGPointMake(self.view.center.x, _downloadBtn.center.y);
        [_downloadBtn setTitle:@"开始下载" forState:UIControlStateNormal];
        _downloadBtn.layer.masksToBounds = YES;
        _downloadBtn.layer.cornerRadius = 5;
        _downloadBtn.backgroundColor = [UIColor orangeColor];
        [_downloadBtn addTarget:self action:@selector(didClickDownloadBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_downloadBtn];
    }
}

@end
