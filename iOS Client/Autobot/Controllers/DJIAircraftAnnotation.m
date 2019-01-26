//
//  DJIAircraftAnnotation.m
//  Autobot
//
//  Created by Bjarte Sjursen on 16/04/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "DJIAircraftAnnotation.h"

@implementation DJIAircraftAnnotation
-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate
{
	self = [super init];
	if (self) {
		_coordinate = coordinate;
	}
	return self;
}
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
	_coordinate = newCoordinate;
}
-(void)updateHeading:(float)heading
{
	if (self.annotationView) {
		[self.annotationView updateHeading:heading];
	}
}
@end
