//
//  RLInputCell.m
//  FCRN
//
//  Created by 荣 li on 2018/1/15.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import "RLInputCell.h"
#import "UIColor+hexColor.h"
@interface RLInputCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameTextLabel;
@property (weak, nonatomic) IBOutlet UIImageView *genderImageView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *bgContainerView;
@property (weak, nonatomic) IBOutlet UILabel *welLabel;

@end

@implementation RLInputCell

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
    
    NSString * gender = [dataDict objectForKey:@"gender"];
    if ([gender isEqualToString:@"男"]) {
        self.genderImageView.image = [UIImage imageNamed:@"male_icon"];
    }else{
        self.genderImageView.image = [UIImage imageNamed:@"female_icon"];
    }
    
    self.nameTextLabel.text = [dataDict objectForKey:@"name"];
    self.dateLabel.text = [dataDict objectForKey:@"date"];
    self.welLabel.text = [dataDict objectForKey:@"wel"];

}

@end
