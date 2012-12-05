//
//  ViewController1.m
//  Animations
//
//  Created by Dmitry Klimkin on 20/11/12.
//  Copyright (c) 2012 Dmitry Klimkin. All rights reserved.
//

#import "ViewController1.h"
#import "SlidingGridView.h"

@interface ViewController1 () <SlidingGridViewDelegate>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) SlidingGridView *slideController;

@end

@implementation ViewController1

@synthesize images = _images;
@synthesize slideController = _slideController;

- (SlidingGridView*)slideController
{
    if (_slideController == nil)
    {
        _slideController = [[SlidingGridView alloc] initWithFrame:CGRectMake(10, 0, 300, 430)];
        _slideController.backgroundColor = [UIColor clearColor];
        _slideController.delegate = self;
        _slideController.cellBackgroundColor = [UIColor darkGrayColor];

        [self.view addSubview: _slideController];
    }
    return _slideController;
}

- (void)viewDidLoad
{
    self.navigationItem.title = @"Sliding Grid View";
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib
    
    //self.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.jpg"]];
   
    NSMutableArray *imgs = [[NSMutableArray alloc] init];
    
    for (int i=1; i<41; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"%d", i];
        UIImage *img = [UIImage imageNamed:imageName];
        UIImageView *imgView = [[UIImageView alloc] initWithImage: img];
        [imgs addObject: imgView];
    }
    
    self.images = imgs;
    
    self.slideController.allowRefreshWithShake = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self performSelector:@selector(setLoadedImages) withObject:nil afterDelay:2.0f];
}

- (void) setLoadedImages
{
    self.slideController.cellSubViews = self.images;
}

- (void)didSelectViewIn:(SlidingGridView *)controller selectedViewIndex:(int)viewIndex
{
    NSLog (@"Selected image idx: %d", viewIndex);
}

@end
