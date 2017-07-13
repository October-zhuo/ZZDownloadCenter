//
//  ViewController.m
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/5.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "ListViewController.h"
#import "ZZDownloadCenter.h"
#import "ZZDownloadConfiguration.h"
#import "DownloadViewModel.h"
#import "DownloadModel.h"
#import "DownloadDetailController.h"

NSString *const kTableviewCellID = @"kTableviewCellID";

@interface ListViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)DownloadViewModel *viewModel;
@property (nonatomic, strong)NSArray *dataArray;
@end

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    [self loadTableview];
    _viewModel  = [[DownloadViewModel alloc] init];
    [_viewModel fetchData];
    [_viewModel addObserver:self forKeyPath:@"dataArray" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if([keyPath isEqualToString:@"dataArray"]){        
        self.dataArray = self.viewModel.dataArray;
        [self.tableView reloadData];
    }
}

- (void)loadTableview{
    if (!_tableView) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kTableviewCellID];
        [self.view addSubview:_tableView];
    }
}

#pragma  mark - tableview datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kTableviewCellID];
    DownloadModel *model = self.dataArray[indexPath.row];
    cell.textLabel.text = model.title;
    return cell;
}


#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DownloadModel *model = self.dataArray[indexPath.row];
    if (model) {
        DownloadDetailController * controller = [[DownloadDetailController alloc] initWithModel:model];
        [self.navigationController pushViewController:controller animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSURL *url = [NSURL URLWithString:@"http://localhost:8421/download.html?file_name=IMChatViewStep1.sketch"];
    ZZDownloadConfiguration *configuration = [[ZZDownloadConfiguration alloc] init];
    
    [[ZZDownloadCenter defaultCenter] downloadWithURL:url configuration:configuration progres:^(float progress) {
        NSLog(@"-=-=-=-=-=-=progress-=-==-=-%f",progress);
    } completion:^(NSURL *localUrlString, NSError *error) {
        if (error) {
            NSLog(@"-------------error---------%@",error);
        }else{
            NSLog(@"==========OK==============%@",localUrlString);
        }
    }];

}

@end
