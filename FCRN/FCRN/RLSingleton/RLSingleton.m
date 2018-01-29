//
//  RLSingleton.m
//  FCRN
//
//  Created by 荣 li on 2018/1/11.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import "RLSingleton.h"
#import "NSDate+date.h"

@implementation RLSingleton

@synthesize infoDict = _infoDict;
@synthesize callCount = _callCount;
@synthesize callDate = _callDate;

+ (instancetype)shareSingle
{
    static RLSingleton *singleton = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[self alloc] init];
    });
    return singleton;
}

- (NSString *)faceSetID{
    if (!_faceSetID) {
        _faceSetID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    return _faceSetID;
}

- (void)setInfoDict:(NSMutableDictionary *)infoDict{
    _infoDict = infoDict;
    [self writeToUserDefaultWithObject:infoDict andKey:@"info"];
}

- (NSMutableDictionary *)infoDict{
    if (!_infoDict) {
        NSDictionary * dict = (NSDictionary *) [[RLSingleton shareSingle] getObjectFromUserDefaultWithKey:@"info"];
        if (dict) {
            _infoDict = [NSMutableDictionary dictionaryWithDictionary:dict];
        }else{
            _infoDict = [NSMutableDictionary dictionary];
        }
    }
    return _infoDict;
}

- (void)setCallCount:(int)callCount{
    _callCount = callCount;
    [self writeToUserDefaultWithObject:@(callCount) andKey:apiCallCount];
}

- (int)callCount{
    NSNumber * value = [self getObjectFromUserDefaultWithKey:apiCallCount];
    if (value) {
        _callCount = [value intValue];
    }else{
        _callCount = 0;
    }
    return _callCount;
}

- (void)setCallDate:(NSString *)callDate{
    _callDate = callDate;
    [self writeToUserDefaultWithObject:callDate andKey:apiCallDate];
}

- (NSString *)callDate{
    if (!_callDate) {
        NSString * date = [self getObjectFromUserDefaultWithKey:apiCallDate];
        if (date) {
            _callDate = date;
        }else{
            _callDate = [NSDate getCurrentDate];
            [self writeToUserDefaultWithObject:_callDate andKey:apiCallDate];
        }
    }
    return _callDate;
}

- (void)writeToUserDefaultWithObject:(id)object andKey:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (id)getObjectFromUserDefaultWithKey:(NSString *)key{
    id obj = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    return obj;
}

- (void)configChildVCWithButtonTag:(NSInteger)tag{
    
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"FACN" bundle:nil];
    RLLeftVC * leftVC = [storyBoard instantiateViewControllerWithIdentifier:@"RLLeftVC"];
    RLBaseNAVC * centerNAV = nil;
    switch (tag) {
        case 0:
        {
            RLInputVC *  inputVC = [storyBoard instantiateViewControllerWithIdentifier:@"RLInputVC"];
            RLBaseNAVC * inputNAV = [[RLBaseNAVC alloc] initWithRootViewController:inputVC];
            centerNAV = inputNAV;
        }
            break;
        case 1:
        {
            RLFaceRecongnizeVC * facnVC =[storyBoard instantiateViewControllerWithIdentifier:@"RLFaceRecongnizeVC"];
            RLBaseNAVC * facnNAV = [[RLBaseNAVC alloc] initWithRootViewController:facnVC];
            centerNAV = facnNAV;
        }
            break;
        case 2:
        {
            RLInputedVC * inputedVC = [storyBoard instantiateViewControllerWithIdentifier:@"RLInputedVC"];
            RLBaseNAVC * inputedNAV = [[RLBaseNAVC alloc] initWithRootViewController:inputedVC];
            centerNAV = inputedNAV;
        }
            break;
        case 3:
        {
            RLInputedVC * inputedVC = [storyBoard instantiateViewControllerWithIdentifier:@"RLInputedVC"];
            inputedVC.isSearch = YES;
            RLBaseNAVC * inputedNAV = [[RLBaseNAVC alloc] initWithRootViewController:inputedVC];
            centerNAV = inputedNAV;
        }
            break;
            
        default:
            break;
    }
    
    MMDrawerController * drawerVC = [[MMDrawerController alloc] initWithCenterViewController:centerNAV leftDrawerViewController:leftVC];
    drawerVC.openDrawerGestureModeMask = MMOpenDrawerGestureModeAll;
    drawerVC.closeDrawerGestureModeMask = MMCloseDrawerGestureModeAll;
    drawerVC.maximumLeftDrawerWidth = 200;
    drawerVC.showsShadow = YES;
    self.drawerVC = drawerVC;
    [UIApplication sharedApplication].keyWindow.rootViewController = drawerVC;
    
}
@end
