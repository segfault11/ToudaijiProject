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
{
    float _theta; // rotation angle of the .obj.
    GLKVector3 _objTranslation;
}

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
    [self setCubeMap:@"SkyBox.jpg"];
    self.objRenderer = [[ObjRenderer alloc] initWithFile:@"Iseki2.obj"];
    _objTranslation = GLKVector3Make(0.0f, -5.0f, -3.0f);
    [self.objRenderer setTranslation:&_objTranslation];
    [self.objRenderer setScale:4.0f];
    [self.objRenderer setAlpha:1.0f];
    return self;
}

- (void)setCubeMap:(NSString*)filename
{
    self.skyBoxRenderer = [[SkyBoxRenderer alloc] initWithCubeMap:filename];
    [self.skyBoxRenderer setScale:5.0f];
    [self.skyBoxRenderer setBottomAlphaMask:@"amap.png"];
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
//    static int isThetaInit = 0;
//    static float prevTheta;
//    
//    if (!isThetaInit)
//    {
//        _theta = -self.motionManager.deviceMotion.attitude.yaw;
//        isThetaInit = 1;
//    }
//    else
//    {
//        /* compute delta theta */
//        float dTheta = -self.motionManager.deviceMotion.attitude.yaw - prevTheta;
//        
//        /* integrate theta in time */
//        //_theta += 1.3f*dTheta; /* modified motion of the .obj */
//        _theta += 1.0f*dTheta; /* normal motion of the obj */
//        
//        /* enforce constraints on motion */
//        /* TODO */
//    }
//
//    NSLog(@"%f", GLKMathRadiansToDegrees(self.motionManager.deviceMotion.attitude.yaw));
//    
//    // compute an rotational offset for the .obj original position based on the
//    // rotation of the user (yaw) around the the y axis of the synthetic camera
//    GLKVector3 off = GLKVector3Make(
//            sinf(self.motionManager.deviceMotion.attitude.yaw),
//            0.0f,
//            cosf(self.motionManager.deviceMotion.attitude.yaw)
//        );
//    
//    // scale the rotational offset
//    off = GLKVector3MultiplyScalar(off, 1.2f);
//    
//    // adjust the original translation by the offset
//    GLKVector3 translation = GLKVector3Add(_objTranslation, off);
//    
//    // set the translation in the obj renderer.
//    [self.objRenderer setTranslation:&translation];
//    [self.skyBoxRenderer setBottomAlphaMaskTranslationX:off.x AndZ:off.z];


//    NSLog(@"yaw = %f", GLKMathRadiansToDegrees(self.motionManager.deviceMotion.attitude.yaw));
//    NSLog(@"roll = %f", GLKMathRadiansToDegrees(self.motionManager.deviceMotion.attitude.roll + GLKMathDegreesToRadians(90.0)));
//

    // rotate camera on sphere
    GLKVector3 v = GLKVector3Make(0.0f, 0.0f, -1.0f); // original camera position
    GLKMatrix4 ry = GLKMatrix4MakeRotation(self.motionManager.deviceMotion.attitude.yaw, 0, 1, 0);
    GLKMatrix4 rx = GLKMatrix4MakeRotation(-self.motionManager.deviceMotion.attitude.roll - GLKMathDegreesToRadians(90.0), 1, 0, 0);
    
    v = GLKMatrix4MultiplyVector3(ry, v);
    v = GLKMatrix4MultiplyVector3(rx, v);
    
    // set camera from sphere to the elipsoid (defined by a, b and c) by
    // shooting a ray from the origin through the camera position on the sphere
    // and calculating its intersection with the sphere.
    float a = 2.0f, b = 2.0f, c = 4.0f;
    float k = 1.0f/sqrtf((v.x*v.x)/(a*a) + (v.y*v.y)/(b*b) + (v.z*v.z)/(c*c));
    
    v = GLKVector3MultiplyScalar(v, k);
    
    // translate skybox and .obj in opposite direction of the camera postion
    v.x *= -1.0f;
    v.y *= -1.0f;
    v.z *= -1.0f;
    [self.skyBoxRenderer setTranslation:&v];
    
    v = GLKVector3Add(_objTranslation, v);
    [self.objRenderer setTranslation:&v];
    
    //NSLog(@"v = [%f %f %f]", v.x, v.y, v.z);
    
    
    
    // set the rotation of the sky box and the .obj to opposite rotation of the
    // camera rotation
    [self.skyBoxRenderer setRotationZ:self.motionManager.deviceMotion.attitude.pitch];
    [self.skyBoxRenderer setRotationY:-self.motionManager.deviceMotion.attitude.yaw];
    [self.skyBoxRenderer setRotationX:self.motionManager.deviceMotion.attitude.roll + GLKMathDegreesToRadians(90.0)];
    [self.objRenderer setRotationZ:self.motionManager.deviceMotion.attitude.pitch];
    [self.objRenderer setRotationY:-self.motionManager.deviceMotion.attitude.yaw];
    [self.objRenderer setRotationX:self.motionManager.deviceMotion.attitude.roll + GLKMathDegreesToRadians(90.0)];

//    prevTheta = -self.motionManager.deviceMotion.attitude.yaw;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.objRenderer render];
    glClear(GL_DEPTH_BUFFER_BIT);
    [self.skyBoxRenderer render];
}

@end
