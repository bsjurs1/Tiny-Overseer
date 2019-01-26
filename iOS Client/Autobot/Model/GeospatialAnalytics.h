//
//  GeospatialAnalytics.h
//  Autobot
//
//  Created by Bjarte Sjursen on 27/05/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>
#import <MapKit/MapKit.h>

@interface GeospatialAnalytics : NSObject
+ (CLLocation*) calculateVincentysDirectWithLatitude:(double) lat longitude: (double) lon distance: (double) distance andBearing: (double) initialBearing;

+ (double) radians:(double) degrees;

+ (double) degrees:(double) radians;

@end
