//
//  ViewController.m
//  Animations
//
//  Created by Dmitry Klimkin on 20/11/12.
//  Copyright (c) 2012 Dmitry Klimkin. All rights reserved.
//

#import "ViewController.h"
#import "SlidingGridView.h"

@interface ViewController () <SlidingGridViewDelegate>

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) SlidingGridView *slideController;

@end

@implementation ViewController

@synthesize images = _images;
@synthesize slideController = _slideController;

- (SlidingGridView*)slideController
{
    if (_slideController == nil)
    {
        _slideController = [[SlidingGridView alloc] initWithFrame:CGRectMake(10, 10, 300, 300)];
        _slideController.backgroundColor = [UIColor whiteColor];
        _slideController.delegate = self;
        [self.view addSubview: _slideController];
    }
    return _slideController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib
    
    NSMutableArray *imgs = [[NSMutableArray alloc] init];
    
    for (int i=1; i<22; i++)
    {
        NSString *imageName = [NSString stringWithFormat:@"%d", i];
        UIImage *img = [UIImage imageNamed:imageName];
        
        [imgs addObject: img];
    }
    
    _images = imgs;
    
    self.slideController.images = imgs;
}

- (void)didSelectViewIn:(SlidingGridView *)controller selectedViewIndex:(int)viewIndex
{
    NSLog (@"Selected image idx: %d", viewIndex);
}

@end
