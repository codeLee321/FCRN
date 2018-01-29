//
//  RLSingleton.h
//  FCRN
//
//  Created by 荣 li on 2018/1/11.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MMDrawerController/MMDrawerController.h>
#import "FCPPSDK.h"
#import "RLLeftVC.h"
#import "RLInputVC.h"
#import "RLFaceRecongnizeVC.h"
#import "RLInputedVC.h"
#import "RLBaseNAVC.h"
#import "RLHttpHint.h"

static NSString * const apiCallCount = @"apiCallCount";
static NSString * const apiCallDate = @"apiCallDate";

@interface RLSingleton : NSObject

@property (nonatomic, strong) MMDrawerController * drawerVC;

@property (strong , nonatomic) FCPPFaceSet *faceSet;

@property (strong , nonatomic) NSMutableDictionary *infoDict;

@property (nonatomic, copy) NSString * faceSetID;
@property (nonatomic, copy) NSString * callDate;     // 调用时的日期

@property (nonatomic, assign) BOOL isPad;

@property (nonatomic, assign) int callCount;          // api调用的次数


+ (instancetype)shareSingle;

- (void)configChildVCWithButtonTag:(NSInteger)tag;

- (void)writeToUserDefaultWithObject:(id)object andKey:(NSString *)key;

- (id)getObjectFromUserDefaultWithKey:(NSString *)key;


@end
