//
//  OmniViewController.h
//  TodaijiCubeMap
//
//  Created by Akaguma on 13/02/18.
//  Copyright (c) 2013年 Akaguma Takayuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "OmniAppDelegate.h"

@interface OmniViewController : GLKViewController
<AVAudioPlayerDelegate>
{
    OmniAppDelegate *_appDelegate;
    
    AVAudioPlayer *_musicPlayer;
    CGPoint _tBegan, _tEnded;
    NSString *_imagename;
    float _pinchZoom;
    
    BOOL _isPop;    
    UIImageView *_popupImage;
    int _animate_num;
    
    IBOutlet GLKView *_omniView;
    
    __weak IBOutlet UIButton *_btnReturnMapView;
    __weak IBOutlet UIButton *_btnInfo;
}



@end
