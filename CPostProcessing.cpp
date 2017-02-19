/*
 * CPostProcessing.cpp
 *
 *  Created on: Apr 23, 2016
 *      Author: karathra
 */

#include "CPostProcessing.h"

CPostProcessing::CPostProcessing(Mat matLeftHough/*, Mat matRightHough*/,
		Mat matLeftROIImage)
{
	// TODO Auto-generated constructor stub
	//printf("in Const\n");
	m_p_nLeftCoordinates = new int(4);
	//p_nRightCoordinates = new int(4);

	FindHighest(matLeftHough, m_p_nLeftCoordinates);
	FindHighest(matLeftHough, m_p_nLeftCoordinates + 2);

	PlotLeftLanes(m_p_nLeftCoordinates, matLeftROIImage);

	//matLeftHough.release();
}

void CPostProcessing::FindHighest(Mat matLeftHough, int* m_p_nLeftCoordinates)
{
	int nRhos = matLeftHough.rows;
	int nThettas = matLeftHough.cols;

	int nRhoCnt;
	int nThettaCnt;

	*(m_p_nLeftCoordinates) = 0;
	*(m_p_nLeftCoordinates + 1) = 0;
	matLeftHough.at<uchar>(*(m_p_nLeftCoordinates), *(m_p_nLeftCoordinates + 1)) =
			1;


	for(nRhoCnt = 0; nRhoCnt < nRhos; nRhoCnt++)
	{
		for(nThettaCnt = 0; nThettaCnt < nThettas; nThettaCnt++)
		{
			if(matLeftHough.at<uchar>(nRhoCnt, nThettaCnt) >
			matLeftHough.at<uchar>(*(m_p_nLeftCoordinates),
					*(m_p_nLeftCoordinates + 1)))
			{
				*(m_p_nLeftCoordinates) = nRhoCnt;
				*(m_p_nLeftCoordinates + 1) = nThettaCnt;

			}
		}
	}
	//printf("from findHighest\nRho Value=%d\tThettaValue=%d\n",
	//*(p_nCoodinates), *(p_nCoodinates+1));
	matLeftHough.at<uchar>(*(m_p_nLeftCoordinates),
			*(m_p_nLeftCoordinates + 1)) = 0;
	matLeftHough.at<uchar>(*(m_p_nLeftCoordinates) - 1,
			*(m_p_nLeftCoordinates + 1) - 1) = 0;
	matLeftHough.at<uchar>(*(m_p_nLeftCoordinates) - 1,
			*(m_p_nLeftCoordinates + 1)) = 0;
	matLeftHough.at<uchar>(*(m_p_nLeftCoordinates) - 1,
			*(m_p_nLeftCoordinates + 1) + 1) = 0;
	matLeftHough.at<uchar>(*(m_p_nLeftCoordinates),
			*(m_p_nLeftCoordinates + 1) - 1) = 0;
	matLeftHough.at<uchar>(*(m_p_nLeftCoordinates),
			*(m_p_nLeftCoordinates + 1) + 1) = 0;
	matLeftHough.at<uchar>(*(m_p_nLeftCoordinates) + 1,
			*(m_p_nLeftCoordinates + 1) - 1) = 0;
	matLeftHough.at<uchar>(*(m_p_nLeftCoordinates) + 1,
			*(m_p_nLeftCoordinates + 1)) = 0;
	matLeftHough.at<uchar>(*(m_p_nLeftCoordinates) + 1,
			*(m_p_nLeftCoordinates + 1) + 1) = 0;

	//printf("Before Rho %d\nThetta %d\n\n", *(m_p_nLeftCoordinates),
						//*(m_p_nLeftCoordinates + 1));

}

void CPostProcessing::PlotLeftLanes(int *m_p_nLeftCoordinates, Mat matLeftROIImage)
{
	//int nRhos = m_matLeftAccu.rows;

	int nRows = matLeftROIImage.rows;
	int nCols = matLeftROIImage.cols;
	int nMaxRhos = (int)sqrt(pow(nRows, 2) + pow(nCols, 2));

	int nColCnt;
	int nYValue;
	int nXValue;
	double nTempAngle = (PI / 180);
	//printf("Before Rho %d\nThetta %d\n\n", *(m_p_nLeftCoordinates),
					//*(m_p_nLeftCoordinates + 1));
	printf("%d\n", nMaxRhos);
	*m_p_nLeftCoordinates = *m_p_nLeftCoordinates + LEFT_MIN_RHO - nMaxRhos;
	*(m_p_nLeftCoordinates + 1) = *(m_p_nLeftCoordinates + 1) + LEFT_MIN_THETTA;

	for(nColCnt = 0; nColCnt < nCols ; nColCnt++)
	{
		nYValue = (int)ceil(((double) *(m_p_nLeftCoordinates) -
				((double)(nColCnt) * cos((double)*(m_p_nLeftCoordinates + 1) *
						nTempAngle))) / sin((double)*(m_p_nLeftCoordinates + 1) *
								nTempAngle));
		//printf("After Rho %d\nThetta %d\n\n", *(m_p_nLeftCoordinates),
							//*(m_p_nLeftCoordinates + 1));
		nYValue = nRows - nYValue;
		nXValue = nCols - nColCnt;
		//printf("Ycalue %d\nXvaue %d\n\n", (nYValue),
				//(nXValue));
		if(nYValue >= 0 && nYValue < nRows)
		{
			matLeftROIImage.at<Vec3b>(nYValue, nXValue)[0] = 0;
			matLeftROIImage.at<Vec3b>(nYValue, nXValue)[1] = 0;
			matLeftROIImage.at<Vec3b>(nYValue, nXValue)[2] = 255;
		}

	}
	//printf("hi");
	imwrite("LaneMarkedLeftROI.jpg", matLeftROIImage);
}


CPostProcessing::~CPostProcessing() {
	// TODO Auto-generated destructor stub
	delete m_p_nLeftCoordinates;
	//delete m_p_nRightCoordinates;
}
