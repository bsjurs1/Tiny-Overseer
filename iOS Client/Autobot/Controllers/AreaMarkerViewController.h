//
//  AreaMarkerViewController.h
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//
#ifndef AREAMARKERVIEWCONTROLLER_H
#define AREAMARKERVIEWCONTROLLER_H
#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "InspectionAreaManager.h"

@interface AreaMarkerViewController : UIViewController
@property(weak, nonatomic) UIViewController* parentMapViewController;
@end

#endif
