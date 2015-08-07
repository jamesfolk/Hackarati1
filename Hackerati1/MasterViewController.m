//
//  MasterViewController.m
//  Hackerati1
//
//  Created by James Folk on 8/6/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "Image.h"
#import "Uri.h"
#import "Name.h"
#import "ImageAttributes.h"
#import "ArtistAttributes.h"
#import "LinkAttributes.h"
#import "Price.h"
#import "Title.h"
#import "ReleaseDate.h"
#import "ReleaseDateAttributes.h"
#import "Summary.h"
#import "Entry.h"
#import "Rights.h"
#import "Feed.h"
#import "Updated.h"
#import "Artist.h"
#import "PriceAttributes.h"
#import "ContentTypeAttributes.h"
#import "CategoryAttributes.h"
#import "Author.h"
#import "Link.h"
#import "Id.h"
#import "IdAttributes.h"
#import "Icon.h"
#import "ContentType.h"
#import "Categary.h"

@interface MasterViewController ()

@property (strong, nonatomic) Feed *currentFeed;

@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    
    //Load the default file...
    NSString *defaultsPath = [[NSBundle mainBundle] pathForResource:@"DefaultValues" ofType:@"plist"];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfFile:defaultsPath];
    
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
    if(standardDefaults)
    {
        [standardDefaults registerDefaults:appDefaults];
        [standardDefaults synchronize];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSString *url = [[NSUserDefaults standardUserDefaults] stringForKey:@"itunesLink"];
        
        NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString:url]];
        [self performSelectorOnMainThread:@selector(fetchJSON:) withObject:data waitUntilDone:YES];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender {
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
        
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
        
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *object = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
            
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"timeStamp"] description];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timeStamp" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Master"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
	NSError *error = nil;
	if (![self.fetchedResultsController performFetch:&error]) {
	     // Replace this implementation with code to handle the error appropriately.
	     // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
	    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	    abort();
	}
    
    return _fetchedResultsController;
}    

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}

/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
 */

#pragma mark - Personalized Functions

- (id)getValue:(id)entry key:(NSString *)theKey
{
    id temp = [entry objectForKey:theKey];
    NSAssert(temp, @"Error in the json schema.");
    return temp;
}

- (Author *)buildAuthor:(id)author
{
    NSAssert(author, @"author is null, possibly json's schema has changed?");
    
    Author *authorObject = [NSEntityDescription insertNewObjectForEntityForName:@"Author" inManagedObjectContext:self.managedObjectContext];
    
    Name *nameObject = [NSEntityDescription insertNewObjectForEntityForName:@"Name" inManagedObjectContext:self.managedObjectContext];
    id name = [self getValue:author key:@"name"];
    NSString *label = [self getValue:name key:@"label"];
    [nameObject setLabel:[[NSString alloc] initWithString:label]];
    
    
    Uri *uriObject = [NSEntityDescription insertNewObjectForEntityForName:@"Uri" inManagedObjectContext:self.managedObjectContext];
    id uri = [self getValue:author key:@"uri"];
    label = [self getValue:uri key:@"label"];
    [uriObject setLabel:[[NSString alloc] initWithString:label]];
    
    [authorObject setName:nameObject];
    [authorObject setUri:uriObject];
    
    return authorObject;
}

- (NSSet *)buildEntry:(id)entries
{
    NSAssert(entries, @"entries are null, possibly json's schema has changed?");
    
    unsigned long capacity = [entries count];
    NSMutableSet *entrySet = [[NSMutableSet alloc] initWithCapacity:capacity];
    id temp = nil;
    
    for (NSDictionary *aEntry in entries)
    {
        Entry *entryObject = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:self.managedObjectContext];
        
#pragma mark build Entry:name
        Name *nameObject = [NSEntityDescription insertNewObjectForEntityForName:@"Name" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"im:name"];
        NSString *label = [self getValue:temp key:@"label"];
        [nameObject setLabel:[[NSString alloc] initWithString:label]];
        [entryObject setName:nameObject];
        
#pragma mark build Entry:image
        id images = [self getValue:aEntry key:@"im:image"];
        capacity = [temp count];
        NSMutableSet *imageSet = [[NSMutableSet alloc] initWithCapacity:capacity];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        for (NSDictionary *img in images)
        {
            Image *imageObject = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:self.managedObjectContext];
            label = [self getValue:img key:@"label"];
            [imageObject setLabel:[[NSString alloc] initWithString:label]];
            
            ImageAttributes *imageAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"ImageAttributes" inManagedObjectContext:self.managedObjectContext];
            id attributes = [self getValue:img key:@"attributes"];
            
            if(nil != (temp = [attributes objectForKey:@"height"]))
            {
                NSString *height = [self getValue:attributes key:@"height"];
                [imageAttributesObject setHeight:[f numberFromString:height]];
            }
            [imageObject setAttributes:imageAttributesObject];
            
            [imageSet addObject:imageObject];
        }
        [entryObject setImage:imageSet];
        
#pragma mark build Entry:summary
        Summary *summaryObject = [NSEntityDescription insertNewObjectForEntityForName:@"Summary" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"summary"];
        label = [self getValue:temp key:@"label"];
        [summaryObject setLabel:[[NSString alloc] initWithString:label]];
        [entryObject setSummary:summaryObject];
        
#pragma mark build Entry:price
        Price *priceObject = [NSEntityDescription insertNewObjectForEntityForName:@"Price" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"im:price"];
        label = [self getValue:temp key:@"label"];
        [priceObject setLabel:[[NSString alloc] initWithString:label]];
        
        PriceAttributes *priceAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"PriceAttributes" inManagedObjectContext:self.managedObjectContext];
        id attributes = [self getValue:temp key:@"attributes"];
        
        if(nil != (temp = [attributes objectForKey:@"amount"]))
        {
            NSString *amount = [self getValue:attributes key:@"amount"];
            [priceAttributesObject setAmount:[f numberFromString:amount]];
        }
        
        if(nil != (temp = [attributes objectForKey:@"currency"]))
        {
            NSString *currency = [self getValue:attributes key:@"currency"];
            [priceAttributesObject setCurrency:[[NSString alloc] initWithString:currency]];
        }
        [priceObject setAttributes:priceAttributesObject];
        [entryObject setPrice:priceObject];
        
#pragma mark build Entry:contentType
        ContentType *contentTypeObject = [NSEntityDescription insertNewObjectForEntityForName:@"ContentType" inManagedObjectContext:self.managedObjectContext];
        ContentTypeAttributes *contentTypeAttributes = [NSEntityDescription insertNewObjectForEntityForName:@"ContentTypeAttributes" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"im:contentType"];
        attributes = [self getValue:temp key:@"attributes"];
        if(nil != (temp = [attributes objectForKey:@"term"]))
        {
            NSString *term = [self getValue:attributes key:@"term"];
            [contentTypeAttributes setTerm:[[NSString alloc] initWithString:term]];
        }
        if(nil != (temp = [attributes objectForKey:@"label"]))
        {
            NSString *label = [self getValue:attributes key:@"label"];
            [contentTypeAttributes setLabel:[[NSString alloc] initWithString:label]];
        }
        [contentTypeObject setAttributes:contentTypeAttributes];
        [entryObject setContentType:contentTypeObject];
        
#pragma mark build Entry:rights
        Rights *rightsObject = [NSEntityDescription insertNewObjectForEntityForName:@"Rights" inManagedObjectContext:self.managedObjectContext];
        
        temp = [self getValue:aEntry key:@"rights"];
        label = [self getValue:temp key:@"label"];
        [rightsObject setLabel:[[NSString alloc] initWithString:label]];
        [entryObject setRights:rightsObject];
        
#pragma mark build Entry:title
        Title *titleObject = [NSEntityDescription insertNewObjectForEntityForName:@"Title" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"title"];
        label = [self getValue:temp key:@"label"];
        [titleObject setLabel:[[NSString alloc] initWithString:label]];
        [entryObject setTitle:titleObject];
        
#pragma mark build Entry:link
        Link *linkObject = [NSEntityDescription insertNewObjectForEntityForName:@"Link" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"link"];
        attributes = [self getValue:temp key:@"attributes"];
        LinkAttributes *linkAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"LinkAttributes" inManagedObjectContext:self.managedObjectContext];
        
        if(nil != (temp = [attributes objectForKey:@"rel"]))
        {
            NSString *rel = [self getValue:attributes key:@"rel"];
            [linkAttributesObject setRel:[[NSString alloc] initWithString:rel]];
        }
        
        if(nil != (temp = [attributes objectForKey:@"type"]))
        {
            NSString *type = [self getValue:attributes key:@"type"];
            [linkAttributesObject setType:[[NSString alloc] initWithString:type]];
        }
        
        if(nil != (temp = [attributes objectForKey:@"href"]))
        {
            NSString *href = [self getValue:attributes key:@"href"];
            [linkAttributesObject setHref:[[NSString alloc] initWithString:href]];
        }
        
        [linkObject setAttributes:linkAttributesObject];
        [entryObject setLink:linkObject];
        
#pragma mark build Entry:id
        Id *idObject = [NSEntityDescription insertNewObjectForEntityForName:@"Id" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"id"];
        label = [self getValue:temp key:@"label"];
        [idObject setLabel:[[NSString alloc] initWithString:label]];
        
        IdAttributes *idAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"IdAttributes" inManagedObjectContext:self.managedObjectContext];
        attributes = [self getValue:temp key:@"attributes"];
        
        if(nil != (temp = [attributes objectForKey:@"im:id"]))
        {
            NSString *_id = [self getValue:attributes key:@"im:id"];
            [idAttributesObject setId:[[NSString alloc] initWithString:_id]];
        }
        
        if(nil != (temp = [attributes objectForKey:@"type"]))
        {
            NSString *bundleId = [self getValue:attributes key:@"im:bundleId"];
            [idAttributesObject setBundleId:[[NSString alloc] initWithString:bundleId]];
        }
        
        [idObject setAttributes:idAttributesObject];
        [entryObject setId:idObject];
        
#pragma mark build Entry:artist
        Artist *artistObject = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"im:artist"];
        
        label = [self getValue:temp key:@"label"];
        [artistObject setLabel:[[NSString alloc] initWithString:label]];
        
        ArtistAttributes *artistAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"ArtistAttributes" inManagedObjectContext:self.managedObjectContext];
        attributes = [self getValue:temp key:@"attributes"];
        
        if(nil != (temp = [attributes objectForKey:@"href"]))
        {
            NSString *href = [self getValue:attributes key:@"href"];
            [artistAttributesObject setHref:[[NSString alloc] initWithString:href]];
        }
        
        [artistObject setAttributes:artistAttributesObject];
        [entryObject setArtist:artistObject];
        
#pragma mark build Entry:category
        Categary *categaryObject = [NSEntityDescription insertNewObjectForEntityForName:@"Categary" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"category"];
        
        CategoryAttributes *categoryAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"CategoryAttributes" inManagedObjectContext:self.managedObjectContext];
        attributes = [self getValue:temp key:@"attributes"];
        
        if(nil != (temp = [attributes objectForKey:@"im:id"]))
        {
            NSString *_id = [self getValue:attributes key:@"im:id"];
            [categoryAttributesObject setId:[f numberFromString:_id]];
        }
        
        if(nil != (temp = [attributes objectForKey:@"term"]))
        {
            NSString *term = [self getValue:attributes key:@"term"];
            [categoryAttributesObject setTerm:[[NSString alloc] initWithString:term]];
        }
        
        if(nil != (temp = [attributes objectForKey:@"scheme"]))
        {
            NSString *scheme = [self getValue:attributes key:@"scheme"];
            [categoryAttributesObject setScheme:[[NSString alloc] initWithString:scheme]];
        }
        
        if(nil != (temp = [attributes objectForKey:@"label"]))
        {
            NSString *label = [self getValue:attributes key:@"label"];
            [categoryAttributesObject setLabel:[[NSString alloc] initWithString:label]];
        }
        
        [categaryObject setAttributes:categoryAttributesObject];
        [entryObject setCategory:categaryObject];
        
#pragma mark build Entry:releaseDate
        ReleaseDate *releaseDateObject = [NSEntityDescription insertNewObjectForEntityForName:@"ReleaseDate" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"im:releaseDate"];
        label = [self getValue:temp key:@"label"];
        [releaseDateObject setLabel:[[NSString alloc] initWithString:label]];
        
        ReleaseDateAttributes *releaseDateAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"ReleaseDateAttributes" inManagedObjectContext:self.managedObjectContext];
        attributes = [self getValue:temp key:@"attributes"];
        
        if(nil != (temp = [attributes objectForKey:@"label"]))
        {
            NSString *label = [self getValue:attributes key:@"label"];
            [releaseDateAttributesObject setLabel:[[NSString alloc] initWithString:label]];
        }
        
        [releaseDateObject setAttributes:releaseDateAttributesObject];
        [entryObject setReleaseDate:releaseDateObject];
        
        
        [entrySet addObject:entryObject];
    }
    
    
    return entrySet;
}

- (Updated *)buildUpdated:(id)updated
{
    NSAssert(updated, @"updated is null, possibly json's schema has changed?");
    
    Updated *updatedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Updated" inManagedObjectContext:self.managedObjectContext];
    
    NSString *temp = [self getValue:updated key:@"label"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"%Y-%m-%d'T'%H:%M:%S%z"];
    NSDate *date = [[NSDate alloc] init];
    date = [dateFormatter dateFromString: temp];
    [updatedObject setLabel:date];
    
    return updatedObject;
}

- (Rights *)buildRights:(id)rights
{
    NSAssert(rights, @"rights is null, possibly json's schema has changed?");
    
    Rights *rightsObject = [NSEntityDescription insertNewObjectForEntityForName:@"Rights" inManagedObjectContext:self.managedObjectContext];
    
    NSString *label = [self getValue:rights key:@"label"];
    [rightsObject setLabel:[[NSString alloc] initWithString:label]];
    
    return rightsObject;
}

- (Title *)buildTitle:(id)title
{
    NSAssert(title, @"title is null, possibly json's schema has changed?");
    
    Title *titleObject = [NSEntityDescription insertNewObjectForEntityForName:@"Title" inManagedObjectContext:self.managedObjectContext];
    
    NSString *label = [self getValue:title key:@"label"];
    [titleObject setLabel:[[NSString alloc] initWithString:label]];
    
    return titleObject;
}

- (Icon *)buildIcon:(id)icon
{
    NSAssert(icon, @"icon is null, possibly json's schema has changed?");
    
    Icon *iconObject = [NSEntityDescription insertNewObjectForEntityForName:@"Icon" inManagedObjectContext:self.managedObjectContext];
    
    NSString *label = [self getValue:icon key:@"label"];
    [iconObject setLabel:[[NSString alloc] initWithString:label]];
    
    return iconObject;
}

- (NSSet *)buildLink:(id)links
{
    NSAssert(link, @"link is null, possibly json's schema has changed?");
    
    unsigned long capacity = [links count];
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:capacity];
    
    for (NSDictionary *aLink in links)
    {
        id temp = nil;
        Link *linkObject = [NSEntityDescription insertNewObjectForEntityForName:@"Link" inManagedObjectContext:self.managedObjectContext];
        LinkAttributes *linkAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"LinkAttributes" inManagedObjectContext:self.managedObjectContext];
        
        id attributes = [self getValue:aLink key:@"attributes"];
        
        if(nil != (temp = [attributes objectForKey:@"rel"]))
        {
            NSString *rel = [self getValue:attributes key:@"rel"];
            [linkAttributesObject setRel:[[NSString alloc] initWithString:rel]];
        }
        
        if(nil != (temp = [attributes objectForKey:@"type"]))
        {
            NSString *type = [self getValue:attributes key:@"type"];
            [linkAttributesObject setRel:[[NSString alloc] initWithString:type]];
        }
        
        if(nil != (temp = [attributes objectForKey:@"href"]))
        {
            NSString *href = [self getValue:attributes key:@"href"];
            [linkAttributesObject setRel:[[NSString alloc] initWithString:href]];
        }
        [linkObject setAttributes:linkAttributesObject];
        
        [set addObject:linkObject];
    }
    
    return set;
}

- (Id *)buildId:(id)_id
{
    NSAssert(_id, @"id is null, possibly json's schema has changed?");
    
    Id *_idObject = [NSEntityDescription insertNewObjectForEntityForName:@"Id" inManagedObjectContext:self.managedObjectContext];
    
    NSString *label = [self getValue:_id key:@"label"];
    [_idObject setLabel:[[NSString alloc] initWithString:label]];
    
    return _idObject;
}

- (Feed*)buildFeed:(id)feed
{
    NSAssert(feed, @"feed is null, possibly json's schema has changed?");
    
    Feed *feedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                               inManagedObjectContext:self.managedObjectContext];
    
    [feedObject setAuthor:[self buildAuthor:[feed objectForKey:@"author"]]];
    [feedObject setEntry:[self buildEntry:[feed objectForKey:@"entry"]]];
    [feedObject setUpdated:[self buildUpdated:[feed objectForKey:@"updated"]]];
    [feedObject setRights:[self buildRights:[feed objectForKey:@"rights"]]];
    [feedObject setTitle:[self buildTitle:[feed objectForKey:@"title"]]];
    [feedObject setIcon:[self buildIcon:[feed objectForKey:@"icon"]]];
    [feedObject setLink:[self buildLink:[feed objectForKey:@"link"]]];
    [feedObject setId:[self buildId:[feed objectForKey:@"id"]]];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    return feedObject;
}

-(void)update:(NSData*)responseData
{
    if(responseData != nil)
    {
        NSError* error;
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        NSDictionary *feed = [self getValue:json key:@"feed"];
        id updated = [self getValue:feed key:@"updated"];
        NSString *dateString = [self getValue:updated key:@"label"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"%Y-%m-%d'T'%H:%M:%S%z"];
        NSDate *lastUpdated = [[NSDate alloc] init];
        lastUpdated = [dateFormatter dateFromString:dateString];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Feed" inManagedObjectContext:self.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        BOOL buildFeed = YES;
        NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if ([array count] > 0)
        {
            buildFeed = NO;
            Feed *savedFeed = [array objectAtIndex:0];
            Updated *updated = [savedFeed updated];
            NSDate *lastSavedUpdated = [updated label];
            
            //The database updated date is older than the json updated date
            if ([lastSavedUpdated compare:lastUpdated] == NSOrderedAscending) {
                [self.managedObjectContext deleteObject:savedFeed];
                buildFeed = YES;
            } else if ([lastSavedUpdated compare:lastUpdated] == NSOrderedDescending) {
                NSAssert(NO, @"Something is wrong, the database date is newer than the recently downloaded date");
            } else {
                NSLog(@"updated dates are the same");
                _currentFeed = savedFeed;
            }
        }
        
        if (buildFeed)
        {
            _currentFeed = [self buildFeed:feed];
        }
    }
}


- (void)fetchJSON:(NSData *)responseData
{
    [self update:responseData];    
}

@end
