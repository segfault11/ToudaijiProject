//
//  ControllerDelegate.h
//  ToudaijiCube
//
//  Created by Arno in Wolde Lübke on 10.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ControllerDelegate : NSObject <GLKViewControllerDelegate, GLKViewDelegate>
- (id)init;
- (void)setCubeMap:(NSString*)filename;
- (void)dealloc;
- (void)glkViewControllerUpdate:(GLKViewController *)controller;
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect;
@end
