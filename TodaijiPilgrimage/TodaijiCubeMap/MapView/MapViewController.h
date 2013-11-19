//
//  CameraViewController.h
//  TodaijiCubeMap
//
//  Created by Akaguma on 13/02/18.
//  Copyright (c) 2013年 Akaguma Takayuki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreMotion/CoreMotion.h>
#import <QuartzCore/QuartzCore.h>
#import "OmniAppDelegate.h"


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


//--------------------------------------------------------------------
// Delegate
//--------------------------------------------------------------------

@interface MapViewController : UIViewController
<CvVideoCameraDelegate,CLLocationManagerDelegate>
{
    CvVideoCamera *_videoCamera;
//    IBOutlet UIImageView *_imageView;
    
    CLLocationManager *_locationManager;
    CMMotionManager *_motionManager;
    LocateData *_locate;
    
    OmniAppDelegate *_appDelegate;
    
    cv::Mat _capImage;
    std::vector<cv::KeyPoint> _key;
    
    MatchResult _mathed_result;
    double _processingTime;
    BOOL _isPop;
    
//    IBOutlet UIButton *btnGpsPoint;
    
    UIImageView *_popupImage;
    
//    IBOutlet UIImageView *infoView;
    
    
}


//--------------------------------------------------------------------
//  Function
//--------------------------------------------------------------------
void RunProcessing(const cv::Mat& src, std::vector<cv::KeyPoint>& key_input, const LocateData* locate, MatchResult& result);
void DrawCircle(cv::Mat& image, const std::vector<cv::KeyPoint>& key_input);
void DrawDeviceInfo(const LocateData* locate, cv::Mat& image);
@end
