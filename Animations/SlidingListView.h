//
//  SlidingListView.h
//  Animations
//
//  Created by Dmitry Klimkin on 21/11/12.
//  Copyright (c) 2012 Dmitry Klimkin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SlidingListView;

@protocol SlidingListViewDelegate <NSObject>

- (void)didSelectCellIn: (SlidingListView *)controller selectedCellIndex: (int) cellIndex;

@end

@interface SlidingListView : UIView

+ (UIView *) getSlidingListViewWithText: (NSString*)text image: (UIImage *)image description: (NSString*)description;
+ (void) updateImageForCell: (UIView *)cellView imageToUpdate: (UIImage *)image;

@property (nonatomic) BOOL allowRefreshWithShake;
@property (nonatomic) double animationDelayStep;
@property (nonatomic, strong) NSArray *cellSubViews;
@property (nonatomic, strong) id<SlidingListViewDelegate> delegate;

@end
