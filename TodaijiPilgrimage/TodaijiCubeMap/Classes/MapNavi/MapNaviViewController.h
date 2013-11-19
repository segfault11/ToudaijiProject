//
//  MapNaviViewController.h
//  TodaijiCubeMap
//
//  Created by takayuki-a on 2013/03/23.
//  Copyright (c) 2013年 Akaguma Takayuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h>
#import "OmniAppDelegate.h"
#import "ParameterDef.h"
#import "CommandViewController.h"

// --------------------------------------------
//  位置・方位情報を保持
// --------------------------------------------

struct LocateData{
    double gps_long;
    double gps_lati;
    
    double gravityX;
    double gravityY;
    double gravityZ;
    
    double userAccelerationX;
    double userAccelerationY;
    double userAccelerationZ;
    
    double gyairoX;
    double gyairoY;
    double gyairoZ;
    
    double magneticX;
    double magneticY;
    double magneticZ;
    int accuracy;
    
    double roll;
    double pitch;
    double yaw;
};

struct MatchResult {
    int mathed_num;
    int omnidata_num;
    
    MatchResult():
    mathed_num(0),omnidata_num(0)
    {}
};

@interface MapNaviViewController : UIViewController
<CvVideoCameraDelegate,CLLocationManagerDelegate>
{
    CvVideoCamera *_videoCamera;
    
    NSArray *_gpsPoint;

    
    CLLocationManager *_locationManager;
    CMMotionManager *_motionManager;
    LocateData *_locate;
    
    OmniAppDelegate *_appDelegate;
    
    cv::Mat _capImage;
    std::vector<cv::KeyPoint> _key;
    
    MatchResult _mathed_result;
    double _processingTime;
    BOOL _isPop;
    
    double _distanceFromHeareToNearPoint;
    
    
    UIViewController *_commandView;
    BOOL _currDirection;

    // ポップアップで表示されるinfo画像
    UIImageView *_popupImage;
    __weak IBOutlet UIButton *_popupBtn;
    
    __weak IBOutlet UIImageView *_dbgImage;
    __weak IBOutlet UIButton *_popupText;
    
    // 背景のカメラ画像
    __weak IBOutlet UIImageView *_imageView;
    __weak IBOutlet UIImageView *_mapImageView;
    
    // 各拠点のボタンIBOutlet
    __weak IBOutlet UIButton *_btnRenbenWithRengezou;
    __weak IBOutlet UIButton *_btnRengezouWithRusyanabutu;
    __weak IBOutlet UIButton *_btnRusyanabutu;
    __weak IBOutlet UIButton *_btnTotou;
    __weak IBOutlet UIButton *_btnDaibutuden;
    
    // 各拠点のポイント表示
    __weak IBOutlet UIButton *_pointDaibutuden;
    __weak IBOutlet UIButton *_pointTotou;
    __weak IBOutlet UIButton *_pointRusyanabutu;
    __weak IBOutlet UIButton *_pointRenbenWithRengezou;
    __weak IBOutlet UIButton *_pointRengezouWithRusyanabutu;
    
    // 各ルートのポイント
    
    __weak IBOutlet UIButton *_route1;
    __weak IBOutlet UIButton *_route2;
    __weak IBOutlet UIButton *_route3;
    __weak IBOutlet UIButton *_route4;
    __weak IBOutlet UIButton *_route5;
    __weak IBOutlet UIButton *_route6;
    __weak IBOutlet UIButton *_route7;
    __weak IBOutlet UIButton *_route8;
}

//--------------------------------------------------------------------
//  Function
//--------------------------------------------------------------------
void RunProcessing(const cv::Mat& src, std::vector<cv::KeyPoint>& key_input, const LocateData* locate, MatchResult& result);
void DrawCircle(cv::Mat& image, const std::vector<cv::KeyPoint>& key_input);
void DrawDeviceInfo(const LocateData* locate, cv::Mat& image);


@end





















