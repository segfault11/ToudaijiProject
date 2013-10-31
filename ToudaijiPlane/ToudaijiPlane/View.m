//
//  View.m
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 30.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//
#import "View.h"
#import "GLUEProgram.h"
#import <CoreVideo/CVOpenGLESTextureCache.h>
#import "Util.h"
#import <GLKit/GLKMath.h>

static GLfloat unitQuad[] = {
        0.0, 0.0,
        1.0, 0.0,
        1.0, 1.0,
        0.0, 0.0,
        1.0, 1.0,
        0.0, 1.0
    };

@interface View ()
{
    CVOpenGLESTextureCacheRef _videoTextureCache;
    GLuint _buffer;
    GLuint _vertexArray;
    CVOpenGLESTextureRef _textureRef;
}
@property(nonatomic, strong) NSObject<Drawable>* drawable;
@property(nonatomic, strong) GLUEProgram* program;
@property(nonatomic, strong) AVCaptureSession* session;
@property(nonatomic, strong) AVCaptureDevice* backCamera;
@property(nonatomic, strong) AVCaptureDeviceInput* input;
@property(nonatomic, strong) AVCaptureVideoDataOutput* output;
@property(nonatomic, strong) AVCaptureVideoPreviewLayer* previewLayer;
- (void)initVideoCapture;
- (void)initTextureCache:(EAGLContext*)glContext;
- (void)initGL;
@end

@implementation View

- (id)initWithGLContext:(EAGLContext*)glContext;
{
    self = [super init];
    
    [self initVideoCapture];
    [self initTextureCache:glContext];
    [self initGL];

    return self;
}

- (void)initVideoCapture
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
    
    if (!self.input) {
        NSLog(@"Failed to create capture device input");
        exit(0);
    }
    
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    } else {
        NSLog(@"Failed to add input");
        exit(0);
    }
    
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

- (void)initTextureCache:(EAGLContext*)glContext;
{
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, glContext, NULL, &_videoTextureCache);
    ASSERT(err == 0)
}

- (void)initGL
{
    // program
    self.program = [[GLUEProgram alloc] init];
    [self.program attachShaderOfType:GL_VERTEX_SHADER FromFile:@"ViewVS.glsl"];
    [self.program attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"ViewFS.glsl"];
    [self.program bindAttribLocation:0 ToVariable:@"pos"];
    [self.program compile];
    
    // program vars
    [self.program SetUniform:@"frame" WithInt:0];
    
    // geometry
    glGenBuffers(1, &_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(unitQuad), unitQuad, GL_STATIC_DRAW);
    
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_TRUE, 0, 0);
    
    ASSERT(GL_NO_ERROR == glGetError());
}

- (void)dealloc
{
    glDeleteBuffers(1, &_buffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
}

- (void)setDrawable:(NSObject<Drawable>*)drawable
{
    self.drawable = drawable;
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    size_t frameWidth = CVPixelBufferGetWidth(pixelBuffer);
    size_t frameHeight = CVPixelBufferGetHeight(pixelBuffer);
    
    CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(
            kCFAllocatorDefault,
            _videoTextureCache,
            pixelBuffer,
            NULL,
            GL_TEXTURE_2D,
            GL_RGBA,
            (GLint)frameWidth,
            (GLint)frameHeight,
            GL_BGRA,
            GL_UNSIGNED_BYTE,
            0,
            &_textureRef
        );

    ASSERT(_textureRef || !err)
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(CVOpenGLESTextureGetTarget(_textureRef), CVOpenGLESTextureGetName(_textureRef));
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // draw video stream
    glClearColor(0.65f, 0.65f, 0.95f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(CVOpenGLESTextureGetTarget(_textureRef), CVOpenGLESTextureGetName(_textureRef));
    [self.program bind];
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    // draw drawable
    [self.drawable draw];
    
    glFlush();
    
    ASSERT(GL_NO_ERROR == glGetError());
    CFRelease(_textureRef);
    CVOpenGLESTextureCacheFlush(_videoTextureCache, 0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    
}
@end
