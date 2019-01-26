//
//  InspectionAreaManager.h
//  Autobot
//
//  Created by Bjarte Sjursen on 20/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#ifndef INSPECTIONAREAMANAGER_H
#define INSPECTIONAREAMANAGER_H

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

// This class is used to manage the coordinates of the waypoints the drone is going to search over.

@interface InspectionAreaManager : NSObject

- (InspectionAreaManager*)initWith:(CLLocationCoordinate2D) startCoordinate and:(CLLocationCoordinate2D) endCoordinate;
- (NSMutableArray<CLLocation*>*) getWaypoints;
-(CLLocation*) getWaypointAtIndex:(int) i;

@end

#endif
