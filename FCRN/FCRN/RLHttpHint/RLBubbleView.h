//
//  RLBubbleView.h
//  FCRN
//
//  Created by 荣 li on 2018/1/9.
//  Copyright © 2018年 荣 li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RLBubbleInfo.h"

@interface RLBubbleView : UIView
/// @brief 进度属性
@property (nonatomic) CGFloat progress;
/**
 *  @author 1em0nsOft LiuRi
 *  @date 2016-08-30 16:08:41
 *
 *  @brief 默认的LK泡泡控件 - 单例方法
 *
 *  @return 默认的LK泡泡控件对象
 */
+ (RLBubbleView *)defaultBubbleView;
/**
 注册泡泡信息对象
 
 @param info 泡泡信息对象
 @param key  泡泡信息对象对应的键
 */
- (void)registerInfo: (RLBubbleInfo *)info forKey: (NSString *)key;

/**
 *  @author 1em0nsOft LiuRi
 *  @date 2016-08-30 16:08:53
 *
 *  @brief 显示指定的信息模型对应的泡泡控件
 */
- (void)showWithInfo: (RLBubbleInfo *)info;

/**
 *  @author 1em0nsOft LiuRi
 *  @date 2016-08-30 16:08:53
 *
 *  @brief 通过传入键来显示已经注册的指定样式泡泡控件
 */
- (void)showWithInfoKey: (NSString *)infoKey;

/**
 *  @author 1em0nsOft LiuRi
 *  @date 2016-08-30 16:08:53
 *
 *  @brief 显示指定的信息模型对应的泡泡控件，并指定的时间后隐藏
 *
 *  @param info          样式信息模型
 *  @param time 指定时间后隐藏泡泡控件的秒数
 */
- (void)showWithInfo: (RLBubbleInfo *)info autoCloseTime: (CGFloat)time;

/**
 *  @author 1em0nsOft LiuRi
 *  @date 2016-08-30 16:08:53
 *
 *  @brief 显示指定的信息模型对应的泡泡控件，并指定的时间后隐藏
 *
 *  @param infoKey          已注册的样式信息模型的键
 *  @param time 指定时间后隐藏泡泡控件的秒数
 */
- (void)showWithInfoKey: (NSString *)infoKey autoCloseTime: (CGFloat)time;

/**
 *  @author 1em0nsOft LiuRi
 *  @date 2016-08-30 16:08:40
 *
 *  @brief 隐藏当前泡泡控件
 */
- (void)hide;
@end
