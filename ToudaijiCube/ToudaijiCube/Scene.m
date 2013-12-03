//------------------------------------------------------------------------------
//
//  Scene.m
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 03.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//------------------------------------------------------------------------------
#include <libxml2/libxml/parser.h>
#include <libxml2/libxml/tree.h>
#import "Scene.h"
//------------------------------------------------------------------------------
//  Declarations of file private functions
//------------------------------------------------------------------------------
static void sceneInitSceneWithNameFromRootNode(
    Scene* scene,
    const char* name,
    xmlNode* rootNode
);
//------------------------------------------------------------------------------
//  Definitions for public functions
//------------------------------------------------------------------------------
Scene* SceneCreateFromFile(const char* filename, const char* sceneName)
{
    // malloc
    Scene* scene = (Scene*)malloc(sizeof(Scene));
    memset(scene, 0, sizeof(Scene));

    if (!scene)
    {
        return NULL;
    }
    
    // init scene from xml file
    LIBXML_TEST_VERSION
    xmlDocPtr doc;
    xmlNode* node;

    NSString* fullName = [[[[NSBundle mainBundle] resourcePath]
                           stringByAppendingString:@"/"]
                          stringByAppendingString:[NSString stringWithUTF8String:filename]];
    doc = xmlReadFile([fullName UTF8String], NULL, 0);

    node = xmlDocGetRootElement(doc);
    sceneInitSceneWithNameFromRootNode(scene,sceneName, node);

    xmlFreeDoc(doc);
    xmlCleanupParser();
    
    return scene;
}
//------------------------------------------------------------------------------
void SceneDestroy(Scene** scene)
{
    if (NULL == *scene)
    {
        return;
    }
    
    free((*scene)->skyBox.alphaMapFile);
    free((*scene)->skyBox.cubeMapFile);
    free((*scene)->obj.objFile);
    free(*scene);

    *scene = NULL;
}
//------------------------------------------------------------------------------
void SceneDump(Scene* scene)
{
    if (scene == NULL)
    {
        return;
    }

    printf("camera: \n");
    
    printf(
        "\tellipsoid: a = %f b = %f c = %f\n",
        scene->camera.elipseParams.x,
        scene->camera.elipseParams.y,
        scene->camera.elipseParams.z
    );
    
    printf("skyBox:\n");
    printf("\tscale: %f\n", scene->skyBox.scale);
    printf("\tcubeMapFile: %s\n", scene->skyBox.cubeMapFile);
    printf("\talphaMapFile: %s\n", scene->skyBox.alphaMapFile);
    printf("obj: \n");
    printf("\tscale: %f\n", scene->obj.scale);

    printf(
        "\tposition: x = %f y = %f z = %f\n",
        scene->obj.position.x,
        scene->obj.position.y,
        scene->obj.position.z
    );

    printf("\tobjFile: %s\n", scene->obj.objFile);
    printf("\trotY: %f\n", scene->obj.rotY);

}
//------------------------------------------------------------------------------
//  Definitions for file private functions
//------------------------------------------------------------------------------
static void scenceFillWithSceneNode(Scene* scene, xmlNode* sceneNode);
static void sceneFillWithCameraNode(Scene* scene, xmlNode* cameraNode);
static void sceneFillWithSkyboxNode(Scene* scene, xmlNode* skyBoxNode);
static void sceneFillWithObjNode(Scene* scene, xmlNode* objNode);
//------------------------------------------------------------------------------
void sceneInitSceneWithNameFromRootNode(
    Scene* scene,
    const char* name,
    xmlNode* rootNode
)
{
    if (rootNode == NULL)
    {
        return;
    }

    for (xmlNode* cur = rootNode->children; cur; cur = cur->next)
    {
        if (cur->type == XML_ELEMENT_NODE &&
            !xmlStrcmp(cur->name, (xmlChar*)"scene")
        )
        {
            if (!xmlStrcmp(xmlGetProp(cur, (xmlChar*)"name"), (xmlChar*)name))
            {
                scenceFillWithSceneNode(scene, cur);
            }
        }
    }
}
//------------------------------------------------------------------------------
void scenceFillWithSceneNode(Scene* scene, xmlNode* sceneNode)
{
    // traverses a scene node and fills the [scene] stucture.
    
    if (sceneNode == NULL)
    {
        return;
    }
    
    for (xmlNode* cur = sceneNode->children; cur; cur = cur->next)
    {
        if (cur->type == XML_ELEMENT_NODE &&
            !xmlStrcmp(cur->name, (xmlChar*)"camera")
        )
        {
            sceneFillWithCameraNode(scene, cur);
        }
        
        if (cur->type == XML_ELEMENT_NODE &&
            !xmlStrcmp(cur->name, (xmlChar*)"skyBox")
        )
        {
            sceneFillWithSkyboxNode(scene, cur);
        }
        
        if (cur->type == XML_ELEMENT_NODE &&
            !xmlStrcmp(cur->name, (xmlChar*)"obj")
        )
        {
            sceneFillWithObjNode(scene, cur);
        }
    }
}
//------------------------------------------------------------------------------
void sceneFillWithCameraNode(Scene* scene, xmlNode* cameraNode)
{
    
    if (cameraNode == NULL)
    {
        return;
    }
    
    for (xmlNode* cur = cameraNode->children; cur; cur = cur->next)
    {
        
        if (cur->type == XML_ELEMENT_NODE &&
            !xmlStrcmp(cur->name, (xmlChar*)"ellipsoid")
        )
        {
            printf("da %s", cur->name);
            scene->camera.elipseParams.x =
                atof((const char*)xmlGetProp(cur, (xmlChar*)"a"));

            scene->camera.elipseParams.y =
                atof((const char*)xmlGetProp(cur, (xmlChar*)"b"));

            scene->camera.elipseParams.z =
                atof((const char*)xmlGetProp(cur, (xmlChar*)"c"));
        }
    }
}
//------------------------------------------------------------------------------
void sceneFillWithSkyboxNode(Scene* scene, xmlNode* skyBoxNode)
{
    if (skyBoxNode == NULL)
    {
        return;
    }
    
    for (xmlNode* cur = skyBoxNode->children; cur; cur = cur->next)
    {
        if (cur->type == XML_ELEMENT_NODE &&
            !xmlStrcmp(cur->name, (xmlChar*)"scale")
        )
        {
            scene->skyBox.scale =
                atof((const char*)xmlGetProp(cur, (xmlChar*)"s"));
        }

        if (cur->type == XML_ELEMENT_NODE &&
            !xmlStrcmp(cur->name, (xmlChar*)"cubeMapFile")
        )
        {
            xmlChar* file = xmlGetProp(cur, (xmlChar*)"filename");
            int len = xmlStrlen(file);
            
            scene->skyBox.cubeMapFile = (char*)malloc(sizeof(char)*(len + 1));
            strcpy(scene->skyBox.cubeMapFile, (const char*)file);
        }

        if (cur->type == XML_ELEMENT_NODE &&
            !xmlStrcmp(cur->name, (xmlChar*)"alphaMapFile")
        )
        {
            xmlChar* file = xmlGetProp(cur, (xmlChar*)"filename");
            int len = xmlStrlen(file);
            
            scene->skyBox.alphaMapFile = (char*)malloc(sizeof(char)*(len + 1));
            strcpy(scene->skyBox.alphaMapFile, (const char*)file);
        }

    }
}
//------------------------------------------------------------------------------
void sceneFillWithObjNode(Scene* scene, xmlNode* objNode)
{
    if (objNode == NULL)
    {
        return;
    }
    
    for (xmlNode* cur = objNode->children; cur; cur = cur->next)
    {
        if (cur->type == XML_ELEMENT_NODE &&
            !xmlStrcmp(cur->name, (xmlChar*)"scale")
        )
        {
            scene->obj.scale =
                atof((const char*)xmlGetProp(cur, (xmlChar*)"s"));
        }

        if (cur->type == XML_ELEMENT_NODE &&
            !xmlStrcmp(cur->name, (xmlChar*)"position")
        )
        {
            scene->obj.position.x =
                atof((const char*)xmlGetProp(cur, (xmlChar*)"x"));

            scene->obj.position.y =
                atof((const char*)xmlGetProp(cur, (xmlChar*)"y"));

            scene->obj.position.z =
                atof((const char*)xmlGetProp(cur, (xmlChar*)"z"));
        }

        if (cur->type == XML_ELEMENT_NODE &&
            !xmlStrcmp(cur->name, (xmlChar*)"objFile")
        )
        {
            xmlChar* file = xmlGetProp(cur, (xmlChar*)"filename");
            int len = xmlStrlen(file);
            
            scene->obj.objFile = (char*)malloc(sizeof(char)*(len + 1));
            strcpy(scene->obj.objFile, (const char*)file);
        }
        
        if (cur->type == XML_ELEMENT_NODE &&
            !xmlStrcmp(cur->name, (xmlChar*)"rot")
        )
        {
            scene->obj.rotY =
                atof((const char*)xmlGetProp(cur, (xmlChar*)"y"));
        }

    }
}
//------------------------------------------------------------------------------
