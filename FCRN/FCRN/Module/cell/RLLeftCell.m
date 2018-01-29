//
//  RLLeftCell.m
//  FCRN
//
//  Created by 荣 li on 2018/1/11.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import "RLLeftCell.h"

@interface RLLeftCell()
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@end

@implementation RLLeftCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setData:(NSDictionary *)data{
    _data = data;
    self.headerImageView.image = [UIImage imageNamed:data[@"image"]];
    self.tipsLabel.text = data[@"tips"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
