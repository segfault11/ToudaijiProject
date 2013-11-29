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
    const Scene* _scene;
}

@property (strong, nonatomic) SkyBoxRenderer* skyBoxRenderer;
@property (strong, nonatomic) ObjRenderer* objRenderer;
@property (strong, nonatomic) CMMotionManager* motionManager;
- (void)setUpCoreMotion;
@end

@implementation ControllerDelegate

- (id)initWithScene:(const Scene*)scene
{
    self = [super init];
    [self setUpCoreMotion];
    [self applyScene:scene];
    return self;
}

- (void)setCubeMap:(NSString*)filename
{
    self.skyBoxRenderer = [[SkyBoxRenderer alloc] initWithCubeMap:filename];
    [self.skyBoxRenderer setScale:5.0f];
    [self.skyBoxRenderer setBottomAlphaMask:@"amap.png"];
}

- (void)applyScene:(const Scene*)scene
{
    _scene = scene;
  
    NSLog(@"%s %f %s", scene->skyBox.cubeMapFile, scene->skyBox.scale, scene->skyBox.alphaMapFile);
    
    self.skyBoxRenderer = [[SkyBoxRenderer alloc] initWithCubeMap:[NSString stringWithUTF8String:scene->skyBox.cubeMapFile]];
    [self.skyBoxRenderer setScale:scene->skyBox.scale];
    [self.skyBoxRenderer setBottomAlphaMask: [NSString stringWithUTF8String:scene->skyBox.alphaMapFile]];
    [self.skyBoxRenderer setRotationAmap:scene->obj.rotY];
    [self.skyBoxRenderer setBottomAlphaMaskTranslationX:scene->obj.position.x AndZ:scene->obj.position.z];    
    
    
    self.objRenderer = [[ObjRenderer alloc] initWithFile:[NSString stringWithUTF8String:scene->obj.objFile]];
    [self.objRenderer setTranslation:&scene->obj.position];
    [self.objRenderer setScale:scene->obj.scale];
    [self.objRenderer setAlpha:1.0f];
    [self.objRenderer setRotationAroundXWith:0.0f AroundYWith:scene->obj.rotY AroundZWith:0.0f];
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
    // rotate camera on sphere
    GLKVector3 v = GLKVector3Make(0.0f, 0.0f, -1.0f); // original camera position
    GLKMatrix4 ry = GLKMatrix4MakeRotation(self.motionManager.deviceMotion.attitude.yaw, 0, 1, 0);
    GLKMatrix4 rx = GLKMatrix4MakeRotation(-self.motionManager.deviceMotion.attitude.roll - GLKMathDegreesToRadians(90.0), 1, 0, 0);
    
    v = GLKMatrix4MultiplyVector3(rx, v); 
    v = GLKMatrix4MultiplyVector3(ry, v);
    
    // set camera from sphere to the elipsoid (defined by a, b and c) by
    // shooting a ray from the origin through the camera position on the sphere
    // and calculating its intersection with the sphere.
    float a = _scene->camera.elipseParams.x;
    float b = _scene->camera.elipseParams.y;
    float c = _scene->camera.elipseParams.z;
    float kinv = sqrtf((v.x*v.x)/(a*a) + (v.y*v.y)/(b*b) + (v.z*v.z)/(c*c));
    
    ASSERT( kinv != 0.0f )

    float k = 1.0f/kinv;
    
    v = GLKVector3MultiplyScalar(v, k);
    
    float test = v.x*v.x/(_scene->camera.elipseParams.x*_scene->camera.elipseParams.x) + v.y*v.y/(_scene->camera.elipseParams.y*_scene->camera.elipseParams.y) + v.z*v.z/(_scene->camera.elipseParams.z*_scene->camera.elipseParams.z);
    NSLog(@"test var is %f", test);
    
    // translate skybox and .obj in opposite direction of the camera postion
    v.x *= -1.0f;
    v.y *= -1.0f;
    v.z *= -1.0f;
    [self.skyBoxRenderer setTranslation:&v];
    
    v = GLKVector3Add(_scene->obj.position, v);
    [self.objRenderer setTranslation:&v];
    
    // set the rotation of the sky box and the .obj to opposite rotation of the
    // camera rotation
    [self.skyBoxRenderer setRotationZ:self.motionManager.deviceMotion.attitude.pitch];
    [self.skyBoxRenderer setRotationY:-self.motionManager.deviceMotion.attitude.yaw];
    [self.skyBoxRenderer setRotationX:self.motionManager.deviceMotion.attitude.roll + GLKMathDegreesToRadians(90.0)];
    [self.objRenderer setRotationZ:self.motionManager.deviceMotion.attitude.pitch];
    [self.objRenderer setRotationY:-self.motionManager.deviceMotion.attitude.yaw];
    [self.objRenderer setRotationX:self.motionManager.deviceMotion.attitude.roll + GLKMathDegreesToRadians(90.0)];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.objRenderer render];
    glClear(GL_DEPTH_BUFFER_BIT);
    [self.skyBoxRenderer render];
//    [self.objRenderer render];

}

@end
