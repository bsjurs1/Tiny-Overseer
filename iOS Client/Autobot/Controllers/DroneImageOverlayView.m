
//
//  DroneImageOverlayView.m
//  
//
//  Created by Bjarte Sjursen on 09/06/2018.
//

#import "DroneImageOverlayView.h"
@interface DroneImageOverlayView()
@property UIImage* overlayImage;
@property double bearing;
@property DroneImageOverlay* droneImageOverlay;
@end
@implementation DroneImageOverlayView

-(void) drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {
	dispatch_sync(dispatch_get_main_queue(), ^{
		CGImageRef imageReference = self.overlayImage.CGImage;
		CGRect rect = [super rectForMapRect: self.droneImageOverlay.boundingMapRect];
		CGContextTranslateCTM(context, 0.5*rect.size.width, 0.5*rect.size.height);
		CGContextRotateCTM(context, self.bearing);
		CGContextScaleCTM(context, 1.0, -1.0);
		CGContextTranslateCTM(context, -0.5*rect.size.width, -0.5*rect.size.height);
		CGContextDrawImage(context, rect, imageReference);
	});
}

- (DroneImageOverlayView*)initWithOverlay:(id<MKOverlay>) overlay
{
	self = [super initWithOverlay:overlay];
	if(self){
		self.droneImageOverlay = (DroneImageOverlay*) overlay;
		self.overlayImage = self.droneImageOverlay.image;
		self.bearing = self.droneImageOverlay.bearing;
		self.droneImageOverlay.droneImageOverlayView = self;
	}
	return self;
}

- (void) updateWith:(DroneImageOverlay*) droneImageOverlay {
	self.droneImageOverlay = droneImageOverlay;
	self.overlayImage = droneImageOverlay.image;
	self.bearing = droneImageOverlay.bearing;
	//[self setNeedsDisplay];
}

@end
