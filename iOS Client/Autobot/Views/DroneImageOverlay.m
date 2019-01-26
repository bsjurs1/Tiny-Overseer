//
//  DroneImageOverlay.m
//  Autobot
//
//  Created by Bjarte Sjursen on 09/06/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "DroneImageOverlay.h"
#import "DroneImageOverlayView.h"
@interface DroneImageOverlay ()
@end

@implementation DroneImageOverlay
- (DroneImageOverlay*)initWithDetection:(DroneImage*) droneImage
{
	self = [super init];
	if (self) {
		self.boundingMapRect = droneImage.overlayBoundingMapRect;
		self.bearing = droneImage.bearing;
		self.coordinate = droneImage.midCoordinate;
		self.image = droneImage.image;
	}
	return self;
}

- (void) update:(DroneImage*) droneImage {
	self.boundingMapRect = droneImage.overlayBoundingMapRect;
	self.bearing = droneImage.bearing;
	self.coordinate = droneImage.midCoordinate;
	self.image = droneImage.image;
	[((DroneImageOverlayView*) self.droneImageOverlayView) updateWith:self];
}

@end
