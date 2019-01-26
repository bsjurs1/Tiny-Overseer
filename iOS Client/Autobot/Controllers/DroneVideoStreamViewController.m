//
//  DroneVideoStreamViewController.m
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "DroneVideoStreamViewController.h"

@interface DroneVideoStreamViewController ()
@property DroneManager* droneManager;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *captureButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *changeWorkModeSegmentedControl;
@end
@implementation DroneVideoStreamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.view.backgroundColor = [UIColor blackColor];
}

-(void) loadDroneManager:(NSObject*) droneManager {
	DroneManager* inputDroneManager = (DroneManager*) droneManager;
	self.droneManager = inputDroneManager;
	[self.droneManager setupVideoPreviewer: self.view];
}

-(void) viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	if(self.droneManager == nil){
		[self.droneManager setupVideoPreviewer:self.view];
	}
}

-(void) viewWillDisappear:(BOOL)animated{
	[super viewWillDisappear:animated];
	if(self.droneManager != nil){
		[self.droneManager resetVideoPreview];
	}
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	
}

- (IBAction)captureAction:(id)sender {
	
}

- (IBAction)recordAction:(id)sender {
	
}

- (IBAction)changeWorkModeAction:(id)sender {
	
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
