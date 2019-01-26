//
//  MapViewController.m
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController (){
	DroneManager* droneManager;
	CGPoint initialVideoViewCenter;
	BOOL isVideoViewFullScreen;
	NSMutableDictionary *datapoints;
	CLLocationManager* locationManager;
	CLLocation* currentLocation;
}
@property(weak, nonatomic) MissionSelectionViewController* missionSelectionViewController;
@property(weak, nonatomic) HomeScreenViewController* homeScreenViewController;
@property(weak, nonatomic) AreaSearchViewController* areaSearchViewController;
@property(weak, nonatomic) ManualFlightViewController* manualFlightViewController;
@property(weak, nonatomic) PointMissionViewController* pointMissionViewController;
@property(weak, nonatomic) AreaMarkerViewController* areaMarkerViewController;
@property(weak, nonatomic) ConfigureDroneViewController* configurationViewController;
@property DroneVideoStreamViewController* droneVideoStreamViewController;
@property (weak, nonatomic) IBOutlet UIView *videoSuperView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *videoViewSegmentedControl;
@property(weak, nonatomic) UIStoryboard* mainStoryBoard;
@property (weak, nonatomic) IBOutlet UIButton *predictCarsButton;

@end

@implementation MapViewController


- (IBAction)predictCars:(UIButton *)sender {
	double delay = [droneManager activatePredictCars];
	[self.networkDelayLabel setText:[NSString stringWithFormat:@"Network delay: %f", delay]];
}

- (IBAction)rotateGimbal:(UIButton *)sender {
	
	[droneManager sendRotateGimbalCommand];
	
}

- (void) displayAlert:(NSString*) message {
	UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Registration Status"
																   message:message
															preferredStyle:UIAlertControllerStyleAlert];
	if([message isEqualToString:@"Register App Success!"]){
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {
																  [droneManager connectToProduct];
															  }];
		UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
																style:UIAlertActionStyleDestructive
															  handler:^(UIAlertAction * action) {
																  NSLog(@"Cancel");
															  }];
		
		[alert addAction:defaultAction];
		[alert addAction:cancelAction];
	}
	else if([message isEqualToString:@"Product connected"]){
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
																style:UIAlertActionStyleDefault
															  handler:^(UIAlertAction * action) {
																  self.droneVideoStreamViewController = [self.mainStoryBoard instantiateViewControllerWithIdentifier:@"droneVideoStream"];
																  [self.droneVideoStreamViewController loadDroneManager:droneManager];
																  [self addChildViewController:self.droneVideoStreamViewController];
																  self.droneVideoStreamViewController.view.frame = CGRectMake(0, 0, self.videoSuperView.frame.size.width, self.videoSuperView.frame.size.height);
																  [self.videoSuperView addSubview: self.droneVideoStreamViewController.view];
																  [self.videoSuperView bringSubviewToFront:self.videoViewSegmentedControl];
															  }];
		
		[alert addAction:defaultAction];
	}
	else{
		UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
																style:UIAlertActionStyleDefault
															  handler: nil];
		[alert addAction:defaultAction];
	}
	[self presentViewController:alert animated:true completion:nil];
}

- (IBAction)resizeVideoView:(UITapGestureRecognizer *)sender {
	if(isVideoViewFullScreen){
		[self.videoSuperView setBounds: CGRectMake(0, 0, 176, 99)];
		[self.videoSuperView setCenter: initialVideoViewCenter];
		isVideoViewFullScreen = false;
	}
	else{
		[self.videoSuperView setBounds: [UIScreen mainScreen].bounds];
		[self.videoSuperView setCenter: self.view.center];
		[self.videoViewSegmentedControl setCenter: self.view.center];
		isVideoViewFullScreen = true;
	}
}

- (IBAction)selectVideoType:(UISegmentedControl *)sender {
	
	if(sender.selectedSegmentIndex == 0){
		self.objectDetectionVideoView.hidden = true;
		[self.videoSuperView sendSubviewToBack: self.objectDetectionVideoView];
		self.droneVideoStreamViewController.view.hidden = false;
	}
	else{
		self.objectDetectionVideoView.hidden = false;
		[self.videoSuperView sendSubviewToBack: self.droneVideoStreamViewController.view];
		self.droneVideoStreamViewController.view.hidden = true;
	}
}

-(void) startMission {
	[droneManager startWaypointMission];
}

-(void) initMission {
	[droneManager initWaypointMission:self.inspectionAreaManager];
}
- (IBAction)translateVideoView:(UIPanGestureRecognizer *)sender {
	
	if(sender.state != UIGestureRecognizerStateEnded){
		[self.videoSuperView setCenter:CGPointMake(initialVideoViewCenter.x + [sender translationInView:self.view].x, initialVideoViewCenter.y + [sender translationInView:self.view].y)];
		
	}
	else{
		initialVideoViewCenter = self.videoSuperView.center;
	}
	
}

- (void)viewDidLoad {
	self.droneLocation = kCLLocationCoordinate2DInvalid;
	datapoints = [NSMutableDictionary new];
    [super viewDidLoad];
	self.mainStoryBoard = [UIStoryboard storyboardWithName: @"Main" bundle: NULL];
	self.homeScreenViewController = [self.mainStoryBoard instantiateViewControllerWithIdentifier:@"homescreen"];
	self.homeScreenViewController.parentMapViewController = self;
	[self addChildViewController: self.homeScreenViewController];
	[self.view addSubview: self.homeScreenViewController.view];
	droneManager = [[DroneManager alloc] init];
	droneManager.parentMapViewController = self;
	initialVideoViewCenter = self.videoSuperView.center;
	isVideoViewFullScreen = false;
	self.videoSuperView.translatesAutoresizingMaskIntoConstraints = YES;
	locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	[locationManager requestWhenInUseAuthorization];
	[locationManager startUpdatingLocation];
	locationManager.desiredAccuracy = kCLLocationAccuracyBest;
	currentLocation = [[CLLocation alloc] init];
	self.mapView.mapType = MKMapTypeSatellite;
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) switchToHomeScreenView{
	self.homeScreenViewController = [self.mainStoryBoard instantiateViewControllerWithIdentifier:@"homescreen"];
	self.homeScreenViewController.parentMapViewController = self;
	[self addChildViewController: self.homeScreenViewController];
	[self.view addSubview: self.homeScreenViewController.view];
	[self.homeScreenViewController didMoveToParentViewController: self];
}

- (void) switchToMissionSelectionView {
	[droneManager registerApp];
	self.missionSelectionViewController = [self.mainStoryBoard instantiateViewControllerWithIdentifier:@"missionSelection"];
	self.missionSelectionViewController.parentMapViewController = self;
	[self addChildViewController: self.missionSelectionViewController];
	[self.view addSubview: self.missionSelectionViewController.view];
	[self.missionSelectionViewController didMoveToParentViewController: self];
}

- (void) switchToAreaSearchView {
	self.areaSearchViewController = [self.mainStoryBoard instantiateViewControllerWithIdentifier:@"areaSearch"];
	self.areaSearchViewController.parentMapViewController = self;
	[self addChildViewController: self.areaSearchViewController];
	[self.view addSubview: self.areaSearchViewController.view];
	[self.areaSearchViewController didMoveToParentViewController: self];
}

- (void) switchToManualFlightView {
	self.manualFlightViewController = [self.mainStoryBoard instantiateViewControllerWithIdentifier:@"manualFlight"];
	self.manualFlightViewController.parentMapViewController = self;
	[self addChildViewController: self.manualFlightViewController];
	[self.view addSubview: self.manualFlightViewController.view];
	[self.manualFlightViewController didMoveToParentViewController: self];
}

- (void) switchToPointMissionView {
	self.pointMissionViewController = [self.mainStoryBoard instantiateViewControllerWithIdentifier:@"pointMission"];
	self.pointMissionViewController.parentMapViewController = self;
	[self addChildViewController: self.pointMissionViewController];
	[self.view addSubview: self.pointMissionViewController.view];
	[self.pointMissionViewController didMoveToParentViewController: self];
}

- (void) switchToAreaMarkerView {
	self.areaMarkerViewController = [self.mainStoryBoard instantiateViewControllerWithIdentifier:@"areaMarker"];
	self.areaMarkerViewController.parentMapViewController = self;
	[self addChildViewController: self.areaMarkerViewController];
	[self.view addSubview: self.areaMarkerViewController.view];
	[self.areaMarkerViewController didMoveToParentViewController: self];
}

- (void) switchToConfigurationView {
	self.configurationViewController = [self.mainStoryBoard instantiateViewControllerWithIdentifier:@"configurationScreen"];
	self.configurationViewController.parentMapViewController = self;
	[self addChildViewController: self.configurationViewController];
	[self.view addSubview: self.configurationViewController.view];
	[self.configurationViewController didMoveToParentViewController: self];
}

#pragma mark - MKMapViewDelegate
-(MKOverlayRenderer*) mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
	if([overlay isKindOfClass:[MKPolyline class]]){
		MKPolylineRenderer* lineView = [[MKPolylineRenderer alloc] initWithOverlay:overlay];
		lineView.strokeColor = [UIColor colorWithRed:0.9490 green:0.8549 blue:0.5137 alpha:1.0];
		lineView.lineWidth = 2.0;
		lineView.lineDashPhase = 4;
		lineView.lineDashPattern = @[@2,@3,@2,@3];
		return lineView;
	}
	else if([overlay isKindOfClass:[DroneImageOverlay class]]){
		return [[DroneImageOverlayView alloc] initWithOverlay:overlay];
	}
	else {
		return [[MKOverlayRenderer alloc] init];
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
	if ([annotation isKindOfClass:[DJIAircraftAnnotation class]])
	{
		DJIAircraftAnnotationView* annoView = [[DJIAircraftAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"Aircraft_Annotation"];
		((DJIAircraftAnnotation*)annotation).annotationView = annoView;
		return annoView;
	}
	else if([annotation.title isEqualToString:@"waypoint"]){
		MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"waypoint"];
		annotationView.pinTintColor = [UIColor colorWithRed:0.9725 green:0.8078 blue:0.3020 alpha:1.0];
		return annotationView;
	}
	if([annotation isKindOfClass:[MKPointAnnotation class]]){
		MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"car_annotation"];
		if([annotation.title isEqualToString:@"currentLocation"]){
			annotationView.pinTintColor = UIColor.blueColor;
		}
		return annotationView;
	}
	
	return nil;
}

-(void) focusMapLocation:(CLLocationCoordinate2D) location {
	if (CLLocationCoordinate2DIsValid(location)) {
		MKCoordinateRegion region = {0};
		region.center = location;
		region.span.latitudeDelta = 0.001;
		region.span.longitudeDelta = 0.001;
		[self.mapView setRegion:region animated:YES];
	}
}



- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations{
	currentLocation = [locations objectAtIndex:0];
}

-(void)updateAircraftLocation:(CLLocationCoordinate2D)location withMapView:(MKMapView *)mapView
{
	if (self.aircraftAnnotation == nil) {
		self.aircraftAnnotation = [[DJIAircraftAnnotation alloc] initWithCoordiante:location];
		[mapView addAnnotation:self.aircraftAnnotation];
		[self focusMapLocation:location];
	}
	[self.aircraftAnnotation setCoordinate:location];
}
- (IBAction)annotateCurrentLocation:(UIButton *)sender {
	
	MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
	point.coordinate = currentLocation.coordinate;
	point.title = @"currentLocation";
	point.subtitle = @"Located here";
	[self.mapView addAnnotation:point];
	
}

-(void)updateAircraftHeading:(float)heading
{
	if (self.aircraftAnnotation) {
		[self.aircraftAnnotation updateHeading:heading];
	}
}

-(void) startWaypointMission:(NSMutableArray<CLLocation*>*) waypoints {
	[droneManager initWaypointMissionWithWaypoints:waypoints];
	[droneManager startWaypointMission];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
