//
//  Author.h
//  Hackerati1
//
//  Created by James Folk on 8/7/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Name, Uri;

@interface Author : NSManagedObject

@property (nonatomic, retain) Name *name;
@property (nonatomic, retain) Uri *uri;

@end
