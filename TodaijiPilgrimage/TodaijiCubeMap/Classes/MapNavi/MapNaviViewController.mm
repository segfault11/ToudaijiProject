//
//  MapNaviViewController.m
//  TodaijiCubeMap
//
//  Created by takayuki-a on 2013/03/23.
//  Copyright (c) 2013年 Akaguma Takayuki. All rights reserved.
//

#import "MapNaviViewController.h"
#import "QViewController.h"
#import "CommandViewController.h"


@interface MapNaviViewController ()

@end

@implementation MapNaviViewController

//--------------------------------------------------------------------
//
//--------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


//--------------------------------------------------------------------
//  色々な情報の初期化
//--------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (OmniAppDelegate*)[[UIApplication sharedApplication] delegate];
    //_appDelegate.radianY = 0.0f;
    _appDelegate.degreeY = 0.0f;
    _appDelegate.loadProgress = -1;
    _appDelegate.animateStartHead = 0.0;
    _appDelegate.isTestGo = false;
    
    _processingTime = 0.0;
    _isPop = false;
    

    [self initLocationData];
    [self initCamera];
    [self initMotinoData];
    [self initLocateData];
    [self initMenuCommand];
    
    [_videoCamera start];
    
//    [self trans180:self.view];
//    [self trans180:_imageView];
//    [self changeUIDirection:180];
}


// 画面上の各種アイテムを回転させるメソッド
//- (void) correspondToDeviceRotation : (int)angle {
//    NSLog(@"correspondToDeviceRotation");
//    
//    // 回転させるためのアフィン変形を作成する
//    CGAffineTransform t = CGAffineTransformMakeRotation(angle * M_PI / 180);
//    
//    // 回転させるのにアニメーションをかけてみた
//    [UIView beginAnimations:@"device rotation" context:nil];
//    [UIView setAnimationDuration:0.3];
//    
//    _popupImage.transform = t;
//    _popupBtn.transform = t;
//    
//    // アニメーション開始
//    [UIView commitAnimations];
//}


//--------------------------------------------------------------------
//
//--------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//--------------------------------------------------------------------
// カメラ初期化
//--------------------------------------------------------------------
- (void)initCamera
{
    [super didReceiveMemoryWarning];
    
    // カメラ初期化
    _videoCamera = [[CvVideoCamera alloc] initWithParentView:_imageView];
    _videoCamera.delegate = self;
    _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    _videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    _videoCamera.defaultFPS = 30;
}


//--------------------------------------------------------------------
// スワイプ設定の初期化
//--------------------------------------------------------------------
- (void)initMenuCommand{
    _currDirection = XYOrigamiDirectionFromLeft;
    _commandView = [[CommandViewController alloc] initWithNibName:@"CommandViewController" bundle:nil];
    

    // UIPanGestureRecognizer をインスタンス化します。また、イベント発生時に呼び出すメソッドを selector で指定します。
    UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc]
                                                   initWithTarget:self
                                                   action:@selector(selSwipeRightGesture:)];
    // 右スワイプのイベントを指定します。
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    swipeRightGesture.numberOfTouchesRequired = 3;
    // Viewへ関連付けします。
    [self.view addGestureRecognizer:swipeRightGesture];
    
    
    
    // UIPanGestureRecognizer をインスタンス化します。また、イベント発生時に呼び出すメソッドを selector で指定します。
    UISwipeGestureRecognizer* swipeLeftGesture = [[UISwipeGestureRecognizer alloc]
                                                  initWithTarget:self
                                                  action:@selector(selSwipeLeftGesture:)];
    // 左スワイプのイベントを指定します。
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeLeftGesture.numberOfTouchesRequired = 3;
    // Viewへ関連付けします。
    [self.view addGestureRecognizer:swipeLeftGesture];
}


//--------------------------------------------------------------------
// 位置情報設定の初期化
//--------------------------------------------------------------------
- (void)initLocateData
{
#if OBJC_LOCATEDATA
    // センサ初期化
    _locate = [[LocateData alloc] init];
#else
    _locate = new LocateData();
#endif
    
    
    // GPS情報の初期化
    _gpsPoint = [NSArray arrayWithObjects:
                 [[CLLocation alloc] initWithLatitude:GPS_DAIBUTUDEN_LAD longitude:GPS_DAIBUTUDEN_LON],
                 [[CLLocation alloc] initWithLatitude:GPS_TOTO_LAD longitude:GPS_TOTO_LON],
                 [[CLLocation alloc] initWithLatitude:GPS_RUSYA_LAD longitude:GPS_RUSYA_LON],
                 [[CLLocation alloc] initWithLatitude:GPS_RENBEN_LAD longitude:GPS_RENBEN_LON],
                 [[CLLocation alloc] initWithLatitude:GPS_KEGONSEKAI_LAD longitude:GPS_KEGONSEKAI_LON],
                 [[CLLocation alloc] initWithLatitude:GPS_DAIBUTUDEN_TOTO_1_LAD longitude:GPS_DAIBUTUDEN_TOTO_1_LON],
                 [[CLLocation alloc] initWithLatitude:GPS_DAIBUTUDEN_TOTO_2_LAD longitude:GPS_DAIBUTUDEN_TOTO_2_LON],
                 [[CLLocation alloc] initWithLatitude:GPS_DAIBUTU_BACK_LEFT_LAD longitude:GPS_DAIBUTU_BACK_LEFT_LON],
                 [[CLLocation alloc] initWithLatitude:GPS_DAIBUTU_BACK_RIGHT_LAD longitude:GPS_DAIBUTU_BACK_RIGHT_LON],
                 
                 nil];
}


//--------------------------------------------------------------------
// Motionセンサ初期化
//--------------------------------------------------------------------
- (void)initMotinoData
{
    _motionManager = [[CMMotionManager alloc] init];
    
    //ジャイロスコープの有無を確認
    if (_motionManager.deviceMotionAvailable) {
        // センサーの更新間隔の指定
        _motionManager.deviceMotionUpdateInterval = 0.01;  // 100Hz
        
        // ハンドラを指定
        CMDeviceMotionHandler handler = ^(CMDeviceMotion *motion, NSError *error) {
            
            /* 加速度センサー(ローパスフィルタ) */
            _locate->gravityX = motion.gravity.x;
            _locate->gravityY = motion.gravity.y;
            _locate->gravityZ = motion.gravity.z;
            
            /* 加速度センサー(ハイパスフィルタ) */
            _locate->userAccelerationX = motion.userAcceleration.x;
            _locate->userAccelerationY = motion.userAcceleration.y;
            _locate->userAccelerationZ = motion.userAcceleration.z;
            
            /* ジャイロスコープ (ラジアン/秒) */
            _locate->gyairoX = motion.rotationRate.x;
            _locate->gyairoY = motion.rotationRate.y;
            _locate->gyairoZ = motion.rotationRate.z;
            
            /* 磁力センサー マイクロテスラ */
            _locate->magneticX = motion.magneticField.field.x;
            _locate->magneticY = motion.magneticField.field.y;
            _locate->magneticZ = motion.magneticField.field.z;
            _locate->accuracy = motion.magneticField.accuracy;  // 磁力の強さ
            
            /* CMAttitude */
            // Y軸中心のラジアン角: -π〜π(-180度〜180度)
            _locate->roll = motion.attitude.roll;
            // X軸中心のラジアン角: -π/2〜π/2(-90度〜90度)
            _locate->pitch = motion.attitude.pitch;
            // Z軸中心のラジアン角: -π〜π(-180度〜180度)
            _locate->yaw = motion.attitude.yaw;
            
            // ImageViewControllerに渡す用
            _appDelegate.motion = _motionManager.deviceMotion;
            
        };
        
#if USE_MAGNETIC
        // Z軸を鉛直として、X軸を横とする。その際、GPSと電子コンパスを利用して、X軸を"真北"に設定
        [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical
                                                            toQueue:[NSOperationQueue currentQueue] withHandler:handler];
#else
        // Z軸を鉛直として、X軸を横とする。電子コンパスの情報は利用しない
        [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical
                                                            toQueue:[NSOperationQueue currentQueue] withHandler:handler];
#endif
                
    }
}


- (void)setLimitMode
{
#if 0
    static BOOL isLimitState = _appDelegate.isLimitMode;
    
    if (isLimitState != _appDelegate.isLimitMode) {
        _btnRusyanabutu.enabled = !_appDelegate.isLimitMode;
        _btnDaibutuden.enabled = !_appDelegate.isLimitMode;
        _btnRengezouWithRusyanabutu.enabled = !_appDelegate.isLimitMode;
        _btnRenbenWithRengezou.enabled = !_appDelegate.isLimitMode;
        
        isLimitState = _appDelegate.isLimitMode;
    }
#else
    _btnRusyanabutu.enabled = !_appDelegate.isLimitMode;
    _btnDaibutuden.enabled = !_appDelegate.isLimitMode;
    _btnRengezouWithRusyanabutu.enabled = !_appDelegate.isLimitMode;
    _btnRenbenWithRengezou.enabled = !_appDelegate.isLimitMode;
#endif
}



//
//CGFloat DegreesToRadians(CGFloat degrees)
//{
//    return degrees * M_PI / 180;
//};
//
//CGFloat RadiansToDegrees(CGFloat radians)
//{
//    return radians * 180 / M_PI;
//};
//
//
//
//-(void)deviceOrientationCheck
//{
////    [self changeUIDirection:45];
//}


//
//-(void)transUIView:(UIView*)ui withAngle:(double)angle
//{
//    double cx = 768.0 / 2.0;
//    double cy = 1004 / 2.0;
//    
//    double rad = DegreesToRadians(angle);
//    double m00 = cos(rad);
//    double m01 = -sin(rad);
//    double m02 = cx-cx * cos(rad) + cy * sin(rad);
//    double m10 = sin(rad);
//    double m11 = cos(rad);
//    double m12 = cy - cx * sin(rad) - cy * cos(rad);
//    
//    ui.transform = CGAffineTransformMake(m00, m01, m10, m11, m02, m12);
//}


-(void)trans180:(UIView*)ui
{
//    const static double cx = 768.0 / 2.0;
//    const static double cy = 1004 / 2.0;
//    
//    ui.transform = CGAffineTransformIdentity;
//    
//    CGAffineTransform t1 = CGAffineTransformMakeRotation(M_PI);
//    CGAffineTransform t2 = CGAffineTransformMakeTranslation((ui.center.x < cx) ? (cx-ui.center.x)*4 : -(ui.center.x-cx)*4,
//                                                            (ui.center.y < cy) ? (cy-ui.center.y)*4 : -(ui.center.y-cy)*4);
//    
//    ui.transform = CGAffineTransformConcat(t1, t2);
}


//--------------------------------------------------------------------
// UIを変化させる
//--------------------------------------------------------------------
- (void)changeUIDirection:(double)angle
{
    
#if 1
    [self trans180:_popupImage];
    [self trans180:_popupBtn];
    
    [self trans180:_dbgImage];
    [self trans180:_mapImageView];
    [self trans180:_btnRenbenWithRengezou];
    [self trans180:_btnRengezouWithRusyanabutu];
    [self trans180:_btnRusyanabutu];
    [self trans180:_btnDaibutuden];
    [self trans180:_btnTotou];
    [self trans180:_pointDaibutuden];
    [self trans180:_pointTotou];
    [self trans180:_pointRusyanabutu];
    [self trans180:_pointRenbenWithRengezou];
    [self trans180:_pointRengezouWithRusyanabutu];
    [self trans180:_route1];
    [self trans180:_route2];
    [self trans180:_route3];
    [self trans180:_route4];
    [self trans180:_route5];
    [self trans180:_route6];
    [self trans180:_route7];
    [self trans180:_route8];
    
#else
    [UIView beginAnimations:@"device rotation" context:nil];
    [UIView setAnimationDuration:0.3];
    _popupImage.transform = t;
    _popupBtn.transform = t;
    _dbgImage.transform = t;
    
    _mapImageView.transform = t;
    
    _btnRenbenWithRengezou.transform = t;
    _btnRengezouWithRusyanabutu.transform = t;
    _btnRusyanabutu.transform = t;
    _btnTotou.transform = t;
    _btnDaibutuden.transform = t;
    
    _pointDaibutuden.transform = t;
    _pointTotou.transform = t;
    _pointRusyanabutu.transform = t;
    _pointRenbenWithRengezou.transform = t;
    _pointRengezouWithRusyanabutu.transform = t;
    
    _route1.transform = t;
    _route2.transform = t;
    _route3.transform = t;
    _route4.transform = t;
    _route5.transform = t;
    _route6.transform = t;
    _route7.transform = t;
    _route8.transform = t;
    // アニメーション開始
    [UIView commitAnimations];
#endif
    
    
}



//--------------------------------------------------------------------
// 位置情報の初期化
//--------------------------------------------------------------------
- (void)initLocationData
{
    CLLocationDegrees headingFilter = kCLHeadingFilterNone;
    CLDeviceOrientation headingOrientation = CLDeviceOrientationUnknown;
    
    // インスタンスの生成
    _locationManager = [[CLLocationManager alloc] init];
    
    
    // ヘディングと位置情報サービスが利用できるかどうかをチェック
    if ([CLLocationManager locationServicesEnabled] && [CLLocationManager headingAvailable]) {
        _locationManager.delegate = self;
        _locationManager.headingFilter = headingFilter;
        _locationManager.headingOrientation = headingOrientation;
        
        // 真北の設定
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // ヘディング開始
        [_locationManager startUpdatingHeading];
        
        // 測位開始
        [_locationManager startUpdatingLocation];
    }
    else {
        NSLog(@"Location services not available.");
    }
}


//--------------------------------------------------------------------
// 位置情報のUIの更新
//--------------------------------------------------------------------
-(void)updateGpsPointUI:(int)index
{
    // 初期化
    _route1.highlighted = NO;
    _route2.highlighted = NO;
    _route3.highlighted = NO;
    _route4.highlighted = NO;
    _route5.highlighted = NO;
    _route6.highlighted = NO;
    _route7.highlighted = NO;
    _route8.highlighted = NO;
    _pointDaibutuden.highlighted = NO;
    _pointRenbenWithRengezou.highlighted = NO;
    _pointRengezouWithRusyanabutu.highlighted = NO;
    _pointRusyanabutu.highlighted = NO;
    _pointTotou.highlighted = NO;
    
    // 指定された場所のみ光らせる
    switch (index) {
        case DAIBUTUDEN:
            _pointDaibutuden.highlighted = YES;
            break;
        case TOTO:
            _pointTotou.highlighted = YES;
            break;
        case RUSYA:
            _pointRengezouWithRusyanabutu.highlighted = YES;
            break;
        case RENBEN:
            _pointRenbenWithRengezou.highlighted = YES;
            break;
        case KEGON:
            _pointRengezouWithRusyanabutu.highlighted = YES;
            break;
        case 5:
            _route1.highlighted = YES;
            break;
        case 6:
            _route2.highlighted = YES;
            break;
        case 7:
            _route3.highlighted = YES;
            break;
        case 8:
            _route4.highlighted = YES;
            break;
        case 9:
            _route5.highlighted = YES;
            break;
        case 10:
            _route6.highlighted = YES;
            break;
        case 11:
            _route7.highlighted = YES;
            break;
        case 12:
            _route8.highlighted = YES;
            break;
            
        default:
            break;
    }
    
    
}


//--------------------------------------------------------------------
// 位置情報UIの更新
//--------------------------------------------------------------------
- (void)updateGpsUIwithDistance:(int)nearDistance
                          first:(int)firstNearPointIndex
                         second:(int)secondNearPointIndex
{
    // 外にいるかどうか判別
    if (DAIBUTUDEN <= firstNearPointIndex && firstNearPointIndex < RUSYA) {
        // 目的地点の場合
        if ((firstNearPointIndex == DAIBUTUDEN
             || firstNearPointIndex == TOTO)
            && nearDistance < POINT_MIN_DISTANCE)
        {
            [self updateGpsPointUI:firstNearPointIndex];
            _popupText.highlighted = YES;
            NSLog(@"大仏 or 東塔");
        }
        //　途中経路の場合
        else {
            NSLog(@"そのほか（大仏 or 東塔）");

            
//            // 大仏殿ポイントと八角灯籠の南側エリア
//            if (firstNearPointIndex == DAIBUTUDEN && secondNearPointIndex == DAIBUTUDEN_1_TOTO) {
//                [self updateGpsPointUI:5];
//            }
//            // 大仏殿ポイントと八角灯籠の北側エリア
//            else if ((firstNearPointIndex == DAIBUTUDEN_1_TOTO && secondNearPointIndex == DAIBUTUDEN_2_TOTO)
//                     || (firstNearPointIndex == DAIBUTUDEN_2_TOTO && secondNearPointIndex == DAIBUTUDEN_1_TOTO)) {
//                [self updateGpsPointUI:6];
//            }
//            // 八角灯籠ポイント周辺
//            else if((firstNearPointIndex == DAIBUTUDEN_2_TOTO && secondNearPointIndex == TOTO)
//                    || (firstNearPointIndex == TOTO && secondNearPointIndex == DAIBUTUDEN_2_TOTO)) {
//                [self updateGpsPointUI:7];
//            }
//            // 東塔と大仏のエリア
//            else if ((firstNearPointIndex == TOTO && secondNearPointIndex == RUSYA)
//                     || (firstNearPointIndex == RUSYA && secondNearPointIndex == TOTO)) {
//                [self updateGpsPointUI:8];
//            }
            [self updateGpsPointUI:-1];
            _popupText.highlighted = NO;
        }
    }
    // 中にいるかどうか
    // (一応処理をわけておくけど、うまく動くならくっつけてもいいかもね)
    else {
        // 目的地点の場合 (この情報だけで、ちゃんと動く？)
        if ((firstNearPointIndex == RUSYA || firstNearPointIndex == RENBEN || firstNearPointIndex == KEGON)
            && nearDistance < POINT_MIN_DISTANCE) {
            [self updateGpsPointUI:firstNearPointIndex];
            _popupText.highlighted = YES;
            NSLog(@"中");
        }
        // 途中経路の場合
        else {
            NSLog(@"そのほか（中）");
//            // 盧舎那仏と蓮弁の間エリア
//            if ((firstNearPointIndex == RUSYA && secondNearPointIndex == RENBEN)
//                || (firstNearPointIndex == RENBEN && secondNearPointIndex == RUSYA)) {
//                [self updateGpsPointUI:9];
//            }
//            // 蓮弁と大仏の左側エリア
//            else if((firstNearPointIndex == RENBEN && secondNearPointIndex == DAIBUTU_LEFT)
//                    || (firstNearPointIndex == DAIBUTU_LEFT && secondNearPointIndex == RENBEN)) {
//                [self updateGpsPointUI:10];
//            }
//            // 大仏の後側エリア
//            else if((firstNearPointIndex == DAIBUTU_LEFT && secondNearPointIndex == DAIBUTU_RIGHT)
//                    || (firstNearPointIndex == DAIBUTU_RIGHT && secondNearPointIndex == DAIBUTU_LEFT)) {
//                [self updateGpsPointUI:11];
//            }
//            // 大仏の右側と華厳世界地点のエリア
//            else if((firstNearPointIndex == DAIBUTU_RIGHT && secondNearPointIndex == KEGON)
//                    || (firstNearPointIndex == KEGON && secondNearPointIndex == DAIBUTU_RIGHT)) {
//                [self updateGpsPointUI:12];
//            }
            [self updateGpsPointUI:-1];
            _popupText.highlighted = NO;
        }
    }
}


//--------------------------------------------------------------------
// 位置情報更新時
//--------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    //緯度・経度を出力
//    NSLog(@"didUpdateToLocation latitude=%.8f, longitude=%.8f",
//          [newLocation coordinate].latitude,
//          [newLocation coordinate].longitude);
    
    _locate->gps_long = [newLocation coordinate].longitude;
    _locate->gps_lati = [newLocation coordinate].latitude;
    
    
    if (!_appDelegate.isGPSView) {
        // 初期化
        int nearDistance = 999999999;
        int firstNearPointIndex = -1;   // 最も近い地点
        int secondNearPointIndex = -1;  // 二番目に近い地点
        
        // 一番近い距離の地点を探す
        for (int i = 0; i < [_gpsPoint count]; ++i) {
            CLLocationDistance distance = [newLocation distanceFromLocation:[_gpsPoint objectAtIndex:i]];
            if (distance < nearDistance) {
                nearDistance = distance;
                secondNearPointIndex = firstNearPointIndex;
                firstNearPointIndex = i;
            }
        }
        // デバッグ用にメンバ変数として距離を覚えておく
        _distanceFromHeareToNearPoint = nearDistance;
        
        // どの地点ともDRAW_MAX_DISTANCE以上離れている場合は何も表示しない
        if (DRAW_MAX_DISTANCE < nearDistance) {
            [self updateGpsPointUI:-1];
        }
        else {
            // それ以外はUIを更新
            [self updateGpsUIwithDistance:nearDistance
                                    first:firstNearPointIndex
                                   second:secondNearPointIndex];
        }
    }
}


//--------------------------------------------------------------------
// 測位失敗時や、5位置情報の利用をユーザーが「不許可」とした場合などに呼ばれる
//--------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
}


//--------------------------------------------------------------------
// 方位を取得
//--------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    // ここで任意の処理
    _appDelegate.heading = newHeading;
}


//--------------------------------------------------------------------
// デバッグ情報表示用
//--------------------------------------------------------------------
- (void)printDbgInfo:(cv::Mat&)image
{
    std::stringstream stm, stm2;
    stm << "Most near point: " << _distanceFromHeareToNearPoint << " [m]";
    cv::putText(image, stm.str(), cv::Point(10, image.rows-20),
                cv::FONT_HERSHEY_PLAIN, 1.0, cv::Scalar(255,255,255,255));
    
    stm2 << "Heading angle [" << _appDelegate.heading.headingAccuracy << "] "
            << _appDelegate.heading.trueHeading << ">>" << _appDelegate.heading.description;
    cv::putText(image, stm2.str(), cv::Point(10, image.rows-40),
                cv::FONT_HERSHEY_PLAIN, 1.0, cv::Scalar(255,255,255,255));
}


//--------------------------------------------------------------------
// fpsを計算し、描画する
//--------------------------------------------------------------------
- (void)fps:(cv::Mat&)image
{
    static NSDate *startDate;
    NSDate *interval = [NSDate date];
    double fps = double(1 / [interval timeIntervalSinceDate:startDate]);
    
    std::stringstream stm, stm2, stm3;
    stm << "FPS: " << fps;
    cv::putText(image, stm.str(), cv::Point(10, image.rows-20),
                cv::FONT_HERSHEY_PLAIN, 1.0, cv::Scalar(0,0,255,255));
    stm2 << "Processing time: " << _processingTime;
    cv::putText(image, stm2.str(), cv::Point(10, image.rows-40),
                cv::FONT_HERSHEY_PLAIN, 1.0, cv::Scalar(0,0,255,255));
    stm3 << "Matched num: " << _mathed_result.mathed_num;
    cv::putText(image, stm3.str(), cv::Point(10, image.rows-60),
                cv::FONT_HERSHEY_PLAIN, 1.0, cv::Scalar(0,0,255,255));
    
    startDate = [NSDate date];
}


//--------------------------------------------------------------------
// float秒に一回trueを返す
//--------------------------------------------------------------------
- (bool)nowCallwithTime:(float)callTime
{
    bool isNow = false;
    static NSDate *startTime = [NSDate date];
    NSDate *interval = [NSDate date];
    double T = double([interval timeIntervalSinceDate:startTime]);
    
    if (callTime < T) {
        isNow = true;
        startTime = [NSDate date];
    }
    
    return isNow;
}


//--------------------------------------------------------------------
// 並列処理のトリガー
//------------------------------------------------------------  --------
- (void)backgroundThreadDidLoad:(id)delegate
{
    @autoreleasepool {
        // 排他制御
        @synchronized(delegate) {
            // ここに時間のかかる処理を行う
            NSDate *startDate = [NSDate date];
            
            // 特徴点抽出
            RunProcessing(_capImage, _key, _locate, _mathed_result);
            
            
            NSDate *interval = [NSDate date];
            _processingTime = double(1 / [interval timeIntervalSinceDate:startDate]);
            
            // デリゲートに通知する
            [delegate performSelectorOnMainThread:@selector(notifyBackgroundThreadDidFinish:)
                                       withObject:delegate waitUntilDone:NO];
        }
    }
}


//--------------------------------------------------------------------
// 並列処理を検知
//--------------------------------------------------------------------
- (void)notifyBackgroundThreadDidFinish:(id)delegate
{
    if ([delegate respondsToSelector:@selector(backgroundThreadDidFinish)]) {
        [delegate backgroundThreadDidFinish];
    }
}


//--------------------------------------------------------------------
// 並列処理の終了処理
//--------------------------------------------------------------------
- (void)backgroundThreadDidFinish
{
}


//--------------------------------------------------------------------
// アンケート集計画面
//--------------------------------------------------------------------
- (IBAction)BtnQuestionnaire:(id)sender {
    NSLog(@"Questionaire");
    QViewController *cnt = [[QViewController alloc] initWithNibName:@"QViewController" bundle:nil] ;
    [self addChildViewController:cnt];
    [self.view addSubview:cnt.view];
}


//--------------------------------------------------------------------
// ポップアップ画面
//--------------------------------------------------------------------
- (IBAction)popUpBtn:(id)sender {
    
    [self changeUIDirection:30];
    
    if (_isPop) {
        [UIView animateWithDuration:0.75
                         animations:^{_popupImage.alpha = 0.0;}
                         completion:^(BOOL finished){ [_popupImage removeFromSuperview]; }];
        _isPop = false;
    }
    else {
        _popupImage = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:@"info_1.png"];
        if (!image) {
            NSLog(@"Not image found");
        }
        else {
            [_popupImage setFrame:CGRectMake(90.0, 750.0, image.size.width, image.size.height)];
            [_popupImage setContentMode:UIViewContentModeScaleToFill];
            [_popupImage setImage:image];
            
            [_popupImage setAlpha:0];
            [UIView beginAnimations:nil context:NULL];
            // 0.75秒で
            [UIView setAnimationDuration:0.75];
            [_popupImage setAlpha:1];
            
            [self.view addSubview:_popupImage];
            [UIView commitAnimations];
            _isPop = true;
        }
    }
}


//--------------------------------------------------------------------
//  全方位画像への切替
//--------------------------------------------------------------------
- (BOOL)isChangeOK {
    BOOL ret = false;
    
    // 傾き加減で全方位画像へ移動するかを判定する
    //  2013年3月23日　傾き加減による画面遷移は無くす方向で
    //    if (CHANGE_ANGEL < fabs(_locate->gravityZ)) {
    if (0) {
        ret = false;
    }
    else {
        if (_isPop) {
            [_popupImage removeFromSuperview];
        }
        
        NSLog(@"Load view");
        

        ret = true;
    }
    return ret;
}


//--------------------------------------------------------------------
//  iPadを正面にかざすように促す
//--------------------------------------------------------------------
- (void)popUpPlease{
    if (_isPop) {
        [_popupImage removeFromSuperview];
    }
    
    _popupImage = [[UIImageView alloc] init];
    UIImage *image = [UIImage imageNamed:@"info_2.png"];
    if (!image) {
        NSLog(@"Not image found");
    }
    else {
        [_popupImage setFrame:CGRectMake(90.0, 750.0, image.size.width, image.size.height)];
        [_popupImage setContentMode:UIViewContentModeScaleToFill];
        [_popupImage setImage:image];
        
        [_popupImage setAlpha:0];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.75];
        [_popupImage setAlpha:1];
        
        [self.view addSubview:_popupImage];
        [UIView commitAnimations];
        _isPop = true;
    }
}


//--------------------------------------------------------------------
// 東塔の映像
//--------------------------------------------------------------------
- (IBAction)BtnScene2:(id)sender {
    if ([self isChangeOK]) {
        _appDelegate.imagepath = @"11_02_%02d";
        _appDelegate.musicpath = @"GAIKAN";
        _appDelegate.infopath = @"info_4.png";
        _appDelegate.animateStartHead = 120.0;
        
#if USE_MAGNETIC
//        _appDelegate.radianY = DEG2RAD(180.0f);
        _appDelegate.degreeY = 180.0f;
#else
        _appDelegate.radianY = DEG2RAD(-90.0f);
#endif
        
        NSLog(@"Change to %@", _appDelegate.imagepath);
    }
    else {
        [self popUpPlease];
    }
}


//--------------------------------------------------------------------
// 天平時代の大仏様
//--------------------------------------------------------------------
- (IBAction)BtnScene4:(id)sender {
    if ([self isChangeOK]) {
        _appDelegate.imagepath = @"11_05_%02d";
        _appDelegate.musicpath = @"GAIKAN";
        _appDelegate.infopath = @"info_3.png";
        _appDelegate.animateStartHead = 0.0;

#if USE_MAGNETIC
//        _appDelegate.radianY = DEG2RAD(175.0f);
        _appDelegate.degreeY = 175.0f;
#else
        _appDelegate.radianY = DEG2RAD(-90.0f);
#endif
        
        NSLog(@"Change to %@", _appDelegate.imagepath);
    }
    else {
        [self popUpPlease];
    }
}


//--------------------------------------------------------------------
// 蓮弁と蓮華世界
//--------------------------------------------------------------------
- (IBAction)BtnScene6:(id)sender {
    if ([self isChangeOK]) {
        _appDelegate.imagepath = @"11_06_%02d";
        _appDelegate.musicpath = @"SHUSHOE";
        _appDelegate.infopath = @"info_6.png";
        _appDelegate.animateStartHead = 45.0;
        
#if USE_MAGNETIC
//        _appDelegate.radianY = DEG2RAD(35.0f);
        _appDelegate.degreeY = 35.0f;
#else
        _appDelegate.radianY = DEG2RAD(110.0f);
#endif
        
        NSLog(@"Change to %@", _appDelegate.imagepath);
    }
    else {
        [self popUpPlease];
    }
}


//--------------------------------------------------------------------
// 盧遮那仏
//--------------------------------------------------------------------
- (IBAction)BtnScene7:(id)sender {
    if ([self isChangeOK]) {
        _appDelegate.imagepath = @"10_06_%02d";
        _appDelegate.musicpath = @"SHUSHOE";
        _appDelegate.infopath = @"info_5.png";
        _appDelegate.animateStartHead = 0.0;

        
#if USE_MAGNETIC
//        _appDelegate.radianY = DEG2RAD(-80.0f);
        _appDelegate.degreeY = -80.0f;
#else
        _appDelegate.radianY = DEG2RAD(0.0f);
#endif
        
        NSLog(@"Change to %@", _appDelegate.imagepath);
    }
    else {
        [self popUpPlease];
    }
}


//--------------------------------------------------------------------
// 蓮華蔵と盧遮那仏
//--------------------------------------------------------------------
- (IBAction)BtnScene12:(id)sender {
    if ([self isChangeOK]) {
        _appDelegate.imagepath = @"11_12_%02d";
        _appDelegate.musicpath = @"RENGEZA";
        _appDelegate.infopath = @"info_7.png";
        _appDelegate.animateStartHead = 320.0;

        
#if USE_MAGNETIC
//        _appDelegate.radianY = DEG2RAD(190.0f);
        _appDelegate.degreeY = 190.0f;
#else
        _appDelegate.radianY = DEG2RAD(-50.0f);
#endif
        
        NSLog(@"Change to %@", _appDelegate.imagepath);
    }
    else {
        [self popUpPlease];
    }
}


//--------------------------------------------------------------------
// 右スワイプされた時に実行されるメソッド、selectorで指定します。
//--------------------------------------------------------------------
- (void)selSwipeRightGesture:(UISwipeGestureRecognizer *)sender {
    if (_currDirection == XYOrigamiDirectionFromLeft) {
        NSLog(@"swipe right (left)");
        [self.view showOrigamiTransitionWith:_commandView.view
                               NumberOfFolds:COMMAND_FOLDSNUM
                                    Duration:COMMAND_DURATION
                                   Direction:XYOrigamiDirectionFromLeft
                                  completion:^(BOOL finished) {
                                      [self setLimitMode];
                                  }];
    }
    else {
        NSLog(@"swipe right (right)");
        [self.view hideOrigamiTransitionWith:_commandView.view
                               NumberOfFolds:COMMAND_FOLDSNUM
                                    Duration:COMMAND_DURATION
                                   Direction:XYOrigamiDirectionFromRight
                                  completion:^(BOOL finished) {
                                  }];
    }
}


//--------------------------------------------------------------------
// 左スワイプされた時に実行されるメソッド、selectorで指定します。
//--------------------------------------------------------------------
- (void)selSwipeLeftGesture:(UISwipeGestureRecognizer *)sender {
    if (_currDirection == XYOrigamiDirectionFromLeft) {
        NSLog(@"swipe left (left)");
        [self.view hideOrigamiTransitionWith:_commandView.view
                               NumberOfFolds:COMMAND_FOLDSNUM
                                    Duration:COMMAND_DURATION
                                   Direction:XYOrigamiDirectionFromLeft
                                  completion:^(BOOL finished) {
                                      [self setLimitMode];
                                  }];
    }
    else {
        NSLog(@"swipe left (right)");
        [self.view showOrigamiTransitionWith:_commandView.view
                               NumberOfFolds:COMMAND_FOLDSNUM
                                    Duration:COMMAND_DURATION
                                   Direction:XYOrigamiDirectionFromRight
                                  completion:^(BOOL finished) {
                                  }];
    }
}


//--------------------------------------------------------------------
//
//--------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    NSLog(@"oriete");
#if 1
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
        return (interfaceOrientation != UIDeviceOrientationPortrait);
    } else {
        return YES;
    }
#else
    return NO;
#endif
}


//--------------------------------------------------------------------
// 毎フレーム呼ばれる画像処理
//--------------------------------------------------------------------
- (void)processImage:(cv::Mat&)image;
{
    if ([self nowCallwithTime:1.0]) {
        _capImage = image.clone();
        [self performSelectorInBackground:@selector(backgroundThreadDidLoad:) withObject:self];
    }
    
    
    
    // デバッグ情報表示用
//    [self printDbgInfo:image];
    
    // 検出した特徴点を描画
    //DrawCircle(image,_key);
    
    // センサ情報を描画
    // 不要ならコメントアウト
    //DrawDeviceInfo(_locate, image);
    
    //[self fps:image];
    
    cv::cvtColor(image, image, CV_BGRA2GRAY);
}


@end
