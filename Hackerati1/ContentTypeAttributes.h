//
//  ContentTypeAttributes.h
//  Hackerati1
//
//  Created by James Folk on 8/7/15.
//  Copyright (c) 2015 James Folk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ContentTypeAttributes : NSManagedObject

@property (nonatomic, retain) NSString * term;
@property (nonatomic, retain) NSString * label;

@end
