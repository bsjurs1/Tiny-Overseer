//
//  DJIAircraftAnnotationView.h
//  Autobot
//
//  Created by Bjarte Sjursen on 16/04/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface DJIAircraftAnnotationView : MKAnnotationView
-(void) updateHeading:(float)heading;
@end
