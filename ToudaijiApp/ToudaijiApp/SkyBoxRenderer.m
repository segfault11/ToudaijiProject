//------------------------------------------------------------------------------
//
//  SkyBoxRenderer.m
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 14.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "SkyBoxRenderer.h"
#import "GLUEProgram.h"
#import <assert.h>
#import <GLKit/GLKit.h>
#import "Camera.h"
#import "SkyBoxManager.h"
#import <opencv2/highgui/highgui_c.h>
//------------------------------------------------------------------------------
//  Skybox Geometry
//------------------------------------------------------------------------------
static GLfloat cubeVertices[] ={
    1.0, -1.0, -1.0,
    1.0, -1.0,  1.0,
    -1.0, -1.0,  1.0,
    -1.0,  -1.0,  -1.0,
    1.0,  1.0, -1.0,
    1.0, 1.0, 1.0,
    -1.0, 1.0, 1.0,
    -1.0,  1.0, -1.0
};
//------------------------------------------------------------------------------
static GLushort cubeIndices[] = {
    4, 7, 6,
    0, 4, 5,
    1, 5, 2,
    2, 6, 3,
    4, 0, 3,
    5, 4, 6,
    1, 0, 5,
    5, 6, 2,
    6, 7, 3,
    7, 4, 3,
    0, 1, 2,
    3, 0, 2
};
//------------------------------------------------------------------------------
void setCubeMapData(const char* filename);
//------------------------------------------------------------------------------
@interface SkyBoxRenderer ()
{
    GLuint _buffer;
    GLuint _indices;
    GLuint _vao;
    GLUEProgram* _program;
    Camera* _camera;
    SkyBoxManager* _skyBoxManager;
}
@property(nonatomic, strong) NSMutableDictionary* skyBoxTextures;
-(id)init;
-(void)dealloc;
-(void)initGL;
-(void)setUpCubeMap:(SkyBox*)skyBox;
@end
//------------------------------------------------------------------------------
@implementation SkyBoxRenderer
//------------------------------------------------------------------------------
+(SkyBoxRenderer*)instance
{
    static SkyBoxRenderer* instance = nil;
    
    @synchronized(self)
    {
        if (!instance)
        {
            instance = [[SkyBoxRenderer alloc] init];
        }
    }
    
    return instance;
}
//------------------------------------------------------------------------------
-(id)init
{
    self = [super init];
    _camera = [Camera instance];
    _skyBoxManager = [SkyBoxManager instance];
    self.skyBoxTextures = [[NSMutableDictionary alloc] init];
    [self initGL];
    return self;
}
//------------------------------------------------------------------------------
-(void)initGL
{
    glGenBuffers(1, &_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);

    glGenBuffers(1, &_indices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indices);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(cubeIndices), cubeIndices, GL_STATIC_DRAW);
    
    glGenVertexArraysOES(1, &_vao);
    glBindVertexArrayOES(_vao);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indices);
    
    _program = [[GLUEProgram alloc] init];
    [_program attachShaderOfType:GL_VERTEX_SHADER FromFile:@"SBRVS.glsl"];
    [_program attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"SBRFS.glsl"];
    [_program bindAttribLocation:0 ToVariable:@"position"];
    [_program compile];
    
    for (int i = 0; i < [_skyBoxManager getNumSkyBoxes]; i++)
    {
        [self setUpCubeMap:[_skyBoxManager getSkyBoxAtIndex:i]];
    }
    
    assert(GL_NO_ERROR == glGetError());
}
//------------------------------------------------------------------------------
-(void)dealloc
{
    glDeleteBuffers(1, &_buffer);
    glDeleteBuffers(1, &_indices);
    glDeleteVertexArraysOES(1, &_vao);
    
    for (NSNumber* tex in self.skyBoxTextures)
    {
        GLuint texHandle = [tex unsignedIntegerValue];
        glDeleteTextures(1, &texHandle);
    }
}
//------------------------------------------------------------------------------
-(void)render:(id)skyBox
{
    GLKMatrix4 view = [_camera getView];
    GLKMatrix4 perspective = [_camera getView];
    GLuint cubeMap = [[self.skyBoxTextures objectForKey:[NSNumber numberWithInt:0]] unsignedIntegerValue];
    
    [_program bind];
    [_program setUniform:@"view" WithMat4:view.m];
    [_program setUniform:@"perspective" WithMat4:perspective.m];
    [_program setUniform:@"skyBox" WithInt:0];
    
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_CUBE_MAP, cubeMap);
    glBindVertexArrayOES(_vao);
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
    
    assert(GL_NO_ERROR == glGetError());
}
//------------------------------------------------------------------------------
-(void)setUpCubeMap:(SkyBox*)skyBox
{
    GLuint cubeMap;
    glGenTextures(1, &cubeMap);
    glBindTexture(GL_TEXTURE_CUBE_MAP, cubeMap);
    NSString* fullName = [[[[NSBundle mainBundle] resourcePath]
                           stringByAppendingString:@"/"]
                          stringByAppendingString:skyBox.fileName];
    setCubeMapData((const char*)[fullName UTF8String]);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    assert(GL_NO_ERROR == glGetError());
    
    [self.skyBoxTextures setObject:[NSNumber numberWithUnsignedInt:cubeMap] forKey:[NSNumber numberWithInt:skyBox.id]];
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------
void setQuad(IplImage* quad, IplImage* cubeMap, CvRect rect, GLenum target)
{
    cvSetImageROI(cubeMap, rect);
    cvCopy(cubeMap, quad, NULL);
    
    glTexImage2D(
                 target, 0, GL_RGB, rect.width, rect.height, 0,
                 GL_RGB, GL_UNSIGNED_BYTE, quad->imageData
                 );
}
//------------------------------------------------------------------------------
void setCubeMapData(const char* filename)
{
    /* load image */
    IplImage* img = cvLoadImage(filename, CV_LOAD_IMAGE_COLOR);

    /* error checks */
    assert(img != NULL);
    assert(img->width % 4 == 0);
    assert(img->height % 3 == 0);
    
    /* compute the width and height of images of each cubes quad. */
    int w = img->width/4;
    int h = img->height/3;
    
    IplImage* quad = cvCreateImage(cvSize(w, h), 8, 3);
    
    /* extract the images for each texture target of the cube map and upload
     ** it to the gpu.
     */
    setQuad(quad, img, cvRect(0*w, 1*h, w, h), GL_TEXTURE_CUBE_MAP_NEGATIVE_X);
    setQuad(quad, img, cvRect(1*w, 1*h, w, h), GL_TEXTURE_CUBE_MAP_POSITIVE_Z);
    setQuad(quad, img, cvRect(2*w, 1*h, w, h), GL_TEXTURE_CUBE_MAP_POSITIVE_X);
    setQuad(quad, img, cvRect(3*w, 1*h, w, h), GL_TEXTURE_CUBE_MAP_NEGATIVE_Z);
    setQuad(quad, img, cvRect(1*w, 0*h, w, h), GL_TEXTURE_CUBE_MAP_POSITIVE_Y);
    setQuad(quad, img, cvRect(1*w, 2*h, w, h), GL_TEXTURE_CUBE_MAP_NEGATIVE_Y);
    
    /* clean up */
    cvReleaseImage(&img);
}
//------------------------------------------------------------------------------

