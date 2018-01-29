//
//  UIImage+image.h
//  FCRN
//
//  Created by 荣 li on 2018/1/15.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (image)
-(UIImage *)imageCompressTargetSize:(CGSize)size;

+ (UIImage *)originImage:(UIImage *)image scaleToSize:(CGSize)newSize;
@end
