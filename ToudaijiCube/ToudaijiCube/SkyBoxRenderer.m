//
//  SkyBoxRenderer.m
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 10.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <opencv2/highgui/highgui_c.h>
#import "SkyBoxRenderer.h"
#import "ErrorHandler.h"
#import "GLUEProgram.h"

/*******************************************************************************
**  Skybox Geometry
*******************************************************************************/
static GLfloat cubeVertices[] = {
    1.0, -1.0, -1.0,
    1.0, -1.0,  1.0,
    -1.0, -1.0,  1.0,
    -1.0,  -1.0,  -1.0,
    1.0,  1.0, -1.0,
    1.0, 1.0, 1.0,
    -1.0, 1.0, 1.0,
    -1.0,  1.0, -1.0
};

static GLfloat quadVertices[] = {
    -1.0f, -1.0f, 1.0f,
    1.0f, -1.0f, 1.0f,
    1.0f, -1.0f, -1.0f,

    -1.0f, -1.0f, 1.0f,
    1.0f, -1.0f, -1.0f,
    -1.0f, -1.0f, -1.0f,
};

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
/******************************************************************************/

/*******************************************************************************
**  Declaration for file private aux. functions.
*******************************************************************************/

void setCubeMapData(const char* filename);

/******************************************************************************/

@interface SkyBoxRenderer ()
{
    GLuint _cubeMap;
    GLuint _alphaMask;
    GLuint _vertexArray;
    GLuint _posBuffer;
    GLuint _indexBuffer;
    GLKMatrix4 _perspective;
    GLKMatrix4 _rotX;
    GLKMatrix4 _rotY;
    GLKMatrix4 _rotZ;
    GLKMatrix4 _translation;
    GLKMatrix4 _scale;      // scalematrix
    float _sscale;          // scale of the skybox
    float _rotAmap;
    GLKVector3 _camPos;     // position of the cam in the cube (set
                            // via [setTranslation])
    
    struct
    {
        GLuint _vao;
        GLuint _vbo;
        GLuint _program;
        GLuint _fbo;
        GLuint _targTex;
    }
    _alphaMap;
}
@property (strong, nonatomic) GLUEProgram* program;
@property (strong, nonatomic) GLUEProgram* programAM;

- (void)setDefault;
- (void)setUpGLSLObject;
- (void)setUpGeometry;
- (void)setUpAlphaMap;
- (void)setUpCubeMap:(NSString*)filename;
- (void)setUpAlphaMask;
@end

@implementation SkyBoxRenderer

- (void)setDefault
{
    /* default init member */
    _perspective = GLKMatrix4MakePerspective(
                                             GLKMathDegreesToRadians(51.3f),
                                             1024.0f/768.0f,
                                             0.001f, 100.0f
                                             );
    
    _rotX = GLKMatrix4Identity;
    _rotY = GLKMatrix4Identity;
    _rotZ = GLKMatrix4Identity;
    _scale = GLKMatrix4Identity;
    _translation = GLKMatrix4Identity;
    _cubeMap = 0;
    _vertexArray = 0;
    _posBuffer = 0;
    _indexBuffer = 0;
    _alphaMask = 0;
    _sscale = 1.0f;
    _rotAmap = 0.0f;
}

- (id)initWithCubeMap:(NSString*)filename;
{
    [self setDefault];
    
    self = [super init];
    [self setUpGLSLObject];
    [self setUpAlphaMap];    
    [self setUpGeometry];
    [self setUpCubeMap:filename];
    [self setUpAlphaMask];

    return self;
}

- (void)setUpAlphaMap
{
    glGenBuffers(1, &_alphaMap._vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _alphaMap._vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), quadVertices, GL_STATIC_DRAW);
    
    glGenVertexArraysOES(1, &_alphaMap._vao);
    glBindVertexArrayOES(_alphaMap._vao);
    glBindBuffer(GL_ARRAY_BUFFER, _alphaMap._vbo);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
    
    self.programAM = [[GLUEProgram alloc] init];
    [self.programAM attachShaderOfType:GL_VERTEX_SHADER FromFile:@"AMRendererVS.glsl"];
    [self.programAM attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"AMRendererFS.glsl"];
    [self.programAM bindAttribLocation:0 ToVariable:@"pos"];
    [self.programAM compile];

    GLKMatrix4 rotation = GLKMatrix4Identity;
    [self.programAM setUniform:@"R" WithMat4:rotation.m];
    [self.programAM setUniform:@"T" WithMat4:_translation.m];
    [self.programAM setUniform:@"S" WithMat4:_scale.m];
    [self.programAM setUniform:@"SR" WithMat4:rotation.m];
    [self.programAM setUniform:@"offX" WithFloat:0.0f];
    [self.programAM setUniform:@"offZ" WithFloat:0.0f];
    [self.programAM setUniform:@"aMap" WithInt:0];
    [self.programAM setUniform:@"perspective" WithMat4:_perspective.m];

    GLint oldFBO;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
    
    glGenFramebuffers(1, &_alphaMap._fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, _alphaMap._fbo);
    
    glGenTextures(1, &_alphaMap._targTex);
    glBindTexture(GL_TEXTURE_2D, _alphaMap._targTex);

    GLubyte* data = malloc(sizeof(GLubyte)*1024*768);
    
    for (int i = 0; i < 1024*768; i++) {
        data[i] = 255;
    }
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, 1024, 768, 0, GL_RED_EXT, GL_UNSIGNED_BYTE, data);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _alphaMap._targTex, 0);
    
    GLuint status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Could not create FBO");
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);

    free(data);
    
    
    ASSERT( GL_NO_ERROR == glGetError() )
}


- (id)initWithCubeMap2:(NSString*)filename;
{
    /* default init */
    [self setDefault];
    
    self = [super init];
    [self setUpGLSLObject];
    [self setUpGeometry];
    [self setUpAlphaMask];
    
    return self;
}

- (void)dealloc
{
    glDeleteBuffers(1, &_posBuffer);
    glDeleteBuffers(1, &_indexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    glDeleteTextures(1, &_cubeMap);
    glDeleteTextures(1, &_alphaMask);
    glDeleteBuffers(1, &_alphaMap._vbo);
    glDeleteVertexArraysOES(1, &_alphaMap._vao);
    glDeleteTextures(1, &_alphaMap._targTex);
    glDeleteFramebuffers(1, &_alphaMap._fbo);
}

- (void)setUpCubeMap:(NSString*)filename
{
    glGenTextures(1, &_cubeMap);
    glBindTexture(GL_TEXTURE_CUBE_MAP, _cubeMap);
    NSString* fullName = [[[[NSBundle mainBundle] resourcePath]
                           stringByAppendingString:@"/"]
                           stringByAppendingString:filename];
    setCubeMapData((const char*)[fullName UTF8String]);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
 
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    ASSERT( GL_NO_ERROR == glGetError() )
}

- (void)setUpAlphaMask
{
    glGenTextures(1, &_alphaMask);
    glBindTexture(GL_TEXTURE_2D, _alphaMask);
  
    GLubyte* data = (GLubyte*)malloc(sizeof(GLubyte)*32*32);
    
    for (unsigned int i = 0; i < 32*32; i++)
    {
        data[i] = 255;
    }

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, 32, 32, 0, GL_RED_EXT, GL_UNSIGNED_BYTE, data);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    /* clean up */
    free(data);
    
    ASSERT( GL_NO_ERROR == glGetError() )
}

- (void)setUpGLSLObject
{
    self.program = [[GLUEProgram alloc] init];
//    [self.program attachShaderOfType:GL_VERTEX_SHADER FromFile:@"SBRVS.glsl"];
//    [self.program attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"SBRFS.glsl"];
    [self.program attachShaderOfType:GL_VERTEX_SHADER FromFile:@"SkyBoxRendererVS.glsl"];
    [self.program attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"SkyBoxRendererFS.glsl"];
    [self.program bindAttribLocation:0 ToVariable:@"pos"];
    [self.program compile];
    
    /* default init it */
    GLKMatrix4 rotation = GLKMatrix4Identity;
    [self.program setUniform:@"R" WithMat4:rotation.m];
    [self.program setUniform:@"T" WithMat4:_translation.m];
    [self.program setUniform:@"S" WithMat4:_scale.m];
    [self.program setUniform:@"perspective" WithMat4:_perspective.m];
    [self.program setUniform:@"cubeMap" WithInt:0];
    [self.program setUniform:@"alphaLayer" WithInt:1];

//    [self.program setUniform:@"alphaMask" WithInt:1];
//    [self.program setUniform:@"isBottom" WithInt:0];
//    [self.program setUniform:@"bottomXOffset" WithFloat:0.0f];
//    [self.program setUniform:@"bottomZOffset" WithFloat:0.0f];
//    [self.program setUniform:@"scale" WithFloat:1.0f];
//    [self.program setUniform:@"rotAmap" WithFloat:_rotAmap];
    
    ASSERT( glGetError() == GL_NO_ERROR )
}

- (void)setUpGeometry
{
    /* create and init position buffer */
    glGenBuffers(1, &_posBuffer);
    ASSERT( _posBuffer )
    glBindBuffer(GL_ARRAY_BUFFER, _posBuffer);
    
    glBufferData(
        GL_ARRAY_BUFFER, 
        sizeof(cubeVertices), 
        cubeVertices, 
        GL_STATIC_DRAW
    );

    /* create and init index buffer */
    glGenBuffers(1, &_indexBuffer);
    ASSERT( _indexBuffer )
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);

    glBufferData(
        GL_ELEMENT_ARRAY_BUFFER, 
        sizeof(cubeIndices), 
        cubeIndices, 
        GL_STATIC_DRAW
    );

    /* create and init vertex array */
    glGenVertexArraysOES(1, &_vertexArray);
    ASSERT( _vertexArray )
    glBindVertexArrayOES(_vertexArray);
    
    glBindBuffer(GL_ARRAY_BUFFER, _posBuffer);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer);

    ASSERT( glGetError() == GL_NO_ERROR )
}

- (void)render
{
    // create and set model matrix
    GLKMatrix4 rotation = GLKMatrix4Identity;

    rotation = GLKMatrix4Multiply(_rotY, rotation);
    rotation = GLKMatrix4Multiply(_rotZ, rotation);
    rotation = GLKMatrix4Multiply(_rotX, rotation);
    
    
    // draw the alpha map

    
    GLint oldFBO;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &oldFBO);
//    NSLog(@"OLD FBO %i", oldFBO);
    glBindFramebuffer(GL_FRAMEBUFFER, _alphaMap._fbo);
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    [self.programAM setUniform:@"R" WithMat4:rotation.m];
    [self.programAM setUniform:@"T" WithMat4:_translation.m];
    [self.programAM setUniform:@"S" WithMat4:_scale.m];
    [self.programAM bind];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _alphaMask);


    glBindVertexArrayOES(_alphaMap._vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glFlush();

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glBindFramebuffer(GL_FRAMEBUFFER, oldFBO);

    // draw cube

    [self.program setUniform:@"R" WithMat4:rotation.m];
    [self.program setUniform:@"T" WithMat4:_translation.m];
    [self.program setUniform:@"S" WithMat4:_scale.m];
    [self.program bind];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_CUBE_MAP, _cubeMap);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _alphaMap._targTex);
    glBindVertexArrayOES(_vertexArray);

    glEnable(GL_BLEND);
    glBlendEquation(GL_FUNC_ADD);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
    
    glDisable(GL_BLEND);



    // ----------
//
//    [self.programAM setUniform:@"R" WithMat4:rotation.m];
//    [self.programAM setUniform:@"T" WithMat4:_translation.m];
//    [self.programAM setUniform:@"S" WithMat4:_scale.m];
//    [self.programAM bind];
//    
//    glActiveTexture(GL_TEXTURE0);
//    glBindTexture(GL_TEXTURE_2D, _alphaMap._targTex);
//
//
//    glBindVertexArrayOES(_alphaMap._vao);
//    glDrawArrays(GL_TRIANGLES, 0, 6);
//    glFlush();

    ASSERT( glGetError() == GL_NO_ERROR )
    
}

- (void)setPerspective:(const GLKMatrix4 *)m
{
    _perspective = *m;
    [self.program setUniform:@"perspective" WithMat4:_perspective.m];
}

- (void)setRotationX:(float)angle
{
    _rotX = GLKMatrix4MakeRotation(angle, 1.0f, 0.0f, 0.0f);
}

- (void)setRotationY:(float)angle
{
    _rotY = GLKMatrix4MakeRotation(angle, 0.0f, 1.0f, 0.0f);
}

- (void)setRotationZ:(float)angle
{
    _rotZ = GLKMatrix4MakeRotation(angle, 0.0f, 0.0f, 1.0f);
}

- (void)setScale:(float)s
{
    _sscale = s;
//    [self.program setUniform:@"scale" WithFloat:s];
    _scale = GLKMatrix4MakeScale(s, s, s);
}

- (void)setBottomAlphaMask:(NSString*)filename
{
    NSString* fullName = [[[[NSBundle mainBundle] resourcePath]
                           stringByAppendingString:@"/"]
                          stringByAppendingString:filename];

    GLKTextureInfo* info = [GLKTextureLoader textureWithContentsOfFile:fullName options:nil error:nil];
    
    if (info.name == 0) {
        REPORT( "Loading alpha mask failed!" );
        return;
    }
    
    glDeleteTextures(1, &_alphaMask);
    _alphaMask = info.name;
}

- (void)setBottomAlphaMaskTranslationX:(float)x AndY:(float)y AndZ:(float)z
{
    [self.programAM setUniform:@"offX" WithFloat:x];
    [self.programAM setUniform:@"offY" WithFloat:y];
    [self.programAM setUniform:@"offZ" WithFloat:z];
//    [self.program setUniform:@"bottomXOffset" WithFloat:x];
//    [self.program setUniform:@"bottomZOffset" WithFloat:z];
}

- (void)setRotationAmap:(float)angle
{
    GLKMatrix4 rot = GLKMatrix4MakeRotation(angle, 0.0, 1.0, 0.0f);
    [self.programAM setUniform:@"SR" WithMat4:rot.m];
//    [self.program setUniform:@"rotAmap" WithFloat:angle];
}

- (void)setScaleAmap:(float)s
{
    [self.programAM setUniform:@"scaleObj" WithFloat:s];
}

- (void)setTranslation:(const GLKVector3*)pos
{
    _camPos = GLKVector3MultiplyScalar(*pos, -1.0f);
    _translation = GLKMatrix4MakeTranslation(pos->x, pos->y, pos->z);
}

@end

/*******************************************************************************
**  Definition of file private aux. functions.
*******************************************************************************/

/* an aux. function used by setCubeMapData */
void setQuad(IplImage* quad, IplImage* cubeMap, CvRect rect, GLenum target)
{
    cvSetImageROI(cubeMap, rect);
    cvCopy(cubeMap, quad, NULL);
    
    glTexImage2D(
        target, 0, GL_RGB, rect.width, rect.height, 0,
        GL_RGB, GL_UNSIGNED_BYTE, quad->imageData
    );
}

/*
** This function extracts the six images of the cube map and uploads these 
** images to the texture targets of the OpenGL cube map.
*/
void setCubeMapData(const char* filename)
{
    /* load image */
    IplImage* img = cvLoadImage(filename, CV_LOAD_IMAGE_COLOR);

    /* error checks */
    if (img == NULL)
    {
        REPORT( "Cube Map file not found." )
    }
    
    if (img->width % 4 != 0)
    {
        REPORT( "Invalid image dimensions." )
    }
    
    if (img->height % 3 != 0)
    {
        REPORT( "Invalid image dimensions." )
    }
    
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
/******************************************************************************/

