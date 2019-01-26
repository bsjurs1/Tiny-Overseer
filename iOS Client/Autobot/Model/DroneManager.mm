//
//  DroneManager.m
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "DroneManager.h"
@interface DroneManager(){
	dispatch_queue_t videoFeedQueue;
	bool isCameraLookDown;
	bool isUpdateOverlay;
	bool isPredictCarsActivated;
	bool isPredictionPerformedAtWaypoint;
	NSTimer* areaCoverTimer;
}
-(void) registerApp;
-(DJIWaypointMissionOperator *) missionOperator;
@property DJIMutableWaypointMission* waypointMission;
@property UIView* videoView;
@property NetworkManager* networkManager;
@property DroneImage* droneImage;
@end
@implementation DroneManager
#pragma mark - class specific helper methods

-(DroneManager*) init {
	self = [super init];
	if(self){
		videoFeedQueue = dispatch_queue_create("Drone Video Feed Queue", DISPATCH_QUEUE_SERIAL);
		self.waypointMission = [[DJIMutableWaypointMission alloc] init];
		isCameraLookDown = false;
		aircraftAltitude = -1;
		isUpdateOverlay = true;
		isPredictCarsActivated = false;
		isPredictionPerformedAtWaypoint = false;
	}
	return self;
}

#pragma mark - DJISDK methods
-(void) registerApp {
	[DJISDKManager registerAppWithDelegate:self];
}

-(void) connectToProduct {
	[DJISDKManager startConnectionToProduct];
}

- (void) appRegisteredWithError:(NSError * _Nullable)error {
	NSString* message;
	if(error != NULL){
		message = @"Register App Failed! Please enter your App Key in the plist file and check the network.";
		MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
		[mapViewController displayAlert:message];
	}
	else{
		[DJISDKManager enableBridgeModeWithBridgeAppIP:@"10.24.17.184"];
		message = @"Register App Success!";
		[self connectToProduct];
	}
}

-(void) productDisconnected {
	DJICamera* camera = [self fetchCamera];
	if(camera && camera.delegate == self){
		[camera setDelegate:nil];
	}
	[self resetVideoPreview];
}

+ (DJIFlightController*) fetchFlightController {
	if (![DJISDKManager product]) {
		return nil;
	}
	if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
		return ((DJIAircraft*)[DJISDKManager product]).flightController;
	}
	return nil;
}

-(void) productConnected:(DJIBaseProduct *)product {
	if(product != nil){
		MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
		[mapViewController displayAlert:@"Product connected"];
		DJIAircraft* product = [DJISDKManager product];
		DJIFlightController* flightController = [DroneManager fetchFlightController];
		flightController.delegate = self;
		DJICamera* camera = [self fetchCamera];
		if(camera != nil){
			camera.delegate = self;
		}
	}
	else{
		MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
		[mapViewController displayAlert:@"Product could not connect"];
	}
}

-(void) updateAircraftOverlayWithImage:(UIImage*) image andPersistOnMapView:(bool) isOverlayPersistant {
	
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	
	if(isOverlayPersistant){
		DroneImage* persistentDroneImage = [[DroneImage alloc] initWithDroneCoordinate:aircraftLocation andDroneAltitude:aircraftAltitude droneHeading:aircraftHeading andDroneImage:image];
		DroneImageOverlay* persistantDroneImageOverlay = [[DroneImageOverlay alloc] initWithDetection:persistentDroneImage];
		[mapViewController.mapView addOverlay: persistantDroneImageOverlay];
	}
	else{
		if(self.droneImage == nil){
			self.droneImage = [[DroneImage alloc] initWithDroneCoordinate:aircraftLocation andDroneAltitude:aircraftAltitude droneHeading:aircraftHeading andDroneImage:image];
			self.droneImageOverlay = [[DroneImageOverlay alloc] initWithDetection:self.droneImage];
			self.droneImage.droneImageOverlay = (NSObject*) self.droneImageOverlay;
			[mapViewController.mapView addOverlay: self.droneImageOverlay];
			return;
		}
		else{
			bool isProcessing = [self.droneImage updateDroneCoordinate:aircraftLocation
													  andDroneAltitude:aircraftAltitude
														  droneHeading:aircraftHeading
														 andDroneImage:image];
			if(!isProcessing){
				[mapViewController.mapView removeOverlay:self.droneImageOverlay];
				[mapViewController.mapView addOverlay:self.droneImageOverlay];
			}
		}
	}
}

-(void) displayDetectedObjectsAsPins {
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	NSMutableArray<CLLocation*>* locations = [self.networkManager getLocations];
	for(int i = 0; i < locations.count; i++){
		MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
		CLLocation* predictedLocation = [locations objectAtIndex:i];
		point.coordinate = CLLocationCoordinate2DMake(predictedLocation.coordinate.latitude, predictedLocation.coordinate.longitude);
		point.title = @"Car";
		point.subtitle = @"Located here";
		[mapViewController.mapView addAnnotation:point];
	}
}


-(double) activatePredictCars {
	
	isPredictCarsActivated = true;
	
	UIImage* image = [self.networkManager getImage];
	double time1 = CACurrentMediaTime();
	UIImage* detectionImage = [self.networkManager getObjectDetectionImage:aircraftLocation aircraftHeading:aircraftHeading aircraftAltitude:aircraftAltitude andImage:image];
	double time2 = CACurrentMediaTime();
	double delay = time2 - time1;
	[self updateAircraftOverlayWithImage:detectionImage andPersistOnMapView:true];
	[self displayDetectedObjectsAsPins];
	return delay;
}

-(void) sendRotateGimbalCommand {
	DJIGimbal* gimbal = [self fetchGimbal];
	
	if (gimbal == nil) {
		return;
	}
	if(isCameraLookDown){
		DJIGimbalRotation *rotation = [DJIGimbalRotation gimbalRotationWithPitchValue:@(0)
																			rollValue:@(0)
																			 yawValue:@(0)
																				 time:0
																				 mode:DJIGimbalRotationModeAbsoluteAngle];
		[gimbal rotateWithRotation:rotation completion:^(NSError * _Nullable error) {
			if (error) {
				NSLog(@"rotateWithRotation failed: %@", error.description);
			}
			else{
				isCameraLookDown = false;
			}
		}];
	}
	else{
		DJIGimbalRotation *rotation = [DJIGimbalRotation gimbalRotationWithPitchValue:@(-90)
																			rollValue:@(0)
																			 yawValue:@(0)
																				 time:0
																				 mode:DJIGimbalRotationModeAbsoluteAngle];
		[gimbal rotateWithRotation:rotation completion:^(NSError * _Nullable error) {
			if (error) {
				NSLog(@"rotateWithRotation failed: %@", error.description);
			}
			else{
				isCameraLookDown = true;
			}
		}];
	}
}

- (DJIGimbal*) fetchGimbal {
	if(![DJISDKManager product]){
		return nil;
	}
	if ([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]) {
		return ((DJIAircraft*)[DJISDKManager product]).gimbal;
	}
	return nil;
}

-(void) flightController:(DJIFlightController *)fc didUpdateState:(DJIFlightControllerState *)state{
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController updateAircraftLocation:state.aircraftLocation.coordinate withMapView: mapViewController.mapView];
	double radianYaw = RADIAN(state.attitude.yaw);
	[mapViewController updateAircraftHeading:radianYaw];
	aircraftLocation = CLLocationCoordinate2DMake(state.aircraftLocation.coordinate.latitude, state.aircraftLocation.coordinate.longitude);
	aircraftAltitude = state.altitude;
	aircraftLatitude = state.aircraftLocation.coordinate.latitude;
	aircraftLongitude = state.aircraftLocation.coordinate.longitude;
	aircraftHeading = fc.compass.heading;
}

#pragma mark - waypoint mission related methods
-(void) didMissionUpload:(NSError*) error {
	if(error != nil){
		[[self missionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error2) {
			[self didMissionUpload:error2];
		}];
	}
	else{
		MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
		[[self missionOperator] startMissionWithCompletion:^(NSError * _Nullable error2) {
			[self didMissionStart:error2];
		}];
		[mapViewController displayAlert:@"Upload success"];
	}
}

-(void) didMissionStart:(NSError*) error {
	if(error == nil){
		MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
		[mapViewController displayAlert:@"Start success"];
	}
}

-(DJIWaypointMissionOperator *)missionOperator {
	return [DJISDKManager missionControl].waypointMissionOperator;
}

-(void) startWaypointMission {
	NSError* error = [[self missionOperator] loadMission:self.waypointMission];
	if(error == nil){
		[[self missionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error2) {
			[self didMissionUpload:error2];
		}];
	}
}

-(void) initWaypointMission:(InspectionAreaManager*) inspectionAreaManager {
	for(CLLocation* location in [inspectionAreaManager getWaypoints]){
		DJIWaypoint* waypoint = [[DJIWaypoint alloc] initWithCoordinate: location.coordinate];
		waypoint.altitude = 25.0f;
		[self.waypointMission addWaypoint:waypoint];
	}
	
	self.waypointMission.maxFlightSpeed = 10.0f;
	self.waypointMission.autoFlightSpeed = 8.0f;
	self.waypointMission.headingMode = DJIWaypointMissionHeadingUsingWaypointHeading;
	self.waypointMission.finishedAction = DJIWaypointMissionFinishedGoHome;
	if(!isCameraLookDown){
		[self sendRotateGimbalCommand];
	}
	[[self missionOperator] addListenerToFinished:self withQueue:nil andBlock:^(NSError * _Nullable error) {
		[areaCoverTimer invalidate];
	}];
	
	[[self missionOperator] addListenerToStarted:self withQueue:nil andBlock:^{
		areaCoverTimer = [NSTimer scheduledTimerWithTimeInterval:4.0
														  target:self
														selector:@selector(activatePredictCars)
														userInfo:nil
														 repeats:true];
	}];

	[[self missionOperator] addListenerToUploadEvent:self withQueue:dispatch_get_main_queue() andBlock:^(DJIWaypointMissionUploadEvent * _Nonnull event) {
		if(event.error != nil){
			[[self missionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error) {
				[self didMissionUpload:error];
			}];
		}
		else{
			[[self missionOperator] startMissionWithCompletion:^(NSError * _Nullable error) {
				[self didMissionStart:error];
			}];
		}
	}];
}

- (void) initWaypointMissionWithWaypoints:(NSMutableArray<CLLocation*>*) waypoints {
	for(CLLocation* location in waypoints){
		DJIWaypoint* waypoint = [[DJIWaypoint alloc] initWithCoordinate: location.coordinate];
		waypoint.altitude = 25.0f;
		DJIWaypointAction* action = [[DJIWaypointAction alloc] initWithActionType:DJIWaypointActionTypeStay param:4000];
		[waypoint addAction:action];
		[self.waypointMission addWaypoint:waypoint];
	}
	self.waypointMission.maxFlightSpeed = 10.0f;
	self.waypointMission.autoFlightSpeed = 8.0f;
	self.waypointMission.headingMode = DJIWaypointMissionHeadingUsingWaypointHeading;
	self.waypointMission.finishedAction = DJIWaypointMissionFinishedGoHome;
	if(!isCameraLookDown){
		[self sendRotateGimbalCommand];
	}
	[[self missionOperator] addListenerToExecutionEvent:self withQueue:nil andBlock:^(DJIWaypointMissionExecutionEvent * _Nonnull event) {
		if(event.progress.execState == DJIWaypointMissionExecuteStateFinishedAction && not isPredictionPerformedAtWaypoint){
			isPredictionPerformedAtWaypoint = true;
			[self activatePredictCars];
		}
		else if(event.progress.execState == DJIWaypointMissionExecuteStateBeginAction){
			isPredictionPerformedAtWaypoint = false;
		}
	}];
	[[self missionOperator] addListenerToUploadEvent:self withQueue:dispatch_get_main_queue() andBlock:^(DJIWaypointMissionUploadEvent * _Nonnull event) {
		if(event.error != nil){
			[[self missionOperator] uploadMissionWithCompletion:^(NSError * _Nullable error) {
				[self didMissionUpload:error];
			}];
		}
		else{
			[[self missionOperator] startMissionWithCompletion:^(NSError * _Nullable error) {
				[self didMissionStart:error];
			}];
		}
	}];
}

#pragma mark - camera methods


-(void) camera:(DJICamera *)camera didUpdateSystemState:(DJICameraSystemState *)systemState{
	
}

-(void) resetVideoPreview {
	[[VideoPreviewer instance] unSetView];
	DJIBaseProduct* product = [DJISDKManager product];
	if([product.model isEqualToString:DJIAircraftModelNameA3] ||
	   [product.model isEqualToString:DJIAircraftModelNameMatrice600] ||
	   [product.model isEqualToString:DJIAircraftModelNameMatrice600Pro]){
		[[DJISDKManager videoFeeder].secondaryVideoFeed removeListener:self];
	}
	else{
		[[DJISDKManager videoFeeder].primaryVideoFeed removeListener:self];
	}
}

-(DJICamera*) fetchCamera {
	if(![DJISDKManager product]){
		return nil;
	}
	if([[DJISDKManager product] isKindOfClass:[DJIAircraft class]]){
		return [DJISDKManager product].camera;
	}
	else if([[DJISDKManager product] isKindOfClass:[DJIHandheld class]]){
		return [DJISDKManager product].camera;
	}
	return nil;
}

-(void) setupVideoPreviewer:(UIView*) view {
	// 10.24.19.205
	// lab408: 129.241.104.68
	self.networkManager = [[NetworkManager alloc] init: (char*)"129.241.104.68"];
	[[VideoPreviewer instance] setView:view withNetworkManager: self.networkManager];
	DJIBaseProduct* product = [DJISDKManager product];
	if([product.model isEqualToString:DJIAircraftModelNameA3] ||
	   [product.model isEqualToString:DJIAircraftModelNameMatrice600] ||
	   [product.model isEqualToString:DJIAircraftModelNameMatrice600Pro]){
		[[DJISDKManager videoFeeder].secondaryVideoFeed addListener:self withQueue:videoFeedQueue];
	}
	else {
		[[DJISDKManager videoFeeder].primaryVideoFeed addListener:self withQueue:videoFeedQueue];
	}
	[[VideoPreviewer instance] start];
}

-(void) videoFeed:(DJIVideoFeed *)videoFeed didUpdateVideoData:(NSData *)videoData {
	[[VideoPreviewer instance] push:(uint8_t *)videoData.bytes length:(int)videoData.length];
	
//	if([self missionOperator] == DJIWaypointMissionExecuteStateBeginAction){
//		[self activatePredictCars];
//	}
//	UIImage* image = [self.networkManager getImage];
//	[self updateAircraftOverlayWithImage:image andPersistOnMapView:false];
}
@end
