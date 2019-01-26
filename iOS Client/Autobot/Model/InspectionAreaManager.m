//
//  InspectionAreaManager.m
//  Autobot
//
//  Created by Bjarte Sjursen on 20/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "InspectionAreaManager.h"

@interface InspectionAreaManager(){
	
	CLLocation* topLeftCoordinate;
	CLLocation* topRightCoordinate;
	CLLocation* bottomLeftCoordinate;
	CLLocation* bottomRightCoordinate;
	
	CLLocationDistance latitudeDistance;
	CLLocationDistance longitudeDistance;
	
	int numberOfWaypoints;
	NSMutableArray<CLLocation*>* waypoints;
}

- (CLLocationDegrees) getLatitudeForWaypoint:(int) i;
- (CLLocationDegrees) getLongitudeForWaypoint:(int) i;
- (CLLocation*) getCoordinatesForWaypoint:(int) i;

@end
@implementation InspectionAreaManager

- (NSMutableArray<CLLocation*>*) getWaypoints {
	return waypoints;
}

-(CLLocation*) getWaypointAtIndex:(int) i {
	return waypoints[i];
}

- (InspectionAreaManager*)initWith:(CLLocationCoordinate2D) startCoordinate and:(CLLocationCoordinate2D) endCoordinate
{
	self = [super init];
	if (self) {
		
		topLeftCoordinate = [[CLLocation alloc] initWithLatitude:startCoordinate.latitude
													   longitude:startCoordinate.longitude];
		topRightCoordinate = [[CLLocation alloc] initWithLatitude:endCoordinate.latitude
														longitude:startCoordinate.longitude];
		bottomLeftCoordinate = [[CLLocation alloc] initWithLatitude:startCoordinate.latitude
														  longitude:endCoordinate.longitude];
		bottomRightCoordinate =  [[CLLocation alloc] initWithLatitude:endCoordinate.latitude
															longitude:endCoordinate.longitude];
		latitudeDistance = [bottomLeftCoordinate distanceFromLocation: bottomRightCoordinate];
		longitudeDistance = [topLeftCoordinate distanceFromLocation: bottomLeftCoordinate];
		numberOfWaypoints = ceil(latitudeDistance/10.0)*2;
		waypoints = [[NSMutableArray alloc] init];
		
		for(int i = 0; i <= (numberOfWaypoints/2); i++){
			CLLocation* coordinate = [self getCoordinatesForWaypoint:i];
			[waypoints addObject: coordinate];
		}
	}
	return self;
}

- (CLLocationDegrees) getLatitudeForWaypoint:(int) i {
	return topLeftCoordinate.coordinate.latitude - (0.00016*floor(i/2.0));
	//		//0.00009 is latitude difference that corresponds to 10 meters
}

- (CLLocationDegrees) getLongitudeForWaypoint:(int) i {
	if((i + 3) % 4 <= 1 ){
		return bottomLeftCoordinate.coordinate.longitude;
	}
	else {
		return topLeftCoordinate.coordinate.longitude;
	}
}

- (CLLocation*) getCoordinatesForWaypoint:(int) i {
	CLLocationDegrees latitude = [self getLatitudeForWaypoint:i];
	CLLocationDegrees longitude = [self getLongitudeForWaypoint:i];
	CLLocation* location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
	return location;
}

@end
