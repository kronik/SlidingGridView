//
//  SlidingListView.m
//  Animations
//
//  Created by Dmitry Klimkin on 21/11/12.
//  Copyright (c) 2012 Dmitry Klimkin. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SlidingListView.h"
#import "SlidingGridSpinner.h"

#define CELLS_IN_COLUMN 6
#define CELLS_COUNT (CELLS_IN_COLUMN - 1) /* 6 cells - 1 (refresh button) */
#define ANIMATION_DEFAULT_DELAY_STEP 0.06
#define USE_CUSTOM_SPINNER NO

#define CELL_VIEW_WIDTH 300.0f
#define CELL_VIEW_HEIGHT 60.0f

#define CELL_X_SHIFT 10.0f
#define CELL_Y_SHIFT 10.0f

#define CELL_AVATAR_VIEW_TAG  1000
#define CELL_TEXT_VIEW_TAG    1001
#define CELL_SUBTEXT_VIEW_TAG 1002

static BOOL L0AccelerationIsShaking(UIAcceleration* last, UIAcceleration* current, double threshold)
{
	double
    deltaX = fabs(last.x - current.x),
    deltaY = fabs(last.y - current.y),
    deltaZ = fabs(last.z - current.z);
    
	return
    (deltaX > threshold && deltaY > threshold) ||
    (deltaX > threshold && deltaZ > threshold) ||
    (deltaY > threshold && deltaZ > threshold);
}

@interface SlidingListView () <UIAccelerometerDelegate>

@property (nonatomic) int currentRangeStartIndex;
@property (nonatomic) int animationFinishedViewsCount;
@property (nonatomic, strong) UIAcceleration* lastAcceleration;
@property (nonatomic) BOOL histeresisExcited;
@property (nonatomic, strong) UIButton *refreshButton;

@end

@implementation SlidingListView

@synthesize cellSubViews = _cellSubViews;
@synthesize currentRangeStartIndex = _currentRangeStartIndex;
@synthesize delegate = _delegate;
@synthesize animationFinishedViewsCount = _animationFinishedViewsCount;
@synthesize animationDelayStep = _animationDelayStep;
@synthesize lastAcceleration = _lastAcceleration;
@synthesize histeresisExcited = _histeresisExcited;
@synthesize refreshButton = _refreshButton;

+(void)setShadowForView: (UIView*)view
{
    view.layer.shadowColor = [UIColor grayColor].CGColor;
    view.layer.shadowOpacity = 8.0;
    view.layer.shadowRadius = 3;
    view.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
}

+(void)setCornerForView: (UIView*)view
{
    view.layer.cornerRadius = 10;
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.layer.borderWidth = 0.5f;
}

+ (UIView *) getSlidingListViewWithText: (NSString*)text image: (UIImage *)image description: (NSString*)description
{
    UIButton *cellView = [UIButton buttonWithType: UIButtonTypeCustom];
    
    cellView.frame = CGRectMake(0, 0, CELL_VIEW_WIDTH, CELL_VIEW_HEIGHT);
    
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame: CGRectMake(5, 5, CELL_VIEW_HEIGHT - 10, CELL_VIEW_HEIGHT - 10)];
    
    avatarView.contentMode = UIViewContentModeScaleAspectFit;
    avatarView.image = image;
    avatarView.tag = CELL_AVATAR_VIEW_TAG;

    [cellView addSubview:avatarView];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame: CGRectMake(CELL_VIEW_HEIGHT, 10, 200, (CELL_VIEW_HEIGHT - 10) / 2)];
    
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = text;
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.font = [UIFont boldSystemFontOfSize: 16.0f];
    textLabel.textColor = [UIColor darkGrayColor];
    
    [cellView addSubview: textLabel];
    
    UILabel *subtextLabel = [[UILabel alloc] initWithFrame: CGRectMake(CELL_VIEW_HEIGHT, 5 + (CELL_VIEW_HEIGHT - 10) / 2, 200, (CELL_VIEW_HEIGHT - 10) / 2)];
    
    subtextLabel.backgroundColor = [UIColor clearColor];
    subtextLabel.text = description;
    subtextLabel.textAlignment = NSTextAlignmentLeft;
    subtextLabel.font = [UIFont boldSystemFontOfSize: 12.0f];
    subtextLabel.textColor = [UIColor grayColor];
    
    [cellView addSubview: subtextLabel];
    
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
    
    arrowView.contentMode = UIViewContentModeScaleAspectFit;
    arrowView.center = CGPointMake(280, CELL_VIEW_HEIGHT / 2);
    
    [cellView addSubview:arrowView];
    
    cellView.userInteractionEnabled = YES;

    return cellView;
}

+ (void) updateImageForCell: (UIView *)cellView imageToUpdate: (UIImage *)image
{
    UIImageView *avatarView = (UIImageView *)[cellView viewWithTag: CELL_AVATAR_VIEW_TAG];
    avatarView.image = image;
    
    [avatarView setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil)
    {
        self.animationDelayStep = ANIMATION_DEFAULT_DELAY_STEP;
        self.animationFinishedViewsCount = CELLS_COUNT;
        
        NSMutableArray *loadViews = [[NSMutableArray alloc] init];
        
        for (int i=0; i<CELLS_COUNT; i++)
        {
            if (USE_CUSTOM_SPINNER == NO)
            {
                UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
                
                [activityIndicator startAnimating];
                [loadViews addObject:activityIndicator];
            }
            else
            {
                SlidingGridSpinner *spinner = [[SlidingGridSpinner alloc] init];
                [loadViews addObject:spinner];
            }
        }
        
        _cellSubViews = loadViews;
        self.currentRangeStartIndex = 0;

        [self initUI];
        
        self.allowRefreshWithShake = YES;

    }
    return self;
}

- (void) setAllowRefreshWithShake:(BOOL)allowRefreshWithShake
{
    _allowRefreshWithShake = allowRefreshWithShake;
    
    if (allowRefreshWithShake == YES)
    {
        [UIAccelerometer sharedAccelerometer].delegate = self;
    }
    else
    {
        [UIAccelerometer sharedAccelerometer].delegate = nil;
    }
}

- (void) accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	if (self.lastAcceleration)
    {
		if (!self.histeresisExcited && L0AccelerationIsShaking(self.lastAcceleration, acceleration, 0.7))
        {
			self.histeresisExcited = YES;
            
			/* SHAKE DETECTED. DO HERE WHAT YOU WANT. */
            [self refreshButtonTap: nil];
            
		}
        else if (self.histeresisExcited && !L0AccelerationIsShaking(self.lastAcceleration, acceleration, 0.2))
        {
			self.histeresisExcited = NO;
		}
	}
    
	self.lastAcceleration = acceleration;
}

- (void) setCellSubViews:(NSArray *)cellSubViews
{    
    _cellSubViews = cellSubViews;
    
    self.currentRangeStartIndex = 0;
    
    for (UIView *subView in cellSubViews)
    {
        if ([subView isKindOfClass:[UIButton class]])
        {
            [((UIButton*)subView) addTarget: self action:@selector(cellTouched:) forControlEvents:UIControlEventTouchUpInside];
        }
    }

    [self refreshButtonTap: nil];
}

- (UIView *)getNextCellSubView
{
    UIView *subView = nil;
    
    self.currentRangeStartIndex %=  self.cellSubViews.count;
    
    subView = self.cellSubViews [self.currentRangeStartIndex];
        
    self.currentRangeStartIndex++;
    
    return subView;
}

- (NSArray *)getNextSlideViews
{
    NSMutableArray *views = [[NSMutableArray alloc] init];
    
    for (int i=0; i<CELLS_COUNT; i++)
    {        
        UIView *subView = [self getNextCellSubView];
        
        subView.userInteractionEnabled = YES;
        subView.center = CGPointMake(-CELL_VIEW_WIDTH * 1.5, CELL_VIEW_HEIGHT / 2);

        [views addObject:subView];
    }
    
    return views;
}

- (void)initUI
{
    for (UIView *subView in self.subviews)
    {
        [subView removeFromSuperview];
    }
    
    NSArray *views = [self getNextSlideViews];
    float xPosition = CELL_X_SHIFT;
    float yPosition = CELL_Y_SHIFT;
    
    for (int i=0; i<CELLS_COUNT; i++)
    {
        NSString *bgName = (i == 0) ? @"ipad-list-element" : @"ipad-list-element";
        UIImageView *shadowContainer = [[UIImageView alloc] initWithFrame: CGRectMake(xPosition, yPosition, CELL_VIEW_WIDTH, CELL_VIEW_HEIGHT)];
        shadowContainer.image = [UIImage imageNamed:bgName];
        shadowContainer.userInteractionEnabled = YES;
        
        [self addSubview: shadowContainer];
        
        /* Create containers */
        UIView *animContainer = [[UIView alloc] initWithFrame: CGRectMake(0, 0, CELL_VIEW_WIDTH, CELL_VIEW_HEIGHT)];
        
        animContainer.clipsToBounds = YES;
        animContainer.backgroundColor = [UIColor clearColor];
        animContainer.userInteractionEnabled = YES;

        [shadowContainer addSubview:animContainer];
        
        UIView *subView = views[i];
        subView.center = CGPointMake(CELL_VIEW_WIDTH / 2, CELL_VIEW_HEIGHT / 2);
        
        [animContainer addSubview: subView];

        // Increase yPosition
        yPosition += CELL_VIEW_HEIGHT;
    }
    
    self.refreshButton = [UIButton buttonWithType: UIButtonTypeCustom];
    self.refreshButton.frame = CGRectMake(xPosition, yPosition, CELL_VIEW_WIDTH, CELL_VIEW_HEIGHT);
    
    self.refreshButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.refreshButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    self.refreshButton.backgroundColor = [UIColor clearColor];
    
    [self.refreshButton setTitle: NSLocalizedString(@"Refresh", nil) forState: UIControlStateNormal];
    [self.refreshButton setTitle: NSLocalizedString(@"Refresh", nil) forState: UIControlStateSelected];
    [self.refreshButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
    [self.refreshButton setTitleColor:[UIColor darkGrayColor] forState: UIControlStateSelected];
    [self.refreshButton setBackgroundImage:[UIImage imageNamed:@"ipad-list-item-selected"] forState: UIControlStateNormal];
    [self.refreshButton setBackgroundImage:[UIImage imageNamed:@"tabbar"] forState: UIControlStateSelected];
    [self.refreshButton setBackgroundImage:[UIImage imageNamed:@"tabbar"] forState: UIControlStateHighlighted];
    
    [self.refreshButton addTarget:self action:@selector(refreshButtonTap:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.refreshButton];
}

- (void)refreshButtonTap: (UIButton *)sender
{
    if ((self.refreshButton.hidden == YES) || (self.cellSubViews.count <= CELLS_COUNT))
    {
        return;
    }

    @synchronized(self)
    {
        if (self.animationFinishedViewsCount != CELLS_COUNT)
        {
            return;
        }
        self.animationFinishedViewsCount = 0;
    }

    NSArray *views = [self getNextSlideViews];
    
    for (int i=0; i<CELLS_COUNT; i++)
    {
        double delayInSeconds = self.animationDelayStep * i;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                       {
                           /* Add new slide */
                           UIView *animContainer = ((UIView*)self.subviews[i]).subviews[0];
                           UIView *slide2View = views[i];

                           [animContainer addSubview: slide2View];
                           
                           UIView *slide1View = animContainer.subviews[0];
                           
                           [UIView animateWithDuration:(0.5)
                                            animations:^
                            {
                                slide1View.center = CGPointMake(CELL_VIEW_WIDTH * 1.5, CELL_VIEW_HEIGHT / 2);
                                slide2View.center = CGPointMake(CELL_VIEW_WIDTH / 2, CELL_VIEW_HEIGHT / 2);
                                
                            }
                                            completion:^(BOOL finished)
                            {
                                [slide1View removeFromSuperview];

                                @synchronized(self)
                                {
                                    self.animationFinishedViewsCount ++;
                                }
                            }];
                       });
    }
}

- (void)cellTouched: (UIButton*) sender
{
    for (int i=0; i<self.cellSubViews.count; i++)
    {
        if (sender == self.cellSubViews[i])
        {
            [self.delegate didSelectCellIn:self selectedCellIndex: i];
            break;
        }
    }
}

@end
