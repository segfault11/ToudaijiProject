//------------------------------------------------------------------------------
//
//  Camera.h
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 14.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//
//------------------------------------------------------------------------------
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
//------------------------------------------------------------------------------
@interface Camera : NSObject
+ (Camera*)instance;
- (GLKMatrix4)getView;
- (GLKMatrix4)getPerspective;
@end
//------------------------------------------------------------------------------
