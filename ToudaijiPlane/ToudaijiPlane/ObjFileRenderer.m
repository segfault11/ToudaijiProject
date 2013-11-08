#include <stdio.h>
#include "ObjFileRenderer.h"
#import "GLUEProgram.h"

static GLUEProgram* program = nil;

/*
**   AUXILLIARY STRUCTS
*/

typedef struct _RenderData
{
    GLuint vertexArray;
    GLuint posBuffer;
    GLuint tcBuffer;
    GLuint tex;
    GLsizei count;
}
RenderData;

void initRenderData(RenderData* renderData, ObjFilePtr file, int mat)
{
    ObjObjectPtr object = NULL;
    ObjGroupPtr group = NULL;
    ObjFacePtr face = NULL;
    ObjVector3I indices;
    ObjVector3F data;
    ObjVector2F data2;
    int numObjects = 0;
    int numGroups = 0;
    int numFaces = 0;
    int matNumFaces = 0; // # faces for material referenced by [mat]
    int faceMat = 0;
    
    // count faces
    ObjFileGetNumObjects(file, &numObjects);
    
    for (int i = 0; i < numObjects; i++) {
        ObjFileGetObject(file, &object, i);
        ObjObjectGetNumGroups(object, &numGroups);

        for (int j = 0; j < numGroups; j++) {
            ObjObjectGetGroup(object, &group, j);
            ObjGroupGetNumFaces(group, &numFaces);

            for (int k = 0; k < numFaces; k++) {
                ObjGroupGetFace(group, &face, k);
                ObjFaceGetMaterialIndex(face, &faceMat);

                if (faceMat == mat) {
                    matNumFaces++;
                }
            }
        }
    }
    
    renderData->count = matNumFaces*3;

    if (!renderData->count) {
        renderData->vertexArray = 0;
        renderData->posBuffer = 0;
        renderData->tcBuffer = 0;
    }
    
    // compute memory size for positions and tex coordinates according to the num of faces
    GLsizeiptr posSize = matNumFaces*sizeof(float)*3*3;
    GLsizeiptr tcSize = matNumFaces*sizeof(float)*3*2;
    
    // allocate host memory
    GLfloat* posBuffer = (GLfloat*)malloc(posSize);
    GLfloat* tcBuffer = (GLfloat*)malloc(tcSize);
    
    // copy geometry to host memory
    int c = 0;
    ObjFileGetNumObjects(file, &numObjects);
    
    for (int i = 0; i < numObjects; i++) {
        ObjFileGetObject(file, &object, i);
        ObjObjectGetNumGroups(object, &numGroups);
        
        for (int j = 0; j < numGroups; j++) {
            ObjObjectGetGroup(object, &group, j);
            ObjGroupGetNumFaces(group, &numFaces);
            
            for (int k = 0; k < numFaces; k++) {
                ObjGroupGetFace(group, &face, k);
                ObjFaceGetMaterialIndex(face, &faceMat);
        
                if (faceMat == mat) {
                    
                    // copy positions
                    ObjFaceGetPositionIndices(face, &indices);
                    
                    ObjFileGetPosition(file, &data, indices.x);
                    memcpy((void*)(posBuffer + 3*(c + 0)), (void*)(&data), sizeof(ObjVector3F));
                    ObjFileGetPosition(file, &data, indices.y);
                    memcpy((void*)(posBuffer + 3*(c + 1)), (void*)(&data), sizeof(ObjVector3F));
                    ObjFileGetPosition(file, &data, indices.z);
                    memcpy((void*)(posBuffer + 3*(c + 2)), (void*)(&data), sizeof(ObjVector3F));
                    
                    // copy tex coordinates
                    ObjFaceGetTexCoordIndices(face, &indices);

                    ObjFileGetTexCoord(file, &data2, indices.x);
                    memcpy((void*)(tcBuffer + 2*(c + 0)), (void*)(&data2), sizeof(ObjVector2F));
                    ObjFileGetTexCoord(file, &data2, indices.y);
                    memcpy((void*)(tcBuffer + 2*(c + 1)), (void*)(&data2), sizeof(ObjVector2F));
                    ObjFileGetTexCoord(file, &data2, indices.z);
                    memcpy((void*)(tcBuffer + 2*(c + 2)), (void*)(&data2), sizeof(ObjVector2F));
                    
                    c += 3;
                }
            }
        }
    }
    
    // allocate device memory and initialize it with host data
    glGenBuffers(1, &renderData->posBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, renderData->posBuffer);
    glBufferData(GL_ARRAY_BUFFER, posSize, posBuffer, GL_STATIC_DRAW);
    
    glGenBuffers(1, &renderData->tcBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, renderData->tcBuffer);
    glBufferData(GL_ARRAY_BUFFER, tcSize, tcBuffer, GL_STATIC_DRAW);
    
    glGenVertexArraysOES(1, &renderData->vertexArray);
    glBindVertexArrayOES(renderData->vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, renderData->posBuffer);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
    glBindBuffer(GL_ARRAY_BUFFER, renderData->tcBuffer);
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, 0);

    // create the texture for this render data
    if (mat != 0)
    {
        ObjMaterial material;
        ObjFileGetMaterial(file, &material, mat);
        NSString* fullTexName = [[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"] stringByAppendingString:[NSString stringWithUTF8String:material.diffuseTex]];
        GLKTextureInfo *tex = [GLKTextureLoader textureWithContentsOfFile:fullTexName options:NULL error:NULL];
        renderData->tex = tex.name;
    }
    
    // clean up
    free(posBuffer);
    free(tcBuffer);
}

void releaseRenderData(RenderData* renderData)
{
    glDeleteTextures(1, &renderData->tex);
    glDeleteBuffers(1, &renderData->posBuffer);
    glDeleteVertexArraysOES(1, &renderData->vertexArray);
}

/*
**   PUBLIC INTERFACE DEFINITION
*/

typedef struct _ObjFileRenderer
{
    RenderData* renderData;
    int numRenderData;
    GLKMatrix4 projection;
    GLKMatrix4 model;
}
ObjFileRenderer;

void ObjFileRendererCreate(ObjFileRendererPtr* renderer, ObjFilePtr file)
{
    // alloc
    *renderer = (ObjFileRendererPtr)malloc(sizeof(ObjFileRenderer));

    if (*renderer == NULL) {
        return;
    }
    
    // find out the # of materials in [file]
    int numMat;
    ObjFileGetNumMaterials(file, &numMat);
    
    // alloc [numMat] [RenderData] and [ObjMaterial] and save their count
    (*renderer)->renderData = (RenderData*)malloc(sizeof(RenderData)*numMat);
    (*renderer)->numRenderData = numMat;
    
    // init the rendering data
    for (int i = 0; i < numMat; i++)
    {
        initRenderData(&(*renderer)->renderData[i], file, i);
    }
    
    // create the glsl program
    if (program == nil)
    {
        program = [[GLUEProgram alloc] init];
        [program attachShaderOfType:GL_VERTEX_SHADER FromFile:@"ObjFileRendererVS.glsl"];
        [program attachShaderOfType:GL_FRAGMENT_SHADER FromFile:@"ObjFileRendererFS.glsl"];
        [program bindAttribLocation:0 ToVariable:@"position"];
        [program bindAttribLocation:1 ToVariable:@"texCoord"];
        [program compile];
        
        /* set the texture unit */
        [program setUniform:@"tex" WithInt:0];
    }
}

void ObjFileRendererRelease(ObjFileRendererPtr* renderer)
{
    if (NULL == *renderer)
    {
        return;
    }
    
    for (int i = 0; i < (*renderer)->numRenderData; i++)
    {
        releaseRenderData(&(*renderer)->renderData[i]);
    }
    
    free((*renderer)->renderData);

    *renderer = NULL;
}

void ObjFileRendererRender(ObjFileRendererPtr renderer)
{
    [program bind];
    [program setUniform:@"projection" WithMat4:renderer->projection.m];
    [program setUniform:@"model" WithMat4:renderer->model.m];
    
    for (int i = 0; i < renderer->numRenderData; i++) {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, renderer->renderData[i].tex);
        glBindVertexArrayOES(renderer->renderData[i].vertexArray);
        glDrawArrays(GL_TRIANGLES, 0, renderer->renderData[i].count);
    }
}

void ObjFileRendererSetProjection(ObjFileRendererPtr renderer, const GLKMatrix4* projection)
{
    renderer->projection = *projection;
}

void ObjFileRendererSetModel(ObjFileRendererPtr renderer, const GLKMatrix4* model)
{
    renderer->model = *model;
}
