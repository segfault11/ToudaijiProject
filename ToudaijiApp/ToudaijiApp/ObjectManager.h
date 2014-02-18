//------------------------------------------------------------------------------
//
//  ObjectManager.h
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 14.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//
//------------------------------------------------------------------------------
#import <Foundation/Foundation.h>
#import "Object.h"

@interface ObjectManager : NSObject
+(ObjectManager*)instance;
-(Object*)getObjectWithID:(int)id;
-(Object*)getObjectAtIndex:(int)idx;
-(int)getNumObjects;
@end
