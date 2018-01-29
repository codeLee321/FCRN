//
//  RLHttpHint.h
//  FCRN
//
//  Created by 荣 li on 2018/1/9.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RLBubbleInfo.h"
#import "RLBubbleView.h"

@interface RLHttpHint : NSObject
+ (instancetype)shareInstance;

extern void ShowSuccessStatus(NSString *statues);
extern void ShowErrorStatus(NSString *statues);
extern void ShowMaskStatus(NSString *statues);
extern void ShowMessage(NSString *statues);
extern void ShowProgress(CGFloat progress);
extern void DismissHud(void);
@end
