//------------------------------------------------------------------------------
//
//  ObjectManager.m
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 14.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "ObjectManager.h"
#import "Object.h"
#import "JSONKit.h"
//------------------------------------------------------------------------------
#define FILE_NAME "/ObjFiles.json"
//------------------------------------------------------------------------------
@interface ObjectManager ()
{
    
}
@property(nonatomic, strong) NSMutableDictionary* objects;
-(id)init;
-(void)dealloc;
-(void)loadObjFiles;
@end
//------------------------------------------------------------------------------
@implementation ObjectManager
//------------------------------------------------------------------------------
+(ObjectManager*)instance
{
    static ObjectManager* instance = nil;
    
    @synchronized(self)
    {
        if (!instance)
        {
            instance = [[ObjectManager alloc] init];
        }
    }
    
    return instance;
}
//------------------------------------------------------------------------------
-(id)init
{
    self = [super init];
    [self loadObjFiles];
    return self;
}
//------------------------------------------------------------------------------
-(void)dealloc
{

}
//------------------------------------------------------------------------------
-(void)loadObjFiles
{
    self.objects = [[NSMutableDictionary alloc] init];
    
    NSString* filename = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:[NSString stringWithUTF8String:FILE_NAME]];
    NSData* data = [[NSData alloc] initWithContentsOfFile:filename];
    
    if (!data)
    {
        NSLog(@"Could not load %s", FILE_NAME);
        exit(0);
    }
    
    NSArray* arr = [data objectFromJSONData];
    
    if (!arr)
    {
        NSLog(@"Invalid file: %s", FILE_NAME);
        exit(0);
    }

    for (NSDictionary* entry in arr)
    {
        Object* o = [[Object alloc] init];
        
        // read id
        NSNumber* id = [entry objectForKey:@"id"];
        
        if (!id)
        {
            NSLog(@"Could not load id property in %s", FILE_NAME);
        }
        
        o.id = [id integerValue];
        
        // read filename
        NSString* fileName = [entry objectForKey:@"filename"];
        
        if (!fileName)
        {
            NSLog(@"Could not load fileName property in %s", FILE_NAME);
        }
        
        o.filename = fileName;

        // read translation
        NSArray* tra = [entry objectForKey:@"translation"];
        
        if (!tra)
        {
            NSLog(@"Could not load translation property in %s", FILE_NAME);
        }
        
        GLKVector3 translation;
        translation.x = [[tra objectAtIndex:0] floatValue];
        translation.y = [[tra objectAtIndex:1] floatValue];
        translation.z = [[tra objectAtIndex:2] floatValue];
        o.translation = translation;


        // read rotation
        NSArray* rot = [entry objectForKey:@"rotation"];
        
        if (!rot)
        {
            NSLog(@"Could not load rotation property in %s", FILE_NAME);
        }
        
        GLKVector3 rotation;
        rotation.x = GLKMathDegreesToRadians([[rot objectAtIndex:0] floatValue]);
        rotation.y = GLKMathDegreesToRadians([[rot objectAtIndex:1] floatValue]);
        rotation.z = GLKMathDegreesToRadians([[rot objectAtIndex:2] floatValue]);
        o.rotation = rotation;
        
        // read scale
        NSNumber* scale = [entry objectForKey:@"scale"];

        if (!scale)
        {
            NSLog(@"Could not load scale property in %s", FILE_NAME);
        }
        
        o.scale = [scale floatValue];
    
        [self.objects setObject:o forKey:id];
    }
}
//------------------------------------------------------------------------------
-(Object*)getObjectWithID:(int)id
{
    return [self.objects objectForKey:[NSNumber numberWithInt:id]];
}
//------------------------------------------------------------------------------
-(Object*)getObjectAtIndex:(int)idx
{
    return [self.objects objectForKey:[self.objects.allKeys objectAtIndex:idx]];
}
//------------------------------------------------------------------------------
-(int)getNumObjects
{
    return self.objects.count;
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------
