//
//  SkyBoxRenderer.m
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 10.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <GLKit/GLKit.h>
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

@interface SkyBoxRenderer ()
{
    GLuint _cubeMap;
    GLuint _vertexArray;
    GLuint _posBuffer;
    GLuint _indexBuffer;
}
@property (strong, nonatomic) GLUEProgram* program;
- (void)setUpGLSLObject;
- (void)setUpGeometry;
- (void)setupCubeMap:(NSString*)filename;
@end

@implementation SkyBoxRenderer

- (id)initWithCubeMap:(NSString*)filename;
{
    self = [super init];
    [self setUpGLSLObject];
    [self setUpGeometry];
    return self;
}

- (void)dealloc
{
    glDeleteBuffers(1, &_posBuffer);
    glDeleteBuffers(1, &_indexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
}

- (void)setupCubeMap:(NSString*)filename
{
    glGenTextures(1, &_cubeMap);
    glBindTexture(GL_TEXTURE_CUBE_MAP, _cubeMap);
    NSString* fullName = [[[[NSBundle mainBundle] resourcePath]
                           stringByAppendingString:@"/"]
                           stringByAppendingString:filename];
    // setCubeMapData((const char*)[fullName UTF8String]);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
}

- (void)setUpGLSLObject
{
    self.program = [[GLUEProgram alloc] init];
    [self.program attachShaderOfType:GL_VERTEX_SHADER FromFile:@"SkyBoxRendererVS.glsl"];
    [self.program attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"SkyBoxRendererFS.glsl"];
    [self.program bindAttribLocation:0 ToVariable:@"pos"];
    [self.program compile];
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
    glBindVertexArrayOES(_vertexArray);
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
}
@end
