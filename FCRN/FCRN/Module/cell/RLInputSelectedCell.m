//
//  RLInputSelectedCell.m
//  FCRN
//
//  Created by 荣 li on 2018/1/15.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import "RLInputSelectedCell.h"
#import "UIColor+hexColor.h"

@interface RLInputSelectedCell()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UILabel *birthdayLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *bgContainerView;
@end

@implementation RLInputSelectedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.bgContainerView.layer.shadowColor = [UIColor colorWithHex:@"#aaaaaa"].CGColor;
    self.bgContainerView.layer.shadowOffset = CGSizeMake(1,1);
    self.bgContainerView.layer.shadowOpacity = 0.8;
    self.bgContainerView.layer.shadowRadius = 2;
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    longPressGesture.minimumPressDuration = 1;
    [self addGestureRecognizer:longPressGesture];

}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture{
    if (self.delegate && [self.delegate respondsToSelector:@selector(longPanActionWithCell:)]) {
        [self.delegate longPanActionWithCell:self];
    }
}

- (void)setDataDict:(NSDictionary *)dataDict{
    _dataDict = dataDict;
    NSData * data = [[NSUserDefaults standardUserDefaults]objectForKey:[dataDict objectForKey:@"header"]];
    self.headerImageView.image = [UIImage imageWithData:data];
    self.nameLabel.text = dataDict[@"name"];
    self.genderLabel.text = [NSString stringWithFormat:@"性别:%@",dataDict[@"gender"]];
    self.birthdayLabel.text = [NSString stringWithFormat:@"生日:%@",dataDict[@"age"]];
    self.dateLabel.text = [NSString stringWithFormat:@"录入时间:%@",dataDict[@"date"]];
}

@end
