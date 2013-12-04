//
//  ViewController.m
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 10.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "ControllerDelegate.h"
#import "ViewController.h"
#import "Scene.h"


@interface ViewController ()
{
    Scene _scene;
    Scene* _scene01;
    Scene* _scene02;
    Scene* _scene03;
    IBOutlet UIButton* button;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) ControllerDelegate* controllerDelegate1;
@property (strong, nonatomic) ControllerDelegate* controllerDelegate2;
@property (strong, nonatomic) ControllerDelegate* controllerDelegate3;
- (IBAction)scene01Pressed:(id)sender;
- (IBAction)scene02Pressed:(id)sender;
- (IBAction)scene03Pressed:(id)sender;
- (void)setupGL;
- (void)setController:(ControllerDelegate*)controllerDelegate;

@end

@implementation ViewController


- (IBAction)scene01Pressed:(id)sender
{
    [self setController:self.controllerDelegate1];
}

- (IBAction)scene02Pressed:(id)sender
{
    [self setController:self.controllerDelegate2];
}

- (IBAction)scene03Pressed:(id)sender
{
    [self setController:self.controllerDelegate3];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
    
    _scene.camera.elipseParams = GLKVector3Make(2.0f, 2.0f, 2.0f);
    _scene.skyBox.cubeMapFile = "SkyBox.jpg";
    _scene.skyBox.scale = 5.0f;
    _scene.skyBox.alphaMapFile = "camap.png";
    _scene.obj.objFile = "Iseki2.obj";
    _scene.obj.position = GLKVector3Make(0.0f, -5.0f, -1.0f);
    _scene.obj.scale = 4.0f;
    _scene.obj.rotY = 0.0f;
    _scene.obj.rotY = M_PI/3.0f;
    
    _scene01 = SceneCreateFromFile("Scenes.xml", "Scene01");
    _scene02 = SceneCreateFromFile("Scenes.xml", "Scene02");
    _scene03 = SceneCreateFromFile("Scenes.xml", "Scene03");
    
    self.controllerDelegate1 = [[ControllerDelegate alloc] initWithScene:_scene01];
    self.controllerDelegate2 = [[ControllerDelegate alloc] initWithScene:_scene02];
    self.controllerDelegate3 = [[ControllerDelegate alloc] initWithScene:_scene03];

    [self setController:self.controllerDelegate1];
}

- (void)setController:(ControllerDelegate*)controllerDelegate
{
    GLKView *view = (GLKView *)self.view;
    self.delegate = controllerDelegate;
    view.delegate = controllerDelegate;
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    SceneDestroy(&_scene01);
    SceneDestroy(&_scene01);
    SceneDestroy(&_scene03);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
}

@end
