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
#import "Drawable.h"

@interface GeometryView : NSObject <Drawable>
- (id)initFromFile:(NSString*)filename;
- (void)dealloc;
- (void)draw;
@end
