//
//  ViewController.m
//  FCRN
//
//  Created by 荣 li on 2018/1/9.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import "FCPPSDK.h"
#import "ViewController.h"
#import "RLSingleton.h"
#import "RLHttpHint.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self initFaceSet];
}

- (void)initFaceSet{
    
    NSString * faceSet_token = [[RLSingleton shareSingle] getObjectFromUserDefaultWithKey:@"faceset_token"];
    if (faceSet_token) {
        
        FCPPFaceSet *faceSet = [[FCPPFaceSet alloc] initWithFaceSetToken:faceSet_token];
        
        [RLSingleton shareSingle].faceSet = faceSet;
        ShowSuccessStatus(@"初始化完成");
        
    }else{
        [self creatFaceSet];
    }
}

- (void)creatFaceSet{
    ShowMaskStatus(@"正在初始化");
    [FCPPFaceSet createFaceSetWithDisplayName:[RLSingleton shareSingle].faceSetID outerId:nil tgas:nil faceTokens:nil userData:nil forceMerge:YES completion:^(id info, NSError *error) {
        if (error == nil) {
            NSString * faceset_token = info[@"faceset_token"];
            
            [[RLSingleton shareSingle] writeToUserDefaultWithObject:faceset_token andKey:@"faceset_token"];
            
            FCPPFaceSet * faceSet = [[FCPPFaceSet alloc] initWithFaceSetToken:faceset_token];
            
            [RLSingleton shareSingle].faceSet = faceSet;
            
            ShowSuccessStatus(@"初始化完成");

        }else{
            ShowErrorStatus(@"初始化失败，请重新启动");
        }
    }];
}

- (IBAction)buttonActon:(UIButton *)sender {
    
    [[RLSingleton shareSingle] configChildVCWithButtonTag:sender.tag];
}


@end
