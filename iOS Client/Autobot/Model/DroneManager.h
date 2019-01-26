//
//  DroneManager.h
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//
#ifndef DRONEMANAGER_H
#define DRONEMANAGER_H

#import <Foundation/Foundation.h>
#import <DJISDK/DJISDK.h>
#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import <VideoPreviewer/VideoPreviewer.h>
#import "InspectionAreaManager.h"
#import "NetworkManager.h"
#import "DroneImageOverlay.h"
#import "DroneImageOverlay.h"

@interface DroneManager : NSObject <DJISDKManagerDelegate, DJIFlightControllerDelegate, DJIBaseProductDelegate, DJIVideoFeedListener, DJICameraDelegate, DJIGimbalDelegate>{
	double aircraftAltitude, aircraftLatitude, aircraftLongitude, aircraftHeading;
	CLLocationCoordinate2D aircraftLocation;
}

-(DroneManager*) init;
@property(nonatomic) UIViewController* parentMapViewController;
-(void) registerApp;
-(void) sendRotateGimbalCommand;
-(void) connectToProduct;
-(void) startWaypointMission;
-(void) initWaypointMission:(InspectionAreaManager*) inspectionAreaManager;
-(void) setupVideoPreviewer:(UIView*) view;
-(void) resetVideoPreview;
-(double) activatePredictCars;
-(void) deActivatePredictCars;
- (void) initWaypointMissionWithWaypoints:(NSMutableArray<CLLocation*>*) waypoints;
@property(nonatomic, assign) CLLocationCoordinate2D droneLocation;
@property DroneImageOverlay* droneImageOverlay;
@end

#endif
