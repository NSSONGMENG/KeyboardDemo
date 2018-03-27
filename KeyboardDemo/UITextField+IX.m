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

static char scrollViewKey;
static char originYKey;
static char originOffsetYKey;

@interface UITextField ()
@property (nonatomic, assign) CGFloat    originY;
@property (nonatomic, assign) CGFloat    originOffsetY;
@property (nonatomic, weak) UIScrollView    * scrollV;
@end
@implementation UITextField (IX)

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

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
                                             selector:@selector(keyboardWillHide)
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
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    return [self ix_initWithFrame:frame];
}

- (BOOL)ix_becomeFirstResponder
{
    self.originY = [self convertPoint:self.bounds.origin toView:[UIApplication sharedApplication].keyWindow].y;
    return [self ix_becomeFirstResponder];
}

- (BOOL)ix_resignFirstResponder
{
    self.originY = 0.f;
    return [self ix_resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notify
{
    if (self.originY <= 0) {
        return;
    }

    NSDictionary    * dic = notify.userInfo;
    CGFloat keyboardH = [dic[@"UIKeyboardBoundsUserInfoKey"] CGRectValue].size.height;
    CGFloat selfH = self.frame.size.height;
   
    if ([UIScreen mainScreen].bounds.size.height - keyboardH > self.originY + 20 + selfH) {
        NSLog(@"键盘不会被遮挡");
    } else {
        NSLog(@"键盘可能会被遮挡");
        UIView * aimV = self.superview;
        int  i = 0;
        while (![aimV isKindOfClass:[UIScrollView class]] && i < 6) {
            aimV = aimV.superview;
        }
        
        if ([aimV isKindOfClass:[UIScrollView class]]) {
            UIScrollView * scrollView = (UIScrollView *)aimV;
            
            CGFloat aimY = [UIScreen mainScreen].bounds.size.height - keyboardH - 20 - selfH;
            self.originOffsetY = self.originY - aimY;
            [scrollView setContentOffset:CGPointMake(0, scrollView.contentOffset.y + self.originOffsetY) animated:YES];
        } else {
            NSLog(@"该text field之上6层未找到scrollView,挪不动啊@~@");
        }
    }
}

- (void)keyboardWillHide
{
    if (self.originY > 0) {
        self.originY = 0.f;
        self.originOffsetY = 0.f;
        if (self.scrollV) {
            [self.scrollV setContentOffset:CGPointMake(0, self.scrollV.contentOffset.y - self.originOffsetY)
                                  animated:YES];
        }
    }
}

#pragma mark -
#pragma mark -


- (void)setScrollV:(UIScrollView *)scrollV
{
    objc_setAssociatedObject(self, &scrollViewKey, scrollV, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollView *)scrollV {
    return objc_getAssociatedObject(self, &scrollViewKey);
}

- (void)setOriginY:(CGFloat)originY
{
    objc_setAssociatedObject(self, &originYKey, @(originY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)originY
{
    return [objc_getAssociatedObject(self, &originYKey) floatValue];
}

- (void)setOriginOffsetY:(CGFloat)originOffsetY
{
    objc_setAssociatedObject(self, &originOffsetYKey, @(originOffsetY), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)originOffsetY
{
    return [objc_getAssociatedObject(self, &originOffsetYKey) floatValue];
}

@end
