//
//  RLLeftVC.m
//  FCRN
//
//  Created by 荣 li on 2018/1/11.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import "RLLeftVC.h"
#import "RLLeftCell.h"
#import "RLSingleton.h"

static NSString * const cellID = @"cellID";
@interface RLLeftVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray * dataSource;
@end

@implementation RLLeftVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
    self.title = @"FCRN";
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RLLeftCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.data = self.dataSource[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [[RLSingleton shareSingle].drawerVC closeDrawerAnimated:YES completion:^(BOOL finished) {
        [[RLSingleton shareSingle] configChildVCWithButtonTag:indexPath.row];
    }];
}

#pragma mark - lazyLoad
- (NSArray *)dataSource{
    if (!_dataSource) {
        _dataSource = @[@{@"image":@"input_icon",@"tips":@"录入信息"},
                        @{@"image":@"fcrn_icon",@"tips":@"人脸识别"},
                        @{@"image":@"inputed_icon",@"tips":@"已录入"},
                        @{@"image":@"search_icon",@"tips":@"搜索"}
                        ];
    }
    return _dataSource;
}
@end
