//
//  GestureHandler.h
//  ToudaijiModelViewer
//
//  Created by Arno in Wolde Lübke on 18.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GestureHandler : NSObject <GLKViewControllerDelegate>
- (id)initWithSampleInterval:(NSTimeInterval)sampleInterval;
- (void)dealloc;
- (void)glkViewControllerUpdate:(GLKViewController *)controller;
- (void)handleTouchBegan:(const CGPoint*)position;
- (void)handleTouchEnd:(const CGPoint*)position;
- (void)handleTouchMoved:(const CGPoint*)position;
@end
