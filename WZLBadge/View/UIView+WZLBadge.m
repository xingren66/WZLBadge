//
//  UIView+WZLBadge.m
//  WZLBadgeDemo
//
//  Created by zilin_weng on 15/6/24.
//  Copyright (c) 2015年 Weng-Zilin. All rights reserved.
//

#import "UIView+WZLBadge.h"
#import <objc/runtime.h>
#import "CAAnimation+WAnimation.h"

#define kWZLBadgeDefaultFont				([UIFont boldSystemFontOfSize:9])

#define kWZLBadgeDefaultMaximumBadgeNumber                     99


static const CGFloat kWZLBadgeDefaultRedDotRadius = 4.f;


#pragma mark -- private apis

/**
 *  iOS 26 起，UINavigationBar 会为 UIBarButtonItem 的 customView 自动附加一层
 *  玻璃(毛玻璃)背景，并按照导航栏自身的背景对 customView 里的子视图做混色。
 *  结果是：把本分类用在一个 UIView(进而是 customView) 上时，挂在它上面的
 *  wzl_badge(UILabel) 的 backgroundColor 会被导航栏背景"吃掉"/变色。
 *
 *  解决办法：不要把 wzl_badge 直接挂在 self 上，而是先挂到一个"背景被显式声明"
 *  的容器 UIView 上，再由容器挂到 self 上。容器成为导航栏玻璃效果的承接层，
 *  内部 UILabel 就能按自己的颜色原样绘制。
 *
 *  视图层级：self(customView) -> wzl_badgeContainer(UIView) -> wzl_badge(UILabel)
 */
@interface UIView (WZLBadgeContainer)
- (UIView *)wzl_badgeContainer;
- (void)setWzl_badgeContainer:(UIView *)wzl_badgeContainer;
@end


@implementation UIView (WZLBadge)

#pragma mark -- public methods
/**
 *  show badge with red dot style and WBadgeAnimTypeNone by default.
 */
- (void)wzl_showBadge
{
    [self wzl_showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
}

/**
 *  wzl_showBadge
 *
 *  @param style WBadgeStyle type
 *  @param value (if 'style' is WBadgeStyleRedDot or WBadgeStyleNew, 
 *                this value will be ignored. In this case, any value will be ok.)
 */
- (void)wzl_showBadgeWithStyle:(WBadgeStyle)style value:(NSInteger)value animationType:(WBadgeAnimType)aniType
{
    self.aniType = aniType;
    switch (style) {
        case WBadgeStyleRedDot:
            [self wzl_showRedDotBadge];
            break;
        case WBadgeStyleNumber:
            [self wzl_showNumberBadgeWithValue:value];
            break;
        case WBadgeStyleNew:
            [self wzl_showNewBadge];
            break;
        default:
            break;
    }
    if (aniType != WBadgeAnimTypeNone) {
        [self beginAnimation];
    }
}

- (void)wzl_showNumberBadgeWithValue:(NSInteger)value animationType:(WBadgeAnimType)aniType {
    self.aniType = aniType;
    [self wzl_showNumberBadgeWithValue:value];
    
    if (aniType != WBadgeAnimTypeNone) {
        [self beginAnimation];
    }
}

/**
 *  clear badge
 */
- (void)wzl_clearBadge
{
    [self wzl_setBadgeHidden:YES];
}

/**
 *  make bage(if existing) not hiden
 */
- (void)wzl_resumeBadge
{
    if (self.wzl_badge && self.wzl_badge.hidden == YES) {
        [self wzl_setBadgeHidden:NO];
    }
}

#pragma mark -- private methods
- (void)wzl_showRedDotBadge
{
    [self wzl_badgeInit];
    //if badge has been displayed and, in addition, is was not red dot style, we must update UI.
    if (self.wzl_badge.tag != WBadgeStyleRedDot) {
        self.wzl_badge.text = @"";
        self.wzl_badge.tag = WBadgeStyleRedDot;
        [self wzl_resetBadgeForRedDot];
        self.wzl_badge.layer.cornerRadius = CGRectGetWidth(self.wzl_badge.frame) / 2;
    }
    [self wzl_setBadgeHidden:NO];
}

- (void)wzl_resetBadgeForRedDot {
    if (self.wzl_badgeRadius > 0) {
        UIView *container = self.wzl_badgeContainer;
        CGPoint center = container ? container.center : self.wzl_badge.center;
        [self wzl_setBadgeFrame:CGRectMake(center.x - self.wzl_badgeRadius, center.y + self.wzl_badgeRadius , self.wzl_badgeRadius * 2, self.wzl_badgeRadius *2)];
    }
}

- (void)wzl_showNewBadge
{
    [self wzl_badgeInit];
    //if badge has been displayed and, in addition, is not red dot style, we must update UI.
    if (self.wzl_badge.tag != WBadgeStyleNew) {
        self.wzl_badge.text = @"new";
        self.wzl_badge.tag = WBadgeStyleNew;
        
        CGRect frame = [self wzl_badgeFrameInSuperview];
        frame.size.width = 22;
        frame.size.height = 13;
        [self wzl_setBadgeFrame:frame];
        
        [self wzl_setBadgeCenter:CGPointMake(CGRectGetWidth(self.frame) + 2 + self.wzl_badgeCenterOffset.x, self.wzl_badgeCenterOffset.y)];
        self.wzl_badge.font = kWZLBadgeDefaultFont;
        self.wzl_badge.layer.cornerRadius = CGRectGetHeight(self.wzl_badge.frame) / 3;
    }
    [self wzl_setBadgeHidden:NO];
}

- (void)wzl_showNumberBadgeWithValue:(NSInteger)value
{
    if (value < 0) {
        return;
    }
    [self wzl_badgeInit];
    [self wzl_setBadgeHidden:(value == 0)];
    self.wzl_badge.tag = WBadgeStyleNumber;
    self.wzl_badge.font = self.wzl_badgeFont;
    self.wzl_badge.text = (value > self.wzl_badgeMaximumBadgeNumber ?
                       [NSString stringWithFormat:@"%@+", @(self.wzl_badgeMaximumBadgeNumber)] :
                       [NSString stringWithFormat:@"%@", @(value)]);
    [self adjustLabelWidth:self.wzl_badge];
    //after adjustLabelWidth:, label frame == text size, take it as the badge content size
    CGRect frame = self.wzl_badge.frame;
    frame.size.width += 4;
    frame.size.height += 4;
    if(CGRectGetWidth(frame) < CGRectGetHeight(frame)) {
        frame.size.width = CGRectGetHeight(frame);
    }
    [self wzl_setBadgeFrame:frame];
    [self wzl_setBadgeCenter:CGPointMake(CGRectGetWidth(self.frame) + 2 + self.wzl_badgeCenterOffset.x, self.wzl_badgeCenterOffset.y)];
    self.wzl_badge.layer.cornerRadius = CGRectGetHeight(self.wzl_badge.frame) / 2;
}

//lazy loading
- (void)wzl_badgeInit
{
    if (self.wzl_badgeBgColor == nil) {
        self.wzl_badgeBgColor = [UIColor redColor];
    }
    if (self.wzl_badgeTextColor == nil) {
        self.wzl_badgeTextColor = [UIColor whiteColor];
    }
    
    if (nil == self.wzl_badge) {
        CGFloat redotWidth = kWZLBadgeDefaultRedDotRadius *2;
        CGRect frm = CGRectMake(CGRectGetWidth(self.frame), -redotWidth, redotWidth, redotWidth);
        
        //1.container: explicit clearColor, isolate the badge background from navigation bar's background(iOS 26)
        UIView *container = [self wzl_setupBadgeContainerWithFrame:frm];
        container.center = CGPointMake(CGRectGetWidth(self.frame) + 2 + self.wzl_badgeCenterOffset.x, self.wzl_badgeCenterOffset.y);
        
        //2.badge label, added into container instead of self
        UILabel *badge = [[UILabel alloc] initWithFrame:container.bounds];
        badge.textAlignment = NSTextAlignmentCenter;
        badge.backgroundColor = self.wzl_badgeBgColor;
        badge.textColor = self.wzl_badgeTextColor;
        badge.text = @"";
        badge.tag = WBadgeStyleRedDot;//red dot by default
        badge.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        badge.layer.cornerRadius = CGRectGetWidth(badge.frame) / 2;
        badge.layer.masksToBounds = YES;//very important
        badge.hidden = NO;
        self.wzl_badge = badge;
        [container addSubview:badge];
        [container bringSubviewToFront:badge];
        [self bringSubviewToFront:container];
    }
}

#pragma mark -- badge container & layout
/**
 *  create(or return existing) badge container view.
 *  the container is the only direct subview added by this category.
 */
- (UIView *)wzl_setupBadgeContainerWithFrame:(CGRect)frame
{
    UIView *container = self.wzl_badgeContainer;
    if (nil == container) {
        container = [[UIView alloc] initWithFrame:frame];
        //explicitly declare the background, so UINavigationBar won't apply its backdrop/tint on the badge below
        container.backgroundColor = [UIColor clearColor];
        container.opaque = NO;
        container.clipsToBounds = NO;
        //never swallow touches which are meant for the bar button item
        container.userInteractionEnabled = NO;
        self.wzl_badgeContainer = container;
        [self addSubview:container];
    }
    return container;
}

///badge frame in self's coordinate system(the container frame)
- (CGRect)wzl_badgeFrameInSuperview
{
    UIView *container = self.wzl_badgeContainer;
    return container ? container.frame : self.wzl_badge.frame;
}

///set badge frame(in self's coordinate system) and keep the label filling the container
- (void)wzl_setBadgeFrame:(CGRect)frame
{
    UIView *container = [self wzl_setupBadgeContainerWithFrame:frame];
    container.frame = frame;
    self.wzl_badge.frame = container.bounds;
}

///set badge center(in self's coordinate system) and keep the label filling the container
- (void)wzl_setBadgeCenter:(CGPoint)center
{
    UIView *container = self.wzl_badgeContainer;
    if (nil == container) {
        return;
    }
    container.center = center;
    self.wzl_badge.frame = container.bounds;
}

- (void)wzl_setBadgeHidden:(BOOL)hidden
{
    self.wzl_badge.hidden = hidden;
    self.wzl_badgeContainer.hidden = hidden;
}

#pragma mark --  other private methods
- (void)adjustLabelWidth:(UILabel *)label
{
    [label setNumberOfLines:0];
    NSString *s = label.text;
    UIFont *font = [label font];
    CGSize size = CGSizeMake(320,2000);
	CGSize labelsize;

	if (![s respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
		labelsize = [s sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
#pragma clang diagnostic pop
		
	} else {
		NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		[style setLineBreakMode:NSLineBreakByWordWrapping];
		
		labelsize = [s boundingRectWithSize:size
									options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
								 attributes:@{ NSFontAttributeName:font, NSParagraphStyleAttributeName : style}
									context:nil].size;
	}
    CGRect frame = label.frame;
	frame.size = CGSizeMake(ceilf(labelsize.width), ceilf(labelsize.height));
    [label setFrame:frame];
}

#pragma mark -- animation

//if u want to add badge animation type, follow steps bellow:
//1. go to definition of WBadgeAnimType and add new type
//2. go to category of CAAnimation+WAnimation to add new animation interface
//3. call that new interface here
- (void)beginAnimation
{
    switch(self.aniType) {
        case WBadgeAnimTypeBreathe:
            [self.wzl_badge.layer addAnimation:[CAAnimation opacityForever_Animation:1.4]
                                    forKey:kBadgeBreatheAniKey];
            break;
        case WBadgeAnimTypeShake:
            [self.wzl_badge.layer addAnimation:[CAAnimation shake_AnimationRepeatTimes:CGFLOAT_MAX
                                                                          durTimes:1
                                                                            forObj:self.wzl_badge.layer]
                                    forKey:kBadgeShakeAniKey];
            break;
        case WBadgeAnimTypeScale:
            [self.wzl_badge.layer addAnimation:[CAAnimation scaleFrom:1.4
                                                          toScale:0.6
                                                         durTimes:1
                                                              rep:MAXFLOAT]
                                    forKey:kBadgeScaleAniKey];
            break;
        case WBadgeAnimTypeBounce:
            [self.wzl_badge.layer addAnimation:[CAAnimation bounce_AnimationRepeatTimes:CGFLOAT_MAX
                                                                          durTimes:1
                                                                            forObj:self.wzl_badge.layer]
                                    forKey:kBadgeBounceAniKey];
            break;
        case WBadgeAnimTypeNone:
        default:
            break;
    }
}


- (void)removeAnimation
{
    if (self.wzl_badge) {
        [self.wzl_badge.layer removeAllAnimations];
    }
}


#pragma mark -- setter/getter
- (UILabel *)wzl_badge
{
    return objc_getAssociatedObject(self, &badgeLabelKey);
}

- (void)setWzl_badge:(UILabel *)label
{
    objc_setAssociatedObject(self, &badgeLabelKey, label, OBJC_ASSOCIATION_RETAIN);
    //externally assigned label should also be hosted by the container
    UIView *container = self.wzl_badgeContainer;
    if (container && label && label.superview != container) {
        label.frame = container.bounds;
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [container addSubview:label];
    }
}

- (UIView *)wzl_badgeContainer
{
    return objc_getAssociatedObject(self, &badgeContainerKey);
}

- (void)setWzl_badgeContainer:(UIView *)wzl_badgeContainer
{
    objc_setAssociatedObject(self, &badgeContainerKey, wzl_badgeContainer, OBJC_ASSOCIATION_RETAIN);
}

- (UIFont *)wzl_badgeFont
{
	id font = objc_getAssociatedObject(self, &badgeFontKey);
	return font == nil ? kWZLBadgeDefaultFont : font;
}

- (void)setWzl_badgeFont:(UIFont *)badgeFont
{
	objc_setAssociatedObject(self, &badgeFontKey, badgeFont, OBJC_ASSOCIATION_RETAIN);
    if (!self.wzl_badge) {
        [self wzl_badgeInit];
    }
    self.wzl_badge.font = badgeFont;
}

- (UIColor *)wzl_badgeBgColor
{
    return objc_getAssociatedObject(self, &badgeBgColorKey);
}

- (void)setWzl_badgeBgColor:(UIColor *)badgeBgColor
{
    objc_setAssociatedObject(self, &badgeBgColorKey, badgeBgColor, OBJC_ASSOCIATION_RETAIN);
    if (!self.wzl_badge) {
        [self wzl_badgeInit];
    }
    self.wzl_badge.backgroundColor = badgeBgColor;
}

- (UIColor *)wzl_badgeTextColor
{
    return objc_getAssociatedObject(self, &badgeTextColorKey);
}

- (void)setWzl_badgeTextColor:(UIColor *)badgeTextColor
{
    objc_setAssociatedObject(self, &badgeTextColorKey, badgeTextColor, OBJC_ASSOCIATION_RETAIN);
    if (!self.wzl_badge) {
        [self wzl_badgeInit];
    }
    self.wzl_badge.textColor = badgeTextColor;
}

- (WBadgeAnimType)aniType
{
    id obj = objc_getAssociatedObject(self, &badgeAniTypeKey);
    if(obj != nil && [obj isKindOfClass:[NSNumber class]])
    {
        return [obj integerValue];
    }
    else
        return WBadgeAnimTypeNone;
}

- (void)setAniType:(WBadgeAnimType)aniType
{
    NSNumber *numObj = @(aniType);
    objc_setAssociatedObject(self, &badgeAniTypeKey, numObj, OBJC_ASSOCIATION_RETAIN);
    if (!self.wzl_badge) {
        [self wzl_badgeInit];
    }
    [self removeAnimation];
    [self beginAnimation];
}

- (CGRect)wzl_badgeFrame
{
    id obj = objc_getAssociatedObject(self, &badgeFrameKey);
    if (obj != nil && [obj isKindOfClass:[NSDictionary class]] && [obj count] == 4) {
        CGFloat x = [obj[@"x"] floatValue];
        CGFloat y = [obj[@"y"] floatValue];
        CGFloat width = [obj[@"width"] floatValue];
        CGFloat height = [obj[@"height"] floatValue];
        return  CGRectMake(x, y, width, height);
    } else
        return CGRectZero;
}

- (void)setWzl_badgeFrame:(CGRect)badgeFrame
{
    NSDictionary *frameInfo = @{@"x" : @(badgeFrame.origin.x), @"y" : @(badgeFrame.origin.y),
                                @"width" : @(badgeFrame.size.width), @"height" : @(badgeFrame.size.height)};
    objc_setAssociatedObject(self, &badgeFrameKey, frameInfo, OBJC_ASSOCIATION_RETAIN);
    if (!self.wzl_badge) {
        [self wzl_badgeInit];
    }
    [self wzl_setBadgeFrame:badgeFrame];
}

- (CGPoint)wzl_badgeCenterOffset
{
    id obj = objc_getAssociatedObject(self, &badgeCenterOffsetKey);
    if (obj != nil && [obj isKindOfClass:[NSDictionary class]] && [obj count] == 2) {
        CGFloat x = [obj[@"x"] floatValue];
        CGFloat y = [obj[@"y"] floatValue];
        return CGPointMake(x, y);
    } else
        return CGPointZero;
}

- (void)setWzl_badgeCenterOffset:(CGPoint)badgeCenterOff
{
    NSDictionary *cenerInfo = @{@"x" : @(badgeCenterOff.x), @"y" : @(badgeCenterOff.y)};
    objc_setAssociatedObject(self, &badgeCenterOffsetKey, cenerInfo, OBJC_ASSOCIATION_RETAIN);
    if (!self.wzl_badge) {
        [self wzl_badgeInit];
    }
    [self wzl_setBadgeCenter:CGPointMake(CGRectGetWidth(self.frame) + 2 + badgeCenterOff.x, badgeCenterOff.y)];
}

//badgeRadiusKey

- (void)setWzl_badgeRadius:(CGFloat)badgeRadius {
    objc_setAssociatedObject(self, &badgeRadiusKey, [NSNumber numberWithFloat:badgeRadius], OBJC_ASSOCIATION_RETAIN);
    if (!self.wzl_badge) {
        [self wzl_badgeInit];
    }
}

- (CGFloat)wzl_badgeRadius {
    return [objc_getAssociatedObject(self, &badgeRadiusKey) floatValue];
}

- (NSInteger)wzl_badgeMaximumBadgeNumber {
    id obj = objc_getAssociatedObject(self, &badgeMaximumBadgeNumberKey);
    if(obj != nil && [obj isKindOfClass:[NSNumber class]])
    {
        return [obj integerValue];
    }
    else
        return kWZLBadgeDefaultMaximumBadgeNumber;
}

- (void)setWzl_badgeMaximumBadgeNumber:(NSInteger)badgeMaximumBadgeNumber {
    NSNumber *numObj = @(badgeMaximumBadgeNumber);
    objc_setAssociatedObject(self, &badgeMaximumBadgeNumberKey, numObj, OBJC_ASSOCIATION_RETAIN);
    if (!self.wzl_badge) {
        [self wzl_badgeInit];
    }
}

@end
