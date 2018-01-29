//
//  NSDate+date.m
//  FCRN
//
//  Created by 荣 li on 2018/1/11.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import "NSDate+date.h"

@implementation NSDate (date)
+ (NSString *)getCurrentTimestamp{
    NSDate *date = [NSDate date];
    NSString *dateStr = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
    return dateStr;
}

+ (NSString *)getCurrentDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    NSString *string = [formatter stringFromDate:[NSDate date]];
    
    return string;
}


@end
