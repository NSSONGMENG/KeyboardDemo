//
//  ViewController.m
//  KeyboardDemo
//
//  Created by Seven on 2018/3/27.
//  Copyright © 2018年 Seven. All rights reserved.
//

#import "ViewController.h"
#import "TestCell.h"

#define kCellIdent  NSStringFromClass([TestCell class])

@interface ViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>

@property (nonatomic, strong) UITableView   * tableV;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableV = [[UITableView alloc] initWithFrame:self.view.bounds
                                           style:UITableViewStylePlain];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    [self.view addSubview:_tableV];
    _tableV.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [_tableV registerClass:[TestCell class] forCellReuseIdentifier:kCellIdent];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TestCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellIdent];
    NSString * str = [NSString stringWithFormat:@"%ld",indexPath.row];
    cell.textF.placeholder = @"请输入内容";
    cell.lab.text = str;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
