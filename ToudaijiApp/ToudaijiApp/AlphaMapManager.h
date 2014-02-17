//
//  AlphaMapManager.h
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 16.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlphaMap.h"

@interface AlphaMapManager : NSObject
+(AlphaMapManager*)instance;
-(AlphaMap*)getAlphaMapWithID:(int)id;
-(AlphaMap*)getAlphaMapAtIndex:(int)idx;
-(int)getNumAlphaMaps;
@end
