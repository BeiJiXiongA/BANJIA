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
    
}
@end

@implementation NotificationDetailViewController
@synthesize noticeContent,noticeID,c_read,byID,readnotificationDetaildel,isnew;
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
//    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    self.view.backgroundColor = [UIColor blackColor];
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-60, 6, 50, 32);
    [moreButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    self.titleLabel.text = @"公告详情";
    readArray = [[NSMutableArray alloc] initWithCapacity:0];
    unreaderArray = [[NSMutableArray alloc] initWithCapacity:0];
    
//    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
//    UIImageView *inputBg = [[UIImageView alloc] initWithFrame:CGRectMake(4, UI_NAVIGATION_BAR_HEIGHT+5, SCREEN_WIDTH-8, 155)];
//    [inputBg setImage:inputImage];
//    [self.bgView addSubview:inputBg];
    
    contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, 152)];
    contentTextView.backgroundColor = [UIColor whiteColor];
    contentTextView.editable = NO;
    contentTextView.scrollEnabled = NO;
    contentTextView.contentInset = UIEdgeInsetsMake(10, 10, 18, 10);
    contentTextView.textColor = TITLE_COLOR;
    contentTextView.font = [UIFont systemFontOfSize:16];
    contentTextView.text = noticeContent;
    [self.bgView addSubview:contentTextView];

    
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
        readButton.frame = CGRectMake(20, contentTextView.frame.origin.y+contentTextView.frame.size.height+7, 120, buttonHeight-10);
        [readButton setBackgroundColor:RGB(56, 188, 99, 1)];
        readButton.tag = 1000;
        readButton.layer.cornerRadius = 15;
        readButton.clipsToBounds = YES;
        [readButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [readButton setTitle:[NSString stringWithFormat:@"已读(%d)",0] forState:UIControlStateNormal];
        [readButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:readButton];
        
        unreadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        unreadButton.frame = CGRectMake(SCREEN_WIDTH/2+20, contentTextView.frame.origin.y+contentTextView.frame.size.height+7, 120, buttonHeight-10);
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

-(void)moreClick
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2 && [byID isEqualToString:[Tools user_id]])
    {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除", nil];
        ac.tag = 3333;
        [ac showInView:self.bgView];
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2 && ![byID isEqualToString:[Tools user_id]])
    {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除",@"举报", nil];
        ac.tag = 3333;
        [ac showInView:self.bgView];
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] != 2 && ![byID isEqualToString:[Tools user_id]])
    {
        UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
        ac.tag = 3333;
        [ac showInView:self.bgView];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 3333)
    {
        
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2 && [byID isEqualToString:[Tools user_id]])
        {
            if (buttonIndex == 0)
            {
                [self deleteNotice];
            }
        }
        else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] == 2 && ![byID isEqualToString:[Tools user_id]])
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
        else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] != 2 && ![byID isEqualToString:[Tools user_id]])
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
                
                if ([self.readnotificationDetaildel respondsToSelector:@selector(readNotificationDetail)])
                {
                    [self.readnotificationDetaildel readNotificationDetail];
                }
                
                [self.navigationController popViewControllerAnimated:YES];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
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
                
                if ([self.readnotificationDetaildel respondsToSelector:@selector(readNotificationDetail)])
                {
                    [self.readnotificationDetaildel readNotificationDetail];
                }

                if ([c_read integerValue] == 1)
                {
                    [self getViewList:@"read"];
                    [self getViewList:@"unread"];
                }
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
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
        [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERBG];
        cell.headerImageView.frame = CGRectMake(14, 3.75, 40, 40);
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
        cell.nameLabel.textColor = TITLE_COLOR;
        cell.contactButton.hidden = YES;
        [cell.contactButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        [cell.contactButton setImage:[UIImage imageNamed:@"telephone1"] forState:UIControlStateNormal];
        cell.contactButton.titleLabel.font = [UIFont systemFontOfSize:18];
        cell.contactButton.frame = CGRectMake( SCREEN_WIDTH-120, 8.75, 30, 30);
        cell.contactButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        cell.contactButton.backgroundColor = [UIColor yellowColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        UIImage *inputImage = [UIImage imageNamed:@"line3"];
        UIImageView *bgImageBG = [[UIImageView alloc] initWithImage:inputImage];
        cell.backgroundView = bgImageBG;
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
        cell.headerImageView.frame = CGRectMake(14, 3.75, 40, 40);
        [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERBG];
        
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
        cell.nameLabel.textColor = TITLE_COLOR;
        cell.contactButton.hidden = NO;
        [cell.contactButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        [cell.contactButton setImage:[UIImage imageNamed:@"telephone1"] forState:UIControlStateNormal];
        
        cell.contactButton.titleLabel.font = [UIFont systemFontOfSize:18];
        cell.contactButton.frame = CGRectMake( SCREEN_WIDTH-60, 8, 30, 30);
        [cell.contactButton addTarget:self action:@selector(callUser:) forControlEvents:UIControlEventTouchUpInside];
        cell.contactButton.tag = UnreadTabelTag+indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImage *inputImage = [UIImage imageNamed:@"line3"];
        UIImageView *bgImageBG = [[UIImageView alloc] initWithImage:inputImage];
        cell.backgroundView = bgImageBG;
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
//                    for (int i=0; i<[unreaderArray count]; ++i)
//                    {
//                        NSString *unReadID = [[unreaderArray objectAtIndex:i] objectForKey:@"_id"];
//                        if ([unReadID isEqualToString:byID])
//                        {
//                            [unreaderArray removeObject:[unreaderArray objectAtIndex:i]];
//                            break;
//                        }
//                    }
                    [unreadTableView reloadData];
                }
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"read_list"] count]>0)
                {
                    [readArray addObjectsFromArray:[[[responseDict objectForKey:@"data"] objectForKey:@"read_list"] allValues]];
//                    for (int i=0; i<[readArray count]; ++i)
//                    {
//                        NSString *unReadID = [[readArray objectAtIndex:i] objectForKey:@"_id"];
//                        if ([unReadID isEqualToString:byID])
//                        {
//                            [readArray removeObject:[readArray objectAtIndex:i]];
//                            break;
//                        }
//                    }
                    [readedTableView reloadData];
                }
                if (![[[responseDict objectForKey:@"data"] objectForKey:@"read_num"] isEqual:[NSNull null]])
                {
                    [readButton setTitle:[NSString stringWithFormat:@"已读(%d)",[readArray count]] forState:UIControlStateNormal];
                }
                else
                {
                    [readButton setTitle:[NSString stringWithFormat:@"已读(%d)",0] forState:UIControlStateNormal];
                }
                if (![[[responseDict objectForKey:@"data"] objectForKey:@"unread_num"] isEqual:[NSNull null]])
                {
                    [unreadButton setTitle:[NSString stringWithFormat:@"未读(%d)",[unreaderArray count]] forState:UIControlStateNormal];
                }
                else
                {
                    [unreadButton setTitle:[NSString stringWithFormat:@"未读(%d)",0] forState:UIControlStateNormal];
                }

            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
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
