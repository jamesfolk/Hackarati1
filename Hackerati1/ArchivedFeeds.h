//
//  ArchivedFeeds.h
//  Hackerati1
//
//  Created by James Folk on 8/7/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Feed;

@interface ArchivedFeeds : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) Feed *feed;

@end
