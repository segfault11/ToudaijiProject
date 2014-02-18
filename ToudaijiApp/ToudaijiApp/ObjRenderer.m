//------------------------------------------------------------------------------
//
//  ObjRenderer.m
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 11.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "ObjRenderer.h"
#import "ObjFileRenderer.h"
#import <assert.h>
#import "ObjectManager.h"
//------------------------------------------------------------------------------
@interface ObjRenderer ()
@property(nonatomic, strong) NSMutableDictionary* objRenderers;
-(id)init;
-(void)dealloc;
-(void)initRenderers;
@end
//------------------------------------------------------------------------------
@implementation ObjRenderer
//------------------------------------------------------------------------------
+(ObjRenderer*)instance
{
    static ObjRenderer* instance = nil;

    @synchronized(self)
    {
        if (!instance)
        {
            instance = [[ObjRenderer alloc] init];
        }
    }
    
    return instance;
}
//------------------------------------------------------------------------------
-(void)render:(Object *)object
{
    ObjFileRenderer* ofr = [self.objRenderers objectForKey:[NSNumber numberWithInt:object.id]];
    [ofr render];
}
//------------------------------------------------------------------------------
-(id)init
{
    self = [super init];
    [self initRenderers];
    return self;
}
//------------------------------------------------------------------------------
-(void)dealloc
{

}
//------------------------------------------------------------------------------
-(void)initRenderers
{
    self.objRenderers = [[NSMutableDictionary alloc] init];
    
    ObjectManager* om = [ObjectManager instance];
    
    for (int i = 0; i < [om getNumObjects]; i++)
    {
        Object* o = [om getObjectAtIndex:i];
        
        // build model matrix
        GLKMatrix4 model = GLKMatrix4Identity;
        GLKMatrix4 scale = GLKMatrix4MakeScale(o.scale, o.scale, o.scale);
        GLKMatrix4 rotX = GLKMatrix4MakeRotation(o.rotation.x, 1.0, 0.0, 0.0);
        GLKMatrix4 rotY = GLKMatrix4MakeRotation(o.rotation.y, 0.0, 1.0, 0.0);
        GLKMatrix4 rotZ = GLKMatrix4MakeRotation(o.rotation.z, 0.0, 0.0, 1.0);
        GLKMatrix4 rot = GLKMatrix4Multiply(rotY, rotX);
        
        rot = GLKMatrix4Multiply(rotZ, rot);
        
        GLKMatrix4 trans = GLKMatrix4MakeTranslation(
                o.translation.x,
                o.translation.y,
                o.translation.z
            );
        
        model = GLKMatrix4Multiply(rot, scale);
        model = GLKMatrix4Multiply(trans, model);
    
        ObjFilePtr file;
        
        ObjFileLoadWithPath(&file, [o.filename UTF8String], [[[NSBundle mainBundle] resourcePath] UTF8String]);
//        ObjFileLoad(&file, [filename UTF8String]);
    
        ObjFileRenderer* ofr = [[ObjFileRenderer alloc] initWithFile:file andModel:model];
        
        [self.objRenderers setObject:ofr forKey:[NSNumber numberWithInt:o.id]];
    }
    
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------