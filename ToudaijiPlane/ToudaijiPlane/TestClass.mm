//
//  TestClass.m
//  ToudaijiPlane
//
//  Created by Arno in Wolde Lübke on 04.11.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "TestClass.h"

#import "Vector4.h"

@implementation TestClass

- (id)init
{
    self = [super init];
    
    Math::Vector4F v;
    v.operator[](0) = 0.0f;
    
    return self;
}

@end
