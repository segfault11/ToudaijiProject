//
//  ObjView.m
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 07.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "ObjView.h"
#import "ObjLoader.h"
#import "GLUEProgram.h"
#import "ObjFileRenderer.h"

@interface ObjView ()
{
    GLuint _vertexArray;
    GLuint _posBuffer;
    GLKMatrix4 _projection;
    GLKMatrix4 _model;
    GLKMatrix4 _translation;
    int _objectNumFaces;
    ObjFileRendererPtr _renderer;
}
@property(nonatomic, strong) GLUEProgram* program;
- (void)initGLBuffer:(ObjFilePtr)file;
@end

@implementation ObjView

- (id)init
{
    self = [super init];

    self.program = [[GLUEProgram alloc] init];
    [self.program attachShaderOfType:GL_VERTEX_SHADER FromFile:@"ObjViewVS.glsl"];
    [self.program attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"ObjViewFS.glsl"];
    [self.program bindAttribLocation:0 ToVariable:@"position"];
    [self.program compile];
    
    // program uniforms
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat w = screenRect.size.width;
    CGFloat h = screenRect.size.height;
    _projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(61.3f), h/w, 0.01f, 100.0f); // height is width and width is height ....
    [self.program setUniform:@"projection" WithMat4:_projection.m];
    _translation = GLKMatrix4MakeTranslation(0.0f, -1.5f, -1.5f);
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(45.0f), 1.0f, 0.0f, 0.0f);
    _model = GLKMatrix4Multiply(rotation, _translation);
    [self.program setUniform:@"model" WithMat4:_model.m];
    
    const char* path = [[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"] UTF8String];
    ObjFilePtr file;
    
    ObjFileLoadWithPath(&file, "Iseki2.obj", path);
    
    if (file == NULL) {
        NSLog(@"Could not load .obj file.");
    }
    
    [self initGLBuffer:file];

    ObjFileRendererCreate(&_renderer, file);
    ObjFileRendererSetProjection(_renderer, &_projection);
    ObjFileRendererSetModel(_renderer, &_model);
    
    // clean up
    ObjFileRelease(&file);
    

    
    return self;
}

- (void)initGLBuffer:(ObjFilePtr)file
{
    ObjObjectPtr object = NULL;
    ObjGroupPtr group = NULL;
    ObjFacePtr face = NULL;
    ObjVector3I indices;
    ObjVector3F data;
    int numGroups = 0;
    int numFaces = 0;
    int objectNumFaces = 0; // total # of faces for the object
    
    ObjFileGetObjectWithName(file, &object, "obj1.002_obj1.003");
    
    if (object == NULL) {
        NSLog(@"Could not find object");
    }
    
    // compute the total number of faces in the object
    ObjObjectGetNumGroups(object, &numGroups);
    for (int i = 0; i < numGroups; i++) {
        ObjObjectGetGroup(object, &group, i);
        ObjGroupGetNumFaces(group, &numFaces);
        objectNumFaces += numFaces;
    }
    
    _objectNumFaces = objectNumFaces;
    printf("# faces: %d\n", objectNumFaces);
    
    // compute the size of posBuffer
    size_t posBufferSize = objectNumFaces*sizeof(float)*3*3;
    
    // get the position data of the object
    int c = 0;
    float* posData = (float*)malloc(posBufferSize);
    
    for (int i = 0; i < numGroups; i++) {
        ObjObjectGetGroup(object, &group, i);
        ObjGroupGetNumFaces(group, &numFaces);
        
        for (int j = 0; j < numFaces; j++) {
            ObjGroupGetFace(group, &face, j);
            ObjFaceGetPositionIndices(face, &indices);
            ObjFileGetPosition(file, &data, indices.x);
            memcpy(posData + c, (float*)(&data), sizeof(float)*3);
            c += 3;
            ObjFileGetPosition(file, &data, indices.y);
            memcpy(posData + c, (float*)(&data), sizeof(float)*3);
            c += 3;
            ObjFileGetPosition(file, &data, indices.z);
            memcpy(posData + c, (float*)(&data), sizeof(float)*3);
            c += 3;
        }
    }
    
    // initialize the buffer object
    glGenBuffers(1, &_posBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _posBuffer);
    glBufferData(GL_ARRAY_BUFFER, posBufferSize, posData, GL_STATIC_DRAW);

    // initialize the vertex array
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, _posBuffer);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
    
    // clean up
    free(posData);
}

- (void)dealloc
{
    glDeleteBuffers(1, &_posBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
}

- (void)draw
{
//    [self.program bind];
//    glBindVertexArrayOES(_vertexArray);
//    glDrawArrays(GL_TRIANGLES, 0, _objectNumFaces*3);
    
    ObjFileRendererRender(_renderer);
}

@end
