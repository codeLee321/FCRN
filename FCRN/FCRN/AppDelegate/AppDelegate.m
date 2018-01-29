//
//  AppDelegate.m
//  FCRN
//
//  Created by 荣 li on 2018/1/9.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import "AppDelegate.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "UIColor+hexColor.h"
#import "RLSingleton.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self configContation];
    
    return YES;
}

- (void)configContation{
    
    [[IQKeyboardManager sharedManager] setEnable:YES];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithHex:@"#888888"]];
    [[UINavigationBar appearance]  setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:17],NSForegroundColorAttributeName:[UIColor colorWithHex:@"#e0e0e0"]}];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad){
        [RLSingleton shareSingle].isPad = YES;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {

}


- (void)applicationDidEnterBackground:(UIApplication *)application {

}


- (void)applicationWillEnterForeground:(UIApplication *)application {

}


- (void)applicationDidBecomeActive:(UIApplication *)application {

}


- (void)applicationWillTerminate:(UIApplication *)application {

}


@end
