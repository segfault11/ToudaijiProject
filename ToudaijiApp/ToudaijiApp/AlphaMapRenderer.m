//------------------------------------------------------------------------------
//
//  AlphaMapRenderer.m
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 16.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "AlphaMapRenderer.h"
#import "AlphaMapManager.h"
#import <assert.h>
#import "GLUEProgram.h"
#import "Camera.h"
//------------------------------------------------------------------------------
static GLfloat quadVertices[] = {
    -1.0f, 0.0f, 1.0f,
    1.0f, 0.0f, 1.0f,
    1.0f, 0.0f, -1.0f,

    -1.0f, 0.0f, 1.0f,
    1.0f, 0.0f, -1.0f,
    -1.0f, 0.0f, -1.0f,
};
//------------------------------------------------------------------------------
@interface AlphaMapRenderer ()
{
    GLuint _buffer;
    GLuint _vao;
    GLuint _fbo;
    GLuint _targetTex;
}
@property(nonatomic, strong) NSMutableDictionary* alphaMapTextures;
@property(nonatomic, strong) GLUEProgram* program;
@property(nonatomic, strong) Camera* camera;
-(id)init;
-(void)dealloc;
-(void)loadAlphaMapTexture:(AlphaMap*)alphaMap;
-(void)loadAlphaMapTextures;
-(void)initGL;
@end
//------------------------------------------------------------------------------
@implementation AlphaMapRenderer
//------------------------------------------------------------------------------
+(AlphaMapRenderer*)instance
{
    static AlphaMapRenderer* instance = nil;
    
    @synchronized(self)
    {
        if (!instance)
        {
            instance = [[AlphaMapRenderer alloc] init];
        }
    }
    
    return instance;
}
//------------------------------------------------------------------------------
-(id)init
{
    self = [super init];
    
    [self loadAlphaMapTextures];
    [self initGL];
    
    self.camera = [Camera instance];
    
    return self;
}
//------------------------------------------------------------------------------
-(void)dealloc
{
    glDeleteBuffers(1, &_buffer);
    glDeleteVertexArraysOES(1, &_vao);
    
    for (GLKTextureInfo* info in self.alphaMapTextures)
    {
        GLuint texHandle = info.name;
        glDeleteTextures(1, &texHandle);
    }
}
//------------------------------------------------------------------------------
-(void)loadAlphaMapTextures
{
    AlphaMapManager* manager = [AlphaMapManager instance];

    self.alphaMapTextures = [[NSMutableDictionary alloc] init];

    for (int i = 0; i < [manager getNumAlphaMaps]; i++)
    {
        AlphaMap* am = [manager getAlphaMapAtIndex:i];
        [self loadAlphaMapTexture:am];
    }
}
//------------------------------------------------------------------------------
-(void)loadAlphaMapTexture:(AlphaMap*)alphaMap
{

    NSString* fullName = [[[[NSBundle mainBundle] resourcePath]
                           stringByAppendingString:@"/"]
                          stringByAppendingString:alphaMap.filename];

    NSError* err;
    GLKTextureInfo* info = [GLKTextureLoader textureWithContentsOfFile:fullName options:nil error:&err];

    if (err)
    {
        NSLog(@"Could not load texture for alpha map with file %@", alphaMap.filename);
        exit(0);
    }

    [self.alphaMapTextures setObject:info forKey:[NSNumber numberWithInt:alphaMap.id]];
}
//------------------------------------------------------------------------------
-(void)initGL
{
    glGenBuffers(1, &_buffer);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), quadVertices, GL_STATIC_DRAW);
    
    glGenVertexArraysOES(1, &_vao);
    glBindVertexArrayOES(_vao);
    glBindBuffer(GL_ARRAY_BUFFER, _buffer);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_TRUE, 0, 0);
    
    self.program = [[GLUEProgram alloc] init];
    [self.program attachShaderOfType:GL_VERTEX_SHADER FromFile:@"AMRVS.glsl"];
    [self.program attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"AMRFS.glsl"];
    [self.program bindAttribLocation:0 ToVariable:@"position"];
    [self.program compile];
    
    
    //
    // set up the framebuffer
    //
    
    // init target texture
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat w = screenRect.size.width;
    CGFloat h = screenRect.size.height;
    
    glGenTextures(1, &_targetTex);
    glBindTexture(GL_TEXTURE_2D, _targetTex);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RED_EXT, w, h, 0, GL_RED_EXT, GL_UNSIGNED_BYTE, 0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    // init framebuffer
    GLint prevFBO;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &prevFBO);
    
    glGenFramebuffers(1, &_fbo);
    glBindFramebuffer(GL_FRAMEBUFFER, _fbo);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, _targetTex, 0);
    
    // check for errors
    GLuint status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    assert(status == GL_FRAMEBUFFER_COMPLETE);

    // rebind the old framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, prevFBO);
}
//------------------------------------------------------------------------------
-(void)render:(AlphaMap*)alphaMap
{
    assert(alphaMap != nil);
 
    // bind frame buffer
    GLint prevFBO;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &prevFBO);
    glBindFramebuffer(GL_FRAMEBUFFER, _fbo);

    
    // draw
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLKTextureInfo* texInfo = [self.alphaMapTextures objectForKey:[NSNumber numberWithInt:alphaMap.id]];
    GLKMatrix4 view = [self.camera getView];
    GLKMatrix4 projection = [self.camera getPerspective];
    
    
    GLKMatrix4 model = GLKMatrix4Identity;
    GLKMatrix4 scale = GLKMatrix4MakeScale(alphaMap.scale, alphaMap.scale, alphaMap.scale);
    GLKMatrix4 rotX = GLKMatrix4MakeRotation(alphaMap.rotation.x, 1.0, 0.0, 0.0);
    GLKMatrix4 rotY = GLKMatrix4MakeRotation(alphaMap.rotation.y, 0.0, 1.0, 0.0);
    GLKMatrix4 rotZ = GLKMatrix4MakeRotation(alphaMap.rotation.z, 0.0, 0.0, 1.0);
    GLKMatrix4 rot = GLKMatrix4Multiply(rotY, rotX);
        
    rot = GLKMatrix4Multiply(rotZ, rot);
        
    GLKMatrix4 trans = GLKMatrix4MakeTranslation(
            alphaMap.translation.x,
            alphaMap.translation.y,
            alphaMap.translation.z
        );
        
    model = GLKMatrix4Multiply(rot, scale);
    model = GLKMatrix4Multiply(trans, model);
    
    [self.program bind];
    [self.program setUniform:@"model" WithMat4:model.m];
    [self.program setUniform:@"view" WithMat4:view.m];
    [self.program setUniform:@"projection" WithMat4:projection.m];
    [self.program setUniform:@"amapSampler" WithInt:0];
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texInfo.name);

    glBindVertexArrayOES(_vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    assert(GL_NO_ERROR == glGetError());
    
    // rebind the old framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, prevFBO);
}
//------------------------------------------------------------------------------
-(GLuint)getRenderTarget
{
    return _targetTex;
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------