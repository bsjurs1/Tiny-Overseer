//
//  DroneImage.m
//  Autobot
//
//  Created by Bjarte Sjursen on 09/06/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "DroneImage.h"
#import "DroneImageOverlay.h"
@interface DroneImage(){
	dispatch_queue_t droneImageQueue;
	bool isProcessing;
}
@end
@implementation DroneImage

-(DroneImage*) initWithDroneCoordinate:(CLLocationCoordinate2D) droneCoordinate andDroneAltitude:(double) droneAltitude droneHeading:(double) droneHeading andDroneImage:(UIImage*) image {
	self = [super init];
	if (self) {
		droneImageQueue = dispatch_queue_create("droneImageQueue", DISPATCH_QUEUE_SERIAL);
		dispatch_set_target_queue(droneImageQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 1));
		dispatch_sync(droneImageQueue, ^{
			isProcessing = false;
			double droneLatitude = droneCoordinate.latitude;
			double droneLongitude = droneCoordinate.longitude;
			double distanceToCorner = 0.7297588134375 * droneAltitude;
			CLLocation* imageTopLeftCornerLocation = [GeospatialAnalytics calculateVincentysDirectWithLatitude:droneLatitude longitude:droneLongitude distance:distanceToCorner andBearing:- 60.64];
			CLLocation* imageTopRightCornerLocation = [GeospatialAnalytics calculateVincentysDirectWithLatitude:droneLatitude longitude:droneLongitude distance:distanceToCorner andBearing:+ 60.64];
			CLLocation* imageBottomLeftCornerLocation = [GeospatialAnalytics calculateVincentysDirectWithLatitude:droneLatitude longitude:droneLongitude distance:distanceToCorner andBearing: - 119.358];
			CLLocation* imageBottomRightCornerLocation = [GeospatialAnalytics calculateVincentysDirectWithLatitude:droneLatitude longitude:droneLongitude distance:distanceToCorner andBearing: 119.358];
			self.midCoordinate = droneCoordinate;
			self.overlayTopLeftCoordinate = CLLocationCoordinate2DMake(imageTopLeftCornerLocation.coordinate.latitude, imageTopLeftCornerLocation.coordinate.longitude);
			self.overlayTopRightCoordinate = CLLocationCoordinate2DMake(imageTopRightCornerLocation.coordinate.latitude, imageTopRightCornerLocation.coordinate.longitude);
			self.overlayBottomLeftCoordinate = CLLocationCoordinate2DMake(imageBottomLeftCornerLocation.coordinate.latitude, imageBottomLeftCornerLocation.coordinate.longitude);
			self.overlayBottomRightCoordinate = CLLocationCoordinate2DMake(imageBottomRightCornerLocation.coordinate.latitude, imageBottomRightCornerLocation.coordinate.longitude);
			MKMapPoint topLeft = MKMapPointForCoordinate(self.overlayTopLeftCoordinate);
			MKMapPoint topRight = MKMapPointForCoordinate(self.overlayTopRightCoordinate);
			MKMapPoint bottomLeft = MKMapPointForCoordinate(self.overlayBottomLeftCoordinate);
			self.overlayBoundingMapRect = MKMapRectMake(topLeft.x, topLeft.y, fabs(topLeft.x - topRight.x), fabs(topLeft.y - bottomLeft.y));
			self.bearing = [GeospatialAnalytics radians:droneHeading];
			self.image = image;
		});
	}
	return self;
}

-(bool) updateDroneCoordinate:(CLLocationCoordinate2D) droneCoordinate andDroneAltitude:(double) droneAltitude droneHeading:(double) droneHeading andDroneImage:(UIImage*) image {
	if(!isProcessing){
		dispatch_async(droneImageQueue, ^{
			isProcessing = true;
			double droneLatitude = droneCoordinate.latitude;
			double droneLongitude = droneCoordinate.longitude;
			double distanceToCorner = 0.7297588134375 * droneAltitude;
			CLLocation* imageTopLeftCornerLocation = [GeospatialAnalytics calculateVincentysDirectWithLatitude:droneLatitude longitude:droneLongitude distance:distanceToCorner andBearing:- 60.64];
			CLLocation* imageBottomRightCornerLocation = [GeospatialAnalytics calculateVincentysDirectWithLatitude:droneLatitude longitude:droneLongitude distance:distanceToCorner andBearing: 119.358];
			self.midCoordinate = droneCoordinate;
			self.overlayTopLeftCoordinate = CLLocationCoordinate2DMake(imageTopLeftCornerLocation.coordinate.latitude, imageTopLeftCornerLocation.coordinate.longitude);
			self.overlayTopRightCoordinate = CLLocationCoordinate2DMake(imageTopLeftCornerLocation.coordinate.latitude, imageBottomRightCornerLocation.coordinate.longitude);
			self.overlayBottomLeftCoordinate = CLLocationCoordinate2DMake(imageBottomRightCornerLocation.coordinate.latitude, imageTopLeftCornerLocation.coordinate.longitude);
			self.overlayBottomRightCoordinate = CLLocationCoordinate2DMake(imageBottomRightCornerLocation.coordinate.latitude, imageBottomRightCornerLocation.coordinate.longitude);
			MKMapPoint topLeft = MKMapPointForCoordinate(self.overlayTopLeftCoordinate);
			MKMapPoint topRight = MKMapPointForCoordinate(self.overlayTopRightCoordinate);
			MKMapPoint bottomLeft = MKMapPointForCoordinate(self.overlayBottomLeftCoordinate);
			self.overlayBoundingMapRect = MKMapRectMake(topLeft.x, topLeft.y, fabs(topLeft.x - topRight.x), fabs(topLeft.y - bottomLeft.y));
			self.bearing = [GeospatialAnalytics radians:droneHeading];
			self.image = image;
			[((DroneImageOverlay*)self.droneImageOverlay) update:self];
			isProcessing = false;
		});
		return false;
	}
	else{
		return true;
	}
}

- (DroneImage*)initWithMidCoordinate:(CLLocationCoordinate2D) midCoordinate andOverlayTopLeftCoordinate:(CLLocationCoordinate2D) overlayTopLeftCoordinate andOverlayTopRightCoordinate:(CLLocationCoordinate2D) overlayTopRightCoordinate andOverlayBottomLeftCoordinate:(CLLocationCoordinate2D) overlayBottomLeftCoordinate bearing:(double) bearing andImage:(UIImage*) image
{
	self = [super init];
	if (self) {
		self.midCoordinate = midCoordinate;
		self.overlayTopLeftCoordinate = overlayTopLeftCoordinate;
		self.overlayTopRightCoordinate = overlayTopRightCoordinate;
		self.overlayBottomLeftCoordinate = overlayBottomLeftCoordinate;
		self.overlayBottomRightCoordinate = CLLocationCoordinate2DMake(overlayBottomLeftCoordinate.latitude, overlayTopRightCoordinate.longitude);
		MKMapPoint topLeft = MKMapPointForCoordinate(overlayTopLeftCoordinate);
		MKMapPoint topRight = MKMapPointForCoordinate(overlayTopRightCoordinate);
		MKMapPoint bottomLeft = MKMapPointForCoordinate(overlayBottomLeftCoordinate);
		self.overlayBoundingMapRect = MKMapRectMake(topLeft.x, topLeft.y, fabs(topLeft.x - topRight.x), fabs(topLeft.y - bottomLeft.y));
		self.bearing = bearing;
		self.image = image;
	}
	return self;
}

@end
