/*
 * CPostProcessing.h
 *
 *  Created on: Apr 23, 2016
 *      Author: karathra
 */

#ifndef CPOSTPROCESSING_H_
#define CPOSTPROCESSING_H_

#include<opencv2/core/core.hpp>
#include<opencv2/highgui/highgui.hpp>
#include<opencv2/imgcodecs.hpp>
#include<opencv2/imgproc.hpp>

using namespace cv;

#define NO_OF_RHO 100
#define NO_OF_THETTA 25
#define LEFT_MIN_RHO 300
#define LEFT_MAX_RHO 400
#define RIGHT_MIN_RHO 350
#define RIGHT_MAX_RHO 450
#define LEFT_MIN_THETTA 40
#define LEFT_MAX_THETTA 65
#define RIGHT_MIN_THETTA 40
#define RIGHT_MAX_THETTA 65

#define PI 3.14159265

class CPostProcessing {
private:
	int* m_p_nLeftCoordinates;
	//int* m_p_nRightCoordinates;
	void FindHighest(Mat matHough, int *m_p_nLeftCoordinates);
	void PlotLeftLanes(int *m_p_nLeftCoordinates, Mat matLeftROIImage);

public:
	CPostProcessing(Mat matLeftHough/*, Mat matRightHough*/, Mat matLeftROIImage);
	~CPostProcessing();
};

#endif /* CPOSTPROCESSING_H_ */
