//
//  ViewController.m
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 10.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "ControllerDelegate.h"
#import "ViewController.h"


@interface ViewController ()
{
    IBOutlet UIButton* button;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (strong, nonatomic) ControllerDelegate* controllerDelegate;

- (IBAction)scene01Pressed:(id)sender;
- (IBAction)scene02Pressed:(id)sender;
- (IBAction)scene03Pressed:(id)sender;
- (void)setupGL;

@end

@implementation ViewController


- (IBAction)scene01Pressed:(id)sender
{
    [self.controllerDelegate setCubeMap:@"SkyBox.jpg"];
}

- (IBAction)scene02Pressed:(id)sender
{
    [self.controllerDelegate setCubeMap:@"SkyBox04.jpg"];
}

- (IBAction)scene03Pressed:(id)sender
{
    [self.controllerDelegate setCubeMap:@"SkyBox03.jpg"];
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
    
    self.controllerDelegate = [[ControllerDelegate alloc] init];
    self.delegate = self.controllerDelegate;
    view.delegate = self.controllerDelegate;
}

- (void)dealloc
{
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
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
