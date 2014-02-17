//------------------------------------------------------------------------------
//
//  ViewController.m
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 14.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "ViewController.h"
#import "AlphaMapRenderer.h"
#import "AlphaMapManager.h"
#import <CoreMotion/CoreMotion.h>
#import <assert.h>
#import "SkyBoxRenderer.h"
#import "Camera.h"
//------------------------------------------------------------------------------
static GLKMatrix4 CMRotationMatrixCreateOpenGLViewMatrix(CMRotationMatrix m);
//------------------------------------------------------------------------------
@interface ViewController ()
@property (strong, nonatomic) EAGLContext* context;
@property (strong, nonatomic) SkyBoxRenderer* skyBoxRender;
@property (strong, nonatomic) AlphaMapRenderer* alphaMapRenderer;
@property (strong, nonatomic) CMMotionManager* motionManager;
@property (strong, nonatomic) Camera* camera;
- (void)setupGL;
- (void)tearDownGL;
- (void)setUpCoreMotion;
@end
//------------------------------------------------------------------------------
@implementation ViewController
//------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    
    [self setupGL];
    [self setUpCoreMotion];
    
    self.skyBoxRender = [SkyBoxRenderer instance];
    self.alphaMapRenderer = [AlphaMapRenderer instance];
    self.camera = [Camera instance];
}
//------------------------------------------------------------------------------
- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context)
    {
        [EAGLContext setCurrentContext:nil];
    }
}
//------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil))
    {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context)
        {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}
//------------------------------------------------------------------------------
- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
}
//------------------------------------------------------------------------------
- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
}
//------------------------------------------------------------------------------
- (void)setUpCoreMotion
{
    self.motionManager = [[CMMotionManager alloc] init];

    assert(
        self.motionManager.gyroAvailable ||
        self.motionManager.accelerometerAvailable ||
        self.motionManager.magnetometerAvailable
    );
    
    self.motionManager.deviceMotionUpdateInterval = 1.0/60.0;
    self.motionManager.showsDeviceMovementDisplay = YES;
    [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryZVertical];
}
//------------------------------------------------------------------------------
#pragma mark - GLKView and GLKViewController delegate methods
//------------------------------------------------------------------------------
- (void)update
{
    CMRotationMatrix rot = self.motionManager.deviceMotion.attitude.rotationMatrix;
    GLKMatrix4 view = CMRotationMatrixCreateOpenGLViewMatrix(rot);
    [self.camera setView:view];
}
//------------------------------------------------------------------------------
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glEnable(GL_DEPTH_TEST);
    glClearColor(1.0, 0.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    [self.alphaMapRenderer render:[[AlphaMapManager instance] getAlphaMapAtIndex:0]];
    [self.skyBoxRender render:0 withAlphaMap:[self.alphaMapRenderer getRenderTarget]];
//    [self.skyBoxRender render:0];
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------
GLKMatrix4 CMRotationMatrixCreateOpenGLViewMatrix(CMRotationMatrix m)
{
    GLKMatrix4 r = GLKMatrix4Identity;
 
    r.m00 = m.m11;
    r.m01 = m.m12;
    r.m02 = m.m13;
    
    r.m10 = m.m21;
    r.m11 = m.m22;
    r.m12 = m.m23;
    
    r.m20 = m.m31;
    r.m21 = m.m32;
    r.m22 = m.m33;
    
    GLKMatrix4 a;
    memset(&a, 0, sizeof(GLKMatrix4));
    a.m33 = 1.0;
    a.m00 = 1.0;
    a.m21 = -1.0;
    a.m12 = 1.0;
    
    return GLKMatrix4Multiply(GLKMatrix4Transpose(r), a);
}
//------------------------------------------------------------------------------