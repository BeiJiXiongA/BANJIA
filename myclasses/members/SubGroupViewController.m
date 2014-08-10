//
//  SubGroupViewController.m
//  School
//
//  Created by TeekerZW on 14-3-5.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "SubGroupViewController.h"
#import "Header.h"
#include "MemberCell.h"
#import "ApplyInfoViewController.h"
#import "StudentDetailViewController.h"
#import "MemberDetailViewController.h"
#import "ParentsDetailViewController.h"
#import "OperatDB.h"
#import "GroupInfoViewController.h"
#import "ChatViewController.h"

@interface SubGroupViewController ()<UITableViewDataSource,
UITableViewDelegate,
StuDetailDelegate,
updateGroupInfoDelegate>
{
    UITableView *tmpTableView;
    OperatDB *db;
}
@end

@implementation SubGroupViewController
@synthesize tmpArray,classID,admin,subGroupDel,titleString,operateFriDel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    db = [[OperatDB alloc] init];
    
    self.titleLabel.text = titleString;
    
    DDLOG(@"tmp array %@",tmpArray);
    
    tmpTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    tmpTableView.delegate = self;
    tmpTableView.dataSource = self;
    tmpTableView.backgroundColor = [UIColor clearColor];
    tmpTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:tmpTableView];
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

-(void)updateGroupInfo:(BOOL)update
{
    
}

#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tmpArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([titleString isEqualToString:@"好友申请"])
    {
        static NSString *memCell = @"subgroup";
        MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:memCell];
        if (cell == nil)
        {
            cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:memCell];
        }
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        cell.headerImageView.frame = CGRectMake(10, 7, 46, 46);
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;

        cell.unreadedMsgLabel.hidden = YES;

        [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"ficon"] andDefault:HEADERDEFAULT];

        cell.memNameLabel.frame = CGRectMake(70, 15, 150, 30);
        cell.memNameLabel.text = [dict objectForKey:@"fname"];

        cell.button1.hidden = NO;
        cell.button2.hidden = NO;
        [cell.button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cell.button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cell.button1 setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
        [cell.button2 setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
        cell.button1.frame = CGRectMake(SCREEN_WIDTH-120, 15, 50, 30);
        cell.button2.frame = CGRectMake(SCREEN_WIDTH-60, 15, 50, 30);

        [cell.button1 setTitle:@"同意" forState:UIControlStateNormal];
        cell.button1.tag =indexPath.row+1000;
        [cell.button1 addTarget:self action:@selector(addFriend:) forControlEvents:UIControlEventTouchUpInside];
        [cell.button2 setTitle:@"忽略" forState:UIControlStateNormal];
        cell.button2.tag = indexPath.row+1000;
        [cell.button2 addTarget:self action:@selector(refuseFriend:) forControlEvents:UIControlEventTouchUpInside];

        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
        lineImageView.image = [UIImage imageNamed:@"sepretorline"];
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    else if([titleString isEqualToString:@"群聊"])
    {
        static NSString *groupChat = @"groupchat";
        MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:groupChat];
        if (cell == nil)
        {
            cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupChat];
        }
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        cell.memNameLabel.text = [dict objectForKey:@"fname"];
        cell.memNameLabel.frame = CGRectMake(70, 15, 220, 30);
        [cell.headerImageView setImage:[UIImage imageNamed:@"newapplyheader"]];
        
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
        lineImageView.image = [UIImage imageNamed:@"sepretorline"];
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    else
    {
        static NSString *memCell = @"subgroup";
        MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:memCell];
        if (cell == nil)
        {
            cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:memCell];
        }
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        cell.memNameLabel.text = [dict objectForKey:@"name"];
        
        cell.remarkLabel.hidden = YES;
        cell.button2.hidden = YES;
        cell.button1.hidden = YES;
        cell.remarkLabel.frame = CGRectMake(SCREEN_WIDTH - 130, 15, 100, 30);
        if ([[dict objectForKey:@"checked"] integerValue] == 0)
        {
            cell.remarkLabel.hidden = YES;
            cell.button2.hidden = NO;
            [cell.button2 setTitle:@"查看" forState:UIControlStateNormal];
            cell.button2.tag = indexPath.row + 3000;
            [cell.button2 addTarget:self action:@selector(checkApply:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            if ([[dict objectForKey:@"role"] isEqualToString:@"teachers"])
            {
                cell.remarkLabel.hidden = NO;
                cell.remarkLabel.text = [dict objectForKey:@"title"];
            }
            if ([[dict objectForKey:@"role"] isEqualToString:@"students"] && [[dict objectForKey:@"title"] length]>0)
            {
                cell.remarkLabel.hidden = NO;
                cell.remarkLabel.text = [dict objectForKey:@"title"];
            }
            
        }
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;
        [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERICON];
        
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
        lineImageView.image = [UIImage imageNamed:@"sepretorline"];
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    return nil;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
    if ([[dict objectForKey:@"checked"] intValue] == 0 || [titleString isEqualToString:@"新申请"])
    {
        ApplyInfoViewController *applyInfoViewController = [[ApplyInfoViewController alloc] init];
        applyInfoViewController.role = [dict objectForKey:@"role"];
        applyInfoViewController.j_id = [dict objectForKey:@"uid"];
        if (![[dict objectForKey:@"title"] isEqual:[NSNull null]])
        {
            applyInfoViewController.title = [dict objectForKey:@"title"];
        }
        else
        {
            applyInfoViewController.title = @"";
        }
        applyInfoViewController.applyName = [dict objectForKey:@"name"];
        [self.navigationController pushViewController:applyInfoViewController animated:YES];
    }
    else if ([[dict objectForKey:@"role"] isEqualToString:@"teachers"])
    {
        MemberDetailViewController *memDetail = [[MemberDetailViewController alloc] init];
        memDetail.teacherID = [dict objectForKey:@"uid"];
        memDetail.teacherName = [dict objectForKey:@"name"];
        memDetail.admin = YES;
        if (![[dict objectForKey:@"title"] isEqual:[NSNull null]])
        {
            memDetail.title = [dict objectForKey:@"title"];
        }
        if (admin)
        {
            memDetail.admin = YES;
        }
        else
        {
            memDetail.admin = NO;
        }
        [self.navigationController pushViewController:memDetail animated:YES];
    }
    else if([[dict objectForKey:@"role"] isEqualToString:@"parents"])
    {
        ParentsDetailViewController *parentDetail = [[ParentsDetailViewController alloc] init];
        parentDetail.parentID = [dict objectForKey:@"uid"];
        parentDetail.parentName = [dict objectForKey:@"name"];
        parentDetail.admin = YES;
        if (admin)
        {
            parentDetail.admin = YES;
        }
        else
        {
            parentDetail.admin = NO;
        }
        [self.navigationController pushViewController:parentDetail animated:YES];
    }
    else if([[dict objectForKey:@"role"] isEqualToString:@"students"])
    {
        StudentDetailViewController *studentDetail = [[StudentDetailViewController alloc] init];
        studentDetail.studentID = [dict objectForKey:@"uid"];
        studentDetail.studentName = [dict objectForKey:@"name"];
        studentDetail.memDel = self;
        studentDetail.admin = YES;
        if (![[dict objectForKey:@"title"] isEqual:[NSNull null]])
        {
            studentDetail.title = [dict objectForKey:@"title"];
        }
        if (admin)
        {
            studentDetail.admin = YES;
        }
        else
        {
            studentDetail.admin = NO;
        }
        [self.navigationController pushViewController:studentDetail animated:YES];
    }
    else if([titleString isEqualToString:@"群聊"])
    {
        ChatViewController  *chat = [[ChatViewController alloc] init];
        chat.isGroup = YES;
        chat.name = [dict objectForKey:@"fname"];
        chat.toID = [dict objectForKey:@"fid"];
        chat.imageUrl = @"";
        [self.navigationController pushViewController:chat animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - applydelegate
-(void)updateList:(BOOL)update
{
    if (update)
    {
        if ([titleString isEqualToString:@"新申请"])
        {
            [tmpArray removeAllObjects];
            [tmpArray addObjectsFromArray:[db findSetWithDictionary:@{@"classid":classID,@"checked":@"0"} andTableName:CLASSMEMBERTABLE]];
            [tmpTableView reloadData];
            if ([self.subGroupDel respondsToSelector:@selector(subGroupUpdate:)])
            {
                [self.subGroupDel subGroupUpdate:YES];
            }

        }
        else if ([titleString isEqualToString:@"管理员"])
        {
            [tmpArray removeAllObjects];
            [tmpArray addObjectsFromArray:[db findSetWithDictionary:@{@"classid":classID,@"admin":@"1"} andTableName:CLASSMEMBERTABLE]];
            [tmpArray addObjectsFromArray:[db findSetWithDictionary:@{@"classid":classID,@"admin":@"2"} andTableName:CLASSMEMBERTABLE]];
            [tmpTableView reloadData];
            if ([self.subGroupDel respondsToSelector:@selector(subGroupUpdate:)])
            {
                [self.subGroupDel subGroupUpdate:YES];
            }
        }
    }
}


#pragma mark - studentDetailDel
-(void)updateListWith:(BOOL)update
{
    if (update)
    {
        if ([titleString isEqualToString:@"管理员"])
        {
            [tmpArray removeAllObjects];
            [tmpArray addObjectsFromArray:[db findSetWithDictionary:@{@"classid":classID,@"admin":@"1"} andTableName:CLASSMEMBERTABLE]];
            [tmpArray addObjectsFromArray:[db findSetWithDictionary:@{@"classid":classID,@"admin":@"2"} andTableName:CLASSMEMBERTABLE]];
            [tmpTableView reloadData];
            if ([self.subGroupDel respondsToSelector:@selector(subGroupUpdate:)])
            {
                [self.subGroupDel subGroupUpdate:YES];
            }
        }
        if ([self.subGroupDel respondsToSelector:@selector(subGroupUpdate:)])
        {
            [self.subGroupDel subGroupUpdate:YES];
        }
    }
}

-(void)checkApply:(UIButton *)button
{
    NSDictionary *dict = [tmpArray objectAtIndex:button.tag - 3000];
    ApplyInfoViewController *applyInfoViewController = [[ApplyInfoViewController alloc] init];
    applyInfoViewController.role = [dict objectForKey:@"role"];
    applyInfoViewController.j_id = [dict objectForKey:@"uid"];
    applyInfoViewController.title = [dict objectForKey:@"title"];
    applyInfoViewController.applyName = [dict objectForKey:@"name"];
    [self.navigationController pushViewController:applyInfoViewController animated:YES];
}

-(void)addFriend:(UIButton *)button
{
    NSDictionary *dict = [tmpArray objectAtIndex:button.tag%1000];
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":[dict objectForKey:@"fid"]
                                                                      } API:MB_ADD_FRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"addfriends responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([db updeteKey:@"checked" toValue:@"1" withParaDict:@{@"fid":[dict objectForKey:@"fid"],@"uid":[Tools user_id]} andTableName:FRIENDSTABLE])
                {
                    DDLOG(@"delete friend apply success");
                }
                [self operateFriendsList:[db findSetWithDictionary:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE] andDataType:@"database"];
                
                if ([self.operateFriDel respondsToSelector:@selector(updataFriends:)])
                {
                    [self.operateFriDel updataFriends:YES];
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
-(void)refuseFriend:(UIButton *)button
{
    NSDictionary *dict = [tmpArray objectAtIndex:button.tag%1000];
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":[dict objectForKey:@"fid"]
                                                                      } API:MB_REFUSE_FRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"refusefriends responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([db deleteRecordWithDict:@{@"fid":[dict objectForKey:@"fid"],@"uid":[Tools user_id]} andTableName:FRIENDSTABLE])
                {
                    DDLOG(@"delete friend apply success");
                }
                [self operateFriendsList:[db findSetWithDictionary:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE] andDataType:@"database"];
                
                if ([self.operateFriDel respondsToSelector:@selector(updataFriends:)])
                {
                    [self.operateFriDel updataFriends:YES];
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
-(void)operateFriendsList:(NSArray *)tmpFriendsList andDataType:(NSString *)datatype
{
    [tmpArray removeAllObjects];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:UCFRIENDSUM];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [tmpArray addObjectsFromArray:[db findSetWithDictionary:@{@"uid":[Tools user_id],@"checked":@"0"} andTableName:FRIENDSTABLE]];
    [tmpTableView reloadData];
}
@end
