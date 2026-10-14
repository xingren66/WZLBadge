//
//  UIView+WZLBadge.h
//  WZLBadgeDemo
//
//  Created by zilin_weng on 15/6/24.
//  Copyright (c) 2015年 Weng-Zilin. All rights reserved.
//  Project description: this is a solution to enable any UIView to display badge

#import <UIKit/UIKit.h>
#import "WZLBadgeProtocol.h"

#pragma mark -- badge apis

/**
 *  NOTE(iOS 26+):
 *  wzl_badge is NOT added as a direct subview of the receiver any more.
 *  The hierarchy is:  self  ->  wzl_badgeContainer(UIView)  ->  wzl_badge(UILabel)
 *
 *  Reason: from iOS 26 on, UINavigationBar automatically attaches a glass
 *  background to the UIBarButtonItem's customView and blends its subviews with
 *  the navigation bar background. If the badge label were attached to the
 *  customView directly, its backgroundColor would be tinted/overridden by the
 *  navigation bar background. The container view declares its own
 *  (clear) backgroundColor and therefore absorbs that effect.
 *
 *  Extra note for bar button items: if the glass background behind the whole
 *  item is still not wanted, set `hidesSharedBackground = YES` on the
 *  UIBarButtonItem (iOS 26+ API) as well.
 */
@interface UIView (WZLBadge)<WZLBadgeProtocol>


/**
 *  show badge with red dot style and WBadgeAnimTypeNone by default.
 */
- (void)wzl_showBadge;

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
             animationType:(WBadgeAnimType)aniType;

/*
 wBadgeStyle default is WBadgeStyleNumber
 */
- (void)wzl_showNumberBadgeWithValue:(NSInteger)value
              animationType:(WBadgeAnimType)aniType;

// wBadgeStyle default is WBadgeStyleNumber ;
// WBadgeAnimType defualt is  WBadgeAnimTypeNone
- (void)wzl_showNumberBadgeWithValue:(NSInteger)value;

/**
 *  clear badge(hide badge)
 */
- (void)wzl_clearBadge;

/**
 *  make bage(if existing) not hiden
 */
- (void)wzl_resumeBadge;

@end
