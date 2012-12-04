//
//  SlidingGridView.h
//  Animations
//
//  Created by Dmitry Klimkin on 21/11/12.
//  Copyright (c) 2012 Dmitry Klimkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlidingGridView;

@protocol SlidingGridViewDelegate <NSObject>

- (void)didSelectViewIn: (SlidingGridView *)controller selectedViewIndex: (int) viewIndex;

@end

@interface SlidingGridView : UIView

@property (nonatomic) BOOL allowRefreshWithShake;
@property (nonatomic) double animationDelayStep;
@property (nonatomic, strong) NSArray *cellSubViews;
@property (nonatomic, strong) UIColor *cellBackgroundColor;
@property (nonatomic, strong) id<SlidingGridViewDelegate> delegate;

@end
