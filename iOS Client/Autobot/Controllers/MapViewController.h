//
//  MapViewController.h
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#ifndef MAPVIEWCONTROLLER_H
#define MAPVIEWCONTROLLER_H
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "HomeScreenViewController.h"
#import "MissionSelectionViewController.h"
#import "AreaMarkerViewController.h"
#import "AreaSearchViewController.h"
#import "ConfigureDroneViewController.h"
#import "ManualFlightViewController.h"
#import "InspectionAreaManager.h"
#import "DroneManager.h"
#import "DJIAircraftAnnotation.h"
#import "DroneVideoStreamViewController.h"
#import "GeospatialAnalytics.h"
#import "PointMissionViewController.h"
#import "DroneImageOverlayView.h"


#define WeakRef(__obj) __weak typeof(self) __obj = self
#define WeakReturn(__obj) if(__obj ==nil)return;
#define DEGREE(x) ((x)*180.0/M_PI)
#define RADIAN(x) ((x)*M_PI/180.0)

@interface MapViewController : UIViewController <MKMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *networkDelayLabel;
- (void) switchToHomeScreenView;
- (void) switchToMissionSelectionView;
- (void) switchToAreaSearchView;
- (void) switchToAreaMarkerView;
- (void) switchToConfigurationView;
- (void) switchToPointMissionView;
- (void) switchToManualFlightView;
- (void) displayAlert:(NSString*) message;
- (void) startWaypointMission:(NSMutableArray<CLLocation*>*) waypoints;
@property InspectionAreaManager* inspectionAreaManager;
@property (nonatomic, strong) DJIAircraftAnnotation* aircraftAnnotation;
@property(nonatomic, assign) CLLocationCoordinate2D droneLocation;
@property (weak, nonatomic) IBOutlet UIImageView *objectDetectionVideoView;
-(void) startMission;
-(void) initMission;
/**
 *  Update Aircraft's location in Map View
 */
-(void)updateAircraftLocation:(CLLocationCoordinate2D)location withMapView:(MKMapView *)mapView;
/**
 *  Update Aircraft's heading in Map View
 */
-(void)updateAircraftHeading:(float)heading;
@end

#endif
