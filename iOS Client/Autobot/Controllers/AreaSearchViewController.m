//
//  AreaSearchViewController.m
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "AreaSearchViewController.h"

@interface AreaSearchViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startMissionButton;

@end

@implementation AreaSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated {
}

- (IBAction)startMission:(UIButton *)sender {
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController startMission];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchToMissionSelectionView:(UIButton *)sender {
	
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController switchToMissionSelectionView];
	
}

- (IBAction) switchToAreaMarkerView:(UIButton *)sender {
	
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController switchToAreaMarkerView];
	
}

- (IBAction)switchToConfigurationScreen:(UIButton *)sender {
	
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController switchToConfigurationView];
	
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
