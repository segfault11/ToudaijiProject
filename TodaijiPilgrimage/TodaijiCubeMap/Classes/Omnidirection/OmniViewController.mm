//
//  OmniViewController.m
//  TodaijiCubeMap
//
//  Created by Akaguma on 13/02/18.
//  Copyright (c) 2013年 Akaguma Takayuki. All rights reserved.
//

#import "OmniViewController.h"

@interface OmniViewController () {
    
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    
    GLKSkyboxEffect *_skyboxEffect;  // スカイボックスのための変数
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation OmniViewController


GLKTextureInfo *_texInfo[TEXNUM];
GLKTextureInfo *_texInit;

CGFloat DegreesToRadians(CGFloat degrees)
{
    return degrees * M_PI / 180;
};

CGFloat RadiansToDegrees(CGFloat radians)
{
    return (radians * 180 / M_PI) + 180;
};


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
//  初期化
//--------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    _appDelegate = (OmniAppDelegate*)[[UIApplication sharedApplication] delegate];
    _animate_num = -1;
    _isPop = false;
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    
    [self setupGL];
    
    _pinchZoom = ANGLE_OMNIVIEW;
    UIPinchGestureRecognizer* pinchGesture = [[UIPinchGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(handlePinchGesture:)];
    
    [self.view addGestureRecognizer:pinchGesture];
    
//    [self trans180:_btnInfo];
//    [self trans180:_btnReturnMapView];
//    [self trans180:_popupImage];
//    [self trans180:self.view];
}

-(void)trans180:(UIView*)ui
{
    const static double cx = 768.0 / 2.0;
    const static double cy = 1004 / 2.0;
    
    ui.transform = CGAffineTransformIdentity;
    
    CGAffineTransform t1 = CGAffineTransformMakeRotation(M_PI);
    CGAffineTransform t2 = CGAffineTransformMakeTranslation((ui.center.x < cx) ? (cx-ui.center.x)*4 : -(ui.center.x-cx)*4,
                                                            (ui.center.y < cy) ? (cy-ui.center.y)*4 : -(ui.center.y-cy)*4);
    
    ui.transform = CGAffineTransformConcat(t1, t2);
}

//--------------------------------------------------------------------
//
//--------------------------------------------------------------------
- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}


//--------------------------------------------------------------------
//
//--------------------------------------------------------------------
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    
}


//--------------------------------------------------------------------
//
//--------------------------------------------------------------------
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
//  テクスチャをセットする
//--------------------------------------------------------------------
- (void)setBaseTextureWithFileName:(NSString *)filename
                     textureNumber:(int)num
{
    NSString *filepath = [NSString stringWithFormat:filename, num];
    NSURL *imageURL = [[NSBundle mainBundle] URLForResource:filepath withExtension:@"png"];
    _texInit = [GLKTextureLoader cubeMapWithContentsOfURL:imageURL
                                                       options:nil
                                                         error:NULL];
    
    if (_texInit != NULL) {
        GLuint texture_name = _skyboxEffect.textureCubeMap.name;
        glDeleteTextures(1, &texture_name);
        _skyboxEffect.textureCubeMap.name = _texInit.name;
    }
    else {
        NSLog(@"texture 見つからないよ");
    }

}


//--------------------------------------------------------------------
//  テクスチャを読み込む(アニメーション用)
//--------------------------------------------------------------------
- (int)setTextureWithFileName: (NSString *)filename textureNumber:(int)num {
    
    NSString *filepath = [NSString stringWithFormat:filename, num];
    NSURL *imageURL = [[NSBundle mainBundle] URLForResource:filepath withExtension:@"png"];
    _texInfo[num] = [GLKTextureLoader cubeMapWithContentsOfURL:imageURL
                                                       options:nil
                                                         error:NULL];
    if (_texInfo[num] == NULL) {
        NSLog(@"Tex Load [%d]=>×: %@", num, filepath);
    }
    else {
        NSLog(@"Tex Load [%d]=>○: %@", num, filepath);
    }
    return num;
}


//--------------------------------------------------------------------
//  テクスチャの切り替え(アニメーション用)
//--------------------------------------------------------------------
- (void)changeTextureWithTexNum: (int)tnum{
    // それ以外はテクスチャを張り替えるだけ
    NSLog(@"Tex Change %d", tnum);
    GLuint texture_name = _skyboxEffect.textureCubeMap.name;
    glDeleteTextures(1, &texture_name);
    _skyboxEffect.textureCubeMap.name = _texInfo[tnum].name;
}


//--------------------------------------------------------------------
//  テクスチャを貼り付け
//--------------------------------------------------------------------
- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    
    // スカイボックスの作成
    _skyboxEffect = [[GLKSkyboxEffect alloc] init];
    _skyboxEffect.xSize = 60;
    _skyboxEffect.ySize = 60;
    _skyboxEffect.zSize = 60;
    
    _appDelegate.imagepath = DEFAULT_OMNI_IMAGE;
    
    [self setBaseTextureWithFileName:_appDelegate.imagepath textureNumber:0];
}


//--------------------------------------------------------------------
//  info情報を表示
//--------------------------------------------------------------------
- (IBAction)btnViewInfo:(id)sender {
    if (_isPop) {
        [UIView animateWithDuration:0.75
                         animations:^{_popupImage.alpha = 0.0;}
                         completion:^(BOOL finished){ [_popupImage removeFromSuperview]; }];
        _isPop = false;
    }
    else {
        _popupImage = [[UIImageView alloc] init];
        UIImage *image = [UIImage imageNamed:_appDelegate.infopath];
        if (!image) {
            NSLog(@"Not image found");
        }
        else {
            [_popupImage setFrame:CGRectMake(90.0, 50.0, image.size.width, image.size.height)];
            [_popupImage setContentMode:UIViewContentModeScaleToFill];
            [_popupImage setImage:image];
            
            [_popupImage setAlpha:0];
//            [self trans180:_popupImage];
            
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
//
//--------------------------------------------------------------------
- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = nil;
}


//--------------------------------------------------------------------
// マップ画面へ戻る
//--------------------------------------------------------------------
- (IBAction)returnMapMode:(id)sender {
    if (self.view.alpha != 0) {
        
        // 現在覚えているテクスチャを全て破棄
        for (int i = 0; i < TEXNUM; ++i) {
            if (_texInfo[i] != NULL) {
                GLuint texture_name = _texInfo[i].name;
                glDeleteTextures(1, &texture_name);
                NSLog(@"Texture Delete [%d]: %@", i, _appDelegate.imagepath);
            }
            else {
                NSLog(@"Texture Skip [%d]: %@", i, _appDelegate.imagepath);
            }
        }
        
        // 遷移アニメーション
        [UIView animateWithDuration:1.0
                         animations:^{self.view.alpha = 0.0;}
                         completion:^(BOOL finished){
                             _imagename = DEFAULT_OMNI_IMAGE;
                             _appDelegate.imagepath = DEFAULT_OMNI_IMAGE;
                             if (_isPop) {
                                 [_popupImage removeFromSuperview];
                             }
                             [_musicPlayer stop];
                             
                         }];
    }
}


#pragma mark - GLKView and GLKViewController delegate methods

//- (double)radHeading:(double)degree
//{
//    double rad = 0.0;
//    
//    if (0 <= degree && degree < 180.0) {
//        rad = ((M_PI*(degree))/180.0);
//    }
//    else if(180.0 <= degree && degree <= 360.0) {
//        rad = ((M_PI*(degree-360.0))/180.0);
//    }
//    return rad;
//}

//--------------------------------------------------------------------
//  更新情報
//--------------------------------------------------------------------
- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(_pinchZoom),
                                                            aspect,
                                                            0.1f,
                                                            1001.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    CMDeviceMotion *motion = _appDelegate.motion;
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4Identity;
    
    // とりあえずクォータニオンを使い続ける
    // ジャイロデータにアクセスする場合はオイラー角の方が便利
#if 1   
    GLKQuaternion glkq;
    if(motion) {
        CMAttitude *attitude = motion.attitude;
        glkq.x = -attitude.quaternion.x;
        glkq.y = -attitude.quaternion.y;
        glkq.z = -attitude.quaternion.z;
        glkq.w = attitude.quaternion.w;
    }else {
        glkq.x = 0.0;
        glkq.y = 1.0;
        glkq.z = 0.0;
        glkq.w = 0.0;
        //glkq.w = 3.14159;
    }
    
    baseModelViewMatrix = GLKMatrix4MakeWithQuaternion(glkq);
    
    //baseModelViewMatrix = GLKMatrix4RotateZ(baseModelViewMatrix, _appDelegate.radianY);
    baseModelViewMatrix = GLKMatrix4RotateZ(baseModelViewMatrix, DEG2RAD(_appDelegate.degreeY));
    
//    baseModelViewMatrix = GLKMatrix4RotateZ(baseModelViewMatrix, [self radHeading:_appDelegate.heading.trueHeading]);
    baseModelViewMatrix = GLKMatrix4RotateX(baseModelViewMatrix, DEG2RAD(90.0));
    
#else
    
    baseModelViewMatrix = GLKMatrix4RotateY(baseModelViewMatrix, -motion.attitude.roll);
    baseModelViewMatrix = GLKMatrix4RotateX(baseModelViewMatrix, -motion.attitude.pitch);
    baseModelViewMatrix = GLKMatrix4RotateZ(baseModelViewMatrix, -motion.attitude.yaw);
    
    baseModelViewMatrix = GLKMatrix4RotateZ(baseModelViewMatrix, _appDelegate.radianY);
    baseModelViewMatrix = GLKMatrix4RotateX(baseModelViewMatrix, DEG2RAD(90.0)); 
#endif
    
    _skyboxEffect.transform.projectionMatrix = projectionMatrix;
    _skyboxEffect.transform.modelviewMatrix = baseModelViewMatrix;
    
}


//--------------------------------------------------------------------
//  ズームイン・アウトのマルチタッチの検証
//--------------------------------------------------------------------
- (void) handlePinchGesture:(UIPinchGestureRecognizer*) sender {
    UIPinchGestureRecognizer* pinch = (UIPinchGestureRecognizer*)sender;
    // エラーチェック
    if (std::isnan(pinch.velocity)) {
        return;
    }
    
    _pinchZoom = _pinchZoom -  pinch.velocity*0.2;
    if (ANGLE_OMNIVIEW < _pinchZoom) {
        _pinchZoom = ANGLE_OMNIVIEW;
    }
    
    if (_pinchZoom < ANGLE_OMNIVIEW_MAX) {
        _pinchZoom = ANGLE_OMNIVIEW_MAX;
    }
}


//--------------------------------------------------------------------
//  音楽再生の準備
//--------------------------------------------------------------------
-(void)prepareAudio
{
    NSError *error = nil;
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:_appDelegate.musicpath
                      ofType:@"mp3"];
    
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url
                                                          error:&error];
    
    if ( error != nil ) {
        NSLog(@"Music Load Error %@", [error localizedDescription]);
    }
    [_musicPlayer prepareToPlay];
    [_musicPlayer setDelegate:self];
    
    // 音声の時間を取得
    NSTimeInterval ti = _musicPlayer.duration;
    NSLog(@"This music play: %lf", ti);
}


//--------------------------------------------------------------------
//  ロード画面更新処理
//--------------------------------------------------------------------
- (void)setProgress:(float)progress {
    [SVProgressHUD showProgress:progress status:@""];
    
    if(progress >= 1.0f) {
        NSLog(@"dissmiss");
        [self performSelector:@selector(dismiss)
                   withObject:nil afterDelay:0.4f];
    }
}


//--------------------------------------------------------------------
//  ロード画面終了処理
//--------------------------------------------------------------------
#pragma mark -
#pragma mark Dismiss Methods Sample

- (void)dismiss {
	[SVProgressHUD dismiss];
}


//--------------------------------------------------------------------
//  描画処理
//--------------------------------------------------------------------
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    static int i_tex = 0;
    static int wait_frame = 0;
    
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // 以下2行でスカイボックスの描画を行う
    [_skyboxEffect prepareToDraw];
    [_skyboxEffect draw];
    
    
    // 全方位画像表示のタイミング！
    if (_imagename != _appDelegate.imagepath) {
        _pinchZoom = ANGLE_OMNIVIEW;
        [self setBaseTextureWithFileName:_appDelegate.imagepath
                           textureNumber:0];
        _imagename = _appDelegate.imagepath;
        
        // 各シーンの映像の場合
        if (![_imagename isEqualToString:DEFAULT_OMNI_IMAGE]) {
            // 全方位画面を表示
            [UIView animateWithDuration:1.00
                             animations:^{self.view.alpha = 1.0;}
                             completion:^(BOOL finished){
                                 ;
                             }];
            
            i_tex = 0;
            [SVProgressHUD showProgress:0 status:@""];
            _appDelegate.loadProgress = 0.0f;
            
            [self prepareAudio];
            [_musicPlayer play];
        }
    }
    
    // 全方位画像読み込み中 (ロード画面の更新)
    if (_appDelegate.loadProgress != -1) {
        [self setTextureWithFileName:_appDelegate.imagepath
                       textureNumber:i_tex];
        
        _appDelegate.loadProgress = (i_tex) * (1.0/(TEXNUM-1));
        [self setProgress:_appDelegate.loadProgress];
        
        if (i_tex == TEXNUM-1) {
            _appDelegate.loadProgress = -1;
            
            // アニメーションを呼び出すタイミング
            // 0 => 方位磁針から探す
            // 1 => すぐに開始する
            if (_appDelegate.isAnimation) {
                _animate_num = 0;
            }
            else {
                _animate_num = 1;
            }
        }
        i_tex++;
    }
    
    if (_animate_num == 0) {
        if (10 < _appDelegate.heading.headingAccuracy) {
            
//            double head = _appDelegate.heading.trueHeading + RadiansToDegrees(_appDelegate.radianY);
            double head = _appDelegate.heading.trueHeading;// + _appDelegate.degreeY;
            if (360.0 < head) {
                head = head  - 360.0;
            }
            
            if (_appDelegate.animateStartHead == 0.0) {
                if ((0 < head && head < 20.0) || 340 < head) {
                    wait_frame++;
                }
                else {
                    if (0 < wait_frame) {
                        wait_frame--;
                    }
                }
            }
            else {
                if (abs(head-_appDelegate.animateStartHead) < 40) {
                    wait_frame++;
                }
                else {
                    if (0 < wait_frame) {
                        wait_frame--;
                    }
                }
            }
            NSLog(@"true:%f,  head:%f", _appDelegate.animateStartHead, head);
        }
        
        if (WAIT_ANIMATION < wait_frame) {
            _animate_num = 1;
            wait_frame = 0;
        }
        
    }
    
    
    // アニメーション中
    if (0 < _animate_num) {
        static int divide_time = 1;
        
        if (divide_time%7 == 0) {
            [self changeTextureWithTexNum:_animate_num];
            _animate_num++;
            
            // アニメーション終了
            if (_animate_num == TEXNUM) {
                _animate_num = -1;
                divide_time = 1;
            }
        }
        divide_time++;
    }
    

    // 下を向けた時はMap画面へ切り替え
    if (_appDelegate.motion.gravity.z < -CHANGE_ANGEL) {
        
//        [UIView beginAnimations:@"device rotation" context:nil];
//        [UIView setAnimationDuration:0.3];
//
//        [_btnReturnMapView setCenter:CGPointMake(210, 14)];
//        
//        // アニメーション開始
//        [UIView commitAnimations];
        
//            [UIView animateWithDuration:0.75
//                             animations:^{self.view.alpha = 0.0;}
//                             completion:^(BOOL finished){
//                                 NSLog(@"Set [DEFAULT_OMNI_IMAGE]");
//                                 _imagename = @DEFAULT_OMNI_IMAGE;
//                                 _appDelegate.imagepath = @DEFAULT_OMNI_IMAGE;
//                                 if (_isPop) {
//                                     [_popupImage removeFromSuperview];
//                                 }
//                                 
//                                 [_musicPlayer stop];
//                                 
//                             }];
    }
}


//--------------------------------------------------------------------
// テクスチャ読み込み
//--------------------------------------------------------------------
- (void)backgroundLoadThreadDidLoad:(NSString*)tex_str
{
//    @autoreleasepool {
//        // 排他制御
////        @synchronized(delegate) {
//
//        
//        // デリゲートに通知する
//        [self performSelectorOnMainThread:@selector(notifyBackgroundLoadThreadDidFinish:)
//                               withObject:(NSString*)tex_str waitUntilDone:NO];
//        
//        
////        }
//    }
}


//--------------------------------------------------------------------
// テクスチャ読み込み処理を検知
//--------------------------------------------------------------------
- (void)notifyBackgroundLoadThreadDidFinish:(NSString*)tex_str
{
//    if ([self respondsToSelector:@selector(backgroundLoadThreadDidFinish)]) {
//        [self backgroundLoadThreadDidFinish];
//    }
}


//--------------------------------------------------------------------
// テクスチャ読み込み処理の終了処理
//--------------------------------------------------------------------
- (void)backgroundLoadThreadDidFinish
{
//    NSLog(@"Tex Load Thread Error");
}


//--------------------------------------------------------------------
// テクスチャ破棄
//--------------------------------------------------------------------
- (void)backgroundDeleteThreadDidLoad:(id)delegate
{
//    @autoreleasepool {
//        // 排他制御
//        @synchronized(delegate) {
//            for (int i = 0; i < TEXNUM; ++i) {
//                if (_texInfo[i] != NULL) {
//                    GLuint texture_name = _texInfo[i].name;
//                    glDeleteTextures(1, &texture_name);
//                    NSLog(@"Texture Delete [%d]: %@", i, _appDelegate.imagepath);
//                }
//                else {
//                    NSLog(@"Texture Skip [%d]: %@", i, _appDelegate.imagepath);
//                }
//            }
//
//            // デリゲートに通知する
//            [delegate performSelectorOnMainThread:@selector(notifyBackgroundDeleteThreadDidFinish:)
//                                       withObject:delegate waitUntilDone:NO];
//        }
//    }
}


//--------------------------------------------------------------------
// テクスチャ読み込み処理を検知
//--------------------------------------------------------------------
- (void)notifyBackgroundDeleteThreadDidFinish:(id)delegate
{
//    if ([delegate respondsToSelector:@selector(backgroundDeleteThreadDidFinish)]) {
//        [delegate backgroundDeleteThreadDidFinish];
//    }
}


//--------------------------------------------------------------------
// テクスチャ読み込み処理の終了処理
//--------------------------------------------------------------------
- (void)backgroundDeleteThreadDidFinish
{
//    NSLog(@"Delte Texture 終了処理来ました!!!");
}


//--------------------------------------------------------------------
// 音楽再生終了検知
//--------------------------------------------------------------------
#pragma mark - AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if ( flag )
    {
        NSLog(@"Play Music Done");
        [_musicPlayer play];
        // Can start next audio?
    }
}
@end
