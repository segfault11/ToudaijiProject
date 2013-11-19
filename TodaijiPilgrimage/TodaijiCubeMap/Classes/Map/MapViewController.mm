//
//  CameraViewController.m
//  TodaijiCubeMap
//
//  Created by Akaguma on 13/02/18.
//  Copyright (c) 2013年 Akaguma Takayuki. All rights reserved.
//
#import "MapViewController.h"
#import "QViewController.h"

#define DEG2RAD(x)        (M_PI*x/180.)


@interface MapViewController ()

@end

////////////////////////////////////////////////////////////////////////////
// Locateデータ
////////////////////////////////////////////////////////////////////////////
//#if OBJC_LOCATEDATA
//@implementation LocateData
//
////--------------------------------------------------------------------
//// 初期化
////--------------------------------------------------------------------
//- (id)init
//{
//    self = [super init];
//    if (self) {
//        
//    }
//    return self;
//}
//
//@end
//#endif




////////////////////////////////////////////////////////////////////////////
// Map データ
////////////////////////////////////////////////////////////////////////////
@implementation MapViewController

//--------------------------------------------------------------------
//
//--------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _appDelegate = (OmniAppDelegate*)[[UIApplication sharedApplication] delegate];
    _processingTime = 0.0;
    _isPop = false;
    
#if OBJC_LOCATEDATA
    // センサ初期化
    _locate = [[LocateData alloc] init];
#else
    _locate = new LocateData();
#endif
    [self initLocationData];
    
    _motionManager = [[CMMotionManager alloc] init];
    _motionManager.deviceMotionUpdateInterval = 0.1;

    
    [self initCamera];
    [self initMotinoData];
    
    [_videoCamera start];
}



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
// センサ初期化
//--------------------------------------------------------------------
- (void)initMotinoData
{
    //ジャイロスコープの有無を確認
    if (_motionManager.deviceMotionAvailable) {
        // センサーの更新間隔の指定
        _motionManager.deviceMotionUpdateInterval = 0.1;  // 100Hz
        
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
        [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXTrueNorthZVertical toQueue:[NSOperationQueue currentQueue] withHandler:handler];
#else
        // Z軸を鉛直として、X軸を横とする。電子コンパスの情報は利用しない
        [_motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical toQueue:[NSOperationQueue currentQueue] withHandler:handler];
#endif
    }
}


//--------------------------------------------------------------------
// 位置情報の初期化
//--------------------------------------------------------------------
- (void)initLocationData
{
    _locationManager = [[CLLocationManager alloc] init];
    
    // 位置情報サービスが利用できるかどうかをチェック
    if ([CLLocationManager locationServicesEnabled]) {
        _locationManager.delegate = self;
        // 測位開始
        [_locationManager startUpdatingLocation];
    }
    else {
        NSLog(@"Location services not available.");
    }
}


//--------------------------------------------------------------------
// 位置情報更新時
//--------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    
    //緯度・経度を出力
//        NSLog(@"didUpdateToLocation latitude=%.6f, longitude=%.6f",
//              [newLocation coordinate].latitude,
//              [newLocation coordinate].longitude);
    
    _locate->gps_long = [newLocation coordinate].longitude;
    _locate->gps_lati = [newLocation coordinate].latitude;
    
    btnGpsPoint.center = CGPointMake(btnGpsPoint.center.x, btnGpsPoint.center.y - 1.0);
    
}


//--------------------------------------------------------------------
// 測位失敗時や、5位置情報の利用をユーザーが「不許可」とした場合などに呼ばれる
//--------------------------------------------------------------------
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError");
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
    cv::putText(image, stm.str(), cv::Point(10, image.rows-20), cv::FONT_HERSHEY_PLAIN, 1.0, cv::Scalar(0,0,255,255));
    stm2 << "Processing time: " << _processingTime;
    cv::putText(image, stm2.str(), cv::Point(10, image.rows-40), cv::FONT_HERSHEY_PLAIN, 1.0, cv::Scalar(0,0,255,255));
    stm3 << "Matched num: " << _mathed_result.mathed_num;
    cv::putText(image, stm3.str(), cv::Point(10, image.rows-60), cv::FONT_HERSHEY_PLAIN, 1.0, cv::Scalar(0,0,255,255));
    
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


#ifdef __cplusplus
//--------------------------------------------------------------------
// 並列処理のトリガー
//--------------------------------------------------------------------
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
            [delegate performSelectorOnMainThread:@selector(notifyBackgroundThreadDidFinish:) withObject:delegate waitUntilDone:NO];
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
// 並列処理の終了処理
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
        // ローディングビュー作成
        UIView *loadingView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        loadingView.backgroundColor = [UIColor blackColor];
        loadingView.alpha = 0.5f;
        
        // インジケータ作成
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [indicator setCenter:CGPointMake(loadingView.bounds.size.width / 2, loadingView.bounds.size.height / 2)];
        
        // ビューに追加
        [loadingView addSubview:indicator];
        [self.navigationController.view addSubview:loadingView];
        
        // インジケータ再生
        [indicator startAnimating];
        
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
//  全方位画像への切替
//--------------------------------------------------------------------

// 東塔の映像
- (IBAction)BtnScene2:(id)sender {
    if ([self isChangeOK]) {
        _appDelegate.imagepath = @"11_02_%02d";
        _appDelegate.musicpath = @"GAIKAN";
        _appDelegate.infopath = @"info_4.png";


#if USE_MAGNETIC
        _appDelegate.radian = DEG2RAD(0.0f);
#else
        _appDelegate.radian = DEG2RAD(-90.0f);
#endif
        
        NSLog(@"Change to %@", _appDelegate.imagepath);
    }
    else {
        [self popUpPlease];
    }
}

// 天平時代の大仏様
- (IBAction)BtnScene4:(id)sender {
    if ([self isChangeOK]) {
        _appDelegate.imagepath = @"11_05_%02d";
        _appDelegate.musicpath = @"GAIKAN";
        _appDelegate.infopath = @"info_3.png";
        
#if USE_MAGNETIC
        _appDelegate.radian = DEG2RAD(0.0f);
#else
        _appDelegate.radian = DEG2RAD(-90.0f);
#endif

        
        NSLog(@"Change to %@", _appDelegate.imagepath);
    }
    else {
        [self popUpPlease];
    }
}

// 蓮弁と蓮華世界
- (IBAction)BtnScene6:(id)sender {
    if ([self isChangeOK]) {
        _appDelegate.imagepath = @"11_06_%02d";
        _appDelegate.musicpath = @"SHUSHOE";
        _appDelegate.infopath = @"info_6.png";

#if USE_MAGNETIC
        _appDelegate.radian = DEG2RAD(0.0f);
#else
        _appDelegate.radian = DEG2RAD(110.0f);
#endif
        
        NSLog(@"Change to %@", _appDelegate.imagepath);
    }
    else {
        [self popUpPlease];
    }
}

// 盧遮那仏
- (IBAction)BtnScene7:(id)sender {
    if ([self isChangeOK]) {
        _appDelegate.imagepath = @"10_06_%02d";
        _appDelegate.musicpath = @"SHUSHOE";
        _appDelegate.infopath = @"info_5.png";
        
#if USE_MAGNETIC
        _appDelegate.radian = DEG2RAD(0.0f);
#else
        _appDelegate.radian = DEG2RAD(0.0f);
#endif
        
        //    _appDelegate.radian = DEG2RAD(10.0f);  //-10.0f;//(-M_PI/2.0f)*1.2;
        NSLog(@"Change to %@", _appDelegate.imagepath);
    }
    else {
        [self popUpPlease];
    }
}

// 蓮華蔵と盧遮那仏
- (IBAction)BtnScene12:(id)sender {
    if ([self isChangeOK]) {
        _appDelegate.imagepath = @"11_12_%02d";
        _appDelegate.musicpath = @"RENGEZA";
        _appDelegate.infopath = @"info_7.png";
        
#if USE_MAGNETIC
        _appDelegate.radian = DEG2RAD(0.0f);
#else
        _appDelegate.radian = DEG2RAD(-50.0f);
#endif
        
        NSLog(@"Change to %@", _appDelegate.imagepath);
    }
    else {
        [self popUpPlease];
    }
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
    // 検出した特徴点を描画
    //DrawCircle(image,_key);
    
    // センサ情報を描画
    // 不要ならコメントアウト
    //DrawDeviceInfo(_locate, image);
    
    //[self fps:image];
    
    cv::cvtColor(image, image, CV_BGRA2GRAY);
}
#endif

@end
