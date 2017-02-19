/*
 * CPreprocessing.cpp
 *
 *  Created on: Apr 16, 2016
 *      Author: karathra
 */

#include "CPreprocessing.h"
//#incldue "Parallel.cu"

CPreprocessing::CPreprocessing(char* pcBuf)
{
	// TODO Auto-generated constructor stub
	m_matImage = imread(pcBuf, 1);

	m_matLeftROIImage = m_matImage(Rect(LEFT_ROI_STARTX, LEFT_ROI_STARTY,
			LEFT_ROI_WIDTH, LEFT_ROI_HIEGHT));
	m_matRightROIImage = m_matImage(Rect(RIGHT_ROI_STARTX, RIGHT_ROI_STARTY,
			RIGHT_ROI_WIDTH, RIGHT_ROI_HIEGHT));
	RGBtoGray(LEFT);
}

__global__ void cudaPrepareHough(unsigned char* d_Hough,
		unsigned char* d_GrayROIImage,
		int nRows,
		int nCols,
		int nMaxRho)
{
	__shared__ int
	matTileNormalisation[NOOFELEMENTSBEFORESOBEL][NOOFELEMENTSBEFORESOBEL];
	__shared__ int
	matTileResultAverage[NOOFELEMENTSBEFORESOBEL][NOOFELEMENTSBEFORESOBEL];

	int nThreadRow;
	int nThreadCol;
	int nIndex;

	int nTileRow;
	int nTileCol;

	nThreadRow = blockIdx.x * blockDim.x + threadIdx.x;
	nThreadCol = blockIdx.y * blockDim.y + threadIdx.y;
	nIndex = nThreadRow * nCols + nThreadCol;

	nTileRow = threadIdx.x;
	nTileCol = threadIdx.y;

	if(nTileRow == 0)
	{
		//checking for top left corner
	    if(nTileCol == 0)
	    {
	    	//if top left corner, thread should copy a[i - 1][j - 1],
	    	//a[i - 1][j],a[i][j] and a[i][j - 1]
	    	matTileNormalisation[0][0] =
	    			d_GrayROIImage[nIndex - nCols - 1];
	    	matTileNormalisation[0][1] =
	    			d_GrayROIImage[nIndex - nCols];
	    	matTileNormalisation[1][1] =
	    			d_GrayROIImage[nIndex];
	    	matTileNormalisation[1][0] =
	    			d_GrayROIImage[nIndex - 1];
	    }
	    else if(nTileCol == NO_OF_THREADS - 1)
	    {
	    	//if top right corner, thread should copy a[i - 1][j + 1],
	    	//a[i - 1][j],a[i][j] and a[i][j + 1]
	    	matTileNormalisation[0][nTileCol + 2] =
	    			d_GrayROIImage[nIndex - nCols  + 1];
	    	matTileNormalisation[0][nTileCol + 1] =
	    			d_GrayROIImage[nIndex - nCols];
	    	matTileNormalisation[1][nTileCol + 1] =
	    			d_GrayROIImage[nIndex];
	    	matTileNormalisation[1][nTileCol + 2] =
	    			d_GrayROIImage[nIndex + 1];

	    }
	    else
	    {
	    	//other threads of first row should copy a[i - 1][j] and a[i][j]
	        matTileNormalisation[0][nTileCol + 1] =
	        		d_GrayROIImage[nIndex - nCols];
	        matTileNormalisation[1][nTileCol + 1] =
	        		d_GrayROIImage[nIndex];
	    }
	}
	else if(nTileRow == NO_OF_THREADS - 1)
	{
		if(nTileCol == 0)
	    {
			//if bottom left corner, thread should copy a[i + 1][j - 1], a[i + 1][j],
			//a[i][j] and a[i][j - 1]
	        matTileNormalisation[nTileRow + 2][0] =
	        		d_GrayROIImage[nIndex + nCols - 1];
	        matTileNormalisation[nTileRow + 2][1] =
	        		d_GrayROIImage[nIndex + nCols];
	        matTileNormalisation[nTileRow + 1][1] =
	        		d_GrayROIImage[nIndex];
	        matTileNormalisation[nTileRow + 1][0] =
	        		d_GrayROIImage[nIndex - 1];
	     }
	     else if(nTileCol == NO_OF_THREADS - 1)
	     {
	    	 //if bottom right corner, thread should copy a[i + 1][j + 1],
	    	 //a[i + 1][j],a[i][j] and a[i][j + 1]
	         matTileNormalisation[nTileRow + 2][nTileCol + 2] =
	        		 d_GrayROIImage[nIndex + nCols  + 1];
	         matTileNormalisation[nTileRow + 2][nTileCol + 1] =
	        		 d_GrayROIImage[nIndex + nCols];
	         matTileNormalisation[nTileRow + 1][nTileCol + 1] =
	        		 d_GrayROIImage[nIndex];
	         matTileNormalisation[nTileRow + 1][nTileCol + 2] =
	        		 d_GrayROIImage[nIndex + 1];

	     }
	     else
	     {
	    	 //other threads of the bottom row are supposed to copy
	    	 //a[i + 1][j] and a[i][j]
	         matTileNormalisation[nTileRow + 2][nTileCol + 1] =
	        		 d_GrayROIImage[nIndex + nCols];
	         matTileNormalisation[nTileRow + 1][nTileCol + 1] =
	        		 d_GrayROIImage[nIndex];
	     }
	 }
	 else if(nTileCol == 0)
	 {
		 //threads of first column are supposed to copy a[i][j - 1] and a[i][j]
	     matTileNormalisation[nTileRow + 1][0] = d_GrayROIImage[nIndex - 1];
	     matTileNormalisation[nTileRow + 1][1] = d_GrayROIImage[nIndex];
	  }
	  else if(nTileCol == NO_OF_THREADS - 1)
	  {
		  //threads of last column are supposed to copy a[i][j + 1] and a[i][j]
	      matTileNormalisation[nTileRow + 1][nTileCol + 2] =
	    		  d_GrayROIImage[nIndex + 1];
	      matTileNormalisation[nTileRow + 1][nTileCol + 1] =
	    		  d_GrayROIImage[nIndex];
	  }
	  else
	  {
		  //rest of the threads copy a[i][j]
	      matTileNormalisation[nTileRow + 1][nTileCol + 1] = d_GrayROIImage[nIndex];
	  }
	  __syncthreads();

	  //normalisation starts
	  //3 * 3 kernel of top hat
	  float nTempSum;
	  nTempSum = (matTileNormalisation[nTileRow][nTileCol] +
			  matTileNormalisation[nTileRow][nTileCol + 1] +
			  matTileNormalisation[nTileRow][nTileCol + 2] +
			  matTileNormalisation[nTileRow + 1][nTileCol] +
			  matTileNormalisation[nTileRow + 1][nTileCol + 1] +
			  matTileNormalisation[nTileRow + 1][nTileCol + 2] +
			  matTileNormalisation[nTileRow + 2][nTileCol] +
			  matTileNormalisation[nTileRow + 2][nTileCol + 1] +
			  matTileNormalisation[nTileRow + 2][nTileCol + 2]) / 9;

	  //get the Normalisation threshold into registry
	  int nNormalisationThresh = 160;

	  if((int)nTempSum > nNormalisationThresh)
	  {
		  matTileResultAverage[nTileRow + 1][nTileCol + 1] = 255;
	  }
	  else
	  {
		  matTileResultAverage[nTileRow + 1][nTileCol + 1] = 0;
	  }

	  __syncthreads();

	  __shared__ float
	  matTileSobel[NOOFELEMENTSBEFORESOBEL - 2][NOOFELEMENTSBEFORESOBEL - 2];
	  int nTempSobelSum;
	  float nSobelx;
	  float nSobely;
	  float nEdgeMag;
	  //start the Sobel edge detector
	  nTempSobelSum = matTileResultAverage[nTileRow][nTileCol + 2] -
			  matTileResultAverage[nTileRow + 2][nTileCol];
	  nSobelx = nTempSobelSum +
			  matTileResultAverage[nTileRow + 2][nTileCol + 2] -
			  matTileResultAverage[nTileRow][nTileCol] +
              2 * (matTileResultAverage[nTileRow + 1][nTileCol + 2] -
              matTileResultAverage[nTileRow + 1][nTileCol]);
	  nSobely = nTempSobelSum +
			  matTileResultAverage[nTileRow][nTileCol] -
			  matTileResultAverage[nTileRow + 2][nTileCol + 2] +
	          2 * (matTileResultAverage[nTileRow][nTileCol + 1] -
	          matTileResultAverage[nTileRow + 2][nTileCol + 1]);

	  nEdgeMag = sqrt(nSobelx * nSobelx + nSobely * nSobely);

	  int nSobelThresh = 50;

	  if((int)nEdgeMag > nSobelThresh)
	  {
		  matTileSobel[nTileRow][nTileCol] = 255;
	  }
	  else
	  {
		  matTileSobel[nTileRow][nTileCol] = 0;
	  }

	  //d_SobelImage[nThreadRow * (nCols - 2) + nThreadCol] =
			  //matTileSobel[nTileRow][nTileCol];

	  __shared__ int matHough[NO_OF_RHO][NO_OF_THETTA];

	  float nThettaCnt;
	  float nTempAngle = (PI / 180);
	  int nRho;
	  nRows = nRows - 2;
	  nCols = nCols - 2;
	  nIndex = nThreadRow * nCols + nThreadCol;
	  int nXTerm = nThreadCol - nCols;
	  int nYTerm = nThreadRow - nRows;
	  //int nMaxRho = ceil(sqrt(pow(nRows, 2) + pow(nCols, 2)));

	  if(nIndex < 200)
	  {
		  matHough[nThreadRow][nThreadCol] = 0;
	  }
	  if(matTileSobel[nTileRow][nTileCol])
	  {
		  for(nThettaCnt = LEFT_MIN_THETTA; nThettaCnt < LEFT_MAX_THETTA; nThettaCnt++)
		  {
			  nRho = ceil((float)nXTerm * cos(nTempAngle * nThettaCnt) +
					  (float)nYTerm * sin(nTempAngle * nThettaCnt));

			  nRho = nRho + nMaxRho;
			  //printf("%d")
			  if(nRho < LEFT_MAX_RHO && nRho > LEFT_MIN_RHO)
			  {
				  nRho = nRho - LEFT_MIN_RHO;
				  int nThetta = nThettaCnt - LEFT_MIN_THETTA;
				  atomicAdd((*(matHough + nRho) + nThetta), 1);
			  }
		  }
	  }

	  __syncthreads();

	  if(nIndex < 200)
	  {
		  atomicAdd((int*)(d_Hough + nIndex), *((int*)matHough + nIndex));
	  }
}

void CPreprocessing::RGBtoGray(int nSide)
{
	int nRows = m_matLeftROIImage.rows;
	int nCols = m_matLeftROIImage.cols;
	//int nColorSize = nRows * nCols * 3;
	int nGraySize = nRows * nCols;
	int nSobelSize = (nRows -2) * (nCols - 2);
	int nMaxRho = ceil(sqrt(pow(nRows -2, 2) + pow(nCols - 2, 2)));

	//unsigned char* d_ROIImageB;
	//unsigned char* d_ROIImageG;
	//unsigned char* d_ROIImageR;
	unsigned char* d_GrayROIImage;
	unsigned char* d_Hough;
	//unsigned char* d_SobelImage;

	//vector<Mat> vecmatChannels;

	//split(m_matLeftROIImage, vecmatChannels);
	//m_matLeftROIGray = Mat(nRows, nCols, CV_8UC1);
	//m_matLeftSobel = Mat(nRows - 2, nCols - 2, CV_8UC1);
	m_matLeftHough = Mat(100, 25, CV_8UC1);
	cvtColor(m_matLeftROIImage, m_matLeftGrayImage, CV_BGR2GRAY);

	//cudaMalloc((void**)&d_ROIImage, nColorSize);
	//cudaMalloc((void**)&d_ROIImageB, nGraySize);
	//cudaMalloc((void**)&d_ROIImageG, nGraySize);
	//cudaMalloc((void**)&d_ROIImageR, nGraySize);
	cudaMalloc((void**)&d_GrayROIImage, nGraySize);
	cudaMalloc((void**)&d_Hough, 100 * 20);
	//cudaMalloc((void**)&d_SobelImage, nSobelSize);

	//imwrite("ROIImage.jpg", m_matLeftROIImage);

	//cudaMemcpy(d_ROIImageB, vecmatChannels[0].data, nGraySize,
	//cudaMemcpyHostToDevice);
	//cudaMemcpy(d_ROIImageG, vecmatChannels[1].data, nGraySize,
	//cudaMemcpyHostToDevice);
	//cudaMemcpy(d_ROIImageR, vecmatChannels[2].data, nGraySize,
	//cudaMemcpyHostToDevice);
	cudaMemcpy(d_GrayROIImage, m_matLeftGrayImage.data,
			nGraySize, cudaMemcpyHostToDevice);
	//cudaEvent_t start,stop;
	//float elapsed_time;
	//cudaEventCreate(&start);
	//cudaEventCreate(&stop);
	//cudaEventRecord(start,0);

	//for(int nCnt = 0; nCnt <10; nCnt++)
	//{
	//cudaRGBtoGray<<<RGBGRAYGRIDSIZE, RGBGRAYBLOCKSIZE>>>
			//(d_ROIImageB, d_ROIImageG, d_ROIImageR, d_GrayROIImage);

	//cudaDeviceSynchronize();

	dim3 dimGrid(HOUGH_X_BLOCK, HOUGH_Y_BLOCK);
	dim3 dimBlock(HOUGH_Y_THREADS, HOUGH_Y_THREADS);

	cudaPrepareHough<<<dimGrid, dimBlock>>>
			(d_Hough, d_GrayROIImage, nRows, nCols, nMaxRho);
	//}

	cudaDeviceSynchronize();
	//cudaEventRecord(stop);
	//cudaEventSynchronize(stop);
	//cudaEventElapsedTime(&elapsed_time,start, stop);

	//printf("The operation was successful, time = %2.6f\n",elapsed_time/10);

	cudaMemcpy(m_matLeftHough.data, d_Hough, nSobelSize, cudaMemcpyDeviceToHost);

	//cudaFree(d_ROIImageB);
	//cudaFree(d_ROIImageG);
	//cudaFree(d_ROIImageR);
	cudaFree(d_GrayROIImage);
	cudaFree(d_Hough);
	//cudaFree(d_SobelImage);

	//vecmatChannels[0].release();
	//vecmatChannels[1].release();
	//vecmatChannels[2].release();
	//printf("buhahha");
	//imwrite("Hough.jpg", m_matLeftHough);
}

CPreprocessing::~CPreprocessing() {
	// TODO Auto-generated destructor stub
	m_matImage.release();
	m_matLeftROIImage.release();
	//m_matRightROIImage.release();
	m_matLeftHough.release();
	//m_matLeftROIGray.release();
	//m_matRightROIGray.release();
}
