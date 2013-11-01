//
//  GeometryView.h
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 31.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

/*
** renders Geometry
*/

#import <Foundation/Foundation.h>
#import <GLKit/GLKMath.h>


@interface GeometryView : NSObject
- (id)initFromFile:(NSString*)filename;
- (void)dealloc;
- (void)setTranslation:(const GLKVector3*)v;
/*
 ** Sets the rotation of the geometry around the x axis. [angle] is in radians.
 */
- (void)setRotationX:(float)angle;
/*
 ** Sets the rotation of the geometry around the y axis. [angle] is in radians.
 */
- (void)setRotationY:(float)angle;
- (void)draw;
@end
