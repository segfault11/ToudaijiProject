//
//  SkyBoxRenderer.h
//  ToudaijiApp
//
//  Created by Arno in Wolde Luebke on 14.02.14.
//  Copyright (c) 2014 Arno in Wolde Luebke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SkyBoxRenderer : NSObject
+(SkyBoxRenderer*)instance;
-(void)render:(id)skyBox;
@end
