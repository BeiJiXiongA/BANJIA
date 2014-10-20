//
//  NotificationDetailViewController.m
//  School
//
//  Created by TeekerZW on 14-2-18.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "NotificationDetailViewController.h"
#import "Header.h"
#import "NotificationDetailCell.h"
#import "MemberDetailViewController.h"
#import "StudentDetailViewController.h"
#import "ParentsDetailViewController.h"
#import "MemberDetailViewController.h"
#import "ReportViewController.h"
#import "ScoreMemListViewController.h"
#import "ScoreDetailViewController.h"

#define UnreadTabelTag 2000
#define ReadTableTag  3000


#define CallAlterViewTag   4000

@interface NotificationDetailViewController ()<
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
UIAlertViewDelegate,
UIActionSheetDelegate>
{
    UITextView *contentTextView;
    NSMutableArray *buttonNamesArray;
    CGFloat buttonHeight;
    
    UIButton *readButton;
    UIButton *unreadButton;
    
    UIScrollView *containerScrollView;
    
    UITableView *readedTableView;
    UITableView *unreadTableView;
    
    NSMutableArray *readArray;
    NSMutableArray *unreaderArray;
    
    NSString *phoneStr;
    
    NSString *classID;
    
    UIButton *moreButton;
    
    NSString *scoreId;
}
@end

@implementation NotificationDetailViewController
@synthesize noticeContent,noticeID,c_read,byID,readnotificationDetaildel,isnew,fromClass,markString,noticeDict;
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
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    scoreId = @"";
    
    DDLOG(@"notice dict %@",noticeDict);
    
    noticeContent = [noticeDict objectForKey:@"content"];
    noticeID = [noticeDict objectForKey:@"_id"];
    byID = [[noticeDict objectForKey:@"by"] objectForKey:@"_id"];
    markString = [NSString stringWithFormat:@"%@发布于%@",[[noticeDict objectForKey:@"by"] objectForKey:@"name"],[Tools showTime:[NSString stringWithFormat:@"%d",[[[noticeDict objectForKey:@"created"] objectForKey:@"sec"] intValue]]]];

        
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-CORNERMORERIGHT, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [moreButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    self.titleLabel.text = @"通知详情";
    readArray = [[NSMutableArray alloc] initWithCapacity:0];
    unreaderArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIView *inputBg = [[UIView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, 155)];
    inputBg.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:inputBg];
    
    NSRange range = [noticeContent rangeOfString:@"$!#"];
    if (range.length > 0)
    {
        scoreId = [noticeContent substringToIndex:range.location];
        noticeContent = [noticeContent substringFromIndex:range.location+range.length];
    }
    
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-20, 115)];
    contentTextView.backgroundColor = [UIColor whiteColor];
    contentTextView.editable = NO;
    contentTextView.textColor = CONTENTCOLOR;
    contentTextView.font = [UIFont systemFontOfSize:16];
    contentTextView.text = noticeContent;
    [self.bgView addSubview:contentTextView];
    
    
    UILabel *markLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 155-40, SCREEN_WIDTH-15, 25)];
    markLabel.text = markString;
    markLabel.textColor = TIMECOLOR;
    markLabel.font = [UIFont systemFontOfSize:12];
    [inputBg addSubview:markLabel];
    
    if ([scoreId length] > 0)
    {
        UIButton *scoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        scoreButton.frame = CGRectMake(SCREEN_WIDTH-90, markLabel.frame.origin.y, 80, 30);
        [scoreButton setTitle:@"查看详情" forState:UIControlStateNormal];
        [scoreButton setTitleColor:RGB(61, 197, 113, 1) forState:UIControlStateNormal];
        [inputBg addSubview:scoreButton];
        [scoreButton addTarget:self action:@selector(getScoreDetail) forControlEvents:UIControlEventTouchUpInside];
    }

    
    if ([c_read integerValue] == 0)
    {
        unreadButton.hidden = YES;
        readButton.hidden = YES;
        contentTextView.frame = CGRectMake(8, UI_NAVIGATION_BAR_HEIGHT+8, SCREEN_WIDTH-16, SCREEN_HEIGHT-16-UI_NAVIGATION_BAR_HEIGHT);
        containerScrollView.hidden = YES;
    }
    else
    {
        buttonNamesArray = [[NSMutableArray alloc] initWithCapacity:2];
        
        buttonHeight = 40;
        
        readButton = [UIButton buttonWithType:UIButtonTypeCustom];
        readButton.frame = CGRectMake(20, inputBg.frame.origin.y+inputBg.frame.size.height+9, 120, buttonHeight-10);
        [readButton setBackgroundColor:RGB(56, 188, 99, 1)];
        readButton.tag = 1000;
        readButton.layer.cornerRadius = 15;
        readButton.clipsToBounds = YES;
        [readButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [readButton setTitle:[NSString stringWithFormat:@"已读(%d)",0] forState:UIControlStateNormal];
        [readButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:readButton];
        
        unreadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        unreadButton.frame = CGRectMake(SCREEN_WIDTH/2+20, inputBg.frame.origin.y+inputBg.frame.size.height+9, 120, buttonHeight-10);
        unreadButton.backgroundColor = [UIColor clearColor];
        unreadButton.tag = 1001;
        unreadButton.layer.cornerRadius = 15;
        unreadButton.clipsToBounds = YES;
        [unreadButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        [unreadButton setTitle:[NSString stringWithFormat:@"未读(%d)",0] forState:UIControlStateNormal];
        [unreadButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:unreadButton];
        
        containerScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, readButton.frame.origin.y+buttonHeight, SCREEN_WIDTH,SCREEN_HEIGHT - readButton.frame.origin.y - buttonHeight)];
        containerScrollView.backgroundColor = [UIColor clearColor];
        containerScrollView.delegate = self;
        containerScrollView.tag = 1000;
        containerScrollView.bounces = NO;
        containerScrollView.pagingEnabled = YES;
        [self.bgView addSubview:containerScrollView];
        
        readedTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, containerScrollView.frame.size.height) style:UITableViewStylePlain];
        readedTableView.delegate = self;
        readedTableView.tag = ReadTableTag;
        readedTableView.dataSource = self;
        readedTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [containerScrollView addSubview:readedTableView];
        
        unreadTableView = [[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, containerScrollView.frame.size.height) style:UITableViewStylePlain];
        unreadTableView.tag = UnreadTabelTag;
        unreadTableView.delegate = self;
        unreadTableView.dataSource = self;
        unreadTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [containerScrollView addSubview:unreadTableView];
        
        containerScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*2, containerScrollView.frame.size.height);
    }
    
    if (isnew)
    {
        [self readNotice];
    }
    else if ([c_read integerValue] == 1)
    {
        [self getViewList:@"read"];
        [self getViewList:@"unread"];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getScoreDetail
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"e_id":scoreId,
                                                                      } API:SCOREDETAIL];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"score detail responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                
                NSArray *objectArray = [[responseDict objectForKey:@"data"] objectForKey:@"details"];
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"isTeacher"] integerValue] == 0)
                {
                    ScoreDetailViewController *scoreDetailViewController = [[ScoreDetailViewController alloc] init];
                    scoreDetailViewController.scoreId = scoreId;
                    scoreDetailViewController.testName = [[responseDict objectForKey:@"data"] objectForKey:@"name"];
                    [self.navigationController pushViewController:scoreDetailViewController animated:YES];
                }
                else if([[[responseDict objectForKey:@"data"] objectForKey:@"isTeacher"] integerValue] == 1)
                {
                    ScoreMemListViewController *memlist = [[ScoreMemListViewController alloc] init];
                    memlist.scoreid = scoreId;
                    [memlist.memListArray addObjectsFromArray:objectArray];
                    [self.navigationController pushViewController:memlist animated:YES];
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


-(void)moreClick
{
    if (fromClass)
    {
        OperatDB *db = [[OperatDB alloc] init];
        NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
        NSInteger userAdmin = [[dict objectForKey:@"admin"] integerValue];
        if ((userAdmin == 2 && [byID isEqualToString:[Tools user_id]]) || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
        }
        else if (userAdmin == 2 && ![byID isEqualToString:[Tools user_id]])
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除",@"举报", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
        }
        else if (userAdmin != 2 && ![byID isEqualToString:[Tools user_id]])
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
        }
    }
    else
    {
        if ([byID isEqualToString:[Tools user_id]])
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
        }
        else
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
        }
    }
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 3333)
    {
        if (fromClass)
        {
            OperatDB *db = [[OperatDB alloc] init];
            NSDictionary *dict = [[db findSetWithDictionary:@{@"classid":classID,@"uid":[Tools user_id]} andTableName:CLASSMEMBERTABLE] firstObject];
            NSInteger userAdmin = [[dict objectForKey:@"admin"] integerValue];
            if ((userAdmin == 2 && [byID isEqualToString:[Tools user_id]]) || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
            {
                if (buttonIndex == 0)
                {
                    [self deleteNotice];
                }
            }
            else if ((userAdmin == 2 && ![byID isEqualToString:[Tools user_id]]) || [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2)
            {
                if (buttonIndex == 0)
                {
                    [self deleteNotice];
                }
                else if(buttonIndex == 1)
                {
                    ReportViewController *reportVC = [[ReportViewController alloc] init];
                    reportVC.reportUserid = byID;
                    reportVC.reportContentID = noticeID;
                    reportVC.reportType = @"content";
                    [self.navigationController pushViewController:reportVC animated:YES];
                }
            }
            else if (userAdmin != 2 && ![byID isEqualToString:[Tools user_id]])
            {
                if (buttonIndex == 0)
                {
                    ReportViewController *reportVC = [[ReportViewController alloc] init];
                    reportVC.reportUserid = byID;
                    reportVC.reportContentID = noticeID;
                    reportVC.reportType = @"content";
                    [self.navigationController pushViewController:reportVC animated:YES];
                }
            }
        }
        else
        {
            if (buttonIndex == 0)
            {
                if ([byID isEqualToString:[Tools user_id]])
                {
                     [self deleteNotice];
                }
                else
                {
                    ReportViewController *reportVC = [[ReportViewController alloc] init];
                    reportVC.reportUserid = byID;
                    reportVC.reportContentID = noticeID;
                    reportVC.reportType = @"content";
                    [self.navigationController pushViewController:reportVC animated:YES];
                }
            }
            
        }
    }
}


-(void)deleteNotice
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":noticeID,
                                                                      @"c_id":classID
                                                                      } API:DELETENOTICE];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"del notice responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                DDLOG(@"read success!");
                
                if ([self.readnotificationDetaildel respondsToSelector:@selector(readNotificationDetail:deleted:)])
                {
                    [self.readnotificationDetaildel readNotificationDetail:noticeDict deleted:YES];
                }
                
                [self.navigationController popViewControllerAnimated:YES];
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

-(void)readNotice
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":noticeID,
                                                                      @"c_id":classID
                                                                      } API:READNTICES];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classInfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                DDLOG(@"read success!");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSNUMBER object:nil];
                
                if ([self.readnotificationDetaildel respondsToSelector:@selector(readNotificationDetail:deleted:)])
                {
                    [self.readnotificationDetaildel readNotificationDetail:noticeDict deleted:NO];
                }
                
                if ([c_read integerValue] == 1)
                {
                    [self getViewList:@"read"];
                    [self getViewList:@"unread"];
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
        }];
        [request startAsynchronous];
    }
}



-(void)buttonClick:(UIButton *)button
{
    if (button.tag == 1000)
    {
        [readButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [readButton setBackgroundColor:RGB(56, 188, 99, 1)];
        unreadButton.backgroundColor = [UIColor clearColor];
        [unreadButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    }
    else if(button.tag == 1001)
    {
        [readButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        [unreadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [unreadButton setBackgroundColor:RGB(56, 188, 99, 1)];
        readButton.backgroundColor = [UIColor clearColor];
    }
    [UIView animateWithDuration:0.2 animations:^{
        containerScrollView.contentOffset = CGPointMake(SCREEN_WIDTH*(button.tag%1000), 0);
    }];
}

#pragma mark - tableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == ReadTableTag)
    {
        return [readArray count];
    }
    else if(tableView.tag == UnreadTabelTag)
    {
        return [unreaderArray count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 47.5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == ReadTableTag)
    {
        static NSString *notificationDetailCell = @"notificationdetailcell";
        NotificationDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:notificationDetailCell];
        if (cell == nil)
        {
            cell = [[NotificationDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notificationDetailCell];
        }
       
        NSDictionary *dict = [readArray objectAtIndex:indexPath.row];
        [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERICON];
        cell.headerImageView.frame = CGRectMake(14, 6.5, 34, 34);
        cell.nameLabel.frame = CGRectMake(60, 8.75, 200, 30);
        
        if ([[dict objectForKey:@"role"] isEqualToString:@"parents"])
        {
            NSMutableString *titleStr = [[NSMutableString alloc] initWithString:[dict objectForKey:@"title"]];
            NSRange range = [titleStr rangeOfString:@"."];
            if (range.length > 0)
            {
                [titleStr replaceCharactersInRange:range withString:@"的"];
            }
            cell.nameLabel.text = [NSString stringWithFormat:@"%@（%@）",[dict objectForKey:@"name"],titleStr];
        }
        else
        {
            cell.nameLabel.text = [dict objectForKey:@"name"];
        }
        cell.nameLabel.backgroundColor = [UIColor clearColor];
        cell.nameLabel.textColor = DongTaiNameColor;
        cell.contactButton.hidden = YES;
        [cell.contactButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        [cell.contactButton setImage:[UIImage imageNamed:@"telephone1"] forState:UIControlStateNormal];
        cell.contactButton.titleLabel.font = [UIFont systemFontOfSize:18];
        cell.contactButton.frame = CGRectMake( SCREEN_WIDTH-120, 8.75, 30, 30);
        cell.contactButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        cell.contactButton.backgroundColor = [UIColor yellowColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
        lineImageView.backgroundColor = LineBackGroudColor;
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    else if(tableView.tag == UnreadTabelTag)
    {
        static NSString *notificationDetailCell = @"notificationdetailcell";
        NotificationDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:notificationDetailCell];
        if (cell == nil)
        {
            cell = [[NotificationDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notificationDetailCell];
        }
        NSDictionary *dict = [unreaderArray objectAtIndex:indexPath.row];
        cell.headerImageView.frame = CGRectMake(14, 6.5, 34, 34);
        [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERICON];
        
        if ([[dict objectForKey:@"role"] isEqualToString:@"parents"])
        {
            NSMutableString *titleStr = [[NSMutableString alloc] initWithString:[dict objectForKey:@"title"]];
            NSRange range = [titleStr rangeOfString:@"."];
            if (range.length > 0)
            {
                [titleStr replaceCharactersInRange:range withString:@"的"];
            }
            cell.nameLabel.text = [NSString stringWithFormat:@"%@（%@）",[dict objectForKey:@"name"],titleStr];
        }
        else
        {
            cell.nameLabel.text = [dict objectForKey:@"name"];
        }
        cell.nameLabel.frame = CGRectMake(60, 8.75, 200, 30);
        cell.nameLabel.backgroundColor = [UIColor clearColor];
        cell.nameLabel.textColor = DongTaiNameColor;
        cell.contactButton.hidden = NO;
        [cell.contactButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        [cell.contactButton setImage:[UIImage imageNamed:@"telephone1"] forState:UIControlStateNormal];
        
        cell.contactButton.titleLabel.font = [UIFont systemFontOfSize:18];
        cell.contactButton.frame = CGRectMake( SCREEN_WIDTH-60, 8, 30, 30);
        [cell.contactButton addTarget:self action:@selector(callUser:) forControlEvents:UIControlEventTouchUpInside];
        cell.contactButton.tag = UnreadTabelTag+indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
        lineImageView.backgroundColor = LineBackGroudColor;
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    return nil;
}

-(void)callUser:(UIButton *)button
{
    NSDictionary *dict = [unreaderArray objectAtIndex:button.tag - UnreadTabelTag];
    if (![[dict objectForKey:@"phone"] isEqual:[NSNull null]])
    {
        if ([[dict objectForKey:@"phone"] length] > 8)
        {
            [Tools dialPhoneNumber:[dict objectForKey:@"phone"] inView:self.bgView];
        }
        else
        {
            [self toUserDetail:dict];
        }
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CallAlterViewTag)
    {
        if (buttonIndex == 1)
        {
            [Tools dialPhoneNumber:phoneStr inView:self.bgView];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict;
    if (tableView.tag == UnreadTabelTag)
    {
        dict = [unreaderArray objectAtIndex:indexPath.row];
    }
    else
    {
        dict = [readArray objectAtIndex:indexPath.row];
    }
    [self toUserDetail:dict];
}

-(void)toUserDetail:(NSDictionary *)dict
{
    NSString *role = [dict objectForKey:@"role"];
    if ([role isEqualToString:@"students"])
    {
        StudentDetailViewController *studentDetail = [[StudentDetailViewController alloc] init];
        studentDetail.studentID = [dict objectForKey:@"_id"];
        studentDetail.studentName = [dict objectForKey:@"name"];
        studentDetail.title = [dict objectForKey:@"title"];
        studentDetail.headerImg = [dict objectForKey:@"img_icon"];
        studentDetail.role = [dict objectForKey:@"role"];
        [self.navigationController pushViewController:studentDetail animated:YES];
    }
    else if([role isEqualToString:@"parents"])
    {
        ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
        parentDetail.parentID = [dict objectForKey:@"_id"];
        parentDetail.parentName = [dict objectForKey:@"name"];
        parentDetail.title = [dict objectForKey:@"title"];
        parentDetail.headerImg = [dict objectForKey:@"img_icon"];
        parentDetail.admin = NO;
        parentDetail.role = [dict objectForKey:@"role"];
        [self.navigationController pushViewController:parentDetail animated:YES];
    }
    else if([role isEqualToString:@"teachers"])
    {
        MemberDetailViewController *teacherDetail = [[MemberDetailViewController alloc] init];
        teacherDetail.teacherID = [dict objectForKey:@"_id"];
        teacherDetail.teacherName = [dict objectForKey:@"name"];
        teacherDetail.title = [dict objectForKey:@"title"];
        teacherDetail.headerImg = [dict objectForKey:@"img_icon"];
        teacherDetail.admin = NO;
        teacherDetail.role = [dict objectForKey:@"role"];
        [self.navigationController pushViewController:teacherDetail animated:YES];
    }
}

#pragma mark - scrollview
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if(scrollView.tag == 1000)
    {
        CGFloat offsetX = scrollView.contentOffset.x;
        if (offsetX/SCREEN_WIDTH == 0)
        {
            [readButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [readButton setBackgroundColor:RGB(56, 188, 99, 1)];
            [unreadButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
            unreadButton.backgroundColor = [UIColor clearColor];
        }
        else
        {
            [readButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
            [unreadButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            readButton.backgroundColor = [UIColor clearColor];
            [unreadButton setBackgroundColor:RGB(56, 188, 99, 1)];
        }
    }
    DDLOG(@"%f",scrollView.contentOffset.x);
}

#pragma mark - getViewList
-(void)getViewList:(NSString *)listType
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":noticeID,
                                                                      @"list_type":listType
                                                                      } API:GETNOTICEVIEWLIST];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"notice_view_list responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [buttonNamesArray removeAllObjects];
                
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"unread_list"] count]>0)
                {
                    [unreaderArray addObjectsFromArray:[[[responseDict objectForKey:@"data"] objectForKey:@"unread_list"] allValues]];
                    for (int i = 0;i<[unreaderArray count];i++)
                    {
                        NSDictionary *dict = [unreaderArray objectAtIndex:i];
                        if ([[dict objectForKey:@"role"] isEqualToString:@"unin_students"])
                        {
                            [unreaderArray removeObject:dict];
                        }
                    }
                    [unreadTableView reloadData];
                }
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"read_list"] count]>0)
                {
                    [readArray addObjectsFromArray:[[[responseDict objectForKey:@"data"] objectForKey:@"read_list"] allValues]];
                    for (int i = 0;i<[readArray count];i++)
                    {
                        NSDictionary *dict = [readArray objectAtIndex:i];
                        if ([[dict objectForKey:@"role"] isEqualToString:@"unin_students"])
                        {
                            [readArray removeObject:dict];
                        }
                    }
                    [readedTableView reloadData];
                }
                if (![[[responseDict objectForKey:@"data"] objectForKey:@"read_num"] isEqual:[NSNull null]])
                {
                    [readButton setTitle:[NSString stringWithFormat:@"已读(%lu)",(unsigned long)[readArray count]] forState:UIControlStateNormal];
                }
                else
                {
                    [readButton setTitle:[NSString stringWithFormat:@"已读(%d)",0] forState:UIControlStateNormal];
                }
                if (![[[responseDict objectForKey:@"data"] objectForKey:@"unread_num"] isEqual:[NSNull null]])
                {
                    [unreadButton setTitle:[NSString stringWithFormat:@"未读(%lu)",(unsigned long)[unreaderArray count]] forState:UIControlStateNormal];
                }
                else
                {
                    [unreadButton setTitle:[NSString stringWithFormat:@"未读(%d)",0] forState:UIControlStateNormal];
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
        }];
        [request startAsynchronous];
    }

}
@end
