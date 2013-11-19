//
//  CVProcessing.mm
//  TodaijiPilgrimage
//
//  Created by Akaguma on 13/02/10.
//  Copyright (c) 2013年 Akaguma Takayuki. All rights reserved.
//
#ifdef __cplusplus
//#include "MapViewController.h"
#include "MapNaviViewController.h"
#include <opencv2/nonfree/nonfree.hpp>
#include <opencv2/legacy/legacy.hpp>

const std::string XMLNAME = "daibutu";

const int OMNI_IMAGE_HEIGHT    = 2700;
const int OMNI_IMAGE_WIDTH     = 5400;


enum FeatureSetNUM {
    DETECTOR = 0,
    EXTRACTOR,
    KEYPOINTS,
    KEYPOINTS3D,
    DISCRIPTORS,
    
    FEATURE_SET_MAXNUM
};

const char *FeatureSet[FEATURE_SET_MAXNUM] = {
    "detector.xml",
    "extractor.xml",
    "keypoints.xml",
    "keypoints3d.xml",
    "discriptors.xml"
};


// ----------------------------------------------------------------
//  特徴点抽出
// ----------------------------------------------------------------
static void getInputImageFeature(const cv::Mat& src,
                                 const int feature_num,
                                 std::vector<cv::KeyPoint>& key,
                                 cv::Mat& descriptors
                                 ){
    cv::Mat grayImg;
    cv::cvtColor(src, grayImg, CV_BGRA2GRAY);
    cv::normalize(grayImg, grayImg, 0, 255, cv::NORM_MINMAX);
    
    // 自然特徴の算出
    cv::SurfFeatureDetector detector(feature_num);
    cv::SurfDescriptorExtractor extractor;
    //    extractor.extended = false;
    
    detector.detect(grayImg, key);
    extractor.compute(grayImg, key, descriptors);
}


//--------------------------------------------------------------------
// double文字列を変換する
//--------------------------------------------------------------------
inline
char* double2char(double num, char *buf)
{
    sprintf(buf, "%.12f", num);
    return buf;
}


// ----------------------------------------------------------------
//  画像の自然特徴データを作成
// ----------------------------------------------------------------
static void readOmniFeatureData(const int data_num,
                                std::vector<cv::KeyPoint>& key,
                                std::vector<cv::Point3f>& key3d,
                                cv::Mat& descriptors
                                ){
    //    std::string path = dir + name;
    //    std::stringstream ssm;
    //    ssm << "0/0_";
    NSString *r_home_dir = NSHomeDirectory();
    NSString *r_doc_dir = [r_home_dir stringByAppendingPathComponent:@"Documents"];
    
    
    NSString *r_file = [r_doc_dir stringByAppendingPathComponent:@"1_"];
    std::string ssm = [r_file UTF8String];
    
    cv::FileStorage cfs_keypoints, cfs_discriptors, cfs_keypoints3d;
    
    cfs_keypoints.open(ssm+FeatureSet[KEYPOINTS], cv::FileStorage::READ);
    cfs_keypoints3d.open(ssm+FeatureSet[KEYPOINTS3D], cv::FileStorage::READ);
    cfs_discriptors.open(ssm+FeatureSet[DISCRIPTORS], cv::FileStorage::READ);
    
    cv::read(cfs_keypoints[XMLNAME], key);
    cfs_keypoints3d[XMLNAME] >> key3d;
    cfs_discriptors[XMLNAME] >> descriptors;
    
    //    std::cout << "key size: " << key.size() << std::endl;
    //    std::cout << "key3d size: " << key3d.size() << std::endl;
    //    std::cout << "desciptors size: " << descriptors.rows << "," << descriptors.cols << std::endl;
}



//--------------------------------------------------------------------
// 特徴点を描画
//--------------------------------------------------------------------
void DrawCircle(cv::Mat& image,
                const std::vector<cv::KeyPoint>& key_input)
{
    for (int i = 0; i < key_input.size(); ++i) {
        cv::circle(image, key_input[i].pt, 1.5, cv::Scalar(0,0,255,255));
    }
}


//--------------------------------------------------------------------
// 探索する全方位画像データセットを判別
//--------------------------------------------------------------------
bool checkOmniDB(const LocateData* loc,
                 std::vector<int>& dataset)
{
    bool ret = false;
    if (-0.5 < loc->gravityZ && loc->gravityZ < 0.5) {
        ret = true;
    }
    return ret;
}


//--------------------------------------------------------------------
// 特徴点を検出処理
//--------------------------------------------------------------------
void RunProcessing(const cv::Mat& src,
                   std::vector<cv::KeyPoint>& key_input,
                   const LocateData* locate,
                   MatchResult& result)
{
    //cv::Mat image, image2;
    
    // ここに画像処理を追加 ////////////////////////////////////////
    std::vector<int> dataset;
    if (!checkOmniDB(locate, dataset)) {
        // 判別対象フレームの時は何も計算しない
        return;
    }
    else {
        // カメラ画像の特徴点探索
        cv::Mat descriptors_input;
        getInputImageFeature(src, 1000, key_input, descriptors_input);
        
#if 0
        // 対応点探索
        for (int i = 0; i < dataset.size(); ++i) {
            // 全方位画像データの読み込み
            std::vector<cv::KeyPoint> key_omni;
            std::vector<cv::Point3f> key3d_omni;
            cv::Mat descriptors_omni;
            
            readOmniFeatureData(dataset[i], key_omni, key3d_omni, descriptors_omni);
            
            // マッチング
            std::vector<cv::DMatch> matches;
            cv::FlannBasedMatcher matcher;
            matcher.match(descriptors_input, descriptors_omni, matches);
            
            
            int N = 100;
            nth_element(matches.begin(), matches.begin()+N-1, matches.end());
            matches.erase(matches.begin()+N, matches.end());
        }
#else
        // とりあえず特定の場所のみで判別
        
        // マッチングはテストでは使用しない
//        std::vector<cv::KeyPoint> key_omni;
//        std::vector<cv::Point3f> key3d_omni;
//        cv::Mat descriptors_omni;
//        
//        readOmniFeatureData(1, key_omni, key3d_omni, descriptors_omni);
//        
//        // マッチング
//        std::vector<cv::DMatch> matches;
//        cv::FlannBasedMatcher matcher;
//        matcher.match(descriptors_input, descriptors_omni, matches);
//        
//        result.mathed_num = matches.size();
//        std::cout << "matched_num: " << matches.size() << std::endl;
        
#endif
        
    }
    
    // ここまで ///////////////////////////////////////////////////
    
}


//--------------------------------------------------------------------
// センサ情報を表示
//--------------------------------------------------------------------
void DrawDeviceInfo(const LocateData* locate, cv::Mat& image)
{
    std::stringstream stm[7];
    char buf[64];
    
    stm[0] << "GPS(long, lati): "       << double2char(locate->gps_long,buf) << ", "
    << double2char(locate->gps_lati,buf);
    stm[1] << "Gravity(x,y,z): "        << locate->gravityX << ", "
    << locate->gravityY << ", "
    << locate->gravityZ;
    stm[2] << "Acceleration(x,y,z): "   << locate->userAccelerationX << ", "
    << locate->userAccelerationY << ", "
    << locate->userAccelerationZ;
    stm[3] << "Gyairo(x,y,z): "         << locate->gyairoX << ", "
    << locate->gyairoY << ", "
    << locate->gyairoZ;
    stm[4] << "Magnetic(x,y,z): "       << locate->gyairoX << ", "
    << locate->gyairoY << ", "
    << locate->gyairoZ;
    stm[5] << "Magnetic accuracy: "     << locate->accuracy;
    stm[6] << "Roll,Pitch,Yaw: "        << locate->roll << ", "
    << locate->pitch << ", "
    << locate->yaw;
    
    for (int i = 0; i < 7; ++i) {
        cv::putText(image, stm[i].str(), cv::Point(10, 10*(i+1)), cv::FONT_HERSHEY_PLAIN, 0.7, cv::Scalar(255,255,255,255));
    }
}


#endif