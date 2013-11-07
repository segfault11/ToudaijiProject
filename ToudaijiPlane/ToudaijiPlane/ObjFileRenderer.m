//
//  ObjFileRenderer.c
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 07.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#include <stdio.h>
#include "ObjFileRenderer.h"
#import <GLKit/GLKit.h>

typedef struct _RenderData
{
    GLuint vertexArray;
    GLuint posBuffer;
}
RenderData;

void initRenderData(RenderData* renderData, ObjFilePtr file, int mat)
{
    ObjObjectPtr object = NULL;
    ObjGroupPtr group = NULL;
    ObjFacePtr face = NULL;
    ObjVector3I indices;
    ObjVector3F data;
    int numObjects = 0;
    int numGroups = 0;
    int numFaces = 0;
    int matNumFaces = 0; // # faces for material referenced by [mat]
    int faceMat = 0;
    
    // count faces
    ObjFileGetNumObjects(file, &numObjects);
    
    for (int i = 0; i < numFaces; i++) {
        ObjFileGetObject(file, &object, i);
        ObjObjectGetNumGroups(object, &numGroups);
        
        for (int j = 0; j < numGroups; j++) {
            ObjObjectGetGroup(object, &group, j);
            ObjGroupGetNumFaces(group, &numFaces)
            
            for (int k = 0; k < numFaces; k++) {
                ObjGroupGetFace(group, &face, k);
                ObjFaceGetMaterialIndex(face, &faceMat);
                
                if (faceMat == mat) {
                    matNumFaces++;
                }
            }
        }
    }
    
    // compute memory size for positions according to the num of faces
    GLsizeiptr posSize = matNumFaces*sizeof(float)*3*3;
    
    if (!posSize) {
        renderData->vertexArray = 0;
        renderData->posBuffer = 0;
    }
    
    // allocate host memory
    GLfloat* posBuffer = (GLfloat*)malloc(posSize);
    
    // copy geometry to host memory
    int c = 0;
    ObjFileGetNumObjects(file, &numObjects);
    
    for (int i = 0; i < numFaces; i++) {
        ObjFileGetObject(file, &object, i);
        ObjObjectGetNumGroups(object, &numGroups);
        
        for (int j = 0; j < numGroups; j++) {
            ObjObjectGetGroup(object, &group, j);
            ObjGroupGetNumFaces(group, &numFaces)
            
            for (int k = 0; k < numFaces; k++) {
                ObjGroupGetFace(group, &face, k);
                ObjFaceGetMaterialIndex(face, &faceMat);
        
                if (faceMat == mat) {
                    ObjFaceGetPositionIndices(face, &indices);
                    ObjFileGetPosition(file, &data, indices.x);
                    memcpy((void*)(posBuffer + c), (void*)(&data), sizeof(ObjVector3F));
                    c += 3;
                    ObjFileGetPosition(file, &data, indices.y);
                    memcpy((void*)(posBuffer + c), (void*)(&data), sizeof(ObjVector3F));
                    c += 3;
                    ObjFileGetPosition(file, &data, indices.z);
                    memcpy((void*)(posBuffer + c), (void*)(&data), sizeof(ObjVector3F));
                    c += 3;
                }
            }
        }
    }
    
    // allocate device memory and initialize it with host data
    glGenBuffer(1, renderData->posBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, renderData->posBuffer);
    glBufferData(GL_ARRAY_BUFFER, posSize, posBuffer, GL_STATIC_DRAW);
    
    glGenVertexArraysOES(1, &renderData->vertexArray);
    glBindVertexArrayOES(renderData->vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, renderData->posBuffer);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
}

void releaseRenderData(RenderData* renderData)
{
    glDeleteBuffers(1, &renderData->posBuffer);
    glDeleteVertexArraysOES(1, &renderData->vertexArray);
}

typedef struct _ObjFileRenderer
{
    RenderData* renderData;
    ObjMaterial* materials;
    int numRenderData;
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
    ObjFileGetNumMaterials(1, &numMat);
    
    // alloc [numMat] [RenderData] and [ObjMaterial] and save their count
    (*renderer)->renderData = (RenderData*)malloc(sizeof(RenderData)*numMat);
    (*renderer)->materials = (ObjMaterial*)malloc(sizeof(ObjMaterial)*numMat);
    (*renderer)->numRenderData = numMat;
    
    // init the rendering data
    for (int i = 0; i < numMat; i++)
    {
        initRenderData((*renderer)->renderData[i], file, i);
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
        releaseRenderData(&(*renderer)->renderData[i]));
    }
    
    free((*renderer)->renderData);

    *renderer = NULL;
}