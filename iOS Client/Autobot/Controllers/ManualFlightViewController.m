//
//  ManualFlightViewController.m
//  Autobot
//
//  Created by Bjarte Sjursen on 07/06/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "ManualFlightViewController.h"

@interface ManualFlightViewController ()
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation ManualFlightViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = UIColor.clearColor;
    // Do any additional setup after loading the view.
}

- (IBAction)cancel:(UIButton *)sender {
	
	[self removeFromParentViewController];
	[self.view removeFromSuperview];
	MapViewController* mapViewController = (MapViewController*) self.parentMapViewController;
	[mapViewController switchToMissionSelectionView];
	
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
