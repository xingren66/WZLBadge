//
//  UIBarButtonItem+WZLBadge.m
//  WZLBadgeDemo
//
//  Created by zilin_weng on 15/8/10.
//  Copyright (c) 2015年 Weng-Zilin. All rights reserved.
//

#import "UIBarButtonItem+WZLBadge.h"
#import <objc/runtime.h>

#define kActualView     [self getActualBadgeSuperView]


@implementation UIBarButtonItem (WZLBadge)

#pragma mark -- public methods

/**
 *  show wzl_badge with red dot style and WBadgeAnimTypeNone by default.
 */
- (void)wzl_showBadge
{
    if (@available(iOS 26.0, *)) {
        self.badge = [UIBarButtonItemBadge indicatorBadge];
    } else {
        [kActualView wzl_showBadge];
    }
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
    if (@available(iOS 26.0, *)) {
        switch (style) {
            case WBadgeStyleRedDot:
                self.badge = [UIBarButtonItemBadge indicatorBadge];
                self.badge.backgroundColor = [UIColor redColor];
                break;
            case WBadgeStyleNumber:
                self.badge = [UIBarButtonItemBadge badgeWithCount:value];
                break;
            case WBadgeStyleNew:
                self.badge = [UIBarButtonItemBadge badgeWithString:@"New"];
                self.badge.foregroundColor = [UIColor redColor];
                break;
            default:
                break;
        }
    } else {
        // Fallback on earlier versions
        [kActualView wzl_showBadgeWithStyle:style value:value animationType:aniType];
    }
}


/**
 *  clear wzl_badge
 */
- (void)wzl_clearBadge
{
    if (@available(iOS 26.0, *)) {
        self.badge = nil;
    } else {
        [kActualView wzl_clearBadge];
    }
}

- (void)wzl_resumeBadge
{
    if (@available(iOS 26.0, *)) {
        self.badge = nil;
    } else {
        [kActualView wzl_resumeBadge];
    }
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
    return [self valueForKeyPath:@"_view"];//use KVC to hack actual view
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
