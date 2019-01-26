//
//  DroneImageOverlayView.h
//  
//
//  Created by Bjarte Sjursen on 09/06/2018.
//

#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DroneImageOverlay.h"

@interface DroneImageOverlayView : MKOverlayRenderer
- (DroneImageOverlayView*)initWithOverlay:(id<MKOverlay>) overlay;
- (void) updateWith:(DroneImageOverlay*) droneImageOverlay;
@end
