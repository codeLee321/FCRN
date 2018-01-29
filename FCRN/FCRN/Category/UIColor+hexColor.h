//
//  UIColor+hexColor.h
//  FCRN
//
//  Created by 荣 li on 2018/1/11.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (hexColor)
/**
 *  十六进制设置颜色
 *
 */
+ (UIColor *)colorWithHex:(NSString *)hex;
@end
