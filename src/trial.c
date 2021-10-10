#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#ifndef M_PI
#define M_PI 3.14159265358979323846
#endif

#define FILE_HEADER_SIZE 14
#define INFO_HEADER_SIZE 40
#define BYTES_PER_PIXEL 3

typedef unsigned char byte;

float quantizer[64] =
	{
	16, 11, 10, 16,  24,  40,  51,  61,
	12, 12, 14, 19,  26,  58,  60,  55,
	14, 13, 16, 24,  40,  57,  69,  56,
	14, 17, 22, 29,  51,  87,  80,  62,
	18, 22, 37, 56,  68, 109, 103,  77,
	24, 35, 55, 64,  81, 104, 113,  92,
	49, 64, 78, 87, 103, 121, 120, 101,
	72, 92, 95, 98, 112, 100, 103,  99
	};

/*
File: dct.c
Summary: 2D AAN implementation of Discrete Cosine transform
	 Code for Forward and Inverse DCT using AAN method
Sources: Forward DCT inspired by // https://unix4lyfe.org/dct-1d/
	 Inverse DCT inspired by (Everything you need to know about jpeg Youtube Playlist) https://www.youtube.com/watch?v=sb8CQ9knDgI&list=PLpsTn9TA_Q8VMDyOPrDKmSJYt1DLgDZU4

Input : float array of 64 elements representing 8 * 8 block
*Note I use a 1-dimensional array to represent 2d data	 
*/


//Compute forward dct
void ForwardDCTComponent(float *component)
{
/*Forward DCT constants*/
const float a1 = 0.707;
const float a2 = 0.541;
const float a3 = 0.707;
const float a4 = 1.307;
const float a5 = 0.383;

const float s0 = 0.353553;
const float s1 = 0.254898;
const float s2 = 0.270598;
const float s3 = 0.300672;
const float s4 = s0;
const float s5 = 0.449988;
const float s6 = 0.653281;
const float s7 = 1.281458;
/*Forward DCT constants*/

	for(int i = 0; i < 8; i++)
	{
		const float b0 = component[0*8 + i] + component[7*8 + i];
		const float b1 = component[1*8 + i] + component[6*8 + i];
		const float b2 = component[2*8 + i] + component[5*8 + i];
		const float b3 = component[3*8 + i] + component[4*8 + i];
		const float b4 =-component[4*8 + i] + component[3*8 + i];
		const float b5 =-component[5*8 + i] + component[2*8 + i];
		const float b6 =-component[6*8 + i] + component[1*8 + i];
		const float b7 =-component[7*8 + i] + component[0*8 + i];
		
		const float c0 = b0 + b3;
		const float c1 = b1 + b2;
		const float c2 =-b2 + b1;
		const float c3 =-b3 + b0;
		const float c4 =-b4 - b5;
		const float c5 = b5 + b6;
		const float c6 = b6 + b7;
		const float c7 = b7;
		
		const float d0 = c0 + c1;
		const float d1 =-c1 + c0;
		const float d2 = c2 + c3;
		const float d3 = c3;
		const float d4 = c4;
		const float d5 = c5;
		const float d6 = c6;
		const float d7 = c7;
		const float d8 = (d4+d6) * a5;
		
		const float e0 = d0;
		const float e1 = d1;
		const float e2 = d2 * a1;
		const float e3 = d3;
		const float e4 = -d4 * a2 - d8;
		const float e5 = d5 * a3;
		const float e6 = d6 * a4 - d8;
		const float e7 = d7;
		
		const float f0 = e0;
		const float f1 = e1;
		const float f2 = e2 + e3;
		const float f3 = e3 - e2;
		const float f4 = e4;
		const float f5 = e5 + e7;
		const float f6 = e6;
		const float f7 = e7 - e5;
		
		const float g0 = f0;
		const float g1 = f1;
		const float g2 = f2;
		const float g3 = f3;
		const float g4 = f4 + f7;
		const float g5 = f5 + f6;
		const float g6 = -f6 + f5;
		const float g7 = f7 - f4;	
		
		component[0*8 + i] = g0 * s0;
		component[4*8 + i] = g1 * s4;
		component[2*8 + i] = g2 * s2;
		component[6*8 + i] = g3 * s6;
		component[5*8 + i] = g4 * s5;
		component[1*8 + i] = g5 * s1;
		component[7*8 + i] = g6 * s7;
		component[3*8 + i] = g7 * s3;		
	}
	for(int i = 0; i < 8; i++)
	{
		const float b0 = component[i*8 + 0]  + component[i*8 + 7];
		const float b1 = component[i*8 + 1]  + component[i*8 + 6];
		const float b2 = component[i*8 + 2]  + component[i*8 + 5];
		const float b3 = component[i*8 + 3]  + component[i*8 + 4];
		const float b4 =-component[i*8 + 4]  + component[i*8 + 3];
		const float b5 =-component[i*8 + 5]  + component[i*8 + 2];
		const float b6 =-component[i*8 + 6]  + component[i*8 + 1];
		const float b7 =-component[i*8 + 7]  + component[i*8 + 0] ;
		
		const float c0 = b0 + b3;
		const float c1 = b1 + b2;
		const float c2 =-b2 + b1;
		const float c3 =-b3 + b0;
		const float c4 =-b4 - b5;
		const float c5 = b5 + b6;
		const float c6 = b6 + b7;
		const float c7 = b7;
		
		const float d0 = c0 + c1;
		const float d1 =-c1 + c0;
		const float d2 = c2 + c3;
		const float d3 = c3;
		const float d4 = c4;
		const float d5 = c5;
		const float d6 = c6;
		const float d7 = c7;
		const float d8 = (d4+d6) * a5;
		
		const float e0 = d0;
		const float e1 = d1;
		const float e2 = d2 * a1;
		const float e3 = d3;
		const float e4 = -d4 * a2 - d8;
		const float e5 = d5 * a3;
		const float e6 = d6 * a4 - d8;
		const float e7 = d7;
		
		const float f0 = e0;
		const float f1 = e1;
		const float f2 = e2 + e3;
		const float f3 = e3 - e2;
		const float f4 = e4;
		const float f5 = e5 + e7;
		const float f6 = e6;
		const float f7 = e7 - e5;
		
		const float g0 = f0;
		const float g1 = f1;
		const float g2 = f2;
		const float g3 = f3;
		const float g4 = f4 + f7;
		const float g5 = f5 + f6;
		const float g6 = -f6 + f5;
		const float g7 = f7 - f4;	
		
		component[i*8 + 0] = g0 * s0;
		component[i*8 + 4] = g1 * s4;
		component[i*8 + 2] = g2 * s2;
		component[i*8 + 6] = g3 * s6;
		component[i*8 + 5] = g4 * s5;
		component[i*8 + 1] = g5 * s1;
		component[i*8 + 7] = g6 * s7;
		component[i*8 + 3] = g7 * s3;	
	}
}

void InverseDCTComponent(float *component)
{
const float m0 = 2.0 * cos(1.0/16.0 * 2.0 * M_PI);
const float m1 = 2.0 * cos(2.0/16.0 * 2.0 * M_PI);
const float m3 = 2.0 * cos(2.0/16.0 * 2.0 * M_PI);
const float m5 = 2.0 * cos(3.0/16.0 * 2.0 * M_PI);
const float m2 = m0-m5;
const float m4 = m0+m5;

const float s0 = cos(0.0/16.0 *M_PI)/sqrt(8);
const float s1 = cos(1.0/16.0 *M_PI)/2.0;
const float s2 = cos(2.0/16.0 *M_PI)/2.0;
const float s3 = cos(3.0/16.0 *M_PI)/2.0;
const float s4 = cos(4.0/16.0 *M_PI)/2.0;
const float s5 = cos(5.0/16.0 *M_PI)/2.0;
const float s6 = cos(6.0/16.0 *M_PI)/2.0;
const float s7 = cos(7.0/16.0 *M_PI)/2.0;

	for(int i = 0; i < 8; i++)
	{
		const float g0 = component[0*8 + i] * s0;
		const float g1 = component[4*8 + i] * s4;
		const float g2 = component[2*8 + i] * s2;
		const float g3 = component[6*8 + i] * s6;
		const float g4 = component[5*8 + i] * s5;
		const float g5 = component[1*8 + i] * s1;
		const float g6 = component[7*8 + i] * s7;
		const float g7 = component[3*8 + i] * s3;
		
		const float f0 = g0;
		const float f1 = g1;
		const float f2 = g2;
		const float f3 = g3;
		const float f4 = g4 - g7;
		const float f5 = g5 + g6;
		const float f6 = g5 - g6;
		const float f7 = g4 + g7;
		
		const float e0 = f0;
		const float e1 = f1;
		const float e2 = f2 - f3;
		const float e3 = f2 + f3;
		const float e4 = f4;
		const float e5 = f5 - f7;
		const float e6 = f6;
		const float e7 = f5 + f7;
		const float e8 = f4 + f6;
		
		const float d0 = e0;
		const float d1 = e1;
		const float d2 = e2 * m1;
		const float d3 = e3;
		const float d4 = e4 * m2;
		const float d5 = e5 * m3;
		const float d6 = e6 * m4;
		const float d7 = e7;
		const float d8 = e8 * m5;
		
		const float c0 = d0 + d1;
		const float c1 = d0 - d1;
		const float c2 = d2 - d3;
		const float c3 = d3;
		const float c4 = d4 + d8;
		const float c5 = d5 + d7;
		const float c6 = d6 - d8;
		const float c7 = d7;
		const float c8 = c5 - c6;
		
		const float b0 = c0 + c3;
		const float b1 = c1 + c2;
		const float b2 = c1 - c2;
		const float b3 = c0 - c3;
		const float b4 = c4 - c8;
		const float b5 = c8;
		const float b6 = c6 - c7;
		const float b7 = c7;
		
		component[0 * 8 + i] = b0 + b7;
		component[1 * 8 + i] = b1 + b6;
		component[2 * 8 + i] = b2 + b5;
		component[3 * 8 + i] = b3 + b4;
		component[4 * 8 + i] = b3 - b4;
		component[5 * 8 + i] = b2 - b5;
		component[6 * 8 + i] = b1 - b6;
		component[7 * 8 + i] = b0 - b7;	
	}
	
	for(int i = 0 ; i < 8; i++)
	{
		const float g0 = component[i*8 + 0] * s0;
		const float g1 = component[i*8 + 4] * s4;
		const float g2 = component[i*8 + 2] * s2;
		const float g3 = component[i*8 + 6] * s6;
		const float g4 = component[i*8 + 5] * s5;
		const float g5 = component[i*8 + 1] * s1;
		const float g6 = component[i*8 + 7] * s7;
		const float g7 = component[i*8 + 3] * s3;
		
		const float f0 = g0;
		const float f1 = g1;
		const float f2 = g2;
		const float f3 = g3;
		const float f4 = g4 - g7;
		const float f5 = g5 + g6;
		const float f6 = g5 - g6;
		const float f7 = g4 + g7;
		
		const float e0 = f0;
		const float e1 = f1;
		const float e2 = f2 - f3;
		const float e3 = f2 + f3;
		const float e4 = f4;
		const float e5 = f5 - f7;
		const float e6 = f6;
		const float e7 = f5 + f7;
		const float e8 = f4 + f6;
		
		const float d0 = e0;
		const float d1 = e1;
		const float d2 = e2 * m1;
		const float d3 = e3;
		const float d4 = e4 * m2;
		const float d5 = e5 * m3;
		const float d6 = e6 * m4;
		const float d7 = e7;
		const float d8 = e8 * m5;
		
		const float c0 = d0 + d1;
		const float c1 = d0 - d1;
		const float c2 = d2 - d3;
		const float c3 = d3;
		const float c4 = d4 + d8;
		const float c5 = d5 + d7;
		const float c6 = d6 - d8;
		const float c7 = d7;
		const float c8 = c5 - c6;
		
		const float b0 = c0 + c3;
		const float b1 = c1 + c2;
		const float b2 = c1 - c2;
		const float b3 = c0 - c3;
		const float b4 = c4 - c8;
		const float b5 = c8;
		const float b6 = c6 - c7;
		const float b7 = c7;
		
		component[i * 8 + 0] = b0 + b7;
		component[i * 8 + 1] = b1 + b6;
		component[i * 8 + 2] = b2 + b5;
		component[i * 8 + 3] = b3 + b4;
		component[i * 8 + 4] = b3 - b4;
		component[i * 8 + 5] = b2 - b5;
		component[i * 8 + 6] = b1 - b6;
		component[i * 8 + 7] = b0 - b7;
	}
}





void Print(float *array,int length)
{
	for(int i = 0; i < 64; i++)
	{
		if(i > 0 && i % 8 == 0)
		{
			putchar('\n');
		}
		printf("(%3.5f) ", array[i]);
		//printf("%.1f) ", array[i]);	
	}
	putchar('\n');
}


void Print2(float *array, int length)
{
	putchar('\n');
	putchar('\n');
	for(int i = 0; i < 64; i++)
	{
		if(i > 0 && i % 8 == 0)
		{
			putchar('\n');
		}
		printf("%.0f, ",round( array[i]));
	}
	putchar('\n');
}

void Print3(float *array)
{
	printf("Output\n");
	for(int i = 0; i < 64; i++)
	{
		if(i > 0 && i % 8 == 0)
		{
			putchar('\n');
		}
		printf("(%3.0f) ", round(array[i]));
	}
	putchar('\n');
}

void Print4(float *array)
{
	for(int i = 0; i < 64; i++)
	{
		if(i > 0 && i % 8 == 0)
		{
			putchar('\n');
		}
		printf("(%3.5f) ", array[i]);
		//printf("%.1f) ", array[i]);	
	}
	putchar('\n');
}


void Quantize(float *array, int quantizationLevel)
{
	for(int i = 0; i < 64; i++)
	{
		array[i] /= (quantizer[i]*quantizationLevel);
		array[i] = round(array[i]);
	}
}


void Dequantize(float *array, int quantizationLevel)
{
	for(int i = 0; i < 64; i++)
	{
		array[i] *= (quantizer[i]*quantizationLevel);
	}
}

void Process(float *array)
{
	for(int i = 0; i < 64; i++)
	{
		array[i] -= 128;
	}
}

void Unprocess(float *array)
{
	for(int i = 0; i < 64; i++)
	{
		array[i] += 128;
		if(array[i] >= 255)
		{
			array[i] = 255;
		}
		if(array[i] <= 0)
		{
			array[i] = 0;
		}
	}
}

byte *CreateBitmapFileHeader(int height, int stride)
{
	int fileSize = FILE_HEADER_SIZE + INFO_HEADER_SIZE + (stride * height);
	byte *fileHeader = calloc(14, sizeof(byte));
	fileHeader[0] = 'B';
	fileHeader[1] = 'M';
	fileHeader[2] = fileSize;
	fileHeader[3] = fileSize >> 8;
	fileHeader[4] = fileSize >> 16;
	fileHeader[5] = fileSize >> 24;
	fileHeader[10] = FILE_HEADER_SIZE + INFO_HEADER_SIZE ;
	return fileHeader;
}

byte *CreateBitmapInfoHeader(int height, int width)
{
	byte *infoHeader = calloc(40, sizeof(byte));
	infoHeader[0] = INFO_HEADER_SIZE;
	infoHeader[4] = width;
	infoHeader[5] = width >> 8;
	infoHeader[6] = width >> 16;
	infoHeader[7] = width >> 24;
	infoHeader[8] = height;
	infoHeader[9] = height >> 8;
	infoHeader[10] = height >> 16;
	infoHeader[11] = height >> 24;
	infoHeader[12] = 1;
	infoHeader[14] = BYTES_PER_PIXEL * 8;
	return infoHeader;	
}

void GenerateBitmap(byte *image, int height, int width, char *fileName)
{
	int widthInBytes = width * BYTES_PER_PIXEL;
	byte padding[3] = {0,0,0};
	int paddingSize = (4 - (widthInBytes) % 4) % 4;
	int stride = widthInBytes + paddingSize;
	FILE *imageFile = fopen(fileName, "wb");
	byte *fileHeader = CreateBitmapFileHeader(height,stride);
	fwrite(fileHeader, 1, FILE_HEADER_SIZE, imageFile);
	byte *infoHeader = CreateBitmapInfoHeader(height, width);
	fwrite(infoHeader, 1, INFO_HEADER_SIZE, imageFile);
	for(int i = 0; i < height; i++)
	{
		fwrite(image + (i *widthInBytes), BYTES_PER_PIXEL,width,imageFile);
		fwrite(padding,1,paddingSize,imageFile);
	}
	free(infoHeader);
	free(fileHeader);
	fclose(imageFile);
}

int GetX(byte *header)
{
	int X = (header[3] - '0') * 1000 +
	(header[4] - '0') * 100 +
	(header[5] - '0') * 10 +
	(header[6] - '0');
	return X;
}

int GetY(byte *header)
{
	int Y = (header[8] - '0') * 1000 +
	(header[9] - '0') * 100 +
	(header[10] - '0') * 10 +
	(header[11] - '0');
	return Y;
}

byte *OpenFile(char *fileName, int *XY)
{
	FILE *fp = fopen(fileName,"r");
	if(fp == NULL)
	{
		printf("Error Opening File");
		return NULL;
	}
	else
	{
		int c = 0;
		byte header[17] = {0};
		fread(header,sizeof(header),1,fp);
		//PrintHeader(header);
		int xSize = GetX(header);
		int ySize = GetY(header);
		XY[0] = xSize;
		XY[1] = ySize;
		int bufferSize = (xSize * ySize);
		
		byte *buffer = malloc(bufferSize*sizeof(byte));
		for(int i = 0 ; i < bufferSize; i++)
		{
			fread(&buffer[i],1,1,fp);
		}
		fclose(fp);
		return buffer;
	}
}

void Trial(float **MCUs, byte *data, int dataLength, int totalWidth, int totalHeight, int mcuUnitLength)
{
	int mcuYTotal = totalHeight / mcuUnitLength; 
	int mcuXTotal = totalWidth / mcuUnitLength; 
	int mcuSquareLength = mcuUnitLength * mcuUnitLength;
	for(int i = 0 ; i < dataLength; i++)
	{	
		int externalYIndex = i / totalWidth;
		int externalXIndex = i % totalWidth;
		
		int mcuYIndex = externalYIndex / mcuUnitLength;
		int mcuXIndex = externalXIndex / mcuUnitLength;
		int internalYIndex = externalYIndex % mcuUnitLength;
		int internalXIndex = i % mcuUnitLength;
		
		int pixelMCUIndex = (internalYIndex * mcuUnitLength) + internalXIndex;
		int mcuIndex = mcuXIndex + (mcuYIndex * mcuXTotal);
		
		if(i > 0 && (i % totalWidth) == 0)
		{
			//putchar('\n');	
		}
		MCUs[mcuIndex][pixelMCUIndex] = (float)data[i];
		//printf("%2d ",mcuIndex);
	}
}

void Untrial(float **MCUs, byte *data, int dataLength, int totalWidth, int totalHeight, int mcuUnitLength)
{
	int mcuYTotal = totalHeight / mcuUnitLength; 
	int mcuXTotal = totalWidth / mcuUnitLength; 
	int mcuSquareLength = mcuUnitLength * mcuUnitLength;
	for(int i = 0 ; i < dataLength; i++)
	{	
		int externalYIndex = i / totalWidth;
		int externalXIndex = i % totalWidth;
		
		int mcuYIndex = externalYIndex / mcuUnitLength;
		int mcuXIndex = externalXIndex / mcuUnitLength;
		int internalYIndex = externalYIndex % mcuUnitLength;
		int internalXIndex = i % mcuUnitLength;
		
		int pixelMCUIndex = (internalYIndex * mcuUnitLength) + internalXIndex;
		int mcuIndex = mcuXIndex + (mcuYIndex * mcuXTotal);
		
		if(i > 0 && (i % totalWidth) == 0)
		{
			//putchar('\n');	
		}
		data[i] = (byte) MCUs[mcuIndex][pixelMCUIndex] ;
		//printf("%2d ",mcuIndex);
	}
}

void FreeMCUS(float **MCUs, int *XY)
{
	int dataLength = XY[0] * XY[1];
	int numberOfMCU = dataLength / (64);
	for(int i = 0 ; i < numberOfMCU; i++)
	{
		free(MCUs[i]);
	} 
	free(MCUs);
}

float **CreateMCUS(byte *buffer, int *XY, int dataLength)
{
	if((XY[0] % 8) != 0 || (XY[1] % 8) != 0)
	{
		printf("\nError: Width or height is not a multiple of 8\n");
		return NULL;
	}
	else if((XY[0] * XY[1]) != dataLength)
	{
		printf("\nError: Height * Width != DataLength");
		return NULL;
	}
	else
	{
		int totalHeight = XY[1];
		int totalWidth = XY[0];
		int mcuUnitLength = 8;
		int mcuSquareLength = 64;
		
		int numberOfMCU = dataLength / (mcuSquareLength);
		int mcuYTotal = totalHeight / mcuUnitLength; 
		int mcuXTotal = totalWidth / mcuUnitLength;
		float **MCUs = malloc(numberOfMCU * sizeof(float*));
		for(int i = 0 ; i < numberOfMCU; i++)
		{
			MCUs[i] = malloc(mcuSquareLength * sizeof(float));
		} 
		if((totalWidth * totalHeight) == dataLength)
		{
			//printf("%d", numberOfMCU);
			Trial(MCUs,buffer,dataLength, totalWidth,totalHeight,mcuUnitLength);
			//Print2dFloatArray(MCUs,numberOfMCU,mcuSquareLength);
			return MCUs;
		}
		else
		{
		    return NULL;
		}
	}
}

void QuantizeDequantize(float **MCUs, int numberOfMCUs, int quantizationLevel)
{
	for(int i = 0 ; i < numberOfMCUs; i++)
	{
		Process(MCUs[i]);
		ForwardDCTComponent(MCUs[i]);
		Quantize(MCUs[i], quantizationLevel);
		Dequantize(MCUs[i], quantizationLevel);
		InverseDCTComponent(MCUs[i]);
		Unprocess(MCUs[i]);
		//Print3(MCUs[i]);	
	}	
}

byte *MCUsToNewBuffer(float **MCUs, int *XY, int numberOfMCUs)
{
	int bufferSize = numberOfMCUs * 64;
	int totalHeight = XY[1];
	int totalWidth = XY[0];
	int mcuUnitLength = 8;
	byte *buffer = malloc(bufferSize*sizeof(byte));
	Untrial(MCUs,buffer,bufferSize, totalWidth,totalHeight,mcuUnitLength);
	return buffer;
}


char *GetSingleLine(byte *buffer, int length, int startIndex)
{
	char *result = malloc(length);
	for(int i = 0; i < length; i++)
	{
		result[i] = buffer[i + startIndex];
	}
	return result;
}

void SaveGrayFrame(byte *buffer,int xsize,int ysize, char *filename)
{
	FILE *f;
	int i;
	f = fopen(filename, "w");
	fprintf(f,"P5\n%d %d\n%d\n",xsize,ysize,255);
	for(i = 0; i < ysize; i++)
	{
		char *ch = GetSingleLine(buffer,xsize,i*xsize);
		fwrite(ch,1,xsize,f);
		free(ch);
	}
	fclose(f);
}

byte *TimesThree(byte *newBuffer, int *XY)
{	
	int bufferSize = XY[0] * XY[1] * 3;
	byte *result = malloc(bufferSize);
	int index = (XY[0] * XY[1])-1;
	for(int i = 0; i < bufferSize; i+=3)
	{
		result[i+0] = newBuffer[index];
		result[i+1] = newBuffer[index];
		result[i+2] = newBuffer[index];
		index--;
	}
	return result;
}

int SingleFrameQuantizeDequantize(char *fileName,char *name, int *XY,int quantizationLevel)
{
	byte *buffer = OpenFile(fileName, XY);
	int dataLength = XY[0] * XY[1];
	int numberOfMCUs = dataLength / 64;
	float **MCUs = CreateMCUS(buffer,XY,dataLength);
	QuantizeDequantize(MCUs,numberOfMCUs,quantizationLevel);
	byte *newBuffer = MCUsToNewBuffer(MCUs, XY, numberOfMCUs);
	byte *planeData = TimesThree(newBuffer,XY);
	GenerateBitmap(planeData, XY[1], XY[0],name);
	free(planeData);
	free(buffer);
	free(newBuffer);
	FreeMCUS(MCUs,XY);
	return 1;
}

int *FlattenMCUs(float **MCUs,int *XY, int numberOfMCUs)
{
	int *flat = malloc(numberOfMCUs * 64 * sizeof(int));
	int index= 0;
	for(int i = 0; i < numberOfMCUs; i++)
	{
		for(int j = 0; j < 64; j++)
		{
			flat[index] = (int)MCUs[i][j];
			index++;	
		}
	}
	return flat;
}

float **UnflattenMCUs(int *flat,int *XY, int numberOfMCUs)
{
	float **MCUs = malloc(numberOfMCUs *sizeof(float*));
	int index = 0;
	
	for(int i = 0; i < numberOfMCUs; i++)
	{
		MCUs[i] = malloc(64 * sizeof(float));
		for(int j = 0; j < 64; j++)
		{
			MCUs[i][j] = flat[index];
			index++;
		}
	}
	return MCUs;
}

int *SendMCUs(char *fileName, int quantizationLevel)
{
	int XY[2] = {0};
	byte *buffer = OpenFile(fileName, XY);
	int dataLength = XY[0] * XY[1];
	int numberOfMCUs = dataLength / 64;
	float **MCUs = CreateMCUS(buffer,XY,dataLength);
	for(int i = 0 ; i < numberOfMCUs; i++)
	{
		Process(MCUs[i]);
		ForwardDCTComponent(MCUs[i]);
		Quantize(MCUs[i], quantizationLevel);	
	}	
	int *newBuffer = FlattenMCUs(MCUs,XY,numberOfMCUs);
	FreeMCUS(MCUs,XY);
	free(buffer);
	return newBuffer;	
}

int ReceiveMCUs(int *coefficients, char *fileName, char *fileNameNew, int *XY, int quantizationLevel)
{
	int dataLength = XY[0] * XY[1];
	int numberOfMCUs = dataLength / 64;
	float **MCUs = UnflattenMCUs(coefficients,XY,numberOfMCUs);
	for(int i = 0 ; i < numberOfMCUs; i++)
	{
		Dequantize(MCUs[i], quantizationLevel);
		InverseDCTComponent(MCUs[i]);
		Unprocess(MCUs[i]);	
	}	
	byte *newBuffer = MCUsToNewBuffer(MCUs, XY, numberOfMCUs);
	byte *planeData = TimesThree(newBuffer,XY);
	SaveGrayFrame(newBuffer,XY[0],XY[1],fileNameNew);
	GenerateBitmap(planeData, XY[1], XY[0],fileName);
	FreeMCUS(MCUs,XY);
	free(newBuffer);
	free(planeData);
	return 1;
}

void SingleFrameSendReceive(char *fileName, char *saveFile,char *saveFile2,int quantizationLevel)
{
	int *toSend = SendMCUs(fileName,quantizationLevel);
	int XY[]= {1080,1920};
	int two = 1;
	ReceiveMCUs(toSend,saveFile,saveFile2, XY,two);
	free(toSend);	
}

//have to send XY, data
/*
int main()
{
	char *fileName = "frame-3.pgm";
	char *saveFile = "sample2.bmp";
	char *initialFile = "sample2.pgm";
	char *newFile = "baba.bmp";
	int quantizationLevel = 1;
	int quantizationLevel2 = 10;
	int XY[2] = {0,0};
	SingleFrameSendReceive(fileName,saveFile,initialFile,quantizationLevel);
	SingleFrameQuantizeDequantize(initialFile,newFile,XY, quantizationLevel2);
	return 0;
}*/
