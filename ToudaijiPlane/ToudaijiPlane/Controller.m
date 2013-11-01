//
//  Controller.m
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 31.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "Controller.h"
#import "VideoView.h"
#import "GeometryView.h"
#import "Util.h"

@interface Controller ()
{
    double _rotY;
}
@property(nonatomic, strong) VideoView* videoView;
@property(nonatomic, strong) GeometryView* geometryView;
@property(nonatomic, strong) AVCaptureSession* session;
@property(nonatomic, strong) AVCaptureDevice* backCamera;
@property(nonatomic, strong) AVCaptureDeviceInput* input;
@property(nonatomic, strong) AVCaptureVideoDataOutput* output;
@property(nonatomic, strong) CMMotionManager* manager;
- (void)initCaptureSession;
- (void)initCoreMotion;
@end


@implementation Controller

- (id)initWithGLContext:(EAGLContext*)context
{
    self = [super init];

    self.videoView = [[VideoView alloc] initWithGLContext:context];
    ASSERT(self.videoView != nil);
    self.geometryView = [[GeometryView alloc] initFromFile:@""];
    [self initCaptureSession];
    [self initCoreMotion];

    return self;
}

- (void)initCaptureSession
{
    // init and configure a AVCaptureSession
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetMedium;
    
    // select the back camera
    NSArray *devices = [AVCaptureDevice devices];
    
    for (AVCaptureDevice *device in devices) {
        
        if ([device hasMediaType:AVMediaTypeVideo]) {
            
            if ([device position] == AVCaptureDevicePositionBack) {
                self.backCamera = device;
            }
        }
    }
    
    // create a capture input device
    NSError* error;
    self.input = [AVCaptureDeviceInput deviceInputWithDevice:self.backCamera error:&error];
    
    ASSERT(self.input)
    ASSERT([self.session canAddInput:self.input])
    [self.session addInput:self.input];
    
    // create an output device
    self.output = [[AVCaptureVideoDataOutput alloc] init];
    [self.output setAlwaysDiscardsLateVideoFrames:YES]; // Probably want to set this to NO when recording
    self.output.videoSettings = @{ (NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA) };
    [self.output setSampleBufferDelegate:self queue:dispatch_get_main_queue()]; // Set dispatch to be on the main thread so OpenGL can do things with the data
    ASSERT([self.session canAddOutput:self.output]);
    [self.session addOutput:self.output];
    
    // start the session
    [self.session startRunning];
}

- (void)initCoreMotion
{
    self.manager = [[CMMotionManager alloc] init];
    self.manager.deviceMotionUpdateInterval = 1.0/15.0;
    self.manager.showsDeviceMovementDisplay = YES;
    [self.manager startDeviceMotionUpdates];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.videoView draw:sampleBuffer];
    NSLog(@"%lf", self.manager.deviceMotion.attitude.roll);
    glClear(GL_DEPTH_BUFFER_BIT);
    [self.geometryView setRotationX:self.manager.deviceMotion.attitude.roll + GLKMathDegreesToRadians(90.0)];
    [self.geometryView setRotationY:-self.manager.deviceMotion.attitude.yaw];
    [self.geometryView draw];
}


@end
