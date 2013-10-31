//
//  GeometryView.m
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 31.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "GeometryView.h"
#import <GLKit/GLKMath.h>
#import "GLUEProgram.h"
#import "Util.h"

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

GLushort cubeIndices[] = {
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

@interface GeometryView ()
{
    GLuint _buffer;
    GLuint _idxBuffer;
    GLuint _vertexArray;
    GLKMatrix4 _projection;
    GLKMatrix4 _model;
}
@property(nonatomic, strong) GLUEProgram* program;
- (void)initGL;
@end


@implementation GeometryView
- (id)initFromFile:(NSString*)filename
{
    self = [super init];
    
    return self;
}

- (void)initGL
{
    // program
    self.program = [[GLUEProgram alloc] init];
    [self.program attachShaderOfType:GL_VERTEX_SHADER FromFile:@"GeometryViewVS.glsl"];
    [self.program attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"GeometryViewFS.glsl"];
    [self.program bindAttribLocation:0 ToVariable:@"position"];
    [self.program compile];
    ASSERT(GL_NO_ERROR == glGetError())

    // program uniforms
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat w = screenRect.size.width;
    CGFloat h = screenRect.size.height;
    _projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f), w/h, 0.01f, 100.0f);
    [self.program SetUniform:@"projection" WithMat4:_projection.m];
    _model = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.0f);
    [self.program SetUniform:@"model" WithMat4:_model.m];
    
    // geometry
    glGenBuffers(1, &_buffer);
    ASSERT(_buffer == 0)
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_idxBuffer);
    ASSERT(_idxBuffer == 0)
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _idxBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(cubeIndices), cubeIndices, GL_STATIC_DRAW);
    
    glGenVertexArraysOES(1, &_vertexArray);
    ASSERT(_vertexArray == 0)
    glBindVertexArrayOES(_vertexArray);
    glEnableVertexAttribArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _idxBuffer);
}

- (void)dealloc
{
    glDeleteBuffers(1, &_buffer);
    glDeleteBuffers(1, &_idxBuffer);
}

- (void)draw;
{
    glClear(GL_DEPTH_BUFFER_BIT);
    [self.program bind];
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
}
@end
