//
//  ObjView.m
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 07.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "ObjView.h"
#import "ObjLoader.h"
#import "GLUEProgram.h"
#import "ObjFileRenderer.h"

@interface ObjView ()
{
    GLKMatrix4 _projection;
    GLKMatrix4 _model;
    ObjFileRendererPtr _renderer;
    GLKMatrix4 _translation;
    GLKMatrix4 _rotX;
    GLKMatrix4 _rotY;
}
@end

@implementation ObjView

- (id)init
{
    self = [super init];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat w = screenRect.size.width;
    CGFloat h = screenRect.size.height;
    _projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(31.3f), h/w, 0.01f, 100.0f); // height is width and width is height ....
    _translation = GLKMatrix4MakeTranslation(0.0f, -3.5f, -3.5f);
    _rotX = GLKMatrix4Identity;
    _rotY = GLKMatrix4Identity;
    
    /* load obj file */
    const char* path = [[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"] UTF8String];
    ObjFilePtr file;
    ObjFileLoadWithPath(&file, "Iseki2.obj", path);
    
    if (file == NULL) {
        NSLog(@"Could not load .obj file.");
    }
    
    /* init the renderer */
    ObjFileRendererCreate(&_renderer, file);
    ObjFileRendererSetProjection(_renderer, &_projection);
    ObjFileRendererSetModel(_renderer, &_translation);
    
    /* clean up */
    ObjFileRelease(&file);
    
    return self;
}

- (void)setRotationX:(float)angle
{
    _rotX = GLKMatrix4MakeRotation(angle, 1.0f, 0.0f, 0.0f);
}

- (void)setRotationY:(float)angle
{
    _rotY = GLKMatrix4MakeRotation(angle, 0.0f, 1.0f, 0.0f);
}

- (void)dealloc
{
    ObjFileRendererRelease(&_renderer);
}

- (void)draw
{
    _model = GLKMatrix4Multiply(_rotX, _translation);
    _model = GLKMatrix4Multiply(_rotY, _model);

    ObjFileRendererSetModel(_renderer, &_model);
    ObjFileRendererRender(_renderer);
}

@end
