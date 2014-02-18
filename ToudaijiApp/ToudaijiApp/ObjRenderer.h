//
//  ObjRenderer.h
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 11.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Object.h"

@interface ObjRenderer : NSObject
+(ObjRenderer*)instance;
-(void)render:(Object*)object;
@end
