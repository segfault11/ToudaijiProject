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

static GLushort cubeIndices[] = {
    0, 1, 2,
    4, 7, 6,
    0, 4, 5,
    1, 5, 2,
    2, 6, 3,
    4, 0, 3,
    3, 0, 2,
    5, 4, 6,
    1, 0, 5,
    5, 6, 2,
    6, 7, 3,
    7, 4, 3
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
    GLuint _vertexArray;
    GLuint _posBuffer;
    GLuint _indexBuffer;
    GLKMatrix4 _perspective;
    GLKMatrix4 _rotX;
    GLKMatrix4 _rotY;
}
@property (strong, nonatomic) GLUEProgram* program;
- (void)setUpGLSLObject;
- (void)setUpGeometry;
- (void)setupCubeMap:(NSString*)filename;
@end

@implementation SkyBoxRenderer

- (id)initWithCubeMap:(NSString*)filename;
{
    /* default init */
    _perspective = GLKMatrix4Identity;
    _rotX = GLKMatrix4Identity;
    _rotY = GLKMatrix4Identity;
    _cubeMap = 0;
    _vertexArray = 0;
    _posBuffer = 0;
    _indexBuffer = 0;
    
    self = [super init];
    [self setUpGLSLObject];
    [self setUpGeometry];
    [self setupCubeMap:filename];
    
    return self;
}

- (void)dealloc
{
    glDeleteBuffers(1, &_posBuffer);
    glDeleteBuffers(1, &_indexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    glDeleteTextures(1, &_cubeMap);
}

- (void)setupCubeMap:(NSString*)filename
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

- (void)setPerspectice:(const GLKMatrix4 *)m
{
    _perspective = *m;
    [self.program setUniform:@"perspective" WithMat4:_perspective.m];
}

- (void)setRotationX:(float)angle
{
    _rotX = GLKMatrix4MakeRotation(angle, 1.0f, 0.0f, 0.0);
    GLKMatrix4 model = GLKMatrix4Multiply(_rotX, _rotY);
    [self.program setUniform:@"model" WithMat4:model.m];
}

- (void)setRotationY:(float)angle
{
    _rotY = GLKMatrix4MakeRotation(angle, 0.0f, 1.0f, 0.0);
    GLKMatrix4 model = GLKMatrix4Multiply(_rotX, _rotY);
    [self.program setUniform:@"model" WithMat4:model.m];
}

- (void)setUpGLSLObject
{
    self.program = [[GLUEProgram alloc] init];
    [self.program attachShaderOfType:GL_VERTEX_SHADER FromFile:@"SkyBoxRendererVS.glsl"];
    [self.program attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"SkyBoxRendererFS.glsl"];
    [self.program bindAttribLocation:0 ToVariable:@"pos"];
    [self.program compile];
    
    /* default init it */
    _perspective = GLKMatrix4MakePerspective(
            GLKMathDegreesToRadians(31.3f),
            1024.0f/768.0f,
            0.01f, 100.0f
        );
    
    [self.program setUniform:@"perspective" WithMat4:_perspective.m];
    [self.program setUniform:@"cubeMap" WithInt:0];
    
    GLKMatrix4 model = GLKMatrix4Identity;
    
    [self.program setUniform:@"model" WithMat4:model.m];
    
    
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
    [self.program bind];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_CUBE_MAP, _cubeMap);
    glBindVertexArrayOES(_vertexArray);
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
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

