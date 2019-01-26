//
//  ViewController.h
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#ifndef HOMESCREENVIEWCONTROLLER_H
#define HOMESCREENVIEWCONTROLLER_H
#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "DroneVideoStreamViewController.h"

@interface HomeScreenViewController : UIViewController
@property(weak, nonatomic) UIViewController* parentMapViewController;
@end

#endif
