//
//  ObjFileRenderer.h
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 07.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#ifndef ToudaijiPlane_ObjFileRenderer_h
#define ToudaijiPlane_ObjFileRenderer_h

#include "ObjLoader.h"
#import <GLKit/GLKit.h>

typedef struct _ObjFileRenderer* ObjFileRendererPtr;

void ObjFileRendererCreate(ObjFileRendererPtr* renderer, ObjFilePtr file);
void ObjFileRendererRelease(ObjFileRendererPtr* renderer);
void ObjFileRendererRender(ObjFileRendererPtr renderer);
void ObjFileRendererSetProjection(ObjFileRendererPtr renderer, const GLKMatrix4* projection);
void ObjFileRendererSetModel(ObjFileRendererPtr renderer, const GLKMatrix4* model);
void ObjFileRendererSetAlpha(ObjFileRendererPtr renderer, float alpha);

#endif
