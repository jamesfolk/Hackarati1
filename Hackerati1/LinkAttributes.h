//
//  LinkAttributes.h
//  Hackerati1
//
//  Created by James Folk on 8/7/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LinkAttributes : NSManagedObject

@property (nonatomic, retain) NSString * rel;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * href;

@end
