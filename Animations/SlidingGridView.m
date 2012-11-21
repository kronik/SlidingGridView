//
//  SlidingGridView.m
//  Animations
//
//  Created by Dmitry Klimkin on 21/11/12.
//  Copyright (c) 2012 Dmitry Klimkin. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SlidingGridView.h"

#define CELL_SEPARATOR_WIDTH 20
#define CELL_SEPARATOR_HEIGHT 20
#define CELLS_IN_ROW 3
#define CELLS_IN_COLUMN 3
#define CELLS_COUNT (CELLS_IN_ROW * CELLS_IN_COLUMN - 1) /* 3 rows * 3 columns - 1 (refresh button) */
#define SLIDES_SEPARATOR_SIZE 50
#define ANIMATION_DEFAULT_DELAY_STEP 0.06
#define CELL_IMAGE_BORDER_SIZE 5

@interface SlidingGridView ()

@property (nonatomic) int currentRangeStartIndex;
@property (nonatomic) int animationFinishedViewsCount;
@property (nonatomic) float cellWidth;
@property (nonatomic) float cellHeight;

@end

@implementation SlidingGridView

@synthesize images = _images;
@synthesize currentRangeStartIndex = _currentRangeStartIndex;
@synthesize delegate = _delegate;
@synthesize animationFinishedViewsCount = _animationFinishedViewsCount;
@synthesize cellHeight = _cellHeight;
@synthesize cellWidth = _cellWidth;
@synthesize animationDelayStep = _animationDelayStep;
@synthesize cellBackgroundColor = _cellBackgroundColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self != nil)
    {
        self.cellWidth = (self.frame.size.width - CELL_SEPARATOR_WIDTH * 3) / CELLS_IN_ROW;
        self.cellHeight = self.cellWidth;
        
        self.animationDelayStep = ANIMATION_DEFAULT_DELAY_STEP;
        self.cellBackgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setShadowForView: (UIView*)view
{
    view.layer.shadowColor = [UIColor grayColor].CGColor;
    view.layer.shadowOpacity = 8.0;
    view.layer.shadowRadius = 3;
    view.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
}

-(void)setCornerForView: (UIView*)view
{
    view.layer.cornerRadius = 10;
    view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    view.layer.borderWidth = 0.5f;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    self.cellWidth = (self.frame.size.width - CELL_SEPARATOR_WIDTH * 3) / CELLS_IN_ROW;
    self.cellHeight = self.cellWidth;
}

- (void) setImages:(NSArray *)images
{
    _images = images;
    
    self.currentRangeStartIndex = 0;
    [self initUI];
}

- (UIImage *)getNextImage
{
    UIImage *image = nil;
    
    self.currentRangeStartIndex %=  self.images.count;
    
    image = self.images [self.currentRangeStartIndex];
    
    self.currentRangeStartIndex++;
    
    return image;
}

- (NSArray *)getNextSlideViews
{
    NSMutableArray *views = [[NSMutableArray alloc] init];
    
    for (int i=0; i<CELLS_COUNT; i++)
    {
        UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.cellWidth, self.cellHeight)];
        view.center = CGPointMake(self.cellWidth / 2, -((self.cellHeight / 2) + SLIDES_SEPARATOR_SIZE));
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage: [self getNextImage]];
        imageView.frame = CGRectMake(CELL_IMAGE_BORDER_SIZE, CELL_IMAGE_BORDER_SIZE, self.cellWidth - (CELL_IMAGE_BORDER_SIZE * 2), self.cellHeight - (CELL_IMAGE_BORDER_SIZE * 2));
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [view addSubview:imageView];
        [view layoutSubviews];
        
        [views addObject:view];
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
    float xPosition = CELL_SEPARATOR_WIDTH / 2;
    float yPosition = CELL_SEPARATOR_WIDTH / 2;
    
    for (int i=0; i<CELLS_COUNT; i++)
    {
        UIView *shadowContainer = [[UIView alloc] initWithFrame: CGRectMake(xPosition, yPosition, self.cellWidth, self.cellHeight)];
        shadowContainer.backgroundColor = self.cellBackgroundColor;
        
        [self setShadowForView: shadowContainer];
        [self setCornerForView: shadowContainer];
        
        [self addSubview: shadowContainer];
        
        /* Create containers */
        UIView *animContainer = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.cellWidth, self.cellHeight)];
        
        animContainer.clipsToBounds = YES;
        animContainer.backgroundColor = self.cellBackgroundColor;
        
        [self setCornerForView: animContainer];
        
        [shadowContainer addSubview:animContainer];
        
        UIView *subView = views[i];
        subView.center = CGPointMake(self.cellWidth / 2, self.cellHeight / 2);
        
        [animContainer addSubview: subView];
        
        
        if (((i + 1) % CELLS_IN_ROW) == 0)
        {
            // Reset xPosition for next row
            xPosition = CELL_SEPARATOR_WIDTH / 2;
            
            if (((i + 1.0) / CELLS_IN_ROW) > 0)
            {
                // Increase yPosition
                yPosition += self.cellHeight + CELL_SEPARATOR_HEIGHT;
            }
        }
        else
        {
            // Same row
            xPosition += self.cellWidth + CELL_SEPARATOR_WIDTH;
        }
    }
    
    UIButton *refreshButton = [UIButton buttonWithType: UIButtonTypeCustom];
    refreshButton.frame = CGRectMake(xPosition, yPosition, self.cellWidth, self.cellHeight);
    
    refreshButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    refreshButton.titleLabel.font = [UIFont systemFontOfSize:16.0f];
    refreshButton.backgroundColor = [UIColor clearColor];
    
    [refreshButton setTitle: NSLocalizedString(@"Refresh", nil) forState: UIControlStateNormal];
    [refreshButton setTitle: NSLocalizedString(@"Refresh", nil) forState: UIControlStateSelected];
    [refreshButton setTitleColor:[UIColor grayColor] forState: UIControlStateNormal];
    [refreshButton setTitleColor:[UIColor grayColor] forState: UIControlStateSelected];
    [refreshButton setBackgroundImage:[UIImage imageNamed:@"refresh"] forState: UIControlStateNormal];
    [refreshButton setBackgroundImage:[UIImage imageNamed:@"refresh_h"] forState: UIControlStateSelected];
    [refreshButton setBackgroundImage:[UIImage imageNamed:@"refresh_h"] forState: UIControlStateHighlighted];
    
    [refreshButton addTarget:self action:@selector(refreshButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    [self setShadowForView: refreshButton];
    [self setCornerForView: refreshButton];
    
    [self addSubview:refreshButton];
}

- (void)refreshButtonTap: (UIButton *)sender
{
    @synchronized(self)
    {
        if ((self.animationFinishedViewsCount > 0) && (self.animationFinishedViewsCount != CELLS_COUNT))
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
                           [animContainer addSubview: views[i]];
                           
                           UIView *slide1View = animContainer.subviews[0];
                           UIView *slide2View = views[i];
                           
                           [UIView animateWithDuration:(0.5)
                                            animations:^
                            {
                                slide1View.center = CGPointMake(self.cellWidth / 2, self.cellHeight + SLIDES_SEPARATOR_SIZE);
                                slide2View.center = CGPointMake(self.cellWidth / 2, self.cellHeight / 2);
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UIView *touchedView = [touches.anyObject view];
    
    if ([touchedView isKindOfClass:[UIImageView class]])
    {
        UIImage *image = ((UIImageView*)touchedView).image;
        
        for (int i=0; i<self.images.count; i++)
        {
            if (image == self.images[i])
            {
                [self.delegate didSelectViewIn:self selectedViewIndex: i];
                break;
            }
        }
    }
}

@end
