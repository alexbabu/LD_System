/*
 * CPreprocessing.h
 *
 *  Created on: Apr 16, 2016
 *      Author: karathra
 */

#ifndef CPREPROCESSING_H_
#define CPREPROCESSING_H_

#include<opencv2/core/core.hpp>
//#inlcude<opencv2/code/cuda.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgcodecs.hpp>
#include<opencv2/imgproc.hpp>

using namespace cv;

#include<math.h>
#include<cuda.h>

#define LEFT_ROI_STARTX 300
#define LEFT_ROI_WIDTH 162
#define LEFT_ROI_STARTY 400
#define LEFT_ROI_HIEGHT 226
#define RIGHT_ROI_STARTX 850
#define RIGHT_ROI_WIDTH 150
#define RIGHT_ROI_STARTY 400
#define RIGHT_ROI_HIEGHT 200

#define LEFT 0
#define RIGHT 1

#define RGBGRAYBLOCKSIZE 32
#define RGBGRAYGRIDSIZE 1145

#define HOUGH_X_BLOCK 5
#define HOUGH_Y_BLOCK 7
#define HOUGH_X_THREADS 32
#define HOUGH_Y_THREADS 32
#define NO_OF_THREADS 32
#define NOOFELEMENTSBEFORESOBEL 34

#define LEFT_MIN_RHO 300
#define LEFT_MAX_RHO 400
#define RIGHT_MIN_RHO 350
#define RIGHT_MAX_RHO 450
#define LEFT_MIN_THETTA 40
#define LEFT_MAX_THETTA 65
#define RIGHT_MIN_THETTA 40
#define RIGHT_MAX_THETTA 65
#define NO_OF_RHO 100
#define NO_OF_THETTA 25

#define PI 3.14159265

class CPreprocessing {
private:
	Mat m_matImage;

	Mat m_matRightROIImage;
	Mat m_matLeftGrayImage;
	//Mat m_matLeftROIGray;
	//Mat m_matRightROIGray;
	//Mat m_matLeftSobel;
	//Mat m_matLeftHough;

	void RGBtoGray(int nSide);
public:

	Mat m_matLeftROIImage;
	Mat m_matLeftHough;

	CPreprocessing(char* pcBuf);
	~CPreprocessing();
};

#endif /* CPREPROCESSING_H_ */
