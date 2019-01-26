//
//  MissionSelectionViewController.m
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "MissionSelectionViewController.h"

@interface MissionSelectionViewController ()
@end

@implementation MissionSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor clearColor];
	UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
	UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
	//always fill the view
	blurEffectView.frame = self.view.bounds;
	blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:blurEffectView];
	[self.view sendSubviewToBack:blurEffectView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)cancelMissionSelection:(UIButton*)sender {
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController switchToHomeScreenView];
}

- (IBAction)switchToAreaSearch:(UIButton *)sender {
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController switchToAreaSearchView];
}

- (IBAction)switchToManualFlightView:(UIButton *)sender {
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController switchToManualFlightView];
}

- (IBAction)switchToPointMissionView:(UIButton *)sender {
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController switchToPointMissionView];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
