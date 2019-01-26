//
//  ConfigureDroneViewController.h
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#ifndef CONFIGUREDRONEVIEWCONTROLLER_H
#define CONFIGUREDRONEVIEWCONTROLLER_H
#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface ConfigureDroneViewController : UIViewController
@property(weak, nonatomic) UIViewController* parentMapViewController;
@end

#endif
