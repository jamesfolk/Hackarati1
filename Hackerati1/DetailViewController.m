//
//  DetailViewController.m
//  Hackerati1
//
//  Created by James Folk on 8/6/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import "DetailViewController.h"
#import "Summary.h"
#import "Title.h"
#import "Id.h"
#import "Image.h"
#import "ImageAttributes.h"
#import "Name.h"
#import "Rights.h"

@interface DetailViewController ()

@property (strong, nonatomic) UIPopoverController *activityPopover;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *entryUIImageView;
@property (weak, nonatomic) IBOutlet UILabel *entryTitle;
@property (weak, nonatomic) IBOutlet UILabel *entryRights;
//@property (weak, nonatomic) IBOutlet UISwitch *entryFavorite;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UITextView *entrySummary;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    
    if (_detailItem) {
//        Title *title = [_detailItem title];
//        self.title = [title label];
        
        
        self.entryUIImageView.image = [self getLargestImage];
        
        Name *name = [_detailItem name];
        self.entryTitle.text = [name label];
        self.title = [name label];
        
        Rights *rights = [_detailItem rights];
        self.entryRights.text = [rights label];
        
        Summary *summary = [_detailItem summary];
        [self.entrySummary setText:[summary label]];
        
        BOOL isFavorite = [[_detailItem favorite] boolValue];
        self.favoriteButton.selected = isFavorite;
//        [self.entryFavorite setOn:isFavorite];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    
    [_favoriteButton setImage:[UIImage imageNamed:@"favoriteOn"] forState:UIControlStateSelected];
    [_favoriteButton setImage:[UIImage imageNamed:@"favoriteOff"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage*)getLargestImage
{
    NSNumber *largestNumber = [NSNumber numberWithInt:0];
    NSSet *images = [self.detailItem image];
    NSData *data = nil;
    UIImage *image = nil;
    
    for (Image *img in images)
    {
        NSComparisonResult result = [largestNumber compare:[[img attributes] height]];
        if(result == NSOrderedAscending)
        {
            data = [[img attributes] uiimage];
        }
    }
    
    if (data)
    {
        image = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return image;
}
                                    
- (IBAction)share:(id)sender
{
    NSString *title = [[self.detailItem title] label];
    NSString *summary = [[self.detailItem summary] label];
    BOOL isFavorite = [[self.detailItem favorite] boolValue];
    NSString *favoriteString = @"";
    if(isFavorite)
        favoriteString = @"**One of my favorites**\n\n";
    
    NSString *text = [[NSString alloc] initWithFormat:@"%@\n%@\n\n%@\n\n", favoriteString, title, summary];
    NSURL *url = [NSURL URLWithString:[[self.detailItem id] label]];
    UIImage *image = [self getLargestImage];
    UIActivityViewController *controller = nil;
    
    if (image)
    {
        controller =
        [[UIActivityViewController alloc]
         initWithActivityItems:@[image, text, url]
         applicationActivities:nil];
    }
    else
    {
        controller =
        [[UIActivityViewController alloc]
         initWithActivityItems:@[text, url]
         applicationActivities:nil];
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [self presentViewController:controller animated:YES completion:nil];
    }
    else
    {
        UIView *targetView = (UIView *)[self.shareButton performSelector:@selector(view)];
        CGRect rect = targetView.frame;
        rect.origin.y = rect.origin.y + rect.size.height;
        
        if (![self.activityPopover isPopoverVisible])
        {
            self.activityPopover = [[UIPopoverController alloc] initWithContentViewController:controller];
            [self.activityPopover presentPopoverFromRect:rect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
        else
        {
            //Dismiss if the button is tapped while pop over is visible
            [self.activityPopover dismissPopoverAnimated:YES];
        }
    }
}

- (IBAction)favoriteTouched:(id)sender
{
    UIButton *button = sender;
    button.selected = !button.selected;
    
    [_detailItem setFavorite:[NSNumber numberWithBool:button.selected]];
}

@end
