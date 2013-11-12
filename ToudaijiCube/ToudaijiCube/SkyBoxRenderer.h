//
//  SkyBoxRenderer.h
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 10.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

/*!
**  
*/
@interface SkyBoxRenderer : NSObject
/*!
** Initializes the SkyBoxRenderer from a cube map, that is
** referenced by [filename]. The cube map is assumed to be in
** the resource folder of the application.
**
** The cubemap is assumed to have the following layout
**
**   0  +Y   0   0
**  -X  +Z  +X  -Z
**   0  -Y   0   0
**
** Init will fail if imgwidth % 4 != 0 || imgheight % 3 != 0
*/
- (id)initWithCubeMap:(NSString*)filename;
- (void)dealloc;
- (void)render;
- (void)setPerspective:(const GLKMatrix4*)m;
/*!
**  Rotates the cube by [angle] around the x axis.
**  @param angle Angle in radians the cube is rotated by.
*/
- (void)setRotationX:(float)angle;
/*!
**  Rotates the cube by [angle] around the y axis.
**  @param angle Angle in radians the cube is rotated by.
*/
- (void)setRotationY:(float)angle;
- (void)setScale:(float)s;
@end
