//
//  NetworkManager.h
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#ifdef __cplusplus
#undef NO
#undef YES
#import <opencv2/opencv.hpp>
#include "socketaddress.hpp"
#include "tcpsocket.hpp"
#include <vector>
#include "outputmemorystream.hpp"
#include "inputmemorystream.hpp"
#include <mutex>
#endif

#ifdef __OBJC__
#import <Availability.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#endif

@interface NetworkManager : NSObject
- (UIImage*) getImage;
-(NetworkManager*) init:(char*) ip;
- (NSMutableArray<NSNumber*>*) getPredictedScores;
- (NSMutableArray<CLLocation*>*) getLocations;
- (void) clearPredictedDataStructures;
-(void) prepareImage:(uint8_t*)  imageData ofSize:(int) size;
- (UIImage*) getObjectDetectionImage:(CLLocationCoordinate2D) aircraftLocation aircraftHeading:(double) aircraftHeading aircraftAltitude:(double) aircraftAltitude andImage:(UIImage*) image;

@end

#endif
