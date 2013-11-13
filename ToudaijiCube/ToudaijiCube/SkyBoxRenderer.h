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
** Renders a sky box. The bottom part of the sky box has a transparent part
** that lets the user see outside the box. That is, while rendering the bottom part
** of the sky box is blended with the current contents of the frame buffer.
** For this reason the sky box should be rendered last. The transparent part is defined
** by an alpha plane that has the same dimensions of the bottom plane but may
** be translated in x and z direction relative to the bottom plane. The 
** see through pattern is defined by an alpha mask. If the the alpha mask is 
** not set, the user cannot the through the bottom. 
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
/*!
** Initializes the SkyBoxRenderer from a cube map, that is
** referenced by [filename]. The cube map is assumed to be in
** the resource folder of the application. This method assumes
** the cube map to be organized as described in the GLKTextureLoader
** reference. That is, north, south, east west, top, bottom.
*/
- (id)initWithCubeMap2:(NSString*)filename;

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
/*!
**  Sets the alpha mask from an image referenced by [filename]. The image should be
**  a one channel gray scale image. The image is assumed to be in the resources
**  folder of the application.
*/
- (void)setBottomAlphaMask:(NSString*)filename;
/*!
** Sets the translation of the bottom alpha mask relative to the bottom plane
** of the sky box.
*/ 
- (void)setBottomAlphaMaskTranslationX:(float)x AndZ:(float)z;
@end
