//
//  GeospatialAnalytics.m
//  Autobot
//
//  Created by Bjarte Sjursen on 27/05/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "GeospatialAnalytics.h"

@implementation GeospatialAnalytics

+ (double) radians:(double) degrees {
	return degrees * (M_PI / 180.0);
}

+ (double) degrees:(double) radians {
	return radians * (180 / M_PI);
}

+ (CLLocation*) calculateVincentysDirectWithLatitude:(double) lat longitude: (double) lon distance: (double) distance andBearing: (double) initialBearing {
	
	const double φ1 = [GeospatialAnalytics radians:lat];
	const double λ1 = [GeospatialAnalytics radians:lon];
	const double α1 = [GeospatialAnalytics radians:initialBearing];
	const double s = distance;
	
	const double a = 6378137.0;
	const double b = 6356752.314245;
	const double f = 0.0033528106647756;
	
	const double sinα1 = sin(α1);
	const double cosα1 = cos(α1);
	
	const double tanU1 = (1 - f) * tan(φ1);
	const double cosU1 = 1.0 / sqrt((1 + tanU1*tanU1));
	const double sinU1 = tanU1 * cosU1;
	
	const double σ1 = atan2(tanU1, cosα1);
	const double sinα = cosU1 * sinα1;
	const double cosSqα = 1 - sinα*sinα;
	const double uSq = cosSqα * (a*a - b*b) / (b*b);
	const double A = 1 + uSq/16384*(4096+uSq*(-768+uSq*(320-175*uSq)));
	const double B = uSq/1024 * (256+uSq*(-128+uSq*(74-47*uSq)));
	
	double cos2σM, sinσ, cosσ, Δσ;
	
	double σ = s / (b*A);
	double σʹ;
	int iterations = 0;
	
	do{
		cos2σM = cos(2*σ1 + σ);
		sinσ = sin(σ);
		cosσ = cos(σ);
		Δσ = B*sinσ*(cos2σM+B/4*(cosσ*(-1+2*cos2σM*cos2σM) - B/6*cos2σM*(-3+4*sinσ*sinσ)*(-3+4*cos2σM*cos2σM)));
		σʹ = σ;
		σ = s / (b*A) + Δσ;
		iterations += 1;
	}while(fabs(σ-σʹ) > 1e-12 && iterations < 100);
	
	double x = sinU1*sinσ - cosU1*cosσ*cosα1;
	double φ2 = atan2(sinU1*cosσ + cosU1*sinσ*cosα1, (1-f)*sqrt(sinα*sinα + x*x));
	double λ = atan2(sinσ*sinα1, cosU1*cosσ - sinU1*sinσ*cosα1);
	double C = f/16*cosSqα*(4+f*(4-3*cosSqα));
	double L = λ - (1-C) * f * sinα * (σ + C*sinσ*(cos2σM+C*cosσ*(-1+2*cos2σM*cos2σM)));
	double λ2 = fmod((λ1 + L+3 * M_PI), (2*M_PI)) - M_PI;  // normalise to -180..+180
	double α2 = atan2(sinα, -x);
	α2 = fmod((α2 + 2*M_PI), (2*M_PI)); // normalise to 0..360
	
	double calculatedLatiude = [GeospatialAnalytics degrees:φ2];
	double calculatedLongitude = [GeospatialAnalytics degrees:λ2];
	
	CLLocation* location = [[CLLocation alloc] initWithLatitude:calculatedLatiude
													  longitude:calculatedLongitude];
	return location;
}

@end
