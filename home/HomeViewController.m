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

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL navOpen;
    UIView *navView;
    
    BOOL addOpen;
    UIView *addView;
    UIButton *addNoticeButton;
    UIButton *addDiaryButton;
    
    
    UITapGestureRecognizer *tapTgr;
    
    UITableView *classTableView;
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
        
    UIImageView *navImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.titleLabel.frame.origin.x+self.titleLabel.frame.size.width, self.titleLabel.frame.origin.y, 30, 30)];
    navImageView.backgroundColor = [UIColor yellowColor];
    [self.navigationBarView addSubview:navImageView];
    
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
    
    navView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-80, UI_NAVIGATION_BAR_HEIGHT-10, 160, 0)];
    navView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.bgView addSubview:navView];
    
    
    classTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, navView.frame.size.width, 0) style:UITableViewStylePlain];
    classTableView.delegate = self;
    classTableView.dataSource = self;
    classTableView.backgroundColor = [UIColor clearColor];
    [navView addSubview:classTableView];
    if ([classTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [classTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    addView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-85, UI_NAVIGATION_BAR_HEIGHT-10, 80, 0)];
    addView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.bgView addSubview:addView];
    
    
    addNoticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addNoticeButton.frame = CGRectMake(3, 10, 80, 0);
    addNoticeButton.alpha = 0;
    [addNoticeButton setTitle:@"添加通知" forState:UIControlStateNormal];
    [addView addSubview:addNoticeButton];
    
    addDiaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addDiaryButton.frame = CGRectMake(3, 50, 80, 0);
    addDiaryButton.alpha = 0;
    [addDiaryButton setTitle:@"添加空间" forState:UIControlStateNormal];
    [addView addSubview:addDiaryButton];
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGSize navSize = navView.frame.size;
    CGSize addSize = addView.frame.size;
    for(UITouch *t in touches)
    {
        DDLOG(@"%@==%@",NSStringFromCGPoint([t locationInView:navView]),NSStringFromCGPoint([t locationInView:addView]));
        
        if (!(([t locationInView:navView].x > 0 && [t locationInView:navView].x < navSize.width &&
             [t locationInView:navView].y > 0 && [t locationInView:navView].y < navSize.height) ||
             ([t locationInView:addView].x > 0 && [t locationInView:addView].x < addSize.width &&
             [t locationInView:addView].y > 0 && [t locationInView:addView].y < addSize.height)))
        {
            addOpen = NO;
            navOpen = NO;
            [self closeAdd];
            [self closeNav];
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
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLOG(@"nav class clicked");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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
            [self closeNav];
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
            [self closeAdd];
        }
    }
    navOpen = !navOpen;
}

-(void)openAdd
{
    [UIView animateWithDuration:0.2 animations:^{
        addView.frame = CGRectMake(SCREEN_WIDTH-85, UI_NAVIGATION_BAR_HEIGHT-10, 80, 90);
        addNoticeButton.frame = CGRectMake(3, 10, 80, 35);
        addDiaryButton.frame = CGRectMake(3, 50, 80, 35);
        addNoticeButton.alpha = 1;
        addDiaryButton.alpha = 1;
    }];

}

-(void)closeAdd
{
    [UIView animateWithDuration:0.2 animations:^{
        addView.frame = CGRectMake(SCREEN_WIDTH-85, UI_NAVIGATION_BAR_HEIGHT-10, 80, 0);
        addNoticeButton.frame = CGRectMake(3, 10, 80, 0);
        addDiaryButton.frame = CGRectMake(3, 50, 80, 0);
        addNoticeButton.alpha = 0;
        addDiaryButton.alpha = 0;
        self.navigationController.sideMenuController.panGestureEnabled = YES;
        self.navigationController.sideMenuController.tapGestureEnabled = YES;
    }];
}

-(void)closeNav
{
    [UIView animateWithDuration:0.2 animations:^{
        navView.frame = CGRectMake(SCREEN_WIDTH/2-80, UI_NAVIGATION_BAR_HEIGHT-10, 160, 0);
        classTableView.frame = CGRectMake(0, 10, navView.frame.size.width, 0);
        self.navigationController.sideMenuController.panGestureEnabled = YES;
        self.navigationController.sideMenuController.tapGestureEnabled = YES;
    }];
}
-(void)openNav
{
    [UIView animateWithDuration:0.2 animations:^{
        navView.frame = CGRectMake(SCREEN_WIDTH/2-80, UI_NAVIGATION_BAR_HEIGHT-10, 160, 200);
        classTableView.frame = CGRectMake(0, 10, navView.frame.size.width, navView.frame.size.height-10);
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

//-(void)sendPush
//{
//    if ([Tools NetworkReachable])
//    {
//        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"platform":@"all",@"audience":@"all",@"notification":@"{\"alert\":\"您有新的消息\"},\"options\":{\"sendno\":342377575}"}
//                                                                API:@"https://api.jpush.cn/v3/push"];
//        
//        [request setCompletionBlock:^{
//            [Tools hideProgress:self.bgView];
//            NSString *responseString = [request responseString];
//            NSDictionary *responseDict = [Tools JSonFromString:responseString];
//            DDLOG(@"report== responsedict %@",responseString);
//            
//        }];
//        
//        [request setFailedBlock:^{
//            NSError *error = [request error];
//            DDLOG(@"error %@",error);
//            [Tools hideProgress:self.bgView];
//        }];
//        [Tools showProgress:self.bgView];
//        [request startAsynchronous];
//    }
//    else
//    {
//        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
//    }
//    
//}


@end
