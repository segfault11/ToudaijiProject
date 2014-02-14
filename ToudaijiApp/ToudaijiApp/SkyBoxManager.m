//------------------------------------------------------------------------------
//
//  SkyBoxManager.m
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 14.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//
//------------------------------------------------------------------------------
#import "SkyBoxManager.h"
#import "JSONKit.h"
//------------------------------------------------------------------------------
#define SKY_BOXES_FILE_NAME "/SkyBoxes.json"
//------------------------------------------------------------------------------
@interface SkyBoxManager ()
{

}
@property(nonatomic, strong) NSMutableDictionary* skyBoxes;
-(id)init;
-(void)dealloc;
-(void)loadSkyBoxes;
@end
//------------------------------------------------------------------------------
@implementation SkyBoxManager
//------------------------------------------------------------------------------
+ (SkyBoxManager*)instance
{
    static SkyBoxManager* skyBoxManager = nil;
    
    @synchronized(self)
    {
        if (skyBoxManager != nil);
        {
            skyBoxManager = [[SkyBoxManager alloc] init];
        }
    }
    
    return skyBoxManager;
}
//------------------------------------------------------------------------------
-(id)init
{
    self = [super init];
    [self loadSkyBoxes];
    return self;
}
//------------------------------------------------------------------------------
-(void)dealloc
{

}
//------------------------------------------------------------------------------
-(void)loadSkyBoxes
{
    self.skyBoxes = [[NSMutableDictionary alloc] init];
    
    NSString* filename = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:[NSString stringWithUTF8String:SKY_BOXES_FILE_NAME]];
    NSData* data = [[NSData alloc] initWithContentsOfFile:filename];
    
    
    if (!data)
    {
        NSLog(@"Could not load %s", SKY_BOXES_FILE_NAME);
        exit(0);
    }
    
    NSArray* arr = [data objectFromJSONData];
    
    if (!arr)
    {
        NSLog(@"Invalid file: %s", SKY_BOXES_FILE_NAME);
        exit(0);
    }

    for (NSDictionary* entry in arr)
    {
        SkyBox* sb = [[SkyBox alloc] init];
        
        NSNumber* id = [entry objectForKey:@"id"];
        
        if (!id)
        {
            NSLog(@"Could not load id property in %s", SKY_BOXES_FILE_NAME);
        }
        
        sb.id = [id integerValue];
        
        NSString* fileName = [entry objectForKey:@"filename"];
        
        if (!id)
        {
            NSLog(@"Could not load fileName property in %s", SKY_BOXES_FILE_NAME);
        }
        
        sb.fileName = fileName;
        
        [self.skyBoxes setObject:sb forKey:id];
        
        NSLog(@"id = %d file name = %@", sb.id, sb.fileName);
    }
    
}
//------------------------------------------------------------------------------
- (SkyBox*)getSkyBoxWithID:(int)id
{
    return [self.skyBoxes objectForKey:[NSNumber numberWithInt:id]];
}
//------------------------------------------------------------------------------
-(SkyBox*)getSkyBoxAtIndex:(int)idx
{
    return [self.skyBoxes objectForKey:[self.skyBoxes.allKeys objectAtIndex:idx]];
}
//------------------------------------------------------------------------------
-(int)getNumSkyBoxes
{
    return self.skyBoxes.count;
}
//------------------------------------------------------------------------------
@end
//------------------------------------------------------------------------------
