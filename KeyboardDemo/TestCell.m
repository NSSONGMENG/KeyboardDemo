//
//  TestCell.m
//  KeyboardDemo
//
//  Created by Seven on 2018/3/27.
//  Copyright © 2018年 Seven. All rights reserved.
//

#import "TestCell.h"

@implementation TestCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createSubview];
    }
    return self;
}

- (void)createSubview
{
    _textF = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 200, 30)];
//    _textF = [UITextField new];
//    _textF.frame = CGRectMake(100, 10, 200, 30);
    _textF.borderStyle = UITextBorderStyleRoundedRect;
    [self.contentView addSubview:_textF];
    
    _lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 80, 30)];
    [self.contentView addSubview:_lab];
}

@end
