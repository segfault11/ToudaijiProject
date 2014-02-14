//
//  SkyBoxManager.h
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 14.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SkyBox.h"


@interface SkyBoxManager : NSObject
+(SkyBoxManager*)instance;
-(SkyBox*)getSkyBoxWithID:(int)id;
-(SkyBox*)getSkyBoxAtIndex:(int)idx;
-(int)getNumSkyBoxes;
@end
