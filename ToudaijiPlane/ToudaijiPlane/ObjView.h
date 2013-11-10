//
//  ObjView.h
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 07.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjView : NSObject
- (id)init;
- (void)dealloc;
- (void)draw;
/*
** Sets the rotation of the geometry around the x axis. [angle] is in radians.
*/
- (void)setRotationX:(float)angle;
/*
** Sets the rotation of the geometry around the y axis. [angle] is in radians.
*/
- (void)setRotationY:(float)angle;
@end
