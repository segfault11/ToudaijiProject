//
//  View.h
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 30.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//


/*
** Renders video frames
*/

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Drawable.h"

@interface View : NSObject <AVCaptureVideoDataOutputSampleBufferDelegate, GLKViewDelegate>
- (id)initWithGLContext:(EAGLContext*)glContext;
- (void)setDrawable:(NSObject<Drawable>*)drawable;
- (void)dealloc;
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect;
@end
