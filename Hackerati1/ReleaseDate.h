//
//  ReleaseDate.h
//  Hackerati1
//
//  Created by James Folk on 8/7/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ReleaseDateAttributes;

@interface ReleaseDate : NSManagedObject

@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) ReleaseDateAttributes *attributes;

@end
