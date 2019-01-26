//
//  DJIAircraftAnnotation.h
//  Autobot
//
//  Created by Bjarte Sjursen on 16/04/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "DJIAircraftAnnotationView.h"

@interface DJIAircraftAnnotation : NSObject<MKAnnotation>
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property(nonatomic, weak) DJIAircraftAnnotationView* annotationView;
-(id) initWithCoordiante:(CLLocationCoordinate2D)coordinate;
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;
-(void) updateHeading:(float)heading;
@end
