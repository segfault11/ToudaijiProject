//
//  ObjRenderer.m
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 11.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "ObjRenderer.h"
#import "ObjFileRenderer.h"
#import "ErrorHandler.h"

@interface ObjRenderer ()
{
    ObjFileRendererPtr _renderer;
    ObjFilePtr _objFile;
    GLKMatrix4 _perspective;
    GLKMatrix4 _scale;
    GLKMatrix4 _translation;
    GLKMatrix4 _rotX;
    GLKMatrix4 _rotY;
}
@end

@implementation ObjRenderer

- (id)initWithFile:(NSString*)filename
{
    self = [super init];
//    NSString* fullName = [[[[NSBundle mainBundle] resourcePath]
//                           stringByAppendingString:@"/"]
//                           stringByAppendingString:filename];

    _perspective = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(31.3f), 1024.0f/768.0f, 0.01f, 100.0f);
    GLKMatrix4 model = GLKMatrix4MakeTranslation(0.0f, 0.0f, -5.0f);
    _translation = GLKMatrix4Identity;
    _rotX = GLKMatrix4Identity;
    _rotX = GLKMatrix4Identity;
    _scale = GLKMatrix4Identity;
    
    /* load the .obj file */
    const char* path = [[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"] UTF8String];
    ObjFileLoadWithPath(&_objFile, [filename UTF8String], path);
    ASSERT( _objFile != NULL )

    /* create and init the actual .obj file renderer */
    ObjFileRendererCreate(&_renderer, _objFile);
    ASSERT( _renderer != NULL )
    ObjFileRendererSetProjection(_renderer, &_perspective);
    ObjFileRendererSetModel(_renderer, &model);
    ObjFileRendererSetAlpha(_renderer, 0.3f);
    
    /* clean up */
    ObjFileRelease(&_objFile);

    return self;
}

- (void)dealloc
{
    ObjFileRendererRelease(&_renderer);
}

- (void)render
{
    ObjFileRendererRender(_renderer);
}

- (void)setRotationX:(float)angle
{
    _rotX = GLKMatrix4MakeRotation(angle, 1.0f, 0.0f, 0.0);
    GLKMatrix4 model = GLKMatrix4Multiply(_translation, _scale);
    model = GLKMatrix4Multiply(_rotY, model);
    model = GLKMatrix4Multiply(_rotX, model);
    ObjFileRendererSetModel(_renderer, &model);
}

- (void)setRotationY:(float)angle
{
    _rotY = GLKMatrix4MakeRotation(angle, 0.0f, 1.0f, 0.0);
    GLKMatrix4 model = GLKMatrix4Multiply(_translation, _scale);
    model = GLKMatrix4Multiply(_rotY, model);
    model = GLKMatrix4Multiply(_rotX, model);
    ObjFileRendererSetModel(_renderer, &model);
}

- (void)setTranslation:(const GLKVector3*)pos
{
    _translation = GLKMatrix4MakeTranslation(pos->x, pos->y, pos->z);
    GLKMatrix4 model = GLKMatrix4Multiply(_translation, _scale);
    model = GLKMatrix4Multiply(_rotY, model);
    model = GLKMatrix4Multiply(_rotX, model);
    ObjFileRendererSetModel(_renderer, &model);    
}

- (void)setScale:(float)s
{
    _scale = GLKMatrix4MakeScale(s, s, s);
    GLKMatrix4 model = GLKMatrix4Multiply(_translation, _scale);
    model = GLKMatrix4Multiply(_rotY, model);
    model = GLKMatrix4Multiply(_rotX, model);
    ObjFileRendererSetModel(_renderer, &model);
}

- (void)setAlpha:(float)a
{
    ObjFileRendererSetAlpha(_renderer, a);
}

@end
