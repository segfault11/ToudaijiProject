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
    
    _perspective = GLKMatrix4MakePerspective(M_PI/3.0, w/h, 0.001, 1000.0);
    _view = GLKMatrix4Identity;
    
    return self;
}
//------------------------------------------------------------------------------
-(void)dealloc
{

}
//------------------------------------------------------------------------------
-(GLKMatrix4)getView
{
    return _view;
}
//------------------------------------------------------------------------------
-(GLKMatrix4)getPerspective
{
    return _perspective;
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------