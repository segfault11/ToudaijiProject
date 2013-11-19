//
//  Parameter.h
//  Todaiji-Pilgrimage
//
//  Created by takayuki-a on 2013/03/20.
//  Copyright (c) 2013年 yokoya.lab. All rights reserved.
//

#ifndef Todaiji_Pilgrimage_Parameter_h
#define Todaiji_Pilgrimage_Parameter_h


///////////////////////////////////////////
//  各種パラメータの定義
///////////////////////////////////////////

// 下に傾けた時に変化する程度具合
#define CHANGE_ANGEL 0.70

// 全方位画像のデフォ画像名
#define DEFAULT_OMNI_IMAGE @"cubedefo"

// コンパスを使用
#define USE_MAGNETIC 1

// 全方位画像の画角
#define ANGLE_OMNIVIEW 60.0f

// 全方位画像の画角（最大）
#define ANGLE_OMNIVIEW_MAX 45.0f

// GPS地点に反映する最長距離[m]
#define DRAW_MAX_DISTANCE 35.0

// 読み込むテクスチャの数
#define TEXNUM 15


// コマンドメニューの巻き数
#define COMMAND_FOLDSNUM 2

// コマンドメニューのアニメーション数
#define COMMAND_DURATION 0.6

// アンケートのURL
#define QUESTION_URL @"http://kdjlskdjriwo:iowshpwsslsjhgg@yokoya.naist.jp/yokoya-lab/todaiji/questionnaire/show_quest.php"


// 表示ポイントかどうかの閾値距離[m]
#define POINT_MIN_DISTANCE 15.0

// 待機フレームの数
#define WAIT_ANIMATION 25

enum GPSARRAY {
    DAIBUTUDEN = 0,
    TOTO,
    RUSYA,
    RENBEN,
    KEGON,
    DAIBUTUDEN_1_TOTO,
    DAIBUTUDEN_2_TOTO,
    DAIBUTU_LEFT,
    DAIBUTU_RIGHT
};

//////////////////////////////////////////////////////// Debug用のデータ
#if 0
// 情報棟前　34.731769,135.733914
// 34.687937,135.839851
#define GPS_DAIBUTUDEN_LAD 34.731769
#define GPS_DAIBUTUDEN_LON 135.733914

//　食堂前通路　34.731773,135.73364
// 34.688231,135.83984
#define GPS_DAIBUTUDEN_TOTO_1_LAD 34.731773
#define GPS_DAIBUTUDEN_TOTO_1_LON 135.73364

// ミレニアムホーム前通路　34.731802,135.733233
// 34.688403,135.839845
#define GPS_DAIBUTUDEN_TOTO_2_LAD 34.731802
#define GPS_DAIBUTUDEN_TOTO_2_LON 135.733233

// 事務前 34.731813,135.732954
// 34.688513,135.839848
#define GPS_TOTO_LAD 34.731813
#define GPS_TOTO_LON 135.732954

#else
//////////////////////////////////////////////////////// 東大寺位置データ ↓


#define GPS_DAIBUTUDEN_LAD 34.687937
#define GPS_DAIBUTUDEN_LON 135.839851

#define GPS_DAIBUTUDEN_TOTO_1_LAD 34.688231
#define GPS_DAIBUTUDEN_TOTO_1_LON 135.83984

#define GPS_DAIBUTUDEN_TOTO_2_LAD 34.688403
#define GPS_DAIBUTUDEN_TOTO_2_LON 135.839845

#define GPS_TOTO_LAD 34.688513
#define GPS_TOTO_LON 135.839848


#endif

// 34.688731,135.839835
#define GPS_RUSYA_LAD 34.688731
#define GPS_RUSYA_LON 135.839835

//34.688831,135.839601
#define GPS_RENBEN_LAD 34.688831
#define GPS_RENBEN_LON 135.839601

//34.689153,135.83955
#define GPS_DAIBUTU_BACK_LEFT_LAD 34.689153
#define GPS_DAIBUTU_BACK_LEFT_LON 135.83955

//34.689164,135.840127
#define GPS_DAIBUTU_BACK_RIGHT_LAD 34.689164
#define GPS_DAIBUTU_BACK_RIGHT_LON 135.840127

//34.688831,135.840041
#define GPS_KEGONSEKAI_LAD 34.688831
#define GPS_KEGONSEKAI_LON 135.840041

//////////////////////////////////////////////////////// 東大寺位置データ　↑




///////////////////////////////////////////
//  パラメータ変換用
///////////////////////////////////////////
#define DEG2RAD(x)        ((M_PI*x)/180.0)


#endif
