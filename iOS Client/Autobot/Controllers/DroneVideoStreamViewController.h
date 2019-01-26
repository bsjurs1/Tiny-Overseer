//
//  DroneVideoStreamViewController.h
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#ifndef DRONEVIDEOSTREAMVIEWCONTROLLER_H
#define DRONEVIDEOSTREAMVIEWCONTROLLER_H
#import <UIKit/UIKit.h>
#import "DroneManager.h"

@interface DroneVideoStreamViewController : UIViewController
-(void) loadDroneManager:(NSObject*)droneManager;
@end

#endif
