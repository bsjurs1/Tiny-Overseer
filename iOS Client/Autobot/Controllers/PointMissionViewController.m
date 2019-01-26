//
//  PointMissionViewController.m
//  Autobot
//
//  Created by Bjarte Sjursen on 07/06/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "PointMissionViewController.h"

@interface PointMissionViewController (){
	BOOL isWaypointCreationActivated;
	BOOL isWaypointsAdded;
	NSMutableArray<CLLocation*>* waypoints;
}
@property (weak, nonatomic) IBOutlet UIButton *addWaypointsButton;
@property (weak, nonatomic) IBOutlet UIButton *startMissionButton;
@end

@implementation PointMissionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = UIColor.clearColor;
	waypoints = [[NSMutableArray alloc] init];
	isWaypointCreationActivated = false;
	isWaypointsAdded = false;
	
    // Do any additional setup after loading the view.
}

- (IBAction)cancel:(UIButton *)sender {
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController switchToMissionSelectionView];
}

- (IBAction)tap:(UITapGestureRecognizer *)sender {
	if(isWaypointCreationActivated){
		MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
		CGPoint touchPoint = [sender locationInView:self.view];
		CLLocationCoordinate2D coordinate = [mapViewController.mapView convertPoint:touchPoint toCoordinateFromView:self.view];
		MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
		CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
		[waypoints addObject:location];
		point.coordinate = coordinate;
		point.title = @"waypoint";
		point.subtitle = @"Located here";
		[mapViewController.mapView addAnnotation:point];
		isWaypointsAdded = true;
	}
}

- (IBAction)addWayPoints:(UIButton *)sender {
	if(!isWaypointCreationActivated){
		isWaypointCreationActivated = true;
		[self.addWaypointsButton setTitle:@"OK" forState:UIControlStateNormal];
	}
	else if(isWaypointCreationActivated){
		isWaypointCreationActivated = false;
		if(isWaypointsAdded){
			self.startMissionButton.enabled = true;
		}
		[self.addWaypointsButton setTitle:@"Add Way points" forState:UIControlStateNormal];
	}
}

- (IBAction)startMission:(id)sender {
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController startWaypointMission:waypoints];
}

@end
