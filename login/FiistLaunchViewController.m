//
//  FiistLaunchViewController.m
//  BANJIA
//
//  Created by TeekerZW on 4/30/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "FiistLaunchViewController.h"
#import "WelcomeViewController.h"
#import "KKNavigationController.h"

@interface FiistLaunchViewController ()<UIScrollViewDelegate>
{
    UIScrollView *showScrollView;
    UIPageControl *showPageControl;
}
@end

@implementation FiistLaunchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBarView.hidden = YES;
    
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 20);
    self.view.backgroundColor = [UIColor blackColor];
    self.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
    
    showScrollView = [[UIScrollView alloc] init];
    showScrollView.delegate = self;
    showScrollView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
    [self.bgView addSubview:showScrollView];
    
    NSArray *showImages = [NSArray arrayWithObjects:@"first",@"sec",@"third", nil];
    for (int i=0 ; i<[showImages count]; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        [imageView setImage:[UIImage imageNamed:[showImages objectAtIndex:i]]];
        [showScrollView addSubview:imageView];
        
        if (i==2)
        {

            imageView.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startBanJia)];
            [imageView addGestureRecognizer:tap];
        }
    }
    showScrollView.pagingEnabled = YES;
    showScrollView.bounces = NO;
    showScrollView.showsHorizontalScrollIndicator = NO;
    showScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*[showImages count]+10, SCREEN_HEIGHT);
    
    showPageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-50, SCREEN_HEIGHT-80, 100, 30)];
    showPageControl.backgroundColor = [UIColor clearColor];
    showPageControl.currentPage = 0;
    showPageControl.numberOfPages = [showImages count];
    showPageControl.pageIndicatorTintColor = [UIColor grayColor];
    showPageControl.currentPageIndicatorTintColor = [UIColor redColor];
    [self.bgView addSubview:showPageControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    showPageControl.currentPage = scrollView.contentOffset.x/SCREEN_WIDTH;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > SCREEN_WIDTH*2)
    {
        WelcomeViewController *welcomeViewCOntroller = [[WelcomeViewController alloc]init];
        KKNavigationController *welNav = [[KKNavigationController alloc] initWithRootViewController:welcomeViewCOntroller];
        
        [self.navigationController presentViewController:welNav animated:YES completion:nil];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"first" forKey:@"first"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

-(void)startBanJia
{
    WelcomeViewController *welcomeViewCOntroller = [[WelcomeViewController alloc]init];
    KKNavigationController *welNav = [[KKNavigationController alloc] initWithRootViewController:welcomeViewCOntroller];
    [self.navigationController presentViewController:welNav animated:YES completion:nil];
    
    [[NSUserDefaults standardUserDefaults] setObject:@"first" forKey:@"first"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
