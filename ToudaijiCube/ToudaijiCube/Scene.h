//
//  Scene.h
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 03.12.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <GLKit/GLKit.h>
/*
**  Description of the to be displayed scene.
*/
typedef struct
{
    struct
    {
        GLKVector3 elipseParams;
    }
    camera;
    
    struct
    {
        char* cubeMapFile;
        char* alphaMapFile;
    }
    skyBox;
    
    struct
    {
        float scale;
        GLKVector3 position;
        char* objFile;
        float rotY;
    }
    obj;
}
Scene;

Scene* SceneCreateFromFile(const char* filename, const char* sceneName);
void SceneDestroy(Scene** scene);
void SceneDump(Scene* scene);