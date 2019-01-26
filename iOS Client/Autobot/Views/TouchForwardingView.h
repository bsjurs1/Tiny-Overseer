//
//  TouchForwardingView.h
//  Autobot
//
//  Created by Bjarte Sjursen on 19/03/2018.
//  Copyright © 2018 Bjarte Sjursen. All rights reserved.
//
#ifndef TOUCHFORWARDINGVIEW_H
#define TOUCHFORWARDINGVIEW_H

#import <UIKit/UIKit.h>

@interface TouchForwardingView : UIView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event;

@end

#endif
