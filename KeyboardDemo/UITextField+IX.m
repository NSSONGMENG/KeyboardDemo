//
//  UITextField+IX.m
//  IXBTC
//
//  Created by Seven on 2018/3/27.
//  Copyright © 2018年 IX CAPITAL MARKETS(HK) LIMITED. All rights reserved.
//

#import "UITextField+IX.h"
#import "IXHookUtility.h"
#import <objc/runtime.h>

static char originYKey;
static char animatedKey;
static char targetViewKey;
static char isSelfKey;

#define kOffset 10

@interface UITextField ()
@property (nonatomic, assign) CGFloat   originY;    //targetV位置
@property (nonatomic, assign) BOOL      animated;   //记录是否发生过移动
@property (nonatomic, assign) BOOL      isSelf;
@end
@implementation UITextField (IX)


+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        SEL originalInit  = @selector(init);
        SEL swizzledInit = @selector(ix_init);
        
        [IXHookUtility swizzlingClass:class
                     originalSelector:originalInit
                     swizzledSelector:swizzledInit];

        SEL originalInitF  = @selector(initWithFrame:);
        SEL swizzledInitF = @selector(ix_initWithFrame:);
        [IXHookUtility swizzlingClass:class
                     originalSelector:originalInitF
                     swizzledSelector:swizzledInitF];
        
        SEL originalResign = @selector(resignFirstResponder);
        SEL swizzledResign = @selector(ix_resignFirstResponder);

        [IXHookUtility swizzlingClass:class
                     originalSelector:originalResign
                     swizzledSelector:swizzledResign];
        
        SEL originalBec = @selector(becomeFirstResponder);
        SEL swizzledBec = @selector(ix_becomeFirstResponder);
        
        [IXHookUtility swizzlingClass:class
                     originalSelector:originalBec
                     swizzledSelector:swizzledBec];
    });
}

- (instancetype)ix_init
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    return [self ix_init];
}

- (instancetype)ix_initWithFrame:(CGRect)frame
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    return [self ix_initWithFrame:frame];
}

- (BOOL)ix_becomeFirstResponder
{
    self.isSelf = YES;
    return [self ix_becomeFirstResponder];
}

- (BOOL)ix_resignFirstResponder
{
    self.isSelf = NO;
    return [self ix_resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notify
{
    if (!self.targetV || !self.isSelf) {
        return;
    }

    NSDictionary    * dic = notify.userInfo;
    CGFloat keyboardH = [dic[@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    CGFloat selfH = self.frame.size.height;
    CGFloat selfPos = [self convertPoint:self.bounds.origin
                                  toView:[UIApplication sharedApplication].keyWindow].y;
    
    if ([UIScreen mainScreen].bounds.size.height - keyboardH > selfPos + kOffset + selfH) {
        NSLog(@"键盘不会被遮挡");
        if ([self.targetV isKindOfClass:[UIScrollView class]]) {
            CGFloat offsetY = selfPos - ([UIScreen mainScreen].bounds.size.height - keyboardH - kOffset - selfH);
            UIScrollView    * scrollV = (UIScrollView *)self.targetV;
            if (scrollV.contentOffset.y <= 0) {
                return;
            }
            CGFloat y = scrollV.contentOffset.y + offsetY;
            [scrollV setContentOffset:CGPointMake(0, y) animated:YES];
        }
    } else {
        NSLog(@"键盘可能会被遮挡");
        
        if (self.targetV) {
            
            CGFloat offsetY = selfPos - ([UIScreen mainScreen].bounds.size.height - keyboardH - kOffset - selfH);
            if ([self.targetV isKindOfClass:[UIScrollView class]]) {
                UIScrollView    * scrollV = (UIScrollView *)self.targetV;
                CGFloat y = scrollV.contentOffset.y + offsetY;
                [scrollV setContentOffset:CGPointMake(0, y) animated:YES];
            } else {
                
                CGRect  frame = self.targetV.frame;
                CGFloat time = [dic[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
                frame.origin.y -= offsetY;
                
                [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.targetV.frame = frame;
                } completion:nil];
                
                self.animated = YES;
            }
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notify
{
    if (self.animated) {
        self.animated = NO;
        if ([self.targetV isKindOfClass:[UIScrollView class]]) {
            UIScrollView * scrollV = (UIScrollView *)self.targetV;
            [scrollV setContentOffset:CGPointMake(scrollV.contentOffset.x, self.originY) animated:YES];
        } else {
            NSDictionary    * dic = notify.userInfo;
            CGFloat time = [dic[@"UIKeyboardAnimationDurationUserInfoKey"] floatValue];
            CGRect  frame = self.targetV.frame;
            frame.origin.y = self.originY;
            
            [UIView animateWithDuration:time delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.targetV.frame = frame;
            } completion:nil];
        }
    }
    
    self.originY = 0.f;
    self.isSelf = NO;
}

#pragma mark -
#pragma mark -

- (void)setOriginY:(CGFloat)originY
{
    objc_setAssociatedObject(self, &originYKey, @(originY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)originY
{
    return [objc_getAssociatedObject(self, &originYKey) floatValue];
}

- (void)setAnimated:(BOOL)animated
{
    objc_setAssociatedObject(self, &animatedKey, @(animated), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)animated
{
    return [objc_getAssociatedObject(self, &animatedKey) boolValue];
}

- (void)setIsSelf:(BOOL)isSelf
{
    objc_setAssociatedObject(self, &isSelfKey, @(isSelf), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)isSelf
{
    return [objc_getAssociatedObject(self, &isSelfKey) boolValue];
}

- (void)setTargetV:(UIView *)targetV
{
    if (targetV) {
        objc_setAssociatedObject(self, &targetViewKey, targetV , OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.originY = targetV.frame.origin.y;
    }
}

- (UIView *)targetV
{
    return objc_getAssociatedObject(self, &targetViewKey);
}

@end
