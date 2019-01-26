//
//  ConfigureDroneViewController.m
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "ConfigureDroneViewController.h"

@interface ConfigureDroneViewController ()

@end

@implementation ConfigureDroneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelConfigurationView:(UIButton *)sender {
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController switchToAreaSearchView];
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
