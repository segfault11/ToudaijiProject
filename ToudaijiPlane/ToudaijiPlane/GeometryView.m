//
//  GeometryView.m
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 31.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "GeometryView.h"
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
    GLKMatrix4 _translation;
    GLKMatrix4 _rotX;
    GLKMatrix4 _rotY;	
}
@property(nonatomic, strong) GLUEProgram* program;
- (void)initGL;
@end


@implementation GeometryView
- (id)initFromFile:(NSString*)filename
{
    self = [super init];
    
    [self initGL];
    
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
    _projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60.0f), h/w, 0.01f, 100.0f); // height is width and width is height ....
    [self.program SetUniform:@"projection" WithMat4:_projection.m];

    // set model matrices
    _translation = GLKMatrix4MakeTranslation(0.0f, 0.0f, -10.0f);
    _rotX = GLKMatrix4MakeRotation(0.0f, 1.0f, 0.0f, 0.0f);
    _rotY = GLKMatrix4MakeRotation(0.0f, 0.0f, 1.0f, 0.0f);
    
    // geometry
    glGenBuffers(1, &_buffer);
    ASSERT(_buffer != 0)
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices), cubeVertices, GL_STATIC_DRAW);

    glGenBuffers(1, &_idxBuffer);
    ASSERT(_idxBuffer != 0)
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _idxBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(cubeIndices), cubeIndices, GL_STATIC_DRAW);

    glGenVertexArraysOES(1, &_vertexArray);
    ASSERT(_vertexArray != 0)
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
    GLKMatrix4 model = _rotX;;
    model = GLKMatrix4Multiply(model, _rotY);
    model = GLKMatrix4Multiply(model, _translation);
    
    [self.program SetUniform:@"model" WithMat4:model.m];
    
    [self.program bind];
    glBindVertexArrayOES(_vertexArray);
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_SHORT, 0);
}

- (void)setRotationY:(float)angle
{
    _rotY = GLKMatrix4MakeRotation(angle, 0.0f, 1.0f, 0.0f);
}

- (void)setTranslation:(const GLKVector3*)v
{

}

@end
