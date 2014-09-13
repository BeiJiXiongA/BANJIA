//
//  SideMenuViewController.m
//  School
//
//  Created by TeekerZW on 1/14/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "SideMenuViewController.h"
#import "HomeViewController.h"
#import "MyClassesViewController.h"
#import "MessageViewController.h"
#import "FriendsViewController.h"
#import "PersonalSettingViewController.h"
#import "XDContentViewController+JDSideMenu.h"
#import "ChatViewController.h"
#import "Header.h"
#import "MyButton.h"

#import "ClassCell.h"

#import "KKNavigationController.h"

#define HOMETAG     2000
#define MYCLASSTAG  2001
#define FRIENDSTAG  2002
#define MESSAGETAG  2003
#define PERSONTAG   2004

@interface SideMenuViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImage *greenImage;
    UIImage *btnImage;
    
    OperatDB *db;
    
    NSArray *menuNamesArray;
    NSArray *menuIconArray;
    
    NSInteger selectIndex;
    UILabel *nameLabel;
    
    HomeViewController *home;
    KKNavigationController *homeNav;
    MyClassesViewController *myClasses;
    KKNavigationController *myClassesNav;
    FriendsViewController *friends;
    KKNavigationController *friendsNav;
    MessageViewController *message;
    KKNavigationController *messageNav;
    PersonalSettingViewController *personalSetting;
    KKNavigationController *personSettingNav;
}
@end

@implementation SideMenuViewController
@synthesize imageView,buttonTableView;
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
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    self.backButton.hidden = YES;
    self.navigationBarView.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeIcon) name:@"changeicon" object:nil];
    
    selectIndex = 0;
    
    db = [[OperatDB alloc] init];
    
    self.bgView.backgroundColor = RGB(49, 54, 58, 1);
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(180/2-43, YSTART+30, 86, 86)];
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.imageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.imageView.layer.borderWidth = 2;
    self.imageView.layer.contentsGravity = kCAGravityResizeAspectFill;
    [Tools fillImageView:self.imageView withImageFromURL:[Tools header_image] andDefault:HEADERICON];
    self.imageView.layer.cornerRadius = imageView.frame.size.width/2;
    self.imageView.clipsToBounds = YES;
    [self.bgView addSubview:self.imageView];
    
    UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTap)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:headerTap];
    
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.imageView.frame.size.height+self.imageView.frame.origin.y+2, 180, 30)];
    nameLabel.font = [UIFont systemFontOfSize:17];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:nameLabel];
    
    menuNamesArray = [NSArray arrayWithObjects:@"   首页",@"   我的班级",@"   我的好友",@"   聊天记录",@"   个人信息", nil];
    menuIconArray = [NSArray arrayWithObjects:@"icon_home",@"icon_class",@"icon_friends",@"icon_chat",@"icon_setup", nil];
    
    buttonTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 183+YSTART, 180, [menuNamesArray count] * 40) style:UITableViewStylePlain];
    buttonTableView.delegate = self;
    buttonTableView.dataSource = self;
    buttonTableView.scrollEnabled = NO;
    buttonTableView.separatorColor = RGB(80, 80, 80, 1);
    buttonTableView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:buttonTableView];
    if ([buttonTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [buttonTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    home = [[HomeViewController alloc] init];
    homeNav = [[KKNavigationController alloc] initWithRootViewController:home];
    myClasses = [[MyClassesViewController alloc] init];
    myClassesNav = [[KKNavigationController alloc] initWithRootViewController:myClasses];
    friends = [[FriendsViewController alloc] init];
    friendsNav = [[KKNavigationController alloc] initWithRootViewController:friends];
    message = [[MessageViewController alloc] init];
    messageNav = [[KKNavigationController alloc] initWithRootViewController:message];
    personalSetting = [[PersonalSettingViewController alloc] init];
    personSettingNav = [[KKNavigationController alloc] initWithRootViewController:personalSetting];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [menuNamesArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *sideButton = @"sidebuttoncell";
    ClassCell *cell = [tableView dequeueReusableCellWithIdentifier:sideButton];
    if (cell == nil)
    {
        cell = [[ClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sideButton];
    }
    cell.headerImageView.frame = CGRectMake(10, 10, 20, 20);
    [cell.headerImageView setImage:[UIImage imageNamed:[menuIconArray objectAtIndex:indexPath.row]]];
    cell.headerImageView.layer.contentsGravity = kCAGravityResizeAspect;
    cell.headerImageView.clipsToBounds = YES;
    
    cell.nameLabel.frame = CGRectMake(30, 5, 100, 30);
    cell.nameLabel.textColor = [UIColor whiteColor];
    cell.nameLabel.text = [menuNamesArray objectAtIndex:indexPath.row];
    cell.nameLabel.font = [UIFont systemFontOfSize:18];
    if (indexPath.row == selectIndex)
    {
        cell.contentView.backgroundColor = RGB(58, 63, 67, 1);
    }
    else
    {
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    cell.contentLable.frame = CGRectMake(140, 10, 20, 20);
    cell.contentLable.backgroundColor = RGB(242, 87, 87, 1);
    cell.contentLable.layer.cornerRadius = 10;
    cell.contentLable.clipsToBounds = YES;
    cell.contentLable.layer.borderColor = [UIColor whiteColor].CGColor;
    cell.contentLable.layer.borderWidth = 0;
    cell.contentLable.textAlignment = NSTextAlignmentCenter;
    cell.contentLable.textColor = [UIColor whiteColor];
    cell.contentLable.hidden = YES;
    
    if (indexPath.row == 1)
    {
        if ([self haveNewNotice] > 0)
        {
            cell.contentLable.hidden = NO;
            cell.contentLable.text = [NSString stringWithFormat:@"%d",[self haveNewNotice]];
        }
    }
    else if (indexPath.row == 2)
    {
        if ([self haveNewFriendApply] > 0)
        {
            cell.contentLable.hidden = NO;
            cell.contentLable.text = [NSString stringWithFormat:@"%d",[self haveNewFriendApply]];
        }
    }
    else if (indexPath.row == 3)
    {
        if ([self haveNewMsg] > 0)
        {
            cell.contentLable.hidden = NO;
            cell.contentLable.text = [NSString stringWithFormat:@"%d",[self haveNewMsg]];
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    cell.lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
    cell.lineImageView.backgroundColor = UIColorFromRGB(0x394043);
    //394043
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selectIndex = indexPath.row;
    NSString *classStr = NSStringFromClass([[(KKNavigationController *)[self.sideMenuController contentController] topViewController] class]);
    
    if (indexPath.row == HOMETAG-2000)
    {
        if (![classStr isEqualToString:@"HomeViewController"])
        {
            [self.sideMenuController setContentController:homeNav animted:NO];
        }
        else
        {
            [home viewWillAppear:NO];
        }
        [home getData];
    }
    else if(indexPath.row == MYCLASSTAG-2000)
    {
        if (![classStr isEqualToString:@"MyClassesViewController"])
        {
            [self.sideMenuController setContentController:myClassesNav animted:NO];
        }
        else
        {
            [myClasses viewWillAppear:NO];
        }
        [myClasses getData];
    }
    else if(indexPath.row == FRIENDSTAG-2000)
    {
        if (![classStr isEqualToString:@"FriendsViewController"])
        {
            [self.sideMenuController setContentController:friendsNav animted:NO];
        }
        else
        {
            [friends viewWillAppear:NO];
        }
        [friends getData];
    }
    else if(indexPath.row == MESSAGETAG-2000)
    {
        if (![classStr isEqualToString:@"MessageViewController"])
        {
            [self.sideMenuController setContentController:messageNav animted:NO];
        }
        else
        {
            [message viewWillAppear:NO];
        }
        [message getChatList];
    }
    else if(indexPath.row == PERSONTAG-2000)
    {
        if (![classStr isEqualToString:@"PersonalSettingViewController"])
        {
            [self.sideMenuController setContentController:personSettingNav animted:NO];
        }
        else
        {
            [personalSetting viewWillAppear:NO];
        }
        [personalSetting getData];
    }
    [self.sideMenuController hideMenuAnimated:NO];
    [tableView reloadData];
}

-(void)headerTap
{
//    [homeNav popToRootViewControllerAnimated:NO];
//    [homeNav dismissViewControllerAnimated:NO completion:nil];
//    
//    [myClassesNav popToRootViewControllerAnimated:NO];
//    [myClassesNav dismissViewControllerAnimated:NO completion:nil];
//    
//    [friendsNav popToRootViewControllerAnimated:NO];
//    [friendsNav dismissViewControllerAnimated:NO completion:nil];
//    
//    [messageNav popToRootViewControllerAnimated:NO];
//    [messageNav dismissViewControllerAnimated:NO completion:nil];
//    
//    [personSettingNav popToRootViewControllerAnimated:NO];
//    [personSettingNav dismissViewControllerAnimated:NO completion:nil];
    
    NSString *classStr = NSStringFromClass([[(KKNavigationController *)[self.sideMenuController contentController] topViewController] class]);
    if (![classStr isEqualToString:@"PersonalSettingViewController"])
    {
        [self.sideMenuController setContentController:personSettingNav animted:NO];
    }
    else
    {
        [self.sideMenuController hideMenuAnimated:NO];
    }
    [personalSetting getData];
    [buttonTableView reloadData];
}

-(void)statusTipTapWithDataDict:(NSDictionary *)dataDict
{
    DDLOG(@"current class %@",NSStringFromClass([[(KKNavigationController *)[self.sideMenuController contentController] visibleViewController] class]));
    DDLOG(@"datadict %@",dataDict);
    NSString *type = [dataDict objectForKey:@"type"];
    
    if ([type isEqualToString:@"chat"])
    {
        ChatViewController *chat = [[ChatViewController alloc] init];
        chat.toID = [dataDict objectForKey:@"f_id"];
        
        NSDictionary *userIconDIct = [ImageTools iconDictWithUserID:[dataDict objectForKey:@"f_id"]];
        if(userIconDIct)
        {
            chat.name = [userIconDIct objectForKey:@"username"];
            chat.imageUrl = [userIconDIct objectForKey:@"uicon"];
        }
        [[(KKNavigationController *)[self.sideMenuController contentController] visibleViewController].navigationController pushViewController:chat animated:YES];
    }
    [buttonTableView reloadData];
}

-(void)changeIcon
{
    [Tools fillImageView:self.imageView withImageFromURL:[Tools header_image] andDefault:HEADERICON];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    nameLabel.text = [Tools user_name];
    [buttonTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)haveNewMsg
{
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0",@"userid":[Tools user_id]} andTableName:CHATTABLE];
    if ([array count] > 0)
    {
        return [array count];
    }
    else if([[[NSUserDefaults standardUserDefaults] objectForKey:NewChatMsgNum] integerValue]>0)
    {
        return [[[NSUserDefaults standardUserDefaults] objectForKey:NewChatMsgNum] integerValue];
    }
    return 0;
}
-(NSInteger)haveNewNotice
{
    NSMutableArray *array = [db findSetWithDictionary:@{@"readed":@"0",@"uid":[Tools user_id]} andTableName:NOTICETABLE];
    
    if ([array count] > 0)
    {
        return [array count];
    }
    else if( [[[NSUserDefaults standardUserDefaults] objectForKey:NewClassNum] integerValue]>0)
    {
        return  [[[NSUserDefaults standardUserDefaults] objectForKey:NewClassNum] integerValue];
    }
    return 0;
}
-(BOOL)haveNewFriendApply
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    int ucfriendNum = [[ud objectForKey:UCFRIENDSUM] intValue];
    if (ucfriendNum > 0)
    {
        return ucfriendNum;
    }
    
    NSArray *ucfriends = [db findSetWithDictionary:@{@"uid":[Tools user_id],@"checked":@"0"} andTableName:FRIENDSTABLE];
    return [ucfriends count];
}

@end
