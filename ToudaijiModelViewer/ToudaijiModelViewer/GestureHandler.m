//
//  GestureHandler.m
//  ToudaijiModelViewer
//
//  Created by Arno in Wolde Lübke on 18.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "GestureHandler.h"
#import <sys/time.h>

@interface GestureHandler ()
{
    CGPoint _velocity;   /* velocity of the finger in px/sec */
    CGPoint _p0;
    CGPoint _p1;
    NSTimeInterval _dt;
    NSTimeInterval _sampleInterval;

    struct timeval _t0;
    struct timeval _t1;
}
@end


@implementation GestureHandler

- (id)initWithSampleInterval:(NSTimeInterval)sampleInterval
{
    self = [super init];
    _sampleInterval = sampleInterval;
    return self;
}

- (void)dealloc
{

}

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{

}

- (void)handleTouchBegan:(const CGPoint*)position
{
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
    struct timeval t;
    gettimeofday(&(t), NULL);
    
    _dt = (t.tv_sec - _t1.tv_sec)*1000.0;
    _dt += (t.tv_usec - _t1.tv_usec)/1000.0;
    
    NSLog(@"%lf", _dt);
    
    if (_dt >= _sampleInterval)
    {
        _p0 = _p1;
        _p1 = *position;
        _t0 = _t1;
        _t1 = t;
        _velocity.x = (_p1.x - _p0.x)/_dt;
        _velocity.y = (_p1.y - _p0.y)/_dt;
    }
}

@end
