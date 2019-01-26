//
//  DJIAircraftAnnotationView.m
//  Autobot
//
//  Created by Bjarte Sjursen on 16/04/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "DJIAircraftAnnotationView.h"

@implementation DJIAircraftAnnotationView

- (instancetype)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	if (self) {
		self.enabled = NO;
		self.draggable = NO;
		self.image = [UIImage imageNamed:@"aircraft.png"];
	}
	
	return self;
}
-(void) updateHeading:(float)heading
{
	self.transform = CGAffineTransformIdentity;
	self.transform = CGAffineTransformMakeRotation(heading);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
