//
//  CoreLocationManager.h
//  CoreLocationDemo
//
//  Created by Arno in Wolde Lübke on 28.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "CoreLocationController.h"


@interface CoreLocationController : CLLocationManager <CLLocationManagerDelegate>
- (id) initWithLabel:(UILabel*)view;
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading;
@end