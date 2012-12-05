//
//  ViewController2.m
//  Animations
//
//  Created by Dmitry Klimkin on 20/11/12.
//  Copyright (c) 2012 Dmitry Klimkin. All rights reserved.
//

#import "ViewController2.h"
#import "SlidingListView.h"

@interface ViewController2 () <SlidingListViewDelegate>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) SlidingListView *slideController;

@end

@implementation ViewController2

@synthesize images = _images;
@synthesize slideController = _slideController;

- (SlidingListView*)slideController
{
    if (_slideController == nil)
    {
        _slideController = [[SlidingListView alloc] initWithFrame:CGRectMake(0, 0, 320, 430)];
        _slideController.backgroundColor = [UIColor clearColor];
        _slideController.delegate = self;
        _slideController.backgroundColor = [UIColor colorWithPatternImage: [UIImage imageNamed:@"bg.jpg"]];

        [self.view addSubview: _slideController];
    }
    return _slideController;
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"Sliding List View";

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.slideController.allowRefreshWithShake = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(setLoadedImages) withObject:nil afterDelay:2.0f];
}

- (void) setLoadedImages
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    
    for (int i=1; i<41; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"%d", i];
        UIImage *img = [UIImage imageNamed:imageName];
     
        UIView *cell = [SlidingListView getSlidingListViewWithText:[NSString stringWithFormat:@"Title: %d", i] image:img description:[NSString stringWithFormat:@"Subtitle: %@", imageName]];
        
        [items addObject:cell];
    }
    
    self.images = items;
        
    self.slideController.cellSubViews = self.images;
}

- (void)didSelectCellIn:(SlidingListView *)controller selectedCellIndex:(int)cellIndex
{
    NSLog (@"Selected image idx: %d", cellIndex);
}

@end
