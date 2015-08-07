//
//  Feed.h
//  Hackerati1
//
//  Created by James Folk on 8/7/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Author, Entry, Icon, Id, Link, Rights, Title, Updated;

@interface Feed : NSManagedObject

@property (nonatomic, retain) Id *id;
@property (nonatomic, retain) NSSet *link;
@property (nonatomic, retain) Icon *icon;
@property (nonatomic, retain) Title *title;
@property (nonatomic, retain) Rights *rights;
@property (nonatomic, retain) Updated *updated;
@property (nonatomic, retain) NSSet *entry;
@property (nonatomic, retain) Author *author;
@end

@interface Feed (CoreDataGeneratedAccessors)

- (void)addLinkObject:(Link *)value;
- (void)removeLinkObject:(Link *)value;
- (void)addLink:(NSSet *)values;
- (void)removeLink:(NSSet *)values;

- (void)addEntryObject:(Entry *)value;
- (void)removeEntryObject:(Entry *)value;
- (void)addEntry:(NSSet *)values;
- (void)removeEntry:(NSSet *)values;

@end
