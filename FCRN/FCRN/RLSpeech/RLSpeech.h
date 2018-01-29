//
//  RLSpeech.h
//  FCRN
//
//  Created by 荣 li on 2018/1/15.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RLSpeech : NSObject
@property (nonatomic, assign) BOOL isReading;
- (void)playWithString:(NSString *)str;

@end
