//
//  ViewController.m
//  CameraCapture
//
//  Created by Arno in Wolde Lübke on 29.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()

@property(nonatomic, strong) AVCaptureSession* session;
@property(nonatomic, strong) AVCaptureDevice* backCamera;
@property(nonatomic, strong) AVCaptureDeviceInput* input;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // init and configure a AVCaptureSession
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    
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
    
    if (!self.input) {
        NSLog(@"Failed to create capture device input");
    }
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    } else {
        NSLog(@"Failed to add input");
    }
    
    // create a preview layer
    self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    self.previewLayer.frame = cameraView.frame;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    screenRect.size.width = 1024;
    screenRect.size.height = 768;
    
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.bounds = screenRect;
    self.previewLayer.position = CGPointMake(CGRectGetMidX(screenRect), CGRectGetMidY(screenRect));
    [self.previewLayer.connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    [cameraView.layer addSublayer:self.previewLayer];
    
    [self.session startRunning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
