//
//  Entry.h
//  Hackerati1
//
//  Created by James Folk on 8/7/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist, Categary, ContentType, Id, Image, Link, Name, Price, ReleaseDate, Rights, Summary, Title;

@interface Entry : NSManagedObject

@property (nonatomic, retain) Name *name;
@property (nonatomic, retain) NSSet *image;
@property (nonatomic, retain) Summary *summary;
@property (nonatomic, retain) Price *price;
@property (nonatomic, retain) ContentType *contentType;
@property (nonatomic, retain) Rights *rights;
@property (nonatomic, retain) Title *title;
@property (nonatomic, retain) Link *link;
@property (nonatomic, retain) Id *id;
@property (nonatomic, retain) Artist *artist;
@property (nonatomic, retain) Categary *category;
@property (nonatomic, retain) ReleaseDate *releaseDate;
@end

@interface Entry (CoreDataGeneratedAccessors)

- (void)addImageObject:(Image *)value;
- (void)removeImageObject:(Image *)value;
- (void)addImage:(NSSet *)values;
- (void)removeImage:(NSSet *)values;

@end
