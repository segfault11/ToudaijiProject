//
//  CommandViewController.h
//  TodaijiCubeMap
//
//  Created by 赤熊 高行 on 13/03/24.
//  Copyright (c) 2013年 Akaguma Takayuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OmniAppDelegate.h"

@interface CommandViewController : UIViewController
{
    OmniAppDelegate *_appDelegate;
    __weak IBOutlet UISwitch *outletGPS;
    __weak IBOutlet UISwitch *outletAnimate;
    __weak IBOutlet UISwitch *outletLimitMode;
    
}

@end
