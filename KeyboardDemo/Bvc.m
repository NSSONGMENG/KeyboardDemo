//
//  Bvc.m
//  KeyboardDemo
//
//  Created by Seven on 2018/4/10.
//  Copyright © 2018年 Seven. All rights reserved.
//

#import "Bvc.h"
#import "UITextField+IX.h"

@interface Bvc ()

@end


@implementation Bvc

- (void)dealloc
{
    NSLog(@" -- %s --",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UIView  * view = [[UIView alloc] initWithFrame:self.view.bounds];
    view.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:view];
    
    UITextField * tf1 = [[UITextField alloc] initWithFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height - 100, 200, 30)];
    tf1.borderStyle = UITextBorderStyleRoundedRect;
    tf1.targetV = view;
    [view addSubview:tf1];
    
    UITextField * tf2 = [[UITextField alloc] initWithFrame:CGRectMake(20, [UIScreen mainScreen].bounds.size.height - 150, 200, 30)];
    tf2.borderStyle = UITextBorderStyleRoundedRect;
    tf2.targetV = view;
    [view addSubview:tf2];
    
    
    UITapGestureRecognizer  * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [view addGestureRecognizer:tap];
}

- (void)tap
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
