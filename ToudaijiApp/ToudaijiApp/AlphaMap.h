//
//  AlphaMap.h
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 16.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface AlphaMap : NSObject
{
    int id;
    NSString* _filename;
    GLKVector3 _translation;
    GLKVector3 _rotation;
    float _scale;    
}
@property int id;
@property NSString* filename;
@property GLKVector3 translation;
@property GLKVector3 rotation;
@property float scale;
@end
