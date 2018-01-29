//
//  RLInputedVC.m
//  FCRN
//
//  Created by 荣 li on 2018/1/11.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import "RLInputedVC.h"
#import "RLTableHeaderView.h"
#import "RLInputCell.h"
#import "RLInputSelectedCell.h"
#import "UIColor+hexColor.h"
#import "RLSingleton.h"


static NSString * const cellID = @"cellID";
static NSString * const selectCellID = @"selectCellID";

@interface RLInputedVC () <UITableViewDelegate, UITableViewDataSource,RLInputSelectedCellDelegate,RLInputCellDelegate,UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic, strong) NSMutableArray * dataSourceArr;
@property (nonatomic, strong) NSIndexPath * selectIndex;
@property (nonatomic, strong) UISearchBar * searchBar;

@end

@implementation RLInputedVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"FCRN";
    
    self.tableView.tableFooterView = [UIView new];
    
    [self configNavItem];

}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.dataSourceArr = [NSMutableArray arrayWithArray:[[RLSingleton shareSingle].infoDict allKeys]];
    self.countLabel.text = [NSString stringWithFormat:@"%ld人参加识别",self.dataSourceArr.count];
    [self.tableView reloadData];
    
    if (self.isSearch && !_searchBar) {
        self.navigationItem.titleView = self.searchBar;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.searchBar.frame = CGRectMake(0, 0, 120, 25);
        } completion:^(BOOL finished) {
            [self.searchBar becomeFirstResponder];
        }];
    }
}

- (void)configNavItem{
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"left_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(leftItemAction:)];
    
    if (self.isSearch) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"right_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(rightItemAction:)];
    }else{
        
        self.navigationItem.titleView = ({
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 83, 28)];
            imageView.image = [UIImage imageNamed:@"titl_icon"];
            imageView;
        });
        
    }
}

- (void)leftItemAction:(UIButton *)btn{
    
    if (self.isSearch) {
        [self.searchBar endEditing:YES];
    }
    
    [[RLSingleton shareSingle].drawerVC toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)rightItemAction:(UIButton *)btn{
    if (!_searchBar) {
        self.navigationItem.titleView = self.searchBar;
        [UIView animateWithDuration:1 animations:^{
            self.searchBar.frame = CGRectMake(0, 0, 120, 25);
        } completion:nil];
    }else{
        [self searchUserDataWithString:self.searchBar.text];
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RLBaseCell * cell = nil;
    NSDictionary * dict = [[RLSingleton shareSingle].infoDict objectForKey:self.dataSourceArr[indexPath.row]];
    
    if (indexPath == self.selectIndex) {
        cell = [tableView dequeueReusableCellWithIdentifier:selectCellID forIndexPath:indexPath];
        ((RLInputSelectedCell *) cell).delegate = self;
        if (dict) {
            ((RLInputSelectedCell *) cell).dataDict = dict;
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
        ((RLInputCell *) cell).delegate = self;
        if (dict) {
           ((RLInputCell *)cell).dataDict = dict;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath == self.selectIndex) {
        return 120.f;
    }
    return 80.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.selectIndex == indexPath) {
        self.selectIndex = nil;
    }else{
        self.selectIndex = indexPath;
    }
    
    [tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self searchUserDataWithString:searchText];
}

- (void)searchUserDataWithString:(NSString *)text{
    if (text.length >0) {
        NSMutableArray * dataArr = [NSMutableArray array];
        for (NSString * key in self.dataSourceArr) {
            NSDictionary * dict = [[RLSingleton shareSingle].infoDict objectForKey:key];
            NSString * userName = dict[@"name"];
            
            if ([userName rangeOfString:text].location !=NSNotFound) {
                [dataArr addObject:key];
            }
        }
        self.dataSourceArr = dataArr;
    }else{
        self.dataSourceArr = [NSMutableArray arrayWithArray:[[RLSingleton shareSingle].infoDict allKeys]];
    }
    
    [self.tableView reloadData];
}

- (void)longPanActionWithCell:(RLBaseCell *)cell{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    [self deleteFaceTokenWithToken:indexPath];
}

- (void)deleteFaceTokenWithToken:(NSIndexPath *)indexPath{
    NSString * faceToken = self.dataSourceArr[indexPath.row];
    __weak typeof(self) weakSelf = self;
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil                                                                             message: nil                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
    //添加Button
    [alertController addAction: [UIAlertAction actionWithTitle: @"删除" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //删除facetoken
        [[RLSingleton shareSingle].faceSet removeFaceToken:@[faceToken] completion:^(id info, NSError *error) {
            if (error == nil) {
                ShowSuccessStatus(@"删除成功");
                [[RLSingleton shareSingle].infoDict removeObjectForKey:weakSelf.dataSourceArr[indexPath.row]];
                [RLSingleton shareSingle].infoDict = [RLSingleton shareSingle].infoDict;
                [weakSelf.dataSourceArr removeObjectAtIndex:indexPath.row];
                [weakSelf.tableView reloadData];
                self.countLabel.text = [NSString stringWithFormat:@"%ld人参加识别",self.dataSourceArr.count];
                
            }else{
                ShowErrorStatus(@"删除失败");
            }
        }];
        
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
    
    if ([RLSingleton shareSingle].isPad) {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        alertController.popoverPresentationController.sourceView = cell;
        alertController.popoverPresentationController.sourceRect = cell.frame;
    }
    [self presentViewController: alertController animated: YES completion: nil];
}

- (UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 0, 25)];
        _searchBar.placeholder = @"搜索已输入用户";
        _searchBar.delegate = self;
        _searchBar.alpha = 0.4;
    }
    return _searchBar;
}
@end
