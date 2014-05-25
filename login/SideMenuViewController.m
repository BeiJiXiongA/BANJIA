//
//  SideMenuViewController.m
//  School
//
//  Created by TeekerZW on 1/14/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "SideMenuViewController.h"
#import "MyClassesViewController.h"
#import "MessageViewController.h"
#import "FriendsViewController.h"
#import "PersonalSettingViewController.h"
#import "XDContentViewController+JDSideMenu.h"
#import "Header.h"

#import "KKNavigationController.h"

@interface SideMenuViewController ()
{
    UIImage *greenImage;
    UIImage *btnImage;
    
    OperatDB *db;
}
@end

@implementation SideMenuViewController
@synthesize imageView;
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
    self.navigationBarView.hidden = YES;
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIcon) name:@"changeicon" object:nil];
    
    db = [[OperatDB alloc] init];
    
    self.bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"drawer"]];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(150/2-43, 30, 86, 86)];
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = 2;
    [Tools fillImageView:self.imageView withImageFromURL:[Tools header_image] andDefault:HEADERBG];
    self.imageView.layer.cornerRadius = imageView.frame.size.width/2;
    self.imageView.clipsToBounds = YES;
    [self.bgView addSubview:self.imageView];
    
    UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTap)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:headerTap];
    
    NSString *name = [Tools user_name];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(150/2-[name length]*20/2, self.imageView.frame.size.height+self.imageView.frame.origin.y+2, [name length]*20, 30)];
    nameLabel.font = [UIFont systemFontOfSize:17];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = name;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:nameLabel];
    
    btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    greenImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg_green"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    NSArray *menuNamesArray = [NSArray arrayWithObjects:@"   我的班级",@"   我的好友",@"   聊天记录",@"   个人信息", nil];
    for(int i=0;i<[menuNamesArray count];++i)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 166+43*i, 150, 40);
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitle:[menuNamesArray objectAtIndex:i] forState:UIControlStateNormal];
        button.tag = 1000+i;
        if (i==0)
        {
            [button setTitleColor:RGB(255, 108, 0, 1) forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
        
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.bgView addSubview:button];
        
        UILabel *unReadLabel = [[UILabel alloc] init];
        unReadLabel.backgroundColor = [UIColor redColor];
        unReadLabel.layer.cornerRadius = 7.5;
        unReadLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        unReadLabel.layer.borderWidth = 2;
        unReadLabel.clipsToBounds = YES;
        unReadLabel.clipsToBounds = YES;
        unReadLabel.tag = 2000+i;
        unReadLabel.textAlignment = NSTextAlignmentCenter;
        unReadLabel.font = [UIFont systemFontOfSize:10];
        unReadLabel.textColor = [UIColor whiteColor];
        unReadLabel.hidden = YES;
        unReadLabel.frame = CGRectMake(100, button.frame.origin.y+12.5, 15, 15);
        [self.bgView addSubview:unReadLabel];
    }
}
-(void)headerTap
{
    PersonalSettingViewController *personalSetting = [[PersonalSettingViewController alloc] init];
    KKNavigationController *personSettingNav = [[KKNavigationController alloc] initWithRootViewController:personalSetting];
    [self.sideMenuController setContentController:personSettingNav animted:YES];
    for(int i=1000;i<1004;++i)
    {
        if (i==1003)
        {
            [((UIButton *)[self.bgView viewWithTag:i]) setTitleColor:RGB(255, 108, 0, 1) forState:UIControlStateNormal];
        }
        else
        {
            [((UIButton *)[self.bgView viewWithTag:i]) setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }

}

-(void)changeIcon
{
    DDLOG(@"changeicon==%@",[[NSUserDefaults standardUserDefaults] objectForKey:HEADERIMAGE]);
    [Tools fillImageView:self.imageView withImageFromURL:[Tools header_image] andDefault:HEADERBG];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    DDLOG(@"%@==%@",[ud objectForKey:@"count"],[ud objectForKey:@"ucfriendsnum"]);
    if ([[ud objectForKey:@"count"] integerValue] > 0)
    {
        [self.bgView viewWithTag:2001].hidden = NO;
    }
    if ([[ud objectForKey:@"ucfriendsnum"] integerValue] > 0)
    {
        [self.bgView viewWithTag:2002].hidden = NO;
        int ucfriends = [[ud  objectForKey:@"ucfriendsnum"] integerValue];
        ((UILabel *)[self.bgView viewWithTag:2002]).text = [NSString stringWithFormat:@"%d",ucfriends];
    }
    
    if ([self haveNewMsg])
    {
        [self.bgView viewWithTag:2002].hidden = NO;
    }
    else
    {
        [self.bgView viewWithTag:2002].hidden = YES;
    }
    if ([self haveNewFriendApply])
    {
        [self.bgView viewWithTag:2001].hidden = NO;
    }
    else
    {
        [self.bgView viewWithTag:2001].hidden = YES;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)haveNewMsg
{
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0",@"userid":[Tools user_id]} andTableName:@"chatMsg"];
    if ([array count] > 0)
    {
        return YES;
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:NewChatMsgNum] integerValue]>0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    return NO;
}
-(BOOL)haveNewNotice
{
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0",@"uid":[Tools user_id]} andTableName:@"notice"];
    if ([array count] > 0)
    {
        return YES;
    }
    return NO;
}
-(BOOL)haveNewFriendApply
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int ucfriendNum = [[ud objectForKey:UCFRIENDSUM] intValue];
    if (ucfriendNum > 0)
    {
        return YES;
    }
    NSArray *ucfriends = [db findSetWithDictionary:@{@"uid":[Tools user_id],@"checked":@"0"} andTableName:FRIENDSTABLE];
    if ([ucfriends count] > 0)
    {
        return YES;
    }
    return NO;
}

-(void)buttonClick:(UIButton *)button
{
    if (button.tag == 1000)
    {
        MyClassesViewController *myClasses = [[MyClassesViewController alloc] init];
        KKNavigationController *myClassesNav = [[KKNavigationController alloc] initWithRootViewController:myClasses];
        [self.sideMenuController setContentController:myClassesNav animted:YES];
    }
    else if(button.tag == 1001)
    {
        FriendsViewController *friends = [[FriendsViewController alloc] init];
        KKNavigationController *friendsNav = [[KKNavigationController alloc] initWithRootViewController:friends];
        [self.sideMenuController setContentController:friendsNav animted:YES];
        
    }
    else if(button.tag == 1002)
    {
        MessageViewController *message = [[MessageViewController alloc] init];
        KKNavigationController *messageNav = [[KKNavigationController alloc] initWithRootViewController:message];
        [self.sideMenuController setContentController:messageNav animted:YES];
    }
    else if(button.tag == 1003)
    {
        PersonalSettingViewController *personalSetting = [[PersonalSettingViewController alloc] init];
        KKNavigationController *personSettingNav = [[KKNavigationController alloc] initWithRootViewController:personalSetting];
        [self.sideMenuController setContentController:personSettingNav animted:YES];
    }
    
    
    for(int i=1000;i<1004;++i)
    {
        if (i==button.tag)
        {
            [((UIButton *)[self.bgView viewWithTag:i]) setTitleColor:RGB(255, 108, 0, 1) forState:UIControlStateNormal];
        }
        else
        {
            [((UIButton *)[self.bgView viewWithTag:i]) setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

@end
