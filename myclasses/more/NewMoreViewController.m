//
//  NewMoreViewController.m
//  BANJIA
//
//  Created by TeekerZW on 7/21/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "NewMoreViewController.h"
#import "XDTabViewController.h"
#import "ClassQRViewController.h"
#import "ClassInfoViewController.h"
#import "MoreViewController.h"
#import "GroupChatViewController.h"
#import "ScoreTableViewController.h"

#define MOREACTIONSHEETTAG    1000

@interface NewMoreViewController ()<UIActionSheetDelegate,UIAlertViewDelegate>
{
    UIImageView *topicImageView;
    UIImageView *headerImageView;
    UILabel *classNumLabel;
    
    NSString *classID;
    NSString *className;
    NSString *schoolName;
    NSString *schoolID;
    NSString *classNumber;
    
    NSDictionary *classInfoDict;
    
    NSString *role;
    
    NSString *roleStr;
    
    UIButton *qrButton;
    
    NSString *headerImg;
}
@end

@implementation NewMoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CHANGECLASSINFO object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = @"班级信息";
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    schoolID = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolid"];
    role = [[NSUserDefaults standardUserDefaults] objectForKey:@"role"];
    if ([role isEqualToString:@"teachers"])
    {
        roleStr = @"老师";
    }
    else if([role isEqualToString:@"parents"])
    {
        roleStr = @"家长";
    }
    else
    {
        roleStr = @"学生";
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeClassInfo) name:CHANGECLASSINFO object:nil];
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - CORNERMORERIGHT, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [inviteButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:inviteButton];
    
    topicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, 150)];
    topicImageView.backgroundColor = [UIColor whiteColor];
    topicImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
    topicImageView.clipsToBounds = YES;
    [topicImageView setImage:[UIImage imageNamed:@"toppic"]];
    [self.bgView addSubview:topicImageView];
    
    headerImg = @"headpic.jpg";
    
    headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, topicImageView.frame.size.height-100, 80, 80)];
    headerImageView.backgroundColor = [UIColor whiteColor];
    headerImageView.layer.cornerRadius = 5;
    [headerImageView setImage:[UIImage imageNamed:headerImg]];
    headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    headerImageView.layer.borderWidth = 2;
    headerImageView.layer.masksToBounds = YES;
    [topicImageView addSubview:headerImageView];
    
    UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ShowBigImage:)];
    headerImageView.userInteractionEnabled = YES;
    [headerImageView addGestureRecognizer:headerTap];
    
    CGFloat fontSize = 16;
    
    UILabel *classNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, headerImageView.frame.origin.y+5, 200, 20)];
    classNameLabel.text = className;
    classNameLabel.backgroundColor = [UIColor clearColor];
    classNameLabel.textColor = [UIColor whiteColor];
    classNameLabel.font = [UIFont systemFontOfSize:fontSize];
    classNameLabel.shadowColor = TITLE_COLOR;
    classNameLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    [topicImageView addSubview:classNameLabel];
    
    classNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, classNameLabel.frame.origin.y+classNameLabel.frame.size.height+5, 200, 20)];
    classNumLabel.text = @"班号:";
    classNumLabel.backgroundColor = [UIColor clearColor];
    classNumLabel.textColor = [UIColor whiteColor];
    classNumLabel.font = [UIFont systemFontOfSize:fontSize];
    classNumLabel.shadowColor = TITLE_COLOR;
    classNumLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    [topicImageView addSubview:classNumLabel];
    
    qrButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [qrButton setImage:[UIImage imageNamed:@"icon_qr20"] forState:UIControlStateNormal];
    qrButton.frame = CGRectMake(SCREEN_WIDTH-100, classNumLabel.frame.origin.y+UI_NAVIGATION_BAR_HEIGHT-5, 30, 30);
    qrButton.hidden = YES;
    [qrButton addTarget:self action:@selector(checkQRCode) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:qrButton];
    
    UILabel *roleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, classNumLabel.frame.origin.y+classNumLabel.frame.size.height+5, 200, 20)];
    roleLabel.text = [NSString stringWithFormat:@"您的身份:%@",roleStr];
    roleLabel.backgroundColor = [UIColor clearColor];
    roleLabel.textColor = [UIColor whiteColor];
    roleLabel.font = [UIFont systemFontOfSize:fontSize];
    roleLabel.shadowColor = TITLE_COLOR;
    roleLabel.shadowOffset = CGSizeMake(0.5, 0.5);
    [topicImageView addSubview:roleLabel];
    
    NSArray *buttonNameArray = [NSArray arrayWithObjects:@"班级信息",@"群聊",@"成绩簿", nil];
    
    NSArray *buttonImageArray = [NSArray arrayWithObjects:@"classinfoicon",@"groupchaticon",@"scorealbum", nil];
    
    CGFloat buttonSize = SCREEN_WIDTH/3-40;
    CGFloat buttonSpace = (SCREEN_WIDTH-buttonSize*3)/6;
    CGFloat origY = topicImageView.frame.size.height+40;
    
    for (int i=0; i<[buttonImageArray count]; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(buttonSpace+(buttonSize+buttonSpace*2)*(i%3),
                                  origY+buttonSpace+(buttonSize + buttonSpace*2)*(i/3)+30, buttonSize, buttonSize);
        [button setImage:[UIImage imageNamed:[buttonImageArray objectAtIndex:i]] forState:UIControlStateNormal];
        button.tag = 333+i;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = self.bgView.backgroundColor;
        [self.bgView addSubview:button];
        
        UILabel *buttonLabel = [[UILabel alloc] initWithFrame:CGRectMake(buttonSpace+(buttonSize+buttonSpace*2)*(i%3), origY+buttonSpace+(buttonSize + buttonSpace*2)*(i/3)+30+buttonSize+5, buttonSize, 20)];
        buttonLabel.text = [buttonNameArray objectAtIndex:i];
        buttonLabel.font = [UIFont systemFontOfSize:fontSize];
        buttonLabel.textColor = TITLE_COLOR;
        buttonLabel.backgroundColor = self.bgView.backgroundColor;
        buttonLabel.textAlignment = NSTextAlignmentCenter;
        [self.bgView addSubview:buttonLabel];
    }
    
    [self getClassInfo];
}

-(void)changeClassInfo
{
    [self reloadView];
}

#pragma mark - 查看头像
-(void)ShowBigImage:(UITapGestureRecognizer *)headerTap
{
    MJPhoto *photo = [[MJPhoto alloc] init];
    if ([headerImg length] > 0 && ![headerImg isEqualToString:@"headpic.jpg"])
    {
        photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEURL,headerImg]];
    }
    else
    {
        photo.image = [UIImage imageNamed:headerImg];
    }
    photo.srcImageView = (UIImageView *)headerTap.view;
    MJPhotoBrowser *photoBroser = [[MJPhotoBrowser alloc] init];
    photoBroser.photos = [NSArray arrayWithObject:photo];
    [photoBroser show];
}

-(void)unShowSelfViewController
{
    [[XDTabViewController sharedTabViewController] dismissViewControllerAnimated:YES completion:nil];
    [[NSUserDefaults standardUserDefaults] setObject:NOTFROMCLASS forKey:FROMWHERE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)buttonClick:(UIButton *)button
{
    if (button.tag - 333 == 0)
    {
        //班级信息
        ClassInfoViewController *classInfoViewController = [[ClassInfoViewController alloc] init];
        [[XDTabViewController sharedTabViewController].navigationController pushViewController:classInfoViewController animated:YES];
        
    }
    else if (button.tag - 333 == 1)
    {
        //群聊   18622653143 android
        
        GroupChatViewController *groupChatViewController = [[GroupChatViewController alloc] init];
        [[XDTabViewController sharedTabViewController].navigationController pushViewController:groupChatViewController animated:YES];
    }
    else if(button.tag - 333 == 2)
    {
        //成绩簿
        ScoreTableViewController *scoreTableVC = [[ScoreTableViewController alloc] init];
        [[XDTabViewController sharedTabViewController].navigationController pushViewController:scoreTableVC animated:YES];
    }
}

-(void)moreClick
{
    OperatDB *db = [[OperatDB alloc] init];
    NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
    int userAdmin = [[dict objectForKey:@"admin"] integerValue];
    if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
    {
        UIActionSheet *moreAction = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"班级设置", nil];
        moreAction.tag = MOREACTIONSHEETTAG;
        [moreAction showInView:self.bgView];
    }
    else
    {
        UIActionSheet *moreAction = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"退出班级", nil];
        moreAction.tag = MOREACTIONSHEETTAG;
        [moreAction showInView:self.bgView];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == MOREACTIONSHEETTAG)
    {
        OperatDB *db = [[OperatDB alloc] init];
        NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
        int userAdmin = [[dict objectForKey:@"admin"] integerValue];
        if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            if (buttonIndex == 0)
            {
                //班级设置
                MoreViewController *more = [[MoreViewController alloc] init];
                [[XDTabViewController sharedTabViewController].navigationController pushViewController:more animated:YES];
            }
        }
        else
        {
            if (buttonIndex == 0)
            {
                //退出班级
                [self signOut];
            }
        }
    }
}

-(void)checkQRCode
{
    ClassQRViewController *classQRVC = [[ClassQRViewController alloc] init];
    classQRVC.classNumber = classNumber;
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:classQRVC animated:YES];
}

-(void)getClassInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID
                                                                      } API:CLASSINFO];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classinfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                classInfoDict = [responseDict objectForKey:@"data"];
                if ([classInfoDict objectForKey:@"img_icon"] && [[classInfoDict objectForKey:@"img_icon"] length] > 0)
                {
                    headerImg = [classInfoDict objectForKey:@"img_icon"];
                }
                [self reloadView];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
}
-(void)reloadView
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![[ud objectForKey:@"classiconimage"] isEqual:[NSNull null]] && [[ud objectForKey:@"classiconimage"] length] > 10)
    {
        [Tools fillImageView:headerImageView withImageFromURL:[ud objectForKey:@"classiconimage"] andDefault:@"headpic.jpg"];
    }
    else if ([headerImg length] > 0 && ![headerImg isEqualToString:@"headpic.jpg"])
    {
        [Tools fillImageView:headerImageView withImageFromURL:headerImg andDefault:@"headpic.jpg"];
    }
    else
    {
        [headerImageView setImage:[UIImage imageNamed:headerImg]];
    }
    
    NSString *topurlstring = [[NSUserDefaults standardUserDefaults] objectForKey:@"classkbimage"];
    if ([topurlstring length] >10)
    {
        [Tools fillImageView:topicImageView withImageFromURL:topurlstring andDefault:@"toppic"];
    }
    else if ([[classInfoDict objectForKey:@"img_kb"] length] > 10)
    {
        [Tools fillImageView:topicImageView withImageFromURL:[classInfoDict objectForKey:@"img_kb"] andDefault:@"toppic"];
    }
    else
    {
        [topicImageView setImage:[UIImage imageNamed:@"toppic"]];
    }
    
    
    if ([classInfoDict objectForKey:@"number"] &&
        ![[classInfoDict objectForKey:@"number"] isEqual:[NSNull null]])
    {
        NSString *tmpclassnumber = [NSString stringWithFormat:@"%d",[[classInfoDict objectForKey:@"number"] integerValue]];
        if ([tmpclassnumber isEqualToString:@"0"])
        {
            classNumLabel.text = @"班号:未获取到";
            qrButton.hidden = YES;
        }
        else
        {
            classNumLabel.text = [NSString stringWithFormat:@"班号:%@",tmpclassnumber];
            qrButton.hidden = NO;
            classNumber = tmpclassnumber;
        }
    }
    else
    {
        classNumLabel.text = @"班号:未获取到";
        qrButton.hidden = YES;
    }

}

-(void)signOut
{
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要退出这个班级吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    al.tag = 2222;
    [al show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2222)
    {
        if (buttonIndex == 1)
        {
            [self signoutclass];
        }
    }
}

-(void)signoutclass
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"role":[[NSUserDefaults standardUserDefaults] objectForKey:@"role"],
                                                                      @"c_id":classID
                                                                      } API:SIGNOUTCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"signout responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:CHANGECLASSINFO object:nil];
                [self unShowSelfViewController];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
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

@end
