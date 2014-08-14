//
//  XDTabViewController.m
//  XDCommonApp
//
//  Created by  on 13-6-5.
//  Copyright (c) 2013年 xin wang. All rights reserved.
//

#import "XDTabViewController.h"
#import "Header.h"

#define SELECTED_VIEW_CONTROLLER_TAG 98456345

@interface XDTabViewController ()
{
    NSString *classID;
}
@end

@implementation XDTabViewController
@synthesize label0,label1,label2,label3;
static XDTabViewController *_tabViewController = nil;
+(XDTabViewController *)sharedTabViewController
{
    @synchronized(self)
    {
        if (_tabViewController == nil)
        {
            _tabViewController = [[XDTabViewController alloc] init];
        }
    }
    return _tabViewController;
}


- (void)selectItemAtIndex:(NSInteger)index {
    [self touchDownAtItemAtIndex:index];
}

- (void)setTabBarHidden:(BOOL)isHidden
{
    [_tabBar setHidden:isHidden];
}

#pragma -mark View Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tabBar = [[XDTabBar alloc] initWithItemCount:self.tabBarContents.count
                                             itemSize:CGSizeMake(SCREEN_WIDTH / self.tabBarContents.count, UI_TAB_BAR_HEIGHT)
                                                  tag:0
                                             delegate:self];
    
    self.tabBar.frame = CGRectMake(0,0,UI_SCREEN_WIDTH,SCREEN_HEIGHT);
    self.tabBar.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:_tabBar];
    

    label0 = [[UILabel alloc] initWithFrame:CGRectMake(50, SCREEN_HEIGHT-50, 20, 20)];
    label0.layer.cornerRadius = 10;
    label0.clipsToBounds = YES;
    label0.hidden = YES;
    label0.font = [UIFont systemFontOfSize:12];
    label0.textColor = [UIColor whiteColor];
    label0.textAlignment = NSTextAlignmentCenter;
    label0.backgroundColor = [UIColor redColor];
    [self.bgView addSubview:label0];
    
    label1 = [[UILabel alloc] initWithFrame:CGRectMake(140, SCREEN_HEIGHT-50, 20, 20)];
    label1.layer.cornerRadius = 10;
    label1.clipsToBounds = YES;
    label1.hidden = YES;
    label1.font = [UIFont systemFontOfSize:12];
    label1.textColor = [UIColor whiteColor];
    label1.textAlignment = NSTextAlignmentCenter;
    label1.backgroundColor = [UIColor redColor];
    [self.bgView addSubview:label1];
    
    label2 = [[UILabel alloc] initWithFrame:CGRectMake(210, SCREEN_HEIGHT-50, 20, 20)];
    label2.layer.cornerRadius = 10;
    label2.clipsToBounds = YES;
    label2.hidden = YES;
    label2.font = [UIFont systemFontOfSize:12];
    label2.textColor = [UIColor whiteColor];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.backgroundColor = [UIColor redColor];
    [self.bgView addSubview:label2];
    
    label3 = [[UILabel alloc] initWithFrame:CGRectMake(290, SCREEN_HEIGHT-50, 20, 20)];
    label3.layer.cornerRadius = 10;
    label3.clipsToBounds = YES;
    label3.hidden = YES;
    label3.font = [UIFont systemFontOfSize:12];
    label3.textColor = [UIColor whiteColor];
    label3.textAlignment = NSTextAlignmentCenter;
    label3.backgroundColor = [UIColor redColor];
    [self.bgView addSubview:label3];
    
    [self selectItemAtIndex:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self selectItemAtIndex:_preItemIndex];
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    OperatDB *db = [[OperatDB alloc] init];
    int newNoticeNum = [[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-notice",classID]] integerValue];
    if (newNoticeNum > 0)
    {
        [XDTabViewController sharedTabViewController].label1.hidden = NO;
        [XDTabViewController sharedTabViewController].label1.text = [NSString stringWithFormat:@"%d",newNoticeNum];
    }
    else
    {
        [XDTabViewController sharedTabViewController].label1.hidden = YES;
    }
    
    NSArray *newApplyArray = [db findSetWithDictionary:@{@"classid":classID,@"checked":@"0"} andTableName:CLASSMEMBERTABLE];
    if ([newApplyArray count] > 0)
    {
        [XDTabViewController sharedTabViewController].label2.hidden = NO;
        [XDTabViewController sharedTabViewController].label2.text = [NSString stringWithFormat:@"%lu",[newApplyArray count]];
    }
    else
    {
        [XDTabViewController sharedTabViewController].label2.hidden = YES;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self setTabBar:nil];
    [self setTabBarContents:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - YCTabBarDelegate

- (UIImage*)imageFor:(XDTabBar*)tabBar atIndex:(NSUInteger)itemIndex {
    NSArray *images = [NSArray arrayWithObjects:
                       @"1-2",
                       @"2-2", @"3-2", @"4-2",
                       nil];

    return [UIImage imageNamed:[images objectAtIndex:itemIndex]];
}

- (UIImage*)hightlightedImageFor:(XDTabBar*)tabBar atIndex:(NSUInteger)itemIndex {
    NSArray *images = [NSArray arrayWithObjects:
                       @"1",
                       @"2", @"3", @"4",
                       nil];

    return [UIImage imageNamed:[images objectAtIndex:itemIndex]];
}

- (UIImage *)backgroundImage {
    return [UIImage imageNamed:@"footer_box_bg"];
}

- (UIImage *)selectedItemBackgroundImage {
     return nil;
}

- (UIImage *)selectedItemImage {
     return nil;
}

- (UIImage *)tabBarArrowImage {
    return nil;
}


- (void)touchDownAtItemAtIndex:(NSUInteger)itemIndex {
    UIView* currentView = [self.tabBar viewWithTag:SELECTED_VIEW_CONTROLLER_TAG];
    [currentView removeFromSuperview];
    
    self.preItemIndex = itemIndex;
    XDContentViewController* viewController = [_tabBarContents objectAtIndex:itemIndex];
    viewController.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - UI_TAB_BAR_HEIGHT);
    viewController.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - UI_TAB_BAR_HEIGHT);
    viewController.view.backgroundColor = [UIColor blackColor];
    viewController.bgView.backgroundColor = [UIColor whiteColor];
    viewController.view.tag = SELECTED_VIEW_CONTROLLER_TAG;
    [self.tabBar insertSubview:viewController.view belowSubview:_tabBar];

    [_tabBar selectItemAtIndex:itemIndex];
}


- (void)touchUpInsideItemAtIndex:(NSUInteger)itemIndex
{
    [_tabBar selectItemAtIndex:itemIndex];
}
@end
