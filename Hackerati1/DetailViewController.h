//
//  DetailViewController.h
//  Hackerati1
//
//  Created by James Folk on 8/6/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entry.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Entry *detailItem;
@property (strong, nonatomic) NSManagedObjectContext *context;

- (IBAction)share:(id)sender;

@end

