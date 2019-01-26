//
//  TouchForwardingView.m
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//

#import "TouchForwardingView.h"

@implementation TouchForwardingView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	for (UIView* subview in self.subviews ) {
		if ( [subview hitTest:[self convertPoint:point toView:subview] withEvent:event] != nil ) {
			return YES;
		}
	}
	return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
