//------------------------------------------------------------------------------
//
//  Camera.m
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 14.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "Camera.h"
//------------------------------------------------------------------------------
@interface Camera ()
{
    GLKMatrix4 _view;
    GLKMatrix4 _perspective;
    GLKMatrix4 _rotX;
    GLKMatrix4 _rotY;
}
-(id)init;
-(void)dealloc;
@end
//------------------------------------------------------------------------------
@implementation Camera
//------------------------------------------------------------------------------
+(Camera*)instance
{
    static Camera* instance = nil;
    
    @synchronized(self)
    {
        if (!instance)
        {
            instance = [[Camera alloc] init];
        }
    }
    
    return instance;
}
//------------------------------------------------------------------------------
-(id)init
{
    self = [super init];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat w = screenRect.size.width;
    CGFloat h = screenRect.size.height;
    
    _perspective = GLKMatrix4MakePerspective(M_PI/6.0, w/h, 0.001, 1000.0);
    _view = GLKMatrix4Identity;
    _rotX = GLKMatrix4Identity;
    _rotY = GLKMatrix4Identity;
    
    return self;
}
//------------------------------------------------------------------------------
-(void)dealloc
{

}
//------------------------------------------------------------------------------
-(void)setView:(GLKMatrix4)view
{
    _view = view;
}
//------------------------------------------------------------------------------
-(GLKMatrix4)getView
{
    GLKMatrix4 rot = GLKMatrix4Multiply(_rotX, _rotY);

    return GLKMatrix4Multiply(_view, rot);
}
//------------------------------------------------------------------------------
-(GLKMatrix4)getPerspective
{
    return _perspective;
}
//------------------------------------------------------------------------------
-(void)rotateAroundXAxisWithAngle:(float)angle
{
    _rotX = GLKMatrix4MakeRotation(-angle, 1.0, 0.0, 0.0);
}
//------------------------------------------------------------------------------
-(void)rotateAroundYAxisWithAngle:(float)angle
{
    _rotY = GLKMatrix4MakeRotation(-angle, 0.0, 1.0, 0.0);
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------