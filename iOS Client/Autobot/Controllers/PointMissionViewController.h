//
//  PointMissionViewController.h
//  Autobot
//
//  Created by Bjarte Sjursen on 07/06/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface PointMissionViewController : UIViewController <UIGestureRecognizerDelegate>
@property(weak, nonatomic) UIViewController* parentMapViewController;
@end
