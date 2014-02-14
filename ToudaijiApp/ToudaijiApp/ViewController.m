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
#import "SkyBoxRenderer.h"
//------------------------------------------------------------------------------
@interface ViewController ()
@property (strong, nonatomic) EAGLContext* context;
@property (strong, nonatomic) SkyBoxRenderer* skyBoxRender;
- (void)setupGL;
- (void)tearDownGL;
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
    
    self.skyBoxRender = [SkyBoxRenderer instance];    
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
#pragma mark - GLKView and GLKViewController delegate methods
//------------------------------------------------------------------------------
- (void)update
{

}
//------------------------------------------------------------------------------
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    [self.skyBoxRender render:0];
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------
