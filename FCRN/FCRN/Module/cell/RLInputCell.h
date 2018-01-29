//
//  RLInputCell.h
//  FCRN
//
//  Created by 荣 li on 2018/1/15.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import "RLBaseCell.h"
@protocol RLInputCellDelegate <NSObject>
@optional
- (void) longPanActionWithCell:(RLBaseCell *)cell;
@end

@interface RLInputCell : RLBaseCell

@property (strong, nonatomic) NSDictionary * dataDict;

@property (nonatomic, assign) id <RLInputCellDelegate> delegate;
@end
