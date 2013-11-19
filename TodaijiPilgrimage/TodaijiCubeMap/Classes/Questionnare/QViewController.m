//
//  QViewController.m
//  TodaijiCubeMap
//
//  Created by Akaguma on 13/03/12.
//  Copyright (c) 2013年 Akaguma Takayuki. All rights reserved.
//

#import "QViewController.h"
#import "ParameterDef.h"

@interface QViewController ()

@end

@implementation QViewController

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
//  
//--------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:QUESTION_URL]];
    webView.delegate = self;
    [webView loadRequest:req];
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
//  読み込み開始
//--------------------------------------------------------------------
- (void)webViewDidStartLoad:(UIWebView *)webView {
    // ページのロードが開始されたので、ステータスバーのロード中インジケータを表示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSLog(@"Load start");
}


//--------------------------------------------------------------------
//  読み込み終了
//--------------------------------------------------------------------
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // ページのロードが終了したので、ステータスバーのロード中インジケータを非表示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"Load end");
    
}


//--------------------------------------------------------------------
//  読み込み失敗
//--------------------------------------------------------------------
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    // エラーが発生したので、ステータスバーのロード中インジケータを非表示
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // エラーの内容をWebView画面に表示する。
    NSLog(@"Error");
    NSString* errString = [NSString stringWithFormat:
                           @"<html><br><br><center><font size=+7 color='red'>エラーが発生しました。:<br>%@</font></center></html>",
                           error.localizedDescription];
    
    [webView loadHTMLString:errString baseURL:nil];
}



//--------------------------------------------------------------------
//  「戻る」ボタン
//--------------------------------------------------------------------
- (IBAction)btnReturn:(id)sender {
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}


//--------------------------------------------------------------------
//  「ホーム」ボタン
//--------------------------------------------------------------------
- (IBAction)btnHome:(id)sender {
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:QUESTION_URL]];
    webView.delegate = self;
    [webView loadRequest:req];}

@end
