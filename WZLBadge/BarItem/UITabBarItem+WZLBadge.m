//
//  UITabBarItem+WZLBadge.m
//  WZLBadgeDemo
//
//  Created by zilin_weng on 15/9/24.
//  Copyright (c) 2015年 Weng-Zilin. All rights reserved.
//

#import "UITabBarItem+WZLBadge.h"

#define kActualView     [self getActualBadgeSuperView]

@implementation UITabBarItem (WZLBadge)

#pragma mark -- public methods

/**
 *  show wzl_badge with red dot style and WBadgeAnimTypeNone by default.
 */
- (void)wzl_showBadge
{
    [kActualView wzl_showBadge];
}

/**
 *  wzl_showBadge
 *
 *  @param style WBadgeStyle type
 *  @param value (if 'style' is WBadgeStyleRedDot or WBadgeStyleNew,
 this value will be ignored. In this case, any value will be ok.)
 *   @param aniType
 */
- (void)wzl_showBadgeWithStyle:(WBadgeStyle)style
                     value:(NSInteger)value
             animationType:(WBadgeAnimType)aniType
{
    [kActualView wzl_showBadgeWithStyle:style value:value animationType:aniType];
}

/**
 *  clear wzl_badge
 */
- (void)wzl_clearBadge
{
    [kActualView wzl_clearBadge];
}

- (void)wzl_resumeBadge
{
    [kActualView wzl_resumeBadge];
}

#pragma mark -- private method

/**
 *  Because UIBarButtonItem is kind of NSObject, it is not able to directly attach wzl_badge.
 This method is used to find actual view (non-nil) inside UIBarButtonItem instance.
 *
 *  @return view
 */
- (UIView *)getActualBadgeSuperView
{
    // 1.get UITabbarButtion
    UIView *bottomView = [self valueForKeyPath:@"_view"];
    
    // 2.get imageView, to make sure wzl_badge front at anytime.
    UIView *actualSuperView = nil;
    if (bottomView) {
        actualSuperView = [self find:bottomView firstSubviewWithClass:NSClassFromString(@"UITabBarSwappableImageView")];
    }
    
    // wzl_badge label will be added onto imageView
    return actualSuperView;
}

- (UIView *)find:(UIView *)view firstSubviewWithClass:(Class)cls
{
    __block UIView *targetView = nil;
    [view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([subview isKindOfClass:cls]) {
            targetView = subview;
            *stop = YES;
        }
    }];
    return targetView;
}

#pragma mark -- setter/getter
- (UILabel *)wzl_badge
{
    return kActualView.wzl_badge;
}

- (void)setWzl_badge:(UILabel *)label
{
    [kActualView setWzl_badge:label];
}

- (UIFont *)wzl_badgeFont
{
	return kActualView.wzl_badgeFont;
}

- (void)setWzl_badgeFont:(UIFont *)wzl_badgeFont
{
	[kActualView setWzl_badgeFont:wzl_badgeFont];
}

- (UIColor *)wzl_badgeBgColor
{
    return [kActualView wzl_badgeBgColor];
}

- (void)setWzl_badgeBgColor:(UIColor *)wzl_badgeBgColor
{
    [kActualView setWzl_badgeBgColor:wzl_badgeBgColor];
}

- (UIColor *)wzl_badgeTextColor
{
    return [kActualView wzl_badgeTextColor];
}

- (void)setWzl_badgeTextColor:(UIColor *)wzl_badgeTextColor
{
    [kActualView setWzl_badgeTextColor:wzl_badgeTextColor];
}

- (WBadgeAnimType)aniType
{
    return [kActualView aniType];
}

- (void)setAniType:(WBadgeAnimType)aniType
{
    [kActualView setAniType:aniType];
}

- (CGRect)wzl_badgeFrame
{
    return [kActualView wzl_badgeFrame];
}

- (void)setWzl_badgeFrame:(CGRect)wzl_badgeFrame
{
    [kActualView setWzl_badgeFrame:wzl_badgeFrame];
}

- (CGPoint)wzl_badgeCenterOffset
{
    return [kActualView wzl_badgeCenterOffset];
}

- (void)setWzl_badgeCenterOffset:(CGPoint)wzl_badgeCenterOffset
{
    [kActualView setWzl_badgeCenterOffset:wzl_badgeCenterOffset];
}

- (CGFloat)wzl_badgeRadius
{
    return [kActualView wzl_badgeRadius];
}

- (void)setWzl_badgeRadius:(CGFloat)wzl_badgeRadius
{
    [kActualView setWzl_badgeRadius:wzl_badgeRadius];
}

- (NSInteger)wzl_badgeMaximumBadgeNumber
{
    return [kActualView wzl_badgeMaximumBadgeNumber];
}

- (void)setWzl_badgeMaximumBadgeNumber:(NSInteger)wzl_badgeMaximumBadgeNumber
{
    [kActualView setWzl_badgeMaximumBadgeNumber:wzl_badgeMaximumBadgeNumber];
}

@end
