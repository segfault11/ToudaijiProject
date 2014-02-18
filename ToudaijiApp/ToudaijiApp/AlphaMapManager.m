//------------------------------------------------------------------------------
//
//  AlphaMapManager.m
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 16.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "AlphaMapManager.h"
#import "JSONKit.h"
//------------------------------------------------------------------------------
#define FILE_NAME "/AlphaMaps.json"
//------------------------------------------------------------------------------
@interface AlphaMapManager ()
{

}
@property(nonatomic, strong) NSMutableDictionary* alphaMaps;
-(id)init;
-(void)dealloc;
-(void)loadAlphaMaps;
@end
//------------------------------------------------------------------------------
@implementation AlphaMapManager
//------------------------------------------------------------------------------
+(AlphaMapManager*)instance
{
    static AlphaMapManager* instance = nil;
    
    @synchronized(self)
    {
        if (!instance)
        {
            instance = [[AlphaMapManager alloc] init];
        }
    }
    
    return instance;
}
//------------------------------------------------------------------------------
-(id)init
{
    self = [super init];
    [self loadAlphaMaps];
    return self;
}
//------------------------------------------------------------------------------
-(void)dealloc
{

}
//------------------------------------------------------------------------------
-(void)loadAlphaMaps
{
    self.alphaMaps = [[NSMutableDictionary alloc] init];
    
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
        AlphaMap* am = [[AlphaMap alloc] init];
        
        NSNumber* id = [entry objectForKey:@"id"];
        
        if (!id)
        {
            NSLog(@"Could not load id property in %s", FILE_NAME);
        }
        
        am.id = [id integerValue];
        
        NSString* fileName = [entry objectForKey:@"filename"];
        
        if (!fileName)
        {
            NSLog(@"Could not load fileName property in %s", FILE_NAME);
        }
        
        am.filename = fileName;
        
        NSArray* tra = [entry objectForKey:@"translation"];
        
        if (!tra)
        {
            NSLog(@"Could not load translation property in %s", FILE_NAME);
        }
        
        GLKVector3 translation;
        translation.x = [[tra objectAtIndex:0] floatValue];
        translation.y = [[tra objectAtIndex:1] floatValue];
        translation.z = [[tra objectAtIndex:2] floatValue];
        am.translation = translation;

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
        am.rotation = rotation;
        
        // read scale
        NSNumber* scale = [entry objectForKey:@"scale"];

        if (!scale)
        {
            NSLog(@"Could not load scale property in %s", FILE_NAME);
        }
        
        am.scale = [scale floatValue];


        
        [self.alphaMaps setObject:am forKey:id];
    }
    
}
//------------------------------------------------------------------------------
-(AlphaMap*)getAlphaMapWithID:(int)id
{
    return [self.alphaMaps objectForKey:[NSNumber numberWithInt:id]];
}
//------------------------------------------------------------------------------
-(AlphaMap*)getAlphaMapAtIndex:(int)idx
{
    return [self.alphaMaps objectForKey:[self.alphaMaps.allKeys objectAtIndex:idx]];
}
//------------------------------------------------------------------------------
-(int)getNumAlphaMaps
{
    return self.alphaMaps.count;
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------
