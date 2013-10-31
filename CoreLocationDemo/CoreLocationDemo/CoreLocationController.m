//
//  CoreLocationManager.m
//  CoreLocationDemo
//
//  Created by Arno in Wolde Lübke on 28.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "CoreLocationController.h"


@interface CoreLocationController ()
{
    UILabel* _view;
}
@end

@implementation CoreLocationController

- (id)init
{
    self = [super init];
    
    self.delegate = self;
    self.distanceFilter = kCLDistanceFilterNone;
    self.desiredAccuracy = kCLLocationAccuracyBest;
    [self startUpdatingLocation];
    [self startUpdatingHeading];
    
    return self;
}

- (id) initWithLabel:(UILabel*)view
{
    self = [self init];
    
    _view = view;
    
    return self;
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Did update location.");

    CLLocation* oldLocation = [locations objectAtIndex:0];∑
    
    _view.text = [NSString stringWithFormat:@"OldLocation %f %f", oldLocation.coordinate.latitude, oldLocation.coordinate.longitude];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    NSLog(@"heading %f", [newHeading magneticHeading]);
}

@end