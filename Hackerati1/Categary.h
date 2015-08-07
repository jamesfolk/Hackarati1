//
//  Categary.h
//  Hackerati1
//
//  Created by James Folk on 8/7/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CategoryAttributes;

@interface Categary : NSManagedObject

@property (nonatomic, retain) CategoryAttributes *attributes;

@end
