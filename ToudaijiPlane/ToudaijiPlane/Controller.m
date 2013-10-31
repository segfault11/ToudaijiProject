//
//  Controller.m
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 31.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

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
@property(strong) CLLocationManager *locationManager;
- (void)initCaptureSession;
- (void)initLocationTracking;
@end


@implementation Controller

- (id)initWithGLContext:(EAGLContext*)context
{
    self = [super init];

    self.videoView = [[VideoView alloc] initWithGLContext:context];
    ASSERT(self.videoView != nil);
    self.geometryView = [[GeometryView alloc] initFromFile:@""];
    [self initCaptureSession];
    [self initLocationTracking];

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

- (void)initLocationTracking
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.headingFilter = 2.0;
    [self.locationManager startUpdatingHeading];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self.videoView draw:sampleBuffer];
    
    glClear(GL_DEPTH_BUFFER_BIT);
    [self.geometryView setRotationY:_rotY];
    [self.geometryView draw];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    _rotY = GLKMathDegreesToRadians([newHeading trueHeading]);
    NSLog(@"roty = %lf", _rotY);
}

@end
