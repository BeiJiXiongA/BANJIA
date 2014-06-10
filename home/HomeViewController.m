//
//  HomeViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-5-31.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "HomeViewController.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDOverlayView.h"
#import "KKNavigationController.h"
#import "KKNavigationController+JDSideMenu.h"
#import "UINavigationController+JDSideMenu.h"
#import "PopView.h"
#import "DemoVIew.h"

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL navOpen;
    PopView *navView;
    
    BOOL addOpen;
    PopView *addView;
    UIButton *addNoticeButton;
    UIButton *addDiaryButton;
    
    DemoVIew *demoView;
    
    
    UITapGestureRecognizer *tapTgr;
    
    UITableView *classTableView;
    
    UIImageView *navImageView;
    
    
}
@end

@implementation HomeViewController

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
    
    self.backButton.hidden = YES;
    self.returnImageView.hidden = YES;
    self.titleLabel.text = @"我的班级";
    self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - [self.titleLabel.text length]*19)/2, self.titleLabel.frame.origin.y, [self.titleLabel.text length]*19, 30);
    self.titleLabel.hidden = YES;
    
    navOpen = NO;
    addOpen = NO;
    
    navImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.titleLabel.frame.origin.x+self.titleLabel.frame.size.width, self.titleLabel.frame.origin.y + 5, 30, 20)];
    navImageView.backgroundColor = [UIColor clearColor];
    [navImageView setImage:[UIImage imageNamed:@"bind_open"]];
    [self.navigationBarView addSubview:navImageView];
    
    demoView = [[DemoVIew alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT)];
    demoView.dataArray = [[NSMutableArray alloc] initWithObjects:@"aaa",@"bbb",@"ccc",@"ddd",@"eee",@"fff",@"ggg",@"aaa",@"bbb",@"ccc",@"ddd",@"eee",@"fff",@"ggg", nil];
    [demoView layoutView];
    [demoView.demoTableView reloadData];
    [self.bgView addSubview:demoView];
    
    
    UIButton *navButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navButton setTitle:@"全部班级" forState:UIControlStateNormal];
    navButton.frame = CGRectMake((SCREEN_WIDTH - [self.titleLabel.text length]*20)/2, self.titleLabel.frame.origin.y, [self.titleLabel.text length]*20, 30);
    navButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [navButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [navButton addTarget:self action:@selector(navClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:navButton];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(5, 4, 42, 34);
    [moreButton setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreOpen) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addButton setTitle:@"添加" forState:UIControlStateNormal];
    addButton.backgroundColor = [UIColor clearColor];
    [addButton setBackgroundImage:[UIImage imageNamed:@"navbtn"] forState:UIControlStateNormal];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:addButton];
    
    navView = [[PopView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-80, UI_NAVIGATION_BAR_HEIGHT-10, 160, 150)];
    navView.wid = 4;
    [self.bgView addSubview:navView];
    
    
    classTableView = [[UITableView alloc] initWithFrame:CGRectMake(5, 20, navView.frame.size.width-10, navView.frame.size.height-20) style:UITableViewStylePlain];
    classTableView.delegate = self;
    classTableView.dataSource = self;
    classTableView.backgroundColor = [UIColor clearColor];
    classTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [navView addSubview:classTableView];
    if ([classTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [classTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    navView.alpha = 0;
    classTableView.alpha = 0;
    
    addView = [[PopView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-125, UI_NAVIGATION_BAR_HEIGHT-10, 120, 85)];
    addView.point = CGPointMake(100, 0);
    addView.wid = 2;
    [self.bgView addSubview:addView];
    
    
    addNoticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addNoticeButton.frame = CGRectMake(35, 15, 80, 30);
    addNoticeButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    addNoticeButton.alpha = 0;
    [addNoticeButton setTitle:@"添加通知" forState:UIControlStateNormal];
    [addView addSubview:addNoticeButton];
    [addNoticeButton addTarget:self action:@selector(addNotice) forControlEvents:UIControlEventTouchUpInside];
    
    addDiaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addDiaryButton.frame = CGRectMake(35, 50, 80, 30);
    addDiaryButton.alpha = 0;
    addDiaryButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [addDiaryButton setTitle:@"添加空间" forState:UIControlStateNormal];
    [addView addSubview:addDiaryButton];
    [addDiaryButton addTarget:self action:@selector(addDongtai) forControlEvents:UIControlEventTouchUpInside];
    
    
    addView.alpha = 0;
    addNoticeButton.alpha = 0;
    addDiaryButton.alpha = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addNotice
{
    
}
-(void)addDongtai
{
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *t in touches)
    {
        if(!(CGRectContainsPoint(navView.frame, [t locationInView:navView]) ||
             CGRectContainsPoint(addView.frame, [t locationInView:addView])))
        {
            if (addOpen)
            {
                addOpen = NO;
                [self closeAdd];
            }
            if (navOpen)
            {
                navOpen = NO;
                [self closeNav];
            }
        }
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellname = @"navclasscell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellname];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellname];
    }
    cell.textLabel.text = @"123";
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLOG(@"nav class clicked");
    
    [self closeNav];
    navOpen = NO;
    
}

-(void)addButtonClick
{
    if (addOpen)
    {
        //close
        [self closeAdd];
        self.navigationController.sideMenuController.panGestureEnabled = YES;
        self.navigationController.sideMenuController.tapGestureEnabled = YES;
    }
    else
    {
        //open
        [self openAdd];
        self.navigationController.sideMenuController.panGestureEnabled = NO;
        self.navigationController.sideMenuController.tapGestureEnabled = NO;
        if (navOpen)
        {
            navOpen = NO;
            [self closeNav];
            demoView.userInteractionEnabled = NO;
        }
    }
    addOpen = !addOpen;
}

-(void)navClick
{
    if (navOpen)
    {
        //close
        [self closeNav];
        self.navigationController.sideMenuController.panGestureEnabled = YES;
        self.navigationController.sideMenuController.tapGestureEnabled = YES;
    }
    else
    {
        //open
        [self openNav];
        self.navigationController.sideMenuController.panGestureEnabled = NO;
        self.navigationController.sideMenuController.tapGestureEnabled = NO;
        if (addOpen)
        {
            addOpen = NO;
            [self closeAdd];
            demoView.userInteractionEnabled = NO;
        }
    }
    navOpen = !navOpen;
}

-(void)openAdd
{
    [UIView animateWithDuration:0.2 animations:^{
        addView.alpha = 1;
        addNoticeButton.alpha = 1;
        addDiaryButton.alpha = 1;
        demoView.userInteractionEnabled = NO;
    }];

}

-(void)closeAdd
{
    [UIView animateWithDuration:0.2 animations:^{
        addNoticeButton.alpha = 0;
        addDiaryButton.alpha = 0;
        addView.alpha = 0;
        self.navigationController.sideMenuController.panGestureEnabled = YES;
        self.navigationController.sideMenuController.tapGestureEnabled = YES;
        demoView.userInteractionEnabled = YES;
    }];
}

-(void)closeNav
{
    [UIView animateWithDuration:0.2 animations:^{
        self.navigationController.sideMenuController.panGestureEnabled = YES;
        self.navigationController.sideMenuController.tapGestureEnabled = YES;
        navView.alpha = 0;
        classTableView.alpha = 0;
        demoView.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.2 animations:^{
            navImageView.transform = CGAffineTransformRotate(navImageView.transform, M_PI);
        } completion:^(BOOL finished) {
            
        }];
    }];
}

-(void)openNav
{
    [UIView animateWithDuration:0.2 animations:^{
        navView.alpha = 1;
        classTableView.alpha = 1;
        demoView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.2 animations:^{
            navImageView.transform = CGAffineTransformRotate(navImageView.transform, -M_PI);
        } completion:^(BOOL finished) {
            
        }];
    }];
}


-(void)moreOpen
{
    if (![[self.navigationController sideMenuController] isMenuVisible])
    {
        [[self.navigationController sideMenuController] showMenuAnimated:YES];
    }
    else
    {
        [[self.navigationController sideMenuController] hideMenuAnimated:YES];
    }
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

//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//        [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeGradient];
//        [MMProgressHUD showWithTitle:@"Title" status:@"Custom Animated Image" images:nil];
//        sleep(1);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MMProgressHUD dismissWithSuccess:@"success!"];
//        });
//
//    });

@end
