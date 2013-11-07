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

typedef struct _ObjFileRenderer* ObjFileRendererPtr;

void ObjFileRendererCreate(ObjFileRendererPtr* renderer, ObjFilePtr file);

#endif
