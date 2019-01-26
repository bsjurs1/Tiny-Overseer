//
//  ViewController.m
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "HomeScreenViewController.h"
@interface HomeScreenViewController ()

@end

@implementation HomeScreenViewController

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (IBAction)selectMission:(UIButton *)sender {
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController switchToMissionSelectionView];
	
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	
}


@end
