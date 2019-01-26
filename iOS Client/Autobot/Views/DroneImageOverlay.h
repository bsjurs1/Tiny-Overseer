//
//  DroneImageOverlay.h
//  Autobot
//
//  Created by Bjarte Sjursen on 09/06/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//
#ifndef DRONEIMAGEOVERLAY
#define DRONEIMAGEOVERLAY
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "DroneImage.h"

@interface DroneImageOverlay : NSObject <MKOverlay>
@property double bearing;
@property UIImage* image;
- (DroneImageOverlay*)initWithDetection:(DroneImage*) droneImage;
- (void) update:(DroneImage*) droneImage;
@property NSObject* droneImageOverlayView;
@property(nonatomic) CLLocationCoordinate2D coordinate;
@property(nonatomic) MKMapRect boundingMapRect;
@end
#endif
