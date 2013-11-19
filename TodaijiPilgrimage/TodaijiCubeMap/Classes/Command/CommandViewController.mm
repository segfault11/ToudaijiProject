//
//  CommandViewController.m
//  TodaijiCubeMap
//
//  Created by 赤熊 高行 on 13/03/24.
//  Copyright (c) 2013年 Akaguma Takayuki. All rights reserved.
//

#import "CommandViewController.h"

@implementation CommandViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _appDelegate = (OmniAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    _appDelegate.isGPSView = outletGPS.state;
    _appDelegate.isAnimation = outletAnimate.state;
    _appDelegate.isLimitMode = outletLimitMode.state;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnTest:(id)sender {
    NSLog(@"Test button go");
    _appDelegate.isTestGo = TRUE;
}

- (IBAction)switchAnimation:(id)sender {
    _appDelegate.isAnimation = !_appDelegate.isAnimation;
}

- (IBAction)switchGPSView:(id)sender {
    _appDelegate.isGPSView = !_appDelegate.isGPSView;
}

- (IBAction)switchLimitMode:(id)sender {
    _appDelegate.isLimitMode = !_appDelegate.isLimitMode;
}


@end
