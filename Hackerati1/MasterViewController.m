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
    
    Name *name = [NSEntityDescription insertNewObjectForEntityForName:@"Name" inManagedObjectContext:self.managedObjectContext];
    id temp = [self getValue:author key:@"name"];
    name.label = [[NSString alloc] initWithString:[self getValue:temp key:@"label"]];
    
    Uri *uri = [NSEntityDescription insertNewObjectForEntityForName:@"Uri" inManagedObjectContext:self.managedObjectContext];
    temp = [self getValue:author key:@"uri"];
    uri.label = [[NSString alloc] initWithString:[self getValue:temp key:@"label"]];
    
    authorObject.name = name;
    authorObject.uri = uri;
    
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
        
        
        Name *name = [NSEntityDescription insertNewObjectForEntityForName:@"Name" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"im:name"];
        name.label = [self getValue:temp key:@"label"];
        entryObject.name = name;
        
        id images = [self getValue:aEntry key:@"im:image"];
        capacity = [temp count];
        NSMutableSet *imageSet = [[NSMutableSet alloc] initWithCapacity:capacity];
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        f.numberStyle = NSNumberFormatterDecimalStyle;
        for (NSDictionary *img in images)
        {
            Image *imageObject = [NSEntityDescription insertNewObjectForEntityForName:@"Image" inManagedObjectContext:self.managedObjectContext];
            imageObject.label = [self getValue:img key:@"label"];
            
            ImageAttributes *imageAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"ImageAttributes" inManagedObjectContext:self.managedObjectContext];
            temp = [self getValue:img key:@"attributes"];
            NSString *height = [self getValue:temp key:@"height"];
            imageAttributesObject.height = [f numberFromString:height];
            
            imageObject.attributes = imageAttributesObject;
            
            [imageSet addObject:imageObject];
        }
        entryObject.image = imageSet;
        
        Summary *summaryObject = [NSEntityDescription insertNewObjectForEntityForName:@"Summary" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"summary"];
        summaryObject.label = [self getValue:temp key:@"label"];
        entryObject.summary = summaryObject;
        
        Price *priceObject = [NSEntityDescription insertNewObjectForEntityForName:@"Price" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"im:price"];
        priceObject.label = [self getValue:temp key:@"label"];
        
        PriceAttributes *priceAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"PriceAttributes" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:temp key:@"attributes"];
        NSString *amount = [self getValue:temp key:@"amount"];
        priceAttributesObject.amount = [f numberFromString:amount];
        priceAttributesObject.currency = [self getValue:temp key:@"currency"];
        priceObject.attributes = priceAttributesObject;
        entryObject.price = priceObject;
        
        ContentType *contentTypeObject = [NSEntityDescription insertNewObjectForEntityForName:@"ContentType" inManagedObjectContext:self.managedObjectContext];
        ContentTypeAttributes *contentTypeAttributes = [NSEntityDescription insertNewObjectForEntityForName:@"ContentTypeAttributes" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"im:contentType"];
        temp = [self getValue:temp key:@"attributes"];
        contentTypeAttributes.term = [self getValue:temp key:@"term"];
        contentTypeAttributes.label = [self getValue:temp key:@"label"];
        contentTypeObject.attributes = contentTypeAttributes;
        entryObject.contentType = contentTypeObject;
        
        Rights *rightsObject = [NSEntityDescription insertNewObjectForEntityForName:@"Rights" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"rights"];
        rightsObject.label = [self getValue:temp key:@"label"];
        entryObject.rights = rightsObject;
        
        Title *titleObject = [NSEntityDescription insertNewObjectForEntityForName:@"Title" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"title"];
        titleObject.label = [self getValue:temp key:@"label"];
        entryObject.title = titleObject;
        
        
        Link *linkObject = [NSEntityDescription insertNewObjectForEntityForName:@"Link" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"link"];
        temp = [self getValue:temp key:@"attributes"];
        LinkAttributes *linkAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"LinkAttributes" inManagedObjectContext:self.managedObjectContext];
        linkAttributesObject.rel = [self getValue:temp key:@"rel"];
        linkAttributesObject.type = [self getValue:temp key:@"type"];
        linkAttributesObject.href = [self getValue:temp key:@"href"];
        linkObject.attributes = linkAttributesObject;
        entryObject.link = linkObject;
        
        Id *idObject = [NSEntityDescription insertNewObjectForEntityForName:@"Id" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"id"];
        idObject.label = [self getValue:temp key:@"label"];
        IdAttributes *idAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"IdAttributes" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:temp key:@"attributes"];
        idAttributesObject.id = [self getValue:temp key:@"im:id"];
        idAttributesObject.bundleId = [self getValue:temp key:@"im:bundleId"];
        idObject.attributes = idAttributesObject;
        entryObject.id = idObject;
        
        Artist *artistObject = [NSEntityDescription insertNewObjectForEntityForName:@"Artist" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"im:artist"];
        artistObject.label = [self getValue:temp key:@"label"];
        ArtistAttributes *artistAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"ArtistAttributes" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:temp key:@"attributes"];
        artistAttributesObject.href = [self getValue:temp key:@"href"];
        artistObject.attributes = artistAttributesObject;
        entryObject.artist = artistObject;
        
        Categary *categaryObject = [NSEntityDescription insertNewObjectForEntityForName:@"Categary" inManagedObjectContext:self.managedObjectContext];
        CategoryAttributes *categoryAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"CategoryAttributes" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"category"];
        temp = [self getValue:temp key:@"attributes"];
        NSString *idValue = [self getValue:temp key:@"im:id"];
        categoryAttributesObject.id = [f numberFromString:idValue];
        categoryAttributesObject.term = [self getValue:temp key:@"term"];
        categoryAttributesObject.scheme = [self getValue:temp key:@"scheme"];
        categoryAttributesObject.label = [self getValue:temp key:@"label"];
        categaryObject.attributes = categoryAttributesObject;
        entryObject.category = categaryObject;
        
        ReleaseDate *releaseDateObject = [NSEntityDescription insertNewObjectForEntityForName:@"ReleaseDate" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:aEntry key:@"im:releaseDate"];
        releaseDateObject.label = [self getValue:temp key:@"label"];
        ReleaseDateAttributes *releaseDateAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"ReleaseDateAttributes" inManagedObjectContext:self.managedObjectContext];
        temp = [self getValue:temp key:@"attributes"];
        releaseDateAttributesObject.label = [self getValue:temp key:@"label"];
        releaseDateObject.attributes = releaseDateAttributesObject;
        entryObject.releaseDate = releaseDateObject;
        
        
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
    [dateFormatter setDateFormat:@"%Y-%m-%dT%H:%M:%S%z"];
    NSDate *date = [dateFormatter dateFromString: temp];
    //TODO: - Currently a hack... until i understand the date format.
    updatedObject.label = [NSDate date];
    
    return updatedObject;
}

- (Rights *)buildRights:(id)rights
{
    NSAssert(rights, @"rights is null, possibly json's schema has changed?");
    
    Rights *rightsObject = [NSEntityDescription insertNewObjectForEntityForName:@"Rights" inManagedObjectContext:self.managedObjectContext];
    
    NSString *label = [self getValue:rights key:@"label"];
    rightsObject.label = [[NSString alloc] initWithString:label];
    
    return rightsObject;
}

- (Title *)buildTitle:(id)title
{
    NSAssert(title, @"title is null, possibly json's schema has changed?");
    
    Title *titleObject = [NSEntityDescription insertNewObjectForEntityForName:@"Title" inManagedObjectContext:self.managedObjectContext];
    
    NSString *label = [self getValue:title key:@"label"];
    titleObject.label = [[NSString alloc] initWithString:label];
    
    return titleObject;
}

- (Icon *)buildIcon:(id)icon
{
    NSAssert(icon, @"icon is null, possibly json's schema has changed?");
    
    Icon *iconObject = [NSEntityDescription insertNewObjectForEntityForName:@"Icon" inManagedObjectContext:self.managedObjectContext];
    
    NSString *label = [self getValue:icon key:@"label"];
    iconObject.label = [[NSString alloc] initWithString:label];
    
    return iconObject;
}

- (NSSet *)buildLink:(id)links
{
    NSAssert(link, @"link is null, possibly json's schema has changed?");
    
    int capacity = [links count];
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity:capacity];
    
    for (NSDictionary *aLink in links)
    {
        Link *linkObject = [NSEntityDescription insertNewObjectForEntityForName:@"Link" inManagedObjectContext:self.managedObjectContext];
        LinkAttributes *linkAttributesObject = [NSEntityDescription insertNewObjectForEntityForName:@"LinkAttributes" inManagedObjectContext:self.managedObjectContext];
        
        id temp = [self getValue:aLink key:@"attributes"];
        linkAttributesObject.rel = [self getValue:temp key:@"rel"];
        id type = nil;
        if(nil != (type = [temp objectForKey:@"type"]))
            linkAttributesObject.type = [self getValue:temp key:@"type"];
        linkAttributesObject.href = [self getValue:temp key:@"href"];
        
        linkObject.attributes = linkAttributesObject;
        
        [set addObject:linkObject];
    }
    
    
    
    return set;
}

- (Id *)buildId:(id)_id
{
    NSAssert(_id, @"id is null, possibly json's schema has changed?");
    
    Id *_idObject = [NSEntityDescription insertNewObjectForEntityForName:@"Id" inManagedObjectContext:self.managedObjectContext];
    
    NSString *label = [self getValue:_id key:@"label"];
    _idObject.label = [[NSString alloc] initWithString:label];
    
    return _idObject;
}

- (void)buildFeed:(id)feed
{
    NSAssert(feed, @"feed is null, possibly json's schema has changed?");
    
    Feed *feedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Feed"
                                               inManagedObjectContext:self.managedObjectContext];
    
    feedObject.author = [self buildAuthor:[feed objectForKey:@"author"]];
    feedObject.entry = [self buildEntry:[feed objectForKey:@"entry"]];
    feedObject.updated = [self buildUpdated:[feed objectForKey:@"updated"]];
    feedObject.rights = [self buildRights:[feed objectForKey:@"rights"]];
    feedObject.title = [self buildTitle:[feed objectForKey:@"title"]];
    feedObject.icon = [self buildIcon:[feed objectForKey:@"icon"]];
    feedObject.link = [self buildLink:[feed objectForKey:@"link"]];
    feedObject.id = [self buildId:[feed objectForKey:@"id"]];
}

- (void)fetchJSON:(NSData *)responseData
{
    //parse out the json data
    if(responseData != nil)
    {
        NSError* error;
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        
        [self buildFeed:[json objectForKey:@"feed"]];
        
        
//        id entries = [feed objectForKey:[[NSUserDefaults standardUserDefaults] stringForKey:@"entry"]];
//        
//        for (id currentEntry in entries)
//        {
//            id entry = [[Entry alloc] initWithJsonEntry:currentEntry];
//            
//            if (![self entryExists:entry])
//            {
//                NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
//                NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
//                NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
//                
//                
//                // If appropriate, configure the new managed object.
//                // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
//                
//                NSData *data=[NSKeyedArchiver archivedDataWithRootObject:entry];
//                [newManagedObject setValue:data forKey:@"entry"];
//                [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
//                [newManagedObject setValue:[entry urlID] forKey:@"urlID"];
//                [newManagedObject setValue:[entry title] forKey:@"title"];
//                
//                // Save the context.
//                NSError *error = nil;
//                if (![context save:&error]) {
//                    // Replace this implementation with code to handle the error appropriately.
//                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//                    abort();
//                }
//            }
//        }
    }
    
}

@end
