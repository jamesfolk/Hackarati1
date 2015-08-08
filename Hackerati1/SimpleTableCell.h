//
//  SimpleTableCell.h
//  Hackerati1
//
//  Created by James Folk on 8/7/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entry.h"

@interface SimpleTableCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
