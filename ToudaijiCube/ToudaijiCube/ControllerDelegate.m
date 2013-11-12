//
//  ControllerDelegate.m
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 10.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "ControllerDelegate.h"
#import "ErrorHandler.h"
#import "SkyBoxRenderer.h"
#import "ObjRenderer.h"
#import <opencv2/highgui/highgui_c.h>

@interface ControllerDelegate ()
@property (strong, nonatomic) SkyBoxRenderer* skyBoxRenderer;
@property (strong, nonatomic) ObjRenderer* objRenderer;
@property (strong, nonatomic) CMMotionManager* motionManager;
- (void)setUpCoreMotion;
@end

@implementation ControllerDelegate

- (id)init
{
    self = [super init];
    [self setUpCoreMotion];
    self.skyBoxRenderer = [[SkyBoxRenderer alloc] initWithCubeMap:@"SkyBox.jpg"];
    self.objRenderer = [[ObjRenderer alloc] initWithFile:@"Iseki2.obj"];
    GLKVector3 v = GLKVector3Make(0.0f, -5.0f, -3.0f);
    [self.objRenderer setTranslation:&v];
    [self.objRenderer setScale:4.0f];
    [self.objRenderer setAlpha:0.3f];
    [self.skyBoxRenderer setScale:5.0f];
    return self;
}

- (void)dealloc
{

}

- (void)setUpCoreMotion
{
    self.motionManager = [[CMMotionManager alloc] init];

    if (!self.motionManager.gyroAvailable || !self.motionManager.accelerometerAvailable || !self.motionManager.magnetometerAvailable)
    {
        REPORT("Required sensors not available.");
    }
    
    self.motionManager.deviceMotionUpdateInterval = 1.0/60.0;
    self.motionManager.showsDeviceMovementDisplay = YES;
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
}

- (void)glkViewControllerUpdate:(GLKViewController *)controller
{
    [self.skyBoxRenderer setRotationY:-self.motionManager.deviceMotion.attitude.yaw];
    [self.skyBoxRenderer setRotationX:self.motionManager.deviceMotion.attitude.roll + GLKMathDegreesToRadians(90.0)];
    [self.objRenderer setRotationY:-self.motionManager.deviceMotion.attitude.yaw];
    [self.objRenderer setRotationX:self.motionManager.deviceMotion.attitude.roll + GLKMathDegreesToRadians(90.0)];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.skyBoxRenderer render];
    glClear(GL_DEPTH_BUFFER_BIT);
    [self.objRenderer render];
}

@end
