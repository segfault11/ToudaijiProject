//
//  Controller.h
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 31.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <CoreLocation/CoreLocation.h>

@interface Controller : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, CLLocationManagerDelegate>
- (id)initWithGLContext:(EAGLContext*)context;
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
@end
