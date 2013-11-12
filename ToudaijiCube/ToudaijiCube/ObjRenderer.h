//
//  ObjRenderer.h
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 11.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ObjRenderer : NSObject
/*
**  Initializes the .obj renderer with the file name of the object. The file is
**  assumed to be in the default application folder.
**  @param filename Filename of the .obj file.
**  @return The initialized object, or nil in case of failiure.
*/
- (id)initWithFile:(NSString*)filename;

- (void)dealloc;
- (void)render;

/*!
**  Rotates the obj by [angle] around the x axis.
**  @param angle Angle in radians the cube is rotated by.
*/
- (void)setRotationX:(float)angle;

/*!
**  Rotates the obj by [angle] around the y axis.
**  @param angle Angle in radians the cube is rotated by.
*/
- (void)setRotationY:(float)angle;

/*!
**  Sets the translation of obj.
*/
- (void)setTranslation:(const GLKVector3*)pos;
/*!
**  Sets the scale of the obj.
*/
- (void)setScale:(float)s;
- (void)setAlpha:(float)a;
@end
