//
//  SimpleTableCell.m
//  Hackerati1
//
//  Created by James Folk on 8/7/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import "SimpleTableCell.h"

@implementation SimpleTableCell

@synthesize imageView;
@synthesize titleLabel;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
