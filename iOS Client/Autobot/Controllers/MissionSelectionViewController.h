//
//  MissionSelectionViewController.h
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#ifndef MISSIONSELECTIONVIEWCONTROLLER_H
#define MISSIONSELECTIONVIEWCONTROLLER_H
#import <UIKit/UIKit.h>
#import "HomeScreenViewController.h"
#import "MapViewController.h"

@interface MissionSelectionViewController : UIViewController
@property(weak, nonatomic) UIViewController* parentMapViewController;
@end

#endif
