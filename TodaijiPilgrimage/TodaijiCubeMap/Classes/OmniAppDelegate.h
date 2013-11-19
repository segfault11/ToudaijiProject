//
//  OmniAppDelegate.h
//  TodaijiCubeMap
//
//  Created by Akaguma on 13/02/18.
//  Copyright (c) 2013年 Akaguma Takayuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import "ParameterDef.h"

@class OmniViewController;


@interface OmniAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) OmniViewController *viewController;


// View間で共通の変数
@property (strong, nonatomic) NSString *imagepath;
@property (strong, nonatomic) NSString *infopath;
@property (strong, nonatomic) NSString *musicpath;
@property (strong, nonatomic) CMDeviceMotion *motion;
@property (strong, nonatomic) CLHeading *heading;
@property (nonatomic) float degreeY;
//@property (nonatomic) float radianY;
@property (nonatomic) float loadProgress;
@property (nonatomic) double animateStartHead;

@property (nonatomic) bool is_omnipoint;

@property (nonatomic) bool isTestGo;

@property (nonatomic) BOOL isAnimation;
@property (nonatomic) BOOL isGPSView;
@property (nonatomic) BOOL isLimitMode;

@end
