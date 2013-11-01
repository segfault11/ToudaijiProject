//
//  ViewController.m
//  CoreMotion
//
//  Created by Arno in Wolde Lübke on 30.10.13.
//  Copyright (c) 2013 Arno in Wolde Lübke. All rights reserved.
//

#import "ViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface ViewController ()
@property(nonatomic, strong) CMMotionManager* manager;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.manager = [[CMMotionManager alloc] init];
    self.manager.deviceMotionUpdateInterval = 1.0/15.0;
    self.manager.showsDeviceMovementDisplay = YES;
    
    CMDeviceMotionHandler  motionHandler = ^ (CMDeviceMotion *motion, NSError *error) {
        NSLog(@"%f      %f         %f", motion.attitude.pitch, motion.attitude.roll, motion.attitude.yaw);
    };

//    [self.manager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical toQueue:[NSOperationQueue currentQueue] withHandler:motionHandler];
    [self.manager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical];
    //[self.manager stopDeviceMotionUpdates];
    
    
    

    
    while (1) {
        CMAttitude* att = [[self.manager deviceMotion] attitude];
        CMRotationRate r = [[self.manager deviceMotion] rotationRate];
        NSLog(@"%f      %f         %f", r.x, [att roll], [att yaw]);
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
