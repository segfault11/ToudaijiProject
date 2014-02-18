//------------------------------------------------------------------------------
//
//  ObjFileRenderer.h
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 07.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//
//------------------------------------------------------------------------------
#ifndef ToudaijiPlane_ObjFileRenderer_h
#define ToudaijiPlane_ObjFileRenderer_h

#include "ObjLoader.h"
#import <GLKit/GLKit.h>
#import "Object.h"

@interface ObjFileRenderer : NSObject
-(id)initWithFile:(ObjFilePtr)file andModel:(GLKMatrix4)model;
-(void)dealloc;
-(void)render;
@end

#endif
