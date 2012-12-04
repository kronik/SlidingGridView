//
//  SlidingGridSpinner.m
//  SlidingGridView
//
//  Created by Dmitry Klimkin on 4/12/12.
//  Copyright (c) 2012 Dmitry Klimkin. All rights reserved.
//

#import "SlidingGridSpinner.h"

@interface SlidingGridSpinner ()

-(void)startRotateAnimation;

@property (nonatomic) float rotationAngle;

@end

@implementation SlidingGridSpinner

@synthesize rotationAngle = _rotationAngle;
@synthesize rotationSpeed = _rotationSpeed;

- (id)init
{
    self = [super init];
    
    if (self)
    {
        // Initialization code
        
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.image = [UIImage imageNamed:@"grid-cell-spinner"];
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.rotationAngle = 0.0f;
        self.rotationSpeed = SPINNER_DEFAULT_ROTATION_SPEED;
        
        [self startRotateAnimation];
    }
    return self;
}

-(void)startRotateAnimation
{
    self.rotationAngle += M_PI / 2.0f;
    
    if(self.rotationAngle == 2.0f * M_PI)
    {
        self.rotationAngle = 0.0f;
    }
    
    if (self.rotationAngle != M_PI / 2.0f)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration: self.rotationSpeed];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        [UIView setAnimationDidStopSelector:@selector(startRotateAnimation)];
        self.transform = CGAffineTransformMakeRotation(self.rotationAngle);
        [UIView commitAnimations];
    }
    else
    {
    }
}

@end
