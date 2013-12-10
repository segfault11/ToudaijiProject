//
//  GestureHandler.m
//  ToudaijiModelViewer
//
//  Created by Arno in Wolde Lübke on 18.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "GestureHandler.h"
#import "ObjFileRenderer.h"
#import <sys/time.h>
#import "ErrorHandler.h"
#import <math.h>

@interface GestureHandler ()
{
    CGPoint _velocity;   /* velocity of the finger in px/sec */
    CGPoint _p0;
    CGPoint _p1;
    NSTimeInterval _dt;
    NSTimeInterval _sampleInterval;

    struct timeval _t0;
    struct timeval _t1;
    
    GLKMatrix4 _perspective;
    GLKMatrix4 _translation;
    GLKMatrix4 _model;
    
    float _angleY;
    float _angleX;

    ObjFileRendererPtr _renderer;
}
@end

@implementation GestureHandler

- (id)initWithSampleInterval:(NSTimeInterval)sampleInterval
{
    self = [super init];
    _sampleInterval = sampleInterval;

    ObjFilePtr file;
    const char* path = [[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"] UTF8String];
    ObjFileLoadWithPath(&file, "Iseki2.obj", path);
    ASSERT( file )
    ObjFileRendererCreate(&_renderer, file);
    ASSERT( _renderer )
    
    // configure the renderer
    _perspective = GLKMatrix4MakePerspective(31.3f, 1024.0f/768.0f, 0.01f, 100.0f);
    _translation = GLKMatrix4MakeTranslation(0.0f, 0.0f, -15.0f);
    ObjFileRendererSetProjection(_renderer, &_perspective);
    ObjFileRendererSetModel(_renderer, &_translation);
    
    _angleX = GLKMathDegreesToRadians(180.0f);
    _angleY = GLKMathDegreesToRadians(0.0f);
    
    ObjFileRelease(&file);
    return self;
}

- (void)dealloc
{
    ObjFileRendererRelease(&_renderer);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glEnable(GL_DEPTH_TEST);
//    glDepthMask(<#GLboolean flag#>)
    glDisable(GL_CULL_FACE);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    ObjFileRendererRender(_renderer);
    glFlush();
}

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    // then compute the rotation angles from the velocity

    float velMin = 50.0f;
    float velMax = 1500.0f;

    float velx = MIN(fabs(_velocity.x), velMax);
    float vely = MIN(fabs(_velocity.y), velMax);
    
    
    float danglex = (velx - velMin)/(velMax - velMin)*0.15f/0.033f*controller.timeSinceLastUpdate;
    float dangley = (vely - velMin)/(velMax - velMin)*0.15f/0.033f*controller.timeSinceLastUpdate;
    
    if (_velocity.x <= -velMin)
    {
        _angleY += danglex;
    }
    else if (_velocity.x >= velMin)
    {
        _angleY -= danglex;
    }

    if (_velocity.y <= -velMin)
    {
        _angleX += dangley;
    }
    else if (_velocity.y >= velMin)
    {
        _angleX -= dangley;
    }

    GLKMatrix4 rotX = GLKMatrix4MakeRotation(_angleX, 1.0f, 0.0f, 0.0f);
    GLKMatrix4 rotY = GLKMatrix4MakeRotation(-_angleY, 0.0f, 1.0f, 0.0f);
    _model = GLKMatrix4Multiply(rotX, rotY);
    _model = GLKMatrix4Multiply(_translation, _model);
    ObjFileRendererSetModel(_renderer, &_model);
}

- (void)handleTouchBegan:(const CGPoint*)position
{
    NSLog(@"%f %f", position->x, position->y);

    _p0 = *position;
    _p1 = *position;
    gettimeofday(&(_t0), NULL);
    gettimeofday(&(_t1), NULL);
    
    _velocity.x = 0.0f;
    _velocity.y = 0.0f;
}

- (void)handleTouchEnd:(const CGPoint*)position
{
    _velocity.x = 0.0f;
    _velocity.y = 0.0f;
}

- (void)handleTouchMoved:(const CGPoint*)position
{
    // compute the finger velocity in px/s
    struct timeval t;
    gettimeofday(&(t), NULL);
    
    _dt = (t.tv_sec - _t1.tv_sec)*1000.0;
    _dt += (t.tv_usec - _t1.tv_usec)/1000.0;
    
    if (_dt >= _sampleInterval)
    {
        _p0 = _p1;
        _p1 = *position;
        _t0 = _t1;
        _t1 = t;
        _velocity.x = (_p1.x - _p0.x)/_dt*1000.0f;
        _velocity.y = (_p1.y - _p0.y)/_dt*1000.0f;
        
        NSLog(@"%f %f", _velocity.x, _velocity.y);
    }
}

- (void)reset
{
    _angleX = GLKMathDegreesToRadians(180.0f);
    _angleY = GLKMathDegreesToRadians(0.0f);
}

@end
