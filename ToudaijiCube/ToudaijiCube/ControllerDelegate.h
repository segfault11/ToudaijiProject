//
//  ControllerDelegate.h
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 10.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
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
        float scale;
        const char* cubeMapFile;
        const char* alphaMapFile;
    }
    skyBox;
    
    struct
    {
        float scale;
        GLKVector3 position;
        const char* objFile;
    }
    obj;
}
Scene;

@interface ControllerDelegate : NSObject <GLKViewControllerDelegate, GLKViewDelegate>
- (id)initWithScene:(const Scene*)scene;
- (void)applyScene:(const Scene*)scene;
- (void)setCubeMap:(NSString*)filename;
- (void)dealloc;
- (void)glkViewControllerUpdate:(GLKViewController *)controller;
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect;
@end
