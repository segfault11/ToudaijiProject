//
//  AlphaMapRenderer.h
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 16.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlphaMap.h"

@interface AlphaMapRenderer : NSObject
+(AlphaMapRenderer*)instance;
-(void)render:(AlphaMap*)alphaMap;
-(GLuint)getRenderTarget;
@end
