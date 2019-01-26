//
//  AreaMarkerViewController.m
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "AreaMarkerViewController.h"

@interface AreaMarkerViewController ()
@property(nonatomic) UIView* markerView;
@property (weak, nonatomic) IBOutlet UIButton *resetAreaButton;
@property(nonatomic) CGPoint markerViewStartingPoint;
@property(nonatomic) CGPoint markerViewEndPoint;
@property (strong, nonatomic) IBOutlet UIPanGestureRecognizer *panGestureRecognizer;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@end

@implementation AreaMarkerViewController

- (void)viewDidLoad {
	
    [super viewDidLoad];
	self.markerView = [[UIView alloc] init];
	self.resetAreaButton.hidden = true;
	self.okButton.hidden = true;
	
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
	
}

- (IBAction) cancelAreaMarking:(UIButton*)sender {
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController switchToAreaSearchView];
}

- (IBAction)resetArea:(UIButton *)sender {
	
	self.panGestureRecognizer.enabled = true;
	[self.markerView removeFromSuperview];
	self.okButton.hidden = true;
	self.resetAreaButton.hidden = true;
	
}


- (void) initMarkerView: (UIPanGestureRecognizer*) sender {
	
	self.markerView.alpha = 0.5;
	self.markerView.backgroundColor = [UIColor colorWithRed:0.9490 green:0.8549 blue:0.5137 alpha:1.0];
	
	CGRect markerViewFrame;
	markerViewFrame.origin = [sender locationInView:self.view];
	markerViewFrame.size.width = 0;
	markerViewFrame.size.height = 0;
	self.markerView.frame = markerViewFrame;
	
	CGFloat x = [sender locationInView:self.view].x;
	CGFloat y = [sender locationInView:self.view].y;
	
	self.markerViewStartingPoint = CGPointMake(x, y);
	
	[self.view addSubview:self.markerView];
	
}

- (void) changeMarkerView: (UIPanGestureRecognizer*) sender {
	CGFloat x = self.markerViewStartingPoint.x < [sender locationInView:self.view].x ? self.markerViewStartingPoint.x : [sender locationInView:self.view].x;
	CGFloat y = self.markerViewStartingPoint.y < [sender locationInView:self.view].y ? self.markerViewStartingPoint.y : [sender locationInView: self.view].y;
	CGFloat width = fabs([sender locationInView:self.view].x - self.markerViewStartingPoint.x);
	CGFloat height = fabs([sender locationInView:self.view].y - self.markerViewStartingPoint.y);
	CGRect frame = CGRectMake(x, y, width, height);
	self.markerView.frame = frame;
}

- (void) finalizeMarkerView: (UIPanGestureRecognizer*) sender {
	self.markerView.alpha = 0.8;
	self.okButton.hidden = false;
	self.resetAreaButton.hidden = false;
	self.panGestureRecognizer.enabled = false;
	self.markerViewEndPoint = [sender locationInView:self.view];
}

- (IBAction)markArea:(UIPanGestureRecognizer *)sender {
	switch (sender.state) {
		case UIGestureRecognizerStateBegan:
			[self initMarkerView:sender];
			break;
		case UIGestureRecognizerStateEnded:
			[self finalizeMarkerView:sender];
			break;
		case UIGestureRecognizerStateChanged:
			[self changeMarkerView:sender];
			break;
		default:
			NSLog(@"default");
			break;
	}
}

- (IBAction)confirmMarkedArea:(UIButton *)sender {
	
	//set the inspectionareaManager of the parent view controller and serve it the coordinates
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	CLLocationCoordinate2D startCoordinate = [mapViewController.mapView convertPoint:self.markerViewStartingPoint
																toCoordinateFromView:self.view];
	CLLocationCoordinate2D endCoordinate = [mapViewController.mapView convertPoint: self.markerViewEndPoint
															  toCoordinateFromView:self.view];
	
	InspectionAreaManager* inspectionAreaManager = [[InspectionAreaManager alloc] initWith:startCoordinate
																					   and:endCoordinate];
	
	mapViewController.inspectionAreaManager = inspectionAreaManager;
	
	int waypointCount = (int) mapViewController.inspectionAreaManager.getWaypoints.count;
	CLLocationCoordinate2D waypoints[waypointCount];
	
	for(int i = 0; i < waypointCount; i++){
		waypoints[i] = [mapViewController.inspectionAreaManager getWaypointAtIndex:i].coordinate;
	}
	
	MKPolyline* inspectionAreaPolyline = [MKPolyline polylineWithCoordinates: waypoints
																	   count: waypointCount];
	[[mapViewController mapView] addOverlay: inspectionAreaPolyline];
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	[mapViewController initMission];
	[mapViewController switchToAreaSearchView];
}

@end
