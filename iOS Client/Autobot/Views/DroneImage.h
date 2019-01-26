//
//  DroneImage.h
//  Autobot
//
//  Created by Bjarte Sjursen on 09/06/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//
#ifndef DRONEIMAGE
#define DRONEIMAGE

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "GeospatialAnalytics.h"

@interface DroneImage : NSObject
@property CLLocationCoordinate2D midCoordinate;
@property CLLocationCoordinate2D overlayTopLeftCoordinate;
@property CLLocationCoordinate2D overlayTopRightCoordinate;
@property CLLocationCoordinate2D overlayBottomLeftCoordinate;
@property CLLocationCoordinate2D overlayBottomRightCoordinate;
@property MKMapRect overlayBoundingMapRect;
@property NSObject* droneImageOverlay;
@property UIImage* image;
@property double bearing;
- (DroneImage*)initWithMidCoordinate:(CLLocationCoordinate2D) midCoordinate andOverlayTopLeftCoordinate:(CLLocationCoordinate2D) overlayTopLeftCoordinate andOverlayTopRightCoordinate:(CLLocationCoordinate2D) overlayTopRightCoordinate andOverlayBottomLeftCoordinate:(CLLocationCoordinate2D) overlayBottomLeftCoordinate bearing:(double) bearing andImage:(UIImage*) image;
-(DroneImage*) initWithDroneCoordinate:(CLLocationCoordinate2D) droneCoordinate andDroneAltitude:(double) droneAltitude droneHeading:(double) droneHeading andDroneImage:(UIImage*) image;
-(bool) updateDroneCoordinate:(CLLocationCoordinate2D) droneCoordinate andDroneAltitude:(double) droneAltitude droneHeading:(double) droneHeading andDroneImage:(UIImage*) image;

@end
#endif
