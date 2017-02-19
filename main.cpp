
#include "main.h"
#include "CPreprocessing.h"
#include "CPostProcessing.h"

#define NO_OF_FRAMES 24000

int main()
{
	int nFrameCnt;
	char cBuf[100];
	Mat Image;
	for (nFrameCnt = 3754; nFrameCnt <= 3754; nFrameCnt++)
	{
		//Getting the address for Image Aquisition
		memset(cBuf, 0, 100);
		//printf("hi");
		sprintf(cBuf, "../../../../dataset/frames%d.jpg", nFrameCnt);
		//printf("%s\n",cBuf);

		//Starting with Preprocessing
		CPreprocessing objPreprocessing(cBuf);

		//Getting into processing part
		CProcessing objProcessing(objPreprocessing.m_matEdgeThresholdedImage);

		//getting into post processing layer
		CPostProcessing objPostProcessing(objPreprocessing.m_matLeftHough,
				objPreprocessing.m_matLeftROIImage);

	}
	//Image.release();
	return 1;
}
