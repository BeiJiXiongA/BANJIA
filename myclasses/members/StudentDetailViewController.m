//
//  StudentDetailViewController.m
//  School
//
//  Created by TeekerZW on 14-2-20.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "StudentDetailViewController.h"
#import "Header.h"
#import "SetStuObjectViewController.h"
#import "ChatViewController.h"
#import "InviteStuPareViewController.h"
#import "SettingStateLimitViewController.h"
#import "InfoCell.h"
#import "ParentsDetailViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>

#define INFOLABELTAG  1000
#define CALLBUTTONTAG  2000
#define MSGBUTTONTAG  3000
#define KICKALTAG    4000
#define SETADMINTAG  5000

#define ContaceACTag  6000

#define INFOTABLEVIEWTAG  3333
#define PARENTTABLEVIEWTAG  4444

#define BGIMAGEHEIGHT  150

@interface StudentDetailViewController ()<UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
SetStudentObject,
MFMessageComposeViewControllerDelegate,
UIActionSheetDelegate,
UpdateUserSettingDelegate>
{
    
    UITableView *infoView;
    
    NSString *hidePhoneNum;
    
    NSString *otherUserAdmin;
    OperatDB *db;
    
    NSString *userPhone;
    
    NSString *schoolName;
    NSString *className;
    NSString *classID;
    
    NSString *phoneNum;
    NSString *headerImageUrl;
    NSString *bgImageUrl;
    NSString *name;
    NSString *qqnum;
    NSString *sexureimage;
    NSString *birth;
    
    CGFloat bgImageHeight;
    
    UIView *tipBgView;
    UIImageView *tipImageView;
    UIButton *defaultParentButtonOnTip;
    
    CGFloat defaultParentY;
    
    NSMutableDictionary *userOptDict;
    
    BOOL shouldAdd;
    BOOL haveDefaultParent;
}
@end

@implementation StudentDetailViewController
@synthesize studentName,studentID,title,admin,headerImg,role,memDel,pArray,studentNum;
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
    self = [super init];
    if (self)
    {
        pArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    qqnum = @"";
    birth = @"";
    hidePhoneNum = @"";
    
    defaultParentY = 0;
    shouldAdd = YES;
    haveDefaultParent = NO;
    
    self.titleLabel.text = @"个人信息";
    
    db = [[OperatDB alloc] init];
    
    otherUserAdmin = @"0";
    if ([studentNum length] == 0)
    {
        studentNum = @"";
    }
    
    userOptDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-CORNERMORERIGHT, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    moreButton.hidden = YES;
    [moreButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    if (![role isEqualToString:@"unin_students"])
    {
        [self.navigationBarView addSubview:moreButton];
        if (![role isEqualToString:@"unin_students"])
        {
            if (![studentID isEqualToString:[Tools user_id]])
            {
                moreButton.hidden = NO;
            }
        }
    }
    
    infoView  = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    infoView.delegate = self;
    infoView.dataSource = self;
    infoView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:infoView];
    
    if (![studentID isEqual:[NSNull null]])
    {
        if ([studentID length] > 10)
        {
            if ([[db findSetWithDictionary:@{@"uid":studentID} andTableName:CLASSMEMBERTABLE] count] > 0)
            {
                NSDictionary *dict = [[db findSetWithDictionary:@{@"uid":studentID} andTableName:CLASSMEMBERTABLE] firstObject];
                DDLOG(@"database dict %@",dict);
                if (![[dict objectForKey:@"phone"] isEqual:[NSNull null]])
                {
                    phoneNum = [dict objectForKey:@"phone"];
                }
                if (![[dict objectForKey:@"img_icon"] isEqual:[NSNull null]])
                {
                    headerImageUrl = [dict objectForKey:@"img_icon"];
                }
                if (![[dict objectForKey:@"birth"] isEqual:[NSNull null]])
                {
                    birth = [dict objectForKey:@"birth"];
                }
                if ([dict objectForKey:@"sn"] && ![[dict objectForKey:@"sn"] isEqual:[NSNull null]])
                {
                    studentNum = [dict objectForKey:@"sn"];
                }
                if (![[dict objectForKey:@"sex"] isEqual:[NSNull null]] && [[dict objectForKey:@"sex"] length] > 0)
                {
                    if ([[dict objectForKey:@"sex"] intValue] == 1)
                    {
                        //男
                        sexureimage = @"male";
                    }
                    else if ([[dict objectForKey:@"sex"] intValue] == 0)
                    {
                        //
                        sexureimage = @"female";
                    }
                }
            }
        }
    }
    
    [self getParentsWithStudentName];
    
    if (![self showPhoneNum])
    {
        phoneNum = @"";
    }
    if ([birth rangeOfString:@"设置"].length > 0)
    {
        birth = @"";
    }
    
    if (![studentID isEqual:[NSNull null]])
    {
        if ([studentID length]>10)
        {
            if([Tools NetworkReachable])
            {
                [self getUserInfo];
            }
            else
            {
                [infoView reloadData];
            }
        }
    }
    

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}
-(void)dealloc
{
    self.memDel = nil;
}

-(void)reloadTip
{
    if (haveDefaultParent && [self shouldShowDefaultParentTip])
    {
        [tipBgView removeFromSuperview];
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if (ShowTips == 1)
        {
            [ud removeObjectForKey:@"defaultparentstip"];
            [ud synchronize];
        }
        if (![ud objectForKey:@"defaultparentstip"])
        {
            if (SYSVERSION < 7)
            {
                defaultParentY -= 20;
            }
            tipBgView = [[UIView alloc] init];
            tipBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
            tipBgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
            [self.bgView addSubview:tipBgView];
            
            tipImageView = [[UIImageView alloc] init];
            [tipImageView setImage:[UIImage imageNamed:@"defaultparenttip"]];
            [tipBgView addSubview:tipImageView];
            
            UITapGestureRecognizer *tipTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkTip)];
            tipImageView.userInteractionEnabled = YES;
            [tipImageView addGestureRecognizer:tipTap];
            
            defaultParentButtonOnTip = [UIButton buttonWithType:UIButtonTypeCustom];
            defaultParentButtonOnTip.backgroundColor = [UIColor whiteColor];
            [defaultParentButtonOnTip setTitle:@"默认家长" forState:UIControlStateNormal];
            [defaultParentButtonOnTip setTitleColor:COMMENTCOLOR forState:UIControlStateNormal];
            defaultParentButtonOnTip.titleLabel.font = [UIFont systemFontOfSize:16];
            defaultParentButtonOnTip.layer.cornerRadius = 3;
            defaultParentButtonOnTip.clipsToBounds = YES;
            [tipBgView addSubview:defaultParentButtonOnTip];
            
            UIImage *tipImage = [UIImage imageNamed:@"defaultparenttip"];
            tipBgView.hidden = NO;
            tipImageView.frame = CGRectMake((SCREEN_WIDTH-tipImage.size.width)/2-2, defaultParentY-tipImage.size.height+10, SCREEN_WIDTH-10, tipImage.size.height);
            defaultParentButtonOnTip.frame = CGRectMake(173, defaultParentY+17, 80, 35);
        }
    }
    else
    {
        [tipBgView removeFromSuperview];
    }
}

-(void)checkTip
{
    [tipBgView removeFromSuperview];
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"defaultparentstip"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(BOOL)shouldShowDefaultParentTip
{
    NSDictionary *selfDict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
    if (([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"] &&
         [selfDict objectForKey:@"re_id"] &&
         [[selfDict objectForKey:@"re_id"] isEqualToString:studentID]) ||
        [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] intValue] == 2)
    {
        return YES;
    }
    return NO;
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)showPhoneNum
{
    if ([studentID isEqualToString:[Tools user_id]])
    {
        return YES;
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"teachers"])
    {
        return YES;
    }
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"])
    {
        NSArray *selfArray = [db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE];
        if ([selfArray count] > 0)
        {
            NSDictionary *dict = [selfArray firstObject];
            if ([studentID isEqualToString:[dict objectForKey:@"re_id"]])
            {
                return YES;
            }
        }
    }
    return NO;
}

-(void)getParentsWithStudentName
{
    [pArray removeAllObjects];
    NSArray *tmpParentsArray = [db findSetWithDictionary:@{@"classid":classID,@"role":@"parents",@"re_id":studentID,@"checked":@"1"} andTableName:CLASSMEMBERTABLE];
    if ([tmpParentsArray count] > 0)
    {
        [pArray addObjectsFromArray:tmpParentsArray];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addFriend
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":studentID
                                                                      } API:MB_APPLY_FRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"请求已申请，请等待对方答复！" toView:self.bgView];
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
#pragma mark - setstuobj
-(void)setStuObj:(NSString *)newTitle
{
    if ([self.memDel respondsToSelector:@selector(updateListWith:)])
    {
        [self.memDel updateListWith:YES];
    }
    title = newTitle;
    [infoView reloadData];
}

#pragma mark - tableview

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH, 35)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:16];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = TITLE_COLOR;
    
    if (section == 2)
    {
        if ([pArray count] > 0)
        {
            headerLabel.text = @"   家长";
            return headerLabel;
        }
        else
            return nil;
    }
    else if(section == 1)
    {
        if([phoneNum length] > 0 || ([birth length] > 0 && ![birth isEqualToString:@"请设置生日"]) || [studentNum length] > 0)
        {
            headerLabel.text = @"   个人信息";
            return headerLabel;
            
        }
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 2)
    {
        if ([pArray count] > 0)
        {
            return 35;
        }
        else
            return 0;
    }
    else if(section == 1)
    {
        if([phoneNum length] > 0 || ([birth length] > 0 && ![birth isEqualToString:@"请设置生日"]) || [studentNum length] > 0)
        {
            return 35;
        }
    }
    return 0;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return BGIMAGEHEIGHT;
    }
    else if(indexPath.section == 2)
    {
        if ([pArray count] > 0)
        {
            return 60;
        }
        return 0;
    }
    else if (indexPath.section == 1)
    {
        if ([studentID length] > 10)
        {
            if (indexPath.row < 3)
            {
                if (indexPath.row == 0)
                {
                    if ([phoneNum length] > 0)
                    {
                        return 40;
                    }
                }
                else if(indexPath.row == 1)
                {
                    if (([birth length] > 0 && ![birth isEqualToString:@"请设置生日"]))
                    {
                        return 40;
                    }
                }
                else if(indexPath.row == 2)
                {
                    if ([studentNum length] > 0)
                    {
                        return 40;
                    }
                }
            }
        }
    }
    else if(indexPath.section == 3)
    {
        if(![role isEqualToString:@"unin_students"])
        {
            return 60;
        }
    }
    return 0;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section == 0)
    {
        return 1;
    }
    else if(section == 2)
    {
        return [pArray count];
    }
    else if(section == 1)
    {
        return 3;
    }
    else if(section == 3)
    {
        return 1;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *infocell = @"infocell";
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:infocell];
    if (cell == nil)
    {
        cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infocell];
    }
    cell.headerImageView.hidden = YES;
    cell.bgImageView.hidden = YES;
    cell.button1.hidden = YES;
    cell.button2.hidden = YES;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (indexPath.section == 0)
    {
        cell.headerImageView.hidden = NO;
        cell.bgImageView.hidden = NO;
        cell.sexureImageView.hidden = NO;
        
        cell.bgImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, BGIMAGEHEIGHT);
        [cell.bgImageView setImage:[UIImage imageNamed:@"toppic"]];
        
        cell.headerImageView.frame = CGRectMake(15, BGIMAGEHEIGHT-DetailHeaderHeight-15, DetailHeaderHeight, DetailHeaderHeight);
        if ([headerImg length] > 0)
        {
            [Tools fillImageView:cell.headerImageView withImageFromURL:headerImg imageWidth:106 andDefault:HEADERICON];
        }
        else
        {
            [cell.headerImageView setImage:[UIImage imageNamed:HEADERICON]];
        }
        
        UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTap:)];
        cell.headerImageView.userInteractionEnabled = YES;
        [cell.headerImageView addGestureRecognizer:headerTap];
        
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;
        cell.headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.headerImageView.layer.borderWidth = 2;
        
        cell.nameLabel.frame = CGRectMake(DetailHeaderHeight+30, cell.headerImageView.frame.origin.y+10, [studentName length]*18, 20);
        cell.nameLabel.text = studentName;
        cell.nameLabel.shadowColor = TITLE_COLOR;
        cell.nameLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        cell.nameLabel.font = [UIFont systemFontOfSize:18];
        
        if (![role isEqualToString:@"unin_students"])
        {
            cell.sexureImageView.frame = CGRectMake(cell.nameLabel.frame.origin.x+cell.nameLabel.frame.size.width+10, cell.nameLabel.frame.origin.y, 20, 20);
            [cell.sexureImageView setImage:[UIImage imageNamed:sexureimage]];
        }
        
        cell.contentLabel.frame = CGRectMake(DetailHeaderHeight+30, cell.headerImageView.frame.origin.y+35, 100, 20);
        cell.contentLabel.text = title;
        cell.contentLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        cell.contentLabel.shadowColor = TITLE_COLOR;
        cell.contentLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *copyPhoneNumTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(copyPhoneNum)];
        cell.nameLabel.userInteractionEnabled = YES;
        copyPhoneNumTap.numberOfTapsRequired = 7;
        copyPhoneNumTap.numberOfTouchesRequired = 1;
        [cell.nameLabel addGestureRecognizer:copyPhoneNumTap];
    }
    else if (indexPath.section == 2)
    {
        if ([pArray count] > 0)
        {
            cell.headerImageView.hidden = NO;
            NSDictionary *parentDict = [pArray objectAtIndex:indexPath.row];
            cell.headerImageView.frame = CGRectMake(15, 10, 40, 40);
            cell.headerImageView.layer.cornerRadius = 3;
            cell.headerImageView.clipsToBounds = YES;
            [Tools fillImageView:cell.headerImageView withImageFromURL:[parentDict objectForKey:@"img_icon"] andDefault:HEADERICON];
            cell.nameLabel.frame = CGRectMake(70, 15, 93, 30);
            cell.nameLabel.backgroundColor = [UIColor clearColor];
            
//            NSString *name = [parentDict objectForKey:@"name"];
            
            cell.nameLabel.text = [parentDict objectForKey:@"name"];
            cell.nameLabel.font = [UIFont systemFontOfSize:15];
            cell.nameLabel.textColor = TITLE_COLOR;
            
            cell.contentLabel.frame = CGRectMake(SCREEN_WIDTH-70, 15, 60, 30);
            cell.contentLabel.textAlignment = NSTextAlignmentRight;
            cell.contentLabel.textColor = TITLE_COLOR;
            NSRange range = [[parentDict objectForKey:@"title"] rangeOfString:@"."];
            if (range.length > 0)
            {
                cell.contentLabel.text = [[parentDict objectForKey:@"title"] substringFromIndex:[[parentDict objectForKey:@"title"] rangeOfString:@"."].location+1];
            }
            else
            {
                cell.contentLabel.text = [parentDict objectForKey:@"title"];
            }
            
            if ([[parentDict objectForKey:@"def"] intValue] == 1)
            {
                
                cell.button1.hidden = NO;
                [cell.button1 setTitle:@"默认家长" forState:UIControlStateNormal];
                [cell.button1 setTitleColor:COMMENTCOLOR forState:UIControlStateNormal];
                cell.button1.titleLabel.textAlignment = NSTextAlignmentLeft;
                cell.button1.titleLabel.font = [UIFont systemFontOfSize:14];
                cell.button1.frame = CGRectMake(175, 17, 65, 26);
                cell.button1.backgroundColor = [UIColor clearColor];
                haveDefaultParent = YES;
                defaultParentY = 0;
                for (int i=0; i<=indexPath.section; i++)
                {
                    defaultParentY += [tableView  rectForHeaderInSection:i].size.height;
                    for (int j=0; j<indexPath.section?(j<[tableView numberOfRowsInSection:i]):(j<indexPath.row); j++)
                    {
                        defaultParentY += [tableView rectForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]].size.height;
                    }
                }
                [self reloadTip];
            }
        }
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
        lineImageView.backgroundColor = LineBackGroudColor;
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    else if(indexPath.section == 1)
    {
        if ([studentID length] < 10)
        {
            return nil;
        }
        if (indexPath.row < ([studentNum length] > 0?3:2))
        {
            cell.nameLabel.frame = CGRectMake(15, 5, 100, 30);
            cell.nameLabel.textColor = TITLE_COLOR;
            cell.contentLabel.frame = CGRectMake(SCREEN_WIDTH-150, 5, 140, 30);
            cell.contentLabel.textColor = TITLE_COLOR;
            cell.contentLabel.textAlignment = NSTextAlignmentRight;
            if (indexPath.row == 0)
            {
                if([phoneNum length] > 0)
                {
                    cell.nameLabel.text = @"手机号";
                    cell.contentLabel.text = phoneNum;
                }
                else
                {
                    cell.nameLabel.text = @"";
                }
            }
            else if(indexPath.row == 1)
            {
                if (([birth length] > 0 && ![birth isEqualToString:@"请设置生日"]))
                {
                    cell.nameLabel.text = @"生日";
                    cell.contentLabel.text = birth;
                }
                else
                {
                    cell.nameLabel.text = @"";
                    cell.contentLabel.text = @"";
                }
                
            }
            else if(indexPath.row == 2)
            {
                if ([studentNum length] > 0)
                {
                    cell.nameLabel.text = @"学号";
                    cell.contentLabel.text = studentNum;
                }
                else
                {
                    cell.nameLabel.text = @"";
                    cell.contentLabel.text = @"";
                }
            }
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.backgroundColor = LineBackGroudColor;
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
    else if(indexPath.section == 3)
    {
        cell.nameLabel.hidden = YES;
        cell.contentLabel.hidden = YES;
        if (![studentID isEqualToString:[Tools user_id]] && ![role isEqualToString:@"unin_students"])
        {
            cell.button1.hidden = NO;
            cell.button2.hidden = NO;
        }
        
        cell.button1.frame = CGRectMake(10, 10, 145, 43.5);
        [cell.button1 setTitle:ADDFRIEND forState:UIControlStateNormal];
        [cell.button1 setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
        
        [cell.button1 addTarget:self action:@selector(addFriend) forControlEvents:UIControlEventTouchUpInside];
        
        cell.button2.frame = CGRectMake(165, 10, 145, 43.5);
        [cell.button2 setTitle:CHATTO forState:UIControlStateNormal];
        [cell.button2 setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
        
        cell.button1.iconImageView.frame = CGRectMake(ALEFT, ATOP, CHATW, CHATH);
        [cell.button1.iconImageView setImage:[UIImage imageNamed:@"add_friend"]];
        
        cell.button2.iconImageView.frame = CGRectMake(CLEFT, CTOP, ADDFRIW, ADDFRIH);
        [cell.button2.iconImageView setImage:[UIImage imageNamed:@"chatto"]];
        
        
        if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"fname":studentName,@"checked":@"1"} andTableName:FRIENDSTABLE] count] > 0)
        {
            cell.button1.hidden = YES;
            cell.button2.frame = CGRectMake((SCREEN_WIDTH-150)/2, 10, 145, 43.5);
        }
        
        [cell.button2 addTarget:self action:@selector(toChat) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        NSDictionary *dict = [pArray objectAtIndex:indexPath.row];
        if (![studentID isEqual:[NSNull null]])
        {
            ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
            parentDetail.parentID = [dict objectForKey:@"uid"];
            parentDetail.parentName = [dict objectForKey:@"name"];
            parentDetail.title = [dict objectForKey:@"title"];
            parentDetail.headerImg = [dict objectForKey:@"img_icon"];
            parentDetail.admin = NO;
            parentDetail.role = [dict objectForKey:@"role"];
            [self.navigationController pushViewController:parentDetail animated:YES];
        }
        else
        {
            ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
            parentDetail.parentID = [dict objectForKey:@"uid"];
            parentDetail.parentName = [dict objectForKey:@"name"];
            parentDetail.title = [dict objectForKey:@"title"];
            parentDetail.headerImg = [dict objectForKey:@"img_icon"];
            parentDetail.admin = NO;
            parentDetail.role = [dict objectForKey:@"role"];
            [self.navigationController pushViewController:parentDetail animated:YES];
        }
    }
    else if(indexPath.section == 1)
    {
        if (indexPath.row == 0)
        {
            if (![studentID isEqualToString:[Tools user_id]])
            {
                UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"打电话",@"发短信", nil];
                ac.tag = ContaceACTag;
                [ac showInView:self.bgView];
            }
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)copyPhoneNum
{
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    [generalPasteBoard setString:hidePhoneNum];
    [Tools showTips:hidePhoneNum toView:self.bgView];
}


#pragma mark - 查看大头像
-(void)headerTap:(UITapGestureRecognizer *)headerTap
{
    MJPhoto *photo = [[MJPhoto alloc] init];
    if ([headerImg length] > 0 && ![headerImg isEqualToString:HEADERICON])
    {
        if ([Tools NetworkReachable])
        {
            if ([[Reachability reachabilityForLocalWiFi] currentReachabilityStatus] == ReachableViaWiFi)
            {
                //wifi
                photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEURL,headerImg]];
            }
            else if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == ReachableViaWWAN)
            {
                //蜂窝
                photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@@%dw",IMAGEURL,headerImg,WWAN_IMAGE_WIDTH]];
            }
        }
        else
        {
            photo.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEURL,headerImg]];
        }
    }
    else
    {
        photo.image = [UIImage imageNamed:HEADERICON];
    }
    photo.srcImageView = (UIImageView *)headerTap.view;
    MJPhotoBrowser *photoBroser = [[MJPhotoBrowser alloc] init];
    photoBroser.photos = [NSArray arrayWithObject:photo];
    [photoBroser show];
}

#pragma mark - parentDetailDelegate
-(void)updateListWith:(BOOL)update
{
    if (update)
    {
        [pArray removeAllObjects];
        if ([self.memDel respondsToSelector:@selector(updateListWith:)])
        {
            [self.memDel updateListWith:YES];
        }
    }
}

-(void)callToUser
{
    [Tools dialPhoneNumber:phoneNum inView:self.bgView];
}

-(void)msgToUser
{
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要发短信吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发信息", nil];
    al.tag = MSGBUTTONTAG;
    [al show];
}


-(void)toChat
{
    ChatViewController *chatViewController = [[ChatViewController alloc] init];
    chatViewController.toID = studentID;
    chatViewController.name = studentName;
    chatViewController.imageUrl = headerImg;
    chatViewController.fromClass = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

-(void)infoButtonClick:(UIButton *)button
{
    if (button.tag == INFOLABELTAG)
    {
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打",@"发信息", nil];
        al.tag = button.tag;
        [al show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CALLBUTTONTAG)
    {
        if (buttonIndex == 1)
        {
            [Tools dialPhoneNumber:phoneNum inView:self.bgView];
        }
        
    }
    else if(alertView.tag == MSGBUTTONTAG)
    {
        if (buttonIndex == 1)
        {
            [self showMessageView:userPhone];
        }
    }
    else if(alertView.tag == KICKALTAG)
    {
        if (buttonIndex == 1)
        {
            [self excludeUser];
        }
    }
    else if(alertView.tag == SETADMINTAG)
    {
        if (buttonIndex == 1)
        {
            if ([otherUserAdmin integerValue] == 0)
            {
                [self appointToAdmin];
            }
            else if ([otherUserAdmin integerValue] == 1)
            {
                //解除管理员任命
                [self rmAdmin];
            }
        }
    }
    else if(alertView.tag == 3333)
    {
        ;
    }
}

-(void)moreClick
{
    NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
    int userAdmin = [[dict objectForKey:@"admin"] intValue];
    if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
    {
        if ([otherUserAdmin integerValue] == 0)
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"任命为普通管理员",@"设置发言权限",@"任命/解除班干部",@"邀请家长",@"踢出班级",@"举报此人", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
            
        }
        else if([otherUserAdmin integerValue] == 1)
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"解除管理员任命",@"设置发言权限",@"任命/解除班干部",@"邀请家长",@"踢出班级",@"举报此人", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
        }
    }
    else
    {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报此人", nil];
        ac.tag = 3333;
        [ac showInView:self.bgView];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 3333)
    {
        NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
        int userAdmin = [[dict objectForKey:@"admin"] intValue];
        if (userAdmin == 2 || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            if (buttonIndex == 0)
            {
                if ([otherUserAdmin integerValue] == 0)
                {
                    //任命为普通管理员
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"设置为管理员后，%@可以进行处理班级申请、审核班级日志、发布班级公告等操作。",studentName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    al.tag = SETADMINTAG;
                    [al show];
                }
                else if([otherUserAdmin integerValue] == 1)
                {
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"您确定要解除%@的管理员身份吗？",studentName] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    al.tag = SETADMINTAG;
                    [al show];
                }
            }
            else if(buttonIndex == 1)
            {
                //设置发言权限
                SettingStateLimitViewController *settingLimit = [[SettingStateLimitViewController alloc] init];
                settingLimit.userid = studentID;
                settingLimit.name = studentName;
                settingLimit.role = role;
                settingLimit.updateUserSettingDel = self;
                settingLimit.userOptDict = userOptDict;
                [self.navigationController pushViewController:settingLimit animated:YES];
            }
            else if(buttonIndex == 2)
            {
                //任命班干部
                SetStuObjectViewController *setStuViewController = [[SetStuObjectViewController alloc] init];
                setStuViewController.classID = classID;
                setStuViewController.userid = studentID;
                setStuViewController.name = studentName;
                setStuViewController.setStudel = self;
                setStuViewController.title = title;
                [self.navigationController pushViewController:setStuViewController animated:YES];
            }
            else if(buttonIndex == 3)
            {
                //邀请家长
                InviteStuPareViewController *invite = [[InviteStuPareViewController alloc] init];
                invite.classID = classID;
                invite.name = studentName;
                invite.userid = studentID;
                invite.className = className;
                invite.schoolName = schoolName;
                [self.navigationController pushViewController:invite animated:YES];
            }
            else if(buttonIndex == 4)
            {
                //踢出班级
                NSString *msg = [NSString stringWithFormat:@"您确定把%@踢出班级吗？",studentName];
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                al.tag = KICKALTAG;
                [al show];
            }
            else if (buttonIndex == 5)
            {
                ReportViewController *reportVC = [[ReportViewController alloc] init];
                reportVC.reportType = @"people";
                reportVC.reportUserid = studentID;
                reportVC.reportContentID = @"";
                [self.navigationController pushViewController:reportVC animated:YES];
            }
            
        }
        else
        {
            if (buttonIndex == 0)
            {
                ReportViewController *reportVC = [[ReportViewController alloc] init];
                reportVC.reportType = @"people";
                reportVC.reportUserid = studentID;
                reportVC.reportContentID = @"";
                [self.navigationController pushViewController:reportVC animated:YES];
            }
        }
    }
    else if(actionSheet.tag == ContaceACTag)
    {
        if (buttonIndex == 0)
        {
            [self callToUser];
        }
        else if(buttonIndex == 1)
        {
            [self showMessageView:phoneNum];
        }
    }
}

-(void)updateUserSetingObject:(NSString *)value forKey:(NSString *)key
{
    [userOptDict setObject:value forKey:key];
}

-(void)appointToAdmin
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"o_id":studentID,
                                                                      @"c_id":classID
                                                                      } API:APPOINTADMIN];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"appointadmin responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([db updeteKey:@"admin" toValue:@"1" withParaDict:@{@"classid":classID,@"uid":studentID} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"appoint %@ admin success!",studentName);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSMEMBERLIST object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
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

-(void)rmAdmin
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"o_id":studentID,
                                                                      @"c_id":classID
                                                                      } API:RMADMIN];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"rmadmin responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([db updeteKey:@"admin" toValue:@"0" withParaDict:@{@"classid":classID,@"uid":studentID} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"rm %@ admin success!",studentName);
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSMEMBERLIST object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
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


-(void)excludeUser
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"m_id":studentID,
                                                                      @"c_id":classID,
                                                                      @"role":@"students"
                                                                      } API:KICKUSERFROMCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"kickuser responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                for (int i=0 ; i<[pArray count]; i++)
                {
                    NSDictionary *pDict = [pArray objectAtIndex:i];
                    if ([db deleteRecordWithDict:@{@"uid":[pDict objectForKey:@"uid"],@"class":classID,@"re_id":studentID} andTableName:CLASSMEMBERTABLE])
                    {
                        DDLOG(@"delete stu parents success");
                    }
                }
                
                if ([db deleteRecordWithDict:@{@"classid":classID,@"uid":studentID} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"delete stu success without parents");
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSMEMBERLIST object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
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

-(void)getUserInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"other_id":studentID,
                                                                      @"c_id":classID
                                                                      } API:MB_GETUSERINFO];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *dict = [responseDict objectForKey:@"data"];
                if (![dict isEqual:[NSNull null]])
                {
                    if ([dict objectForKey:@"phone"])
                    {
                        if ([db updeteKey:@"phone" toValue:[dict objectForKey:@"phone"] withParaDict:@{@"uid":studentID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"teach phone update success!");
                        }
                        phoneNum = [dict objectForKey:@"phone"];
                        hidePhoneNum = phoneNum;
                    }
                    
                    if ([[dict objectForKey:@"sex"] intValue] == 1)
                    {
                        //男
                        sexureimage = @"male";
                    }
                    else if ([[dict objectForKey:@"sex"] intValue] == 0)
                    {
                        //
                        sexureimage = @"female";
                    }
                    
                    if ([db updeteKey:@"sex" toValue:[dict objectForKey:@"sex"] withParaDict:@{@"uid":studentID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                    {
                        DDLOG(@"update sex success");
                    }
                    
                    if ([dict objectForKey:@"birth"] && ![[dict objectForKey:@"birth"] isEqualToString:@"请设置生日"])
                    {
                        if ([db updeteKey:@"birth" toValue:[dict objectForKey:@"birth"] withParaDict:@{@"uid":studentID,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"teach birth update success!");
                        }
                        birth = [dict objectForKey:@"birth"];
                    }
                    otherUserAdmin = [NSString stringWithFormat:@"%ld",(long)[[[dict objectForKey:@"classInfo"] objectForKey:@"admin"] integerValue]];
                    headerImageUrl = [dict objectForKey:@"img_icon"];
                    if ([[[dict objectForKey:@"classInfo"] objectForKey:@"opt"] isKindOfClass:[NSDictionary class]])
                    {
                        NSDictionary *tmpDict = [[dict objectForKey:@"classInfo"] objectForKey:@"opt"];
                        for(NSString *key in [tmpDict allKeys])
                        {
                            [userOptDict setObject:[NSString stringWithFormat:@"%ld",(long)[[tmpDict objectForKey:key] integerValue]] forKey:key];
                        }
                    }
                    if (![self showPhoneNum])
                    {
                        phoneNum = @"";
                    }
                    if ([birth rangeOfString:@"设置"].length > 0)
                    {
                        birth = @"";
                    }
                    
                    
                    
                    if ([dict objectForKey:@"number"] &&
                        ![[dict objectForKey:@"number"] isEqual:[NSNull null]])
                    {
                        if ([[db findSetWithDictionary:@{@"uid":studentID} andTableName:USERICONTABLE] count] > 0)
                        {
                            if ([db deleteRecordWithDict:@{@"uid":studentID} andTableName:USERICONTABLE])
                            {
                                
                                
                                [db insertRecord:@{@"uid":studentID,
                                                   @"unum":[NSString stringWithFormat:@"%d",[[dict objectForKey:@"number"] intValue]],
                                                   @"uicon":headerImageUrl?headerImageUrl:@"",
                                                   @"username":[dict objectForKey:@"r_name"]}
                                    andTableName:USERICONTABLE];
                            }
                            
                        }
                        else
                        {
                            if ([db insertRecord:@{@"uid":studentID,
                                                   @"unum":[NSString stringWithFormat:@"%d",[[dict objectForKey:@"number"] intValue]],
                                                   @"uicon":headerImageUrl?headerImageUrl:@"",
                                                   @"username":[dict objectForKey:@"r_name"]}
                                    andTableName:USERICONTABLE])
                            {
                                DDLOG(@"insert success");
                            }
                        }
                    }
                    [infoView reloadData];
                }
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

#pragma  mark - showmsg
-(void)showMessageView:(NSString *)phoneStr
{
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = [NSArray arrayWithObject:phoneStr];
        
        NSString *msgBody;
        
        controller.body = msgBody;
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
        
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"测试短信"];//修改短信界面标题
    }else{
        [self alertWithTitle:@"提示信息" msg:@"设备没有短信功能"];
    }
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [controller dismissViewControllerAnimated:NO completion:nil];
    
    switch ( result ) {
            
        case MessageComposeResultCancelled:
            
//            [self alertWithTitle:@"提示信息" msg:@"发送取消"];
            break;
        case MessageComposeResultFailed:// send failed
            [self alertWithTitle:@"提示信息" msg:@"发送失败"];
            break;
        case MessageComposeResultSent:
            [self alertWithTitle:@"提示信息" msg:@"发送成功"];
            break;
        default:
            break;
    }
}


- (void) alertWithTitle:(NSString *)titles msg:(NSString *)msg {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:titles
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    
    alert.tag = 3333;
    [alert show];
    
}

@end
