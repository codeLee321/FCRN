//
//  RLInputSelectedCell.h
//  FCRN
//
//  Created by 荣 li on 2018/1/15.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import "RLBaseCell.h"

@protocol RLInputSelectedCellDelegate <NSObject>
@optional
- (void) longPanActionWithCell:(RLBaseCell *)cell;
@end

@interface RLInputSelectedCell : RLBaseCell
@property (nonatomic, strong)NSDictionary * dataDict;

@property (nonatomic, assign) id <RLInputSelectedCellDelegate> delegate;

@end
