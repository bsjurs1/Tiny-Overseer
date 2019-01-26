//
//  NetworkManager.m
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "NetworkManager.h"
extern "C" {
	#include <libavformat/avformat.h>
	#include <libavcodec/avcodec.h>
	#include <libavutil/avutil.h>
	#include <libavutil/pixdesc.h>
	#include <libswscale/swscale.h>
}

const int portNum = 1500;

@interface NetworkManager(){
@private
#pragma mark - predictions
	NSMutableArray<NSNumber*>* predictedScores;
	NSMutableArray<CLLocation*>* predictedLocations;
#pragma mark - server related variables
	char* serverIp;
#pragma mark - image decoding variablesmutex 
	UIImage* objectDetectionImage;
	AVFrame dst;
	int aircraftImageWidth;
	int aircraftImageHeight;
	enum PixelFormat src_pixfmt;
	enum PixelFormat dst_pixfmt;
	struct SwsContext *convert_ctx;
	cv::Size imgSize;
#pragma mark - aircraft variables
	double aircraftAltitude, aircraftLatitude, aircraftLongitude, aircraftHeading;
}
@end
@implementation NetworkManager

#pragma mark - image conversion functions
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
	CGFloat cols = image.size.width;
	CGFloat rows = image.size.height;
	
	cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
	
	CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
													cols,                       // Width of bitmap
													rows,                       // Height of bitmap
													8,                          // Bits per component
													cvMat.step[0],              // Bytes per row
													colorSpace,                 // Colorspace
													kCGImageAlphaNoneSkipLast |
													kCGBitmapByteOrderDefault); // Bitmap info flags
	
	CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
	CGContextRelease(contextRef);
	cvtColor(cvMat, cvMat, CV_BGR2RGB);
	return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
	cvtColor(cvMat, cvMat, CV_BGR2RGB);
	NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
	CGColorSpaceRef colorSpace;
	
	if (cvMat.elemSize() == 1) {
		colorSpace = CGColorSpaceCreateDeviceGray();
	} else {
		colorSpace = CGColorSpaceCreateDeviceRGB();
	}
	
	CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
	
	// Creating CGImage from cv::Mat
	CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
										cvMat.rows,                                 //height
										8,                                          //bits per component
										8 * cvMat.elemSize(),                       //bits per pixel
										cvMat.step[0],                            //bytesPerRow
										colorSpace,                                 //colorspace
										kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
										provider,                                   //CGDataProviderRef
										NULL,                                       //decode
										false,                                      //should interpolate
										kCGRenderingIntentDefault                   //intent
										);
	
	
	// Getting UIImage from CGImage
	UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	
	return finalImage;
}

- (UIImage*) getImage {
	UIImage* image = objectDetectionImage;
	return image;
}

#pragma mark - image decoding functions

-(void) prepareImage:(uint8_t*)  imageData ofSize:(int) size {
	cv::Mat decodedAircraftImage = cv::Mat(aircraftImageHeight, aircraftImageWidth, CV_8UC3);
	AVFrame* frame = (AVFrame*) imageData;
	dst.data[0] = (uint8_t *)decodedAircraftImage.data;
	avpicture_fill( (AVPicture *)&dst, dst.data[0], dst_pixfmt, aircraftImageWidth, aircraftImageHeight);
	sws_scale(convert_ctx, frame->data, frame->linesize, 0, aircraftImageHeight,
			  dst.data, dst.linesize);
	cv::Mat resizedMat;
	cv::resize(decodedAircraftImage, resizedMat, imgSize);
	dispatch_sync(dispatch_get_main_queue(), ^{
		objectDetectionImage = [self UIImageFromCVMat:resizedMat];
	});
}

#pragma mark - networking functions
- (void) sendData:(OutputMemoryStream*) outputMemoryStream ofSize:(size_t) dataSize toTCPSocket:(TCPSocket) tcpSocket {
	int totalBytesSent = 0;
	while(totalBytesSent < dataSize){
		int currentBytesSent = tcpSocket.Send(outputMemoryStream->GetBufferPtr() + totalBytesSent, outputMemoryStream->GetLength() - totalBytesSent);
		if(currentBytesSent < 0){
			continue;
		}
		else{
			totalBytesSent += currentBytesSent;
		}
	}
}

-(InputMemoryStream) receiveDataofSize:(uint32_t) dataSize fromTCPSocket:(TCPSocket) tcpSocket {
	char* buffer = (char*) std::malloc(dataSize);
	InputMemoryStream serverAnalysisMemoryStream = InputMemoryStream(buffer, dataSize);
	uint32_t receivedBytes = tcpSocket.Receive(buffer, dataSize*sizeof(char));
	return serverAnalysisMemoryStream;
}

- (NSString*) receiveStringOfSize:(uint32_t) stringSize FromSocket:(TCPSocket) tcpSocket  {
	InputMemoryStream stringMemoryStream = [self receiveDataofSize:stringSize fromTCPSocket:tcpSocket];
	std::string rawString;
	stringMemoryStream.Read(rawString);
	NSString* serverAnalysisString = [NSString stringWithCString:rawString.c_str()
														encoding:[NSString defaultCStringEncoding]];
	return serverAnalysisString;
}

-(void) extractBoundingBoxesFromString:(NSString*) serverAnalysisString andDrawOnImage:(cv::Mat*) image {
	[predictedScores removeAllObjects];
	[predictedLocations removeAllObjects];
	NSArray<NSString*>* boundingBoxArray = [serverAnalysisString componentsSeparatedByString:@"-"];
	for(NSString* boundingBox in boundingBoxArray){
		NSArray<NSString*>* boundingBoxElements = [boundingBox componentsSeparatedByString:@":"];
		if([boundingBoxElements count] == 8){
			float yMin = [boundingBoxElements[0] floatValue] * 300;
			float xMin = [boundingBoxElements[1] floatValue] * 300;
			float yMax = [boundingBoxElements[2] floatValue] * 300;
			float xMax = [boundingBoxElements[3] floatValue] * 300;
			float score = [boundingBoxElements[5] doubleValue];
			if(score > 0.9){
				cv::rectangle(*image,
							  cv::Point(xMin, yMin),
							  cv::Point(xMax, yMax),
							  cv::Scalar(255, 0, 0),
							  10
							  );
				[predictedLocations addObject:[[CLLocation alloc] initWithLatitude:[boundingBoxElements[6] doubleValue] longitude:[boundingBoxElements[7] doubleValue]]];
				[predictedScores addObject:[NSNumber numberWithDouble:score]];
			}
			int prediction = [boundingBoxElements[4] intValue];
		}
	}
}

-(void) sendMat:(cv::Mat) mat toTCPSocket:(TCPSocket) tcpSocket {
	
	OutputMemoryStream imageMetaDataOutputStream;
	
	std::vector<unsigned char> imageBuffer;
	cv::imencode(".jpg", mat, imageBuffer);
	size_t imageSize = sizeof(unsigned char) * imageBuffer.size();
	
	imageMetaDataOutputStream.Write(1);
	imageMetaDataOutputStream.Write(imageSize);
	
	OutputMemoryStream imageOutputStream;
	imageOutputStream.Write(imageBuffer);
	
	[self sendData: &imageMetaDataOutputStream ofSize:12 toTCPSocket:tcpSocket];
	[self sendData: &imageOutputStream ofSize: imageOutputStream.GetLength() toTCPSocket:tcpSocket];
}

- (UIImage*) getObjectDetectionImage:(CLLocationCoordinate2D) aircraftLocation aircraftHeading:(double) aircraftHeading aircraftAltitude:(double) aircraftAltitude andImage:(UIImage*) image {
	
	TCPSocket server = TCPSocket();
	SocketAddress serverAddress = SocketAddress(serverIp, portNum);
	server.Connect(serverAddress);
	
	cv::Mat aircraftImage = [self cvMatFromUIImage:image];
	
	[self sendMat:aircraftImage toTCPSocket:server];
	
	OutputMemoryStream aircraftGeoInformationOutputMemoryStream;
	aircraftGeoInformationOutputMemoryStream.Write(aircraftLocation.latitude);
	aircraftGeoInformationOutputMemoryStream.Write(aircraftLocation.longitude);
	aircraftGeoInformationOutputMemoryStream.Write(aircraftHeading);
	aircraftGeoInformationOutputMemoryStream.Write(aircraftAltitude);
	
	[self sendData: &aircraftGeoInformationOutputMemoryStream ofSize:aircraftGeoInformationOutputMemoryStream.GetLength() toTCPSocket:server];
	
	NSString* serverAnalysisString = [self receiveStringOfSize:1000 FromSocket:server];
	
	[self extractBoundingBoxesFromString:serverAnalysisString andDrawOnImage:&aircraftImage];
	
	server.Close();
	
	return [self UIImageFromCVMat:aircraftImage];
}

#pragma mark -  global state
- (NSMutableArray<NSNumber*>*) getPredictedScores {
	return predictedScores;
}

-(NSMutableArray<CLLocation*>*) getLocations{
	return predictedLocations;
}

-(void) clearPredictedDataStructures {
	[predictedScores removeAllObjects];
}

-(NetworkManager*) init:(char*) ip {
	if ((self = [super init])){
		predictedScores = [[NSMutableArray alloc] init];
		predictedLocations = [[NSMutableArray alloc] init];
		serverIp = ip;
		aircraftImageWidth = 1280;
		aircraftImageHeight = 720;
		
		//Decoder related functions
		src_pixfmt = PIX_FMT_YUV420P;
		dst_pixfmt = PIX_FMT_BGR24;
		convert_ctx = sws_getContext(aircraftImageWidth, aircraftImageHeight, src_pixfmt, aircraftImageWidth, aircraftImageHeight, dst_pixfmt, SWS_BICUBIC, NULL, NULL, NULL);
		imgSize = cv::Size(300, 300);
	}
	return self;
}

@end

