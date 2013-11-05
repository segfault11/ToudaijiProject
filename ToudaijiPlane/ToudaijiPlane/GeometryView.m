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

static GLfloat cubeVertices2[] =
{
    1.0, -1.0, -1.0,                // 0
    1.0, -1.0,  1.0,                // 1
    -1.0, -1.0,  1.0,               // 2
    
    1.0, -1.0, -1.0,                // 0
    1.0,  1.0, -1.0,                // 4
    1.0, 1.0, 1.0,                  // 5
    
    1.0, -1.0,  1.0,                // 1
    1.0, 1.0, 1.0,                  // 5
    -1.0, -1.0,  1.0,               // 2
    
    -1.0, -1.0,  1.0,               // 2
    -1.0, 1.0, 1.0,                 // 6
    -1.0,  -1.0,  -1.0,             // 3
    
    1.0,  1.0, -1.0,                // 4
    1.0, -1.0, -1.0,                // 0
    -1.0,  -1.0,  -1.0,             // 3
    
    -1.0,  -1.0,  -1.0,             // 3
    1.0, -1.0, -1.0,                // 0
    -1.0, -1.0,  1.0,               // 2
    
    1.0, -1.0,  1.0,                // 1
    1.0, -1.0, -1.0,                // 0
    1.0, 1.0, 1.0,                  // 5
    
    1.0, 1.0, 1.0,                  // 5
    -1.0, 1.0, 1.0,                 // 6
    -1.0, -1.0,  1.0,               // 2
    
    -1.0, 1.0, 1.0,                 // 6
    -1.0,  1.0, -1.0,               // 7
    -1.0,  -1.0,  -1.0,             // 3
    
    -1.0,  1.0, -1.0,               // 7
    1.0,  1.0, -1.0,                // 4
    -1.0,  -1.0,  -1.0              // 3
};


static GLfloat cubeNormals2[] =
{
    0.0, -1.0, 0.0,
    0.0, -1.0, 0.0,
    0.0, -1.0, 0.0,

    1.0, 0.0, 0.0,
    1.0, 0.0, 0.0,
    1.0, 0.0, 0.0,

    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,

    -1.0, 0.0, 0.0,
    -1.0, 0.0, 0.0,
    -1.0, 0.0, 0.0,
    
    0.0, 0.0, -1.0,
    0.0, 0.0, -1.0,
    0.0, 0.0, -1.0,
    
    0.0, -1.0, 0.0,
    0.0, -1.0, 0.0,
    0.0, -1.0, 0.0,

    1.0, 0.0, 0.0,
    1.0, 0.0, 0.0,
    1.0, 0.0, 0.0,
    
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    0.0, 0.0, 1.0,
    
    -1.0, 0.0, 0.0,
    -1.0, 0.0, 0.0,
    -1.0, 0.0, 0.0,
    
    0.0, 0.0, -1.0,
    0.0, 0.0, -1.0,
    0.0, 0.0, -1.0
};



@interface GeometryView ()
{
    GLuint _buffer;
    GLuint _nrmBuffer; // normal buffer
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
    [self.program bindAttribLocation:1 ToVariable:@"normal"];
    [self.program compile];
    ASSERT(GL_NO_ERROR == glGetError())

    // program uniforms
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat w = screenRect.size.width;
    CGFloat h = screenRect.size.height;
    _projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(31.3f), h/w, 0.01f, 100.0f); // height is width and width is height ....
    [self.program setUniform:@"projection" WithMat4:_projection.m];

    // set model matrices
    _translation = GLKMatrix4MakeTranslation(0.0f, -30.0f, -60.0f);
    _rotX = GLKMatrix4MakeRotation(0.0f, 1.0f, 0.0f, 0.0f);
    _rotY = GLKMatrix4MakeRotation(0.0f, 0.0f, 1.0f, 0.0f);
    
    // geometry
    glGenBuffers(1, &_buffer);
    ASSERT(_buffer != 0)
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeVertices2), cubeVertices2, GL_STATIC_DRAW);
    
    glGenBuffers(1, &_nrmBuffer);
    ASSERT(_nrmBuffer != 0)
    glBindBuffer(GL_ARRAY_BUFFER, _nrmBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cubeNormals2), cubeNormals2, GL_STATIC_DRAW);
    
    glGenVertexArraysOES(1, &_vertexArray);
    ASSERT(_vertexArray != 0)
    glBindVertexArrayOES(_vertexArray);

    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
    
    glBindBuffer(GL_ARRAY_BUFFER, _nrmBuffer);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_TRUE, 0, 0);
}

- (void)dealloc
{
    glDeleteBuffers(1, &_buffer);
    glDeleteBuffers(1, &_nrmBuffer);
}

- (void)draw;
{
    glEnable(GL_BLEND);
    glBlendEquation(GL_FUNC_ADD);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    GLKMatrix4 scale = GLKMatrix4MakeScale(25, 1, 25);
    
    
    GLKMatrix4 model = _rotX;
    model = GLKMatrix4Multiply(model, _rotY);
    model = GLKMatrix4Multiply(model, _translation);
    model = GLKMatrix4Multiply(model, scale);
    
    [self.program setUniform:@"model" WithMat4:model.m];
    
    [self.program bind];
    glBindVertexArrayOES(_vertexArray);
    glDrawArrays(GL_TRIANGLES, 0, sizeof(cubeVertices2)/3);
    
    glDisable(GL_BLEND);
}

- (void)setRotationX:(float)angle
{
    _rotX = GLKMatrix4MakeRotation(angle, 1.0f, 0.0f, 0.0f);
}

- (void)setRotationY:(float)angle
{
    _rotY = GLKMatrix4MakeRotation(angle, 0.0f, 1.0f, 0.0f);
}

- (void)setTranslation:(const GLKVector3*)v
{

}

@end
