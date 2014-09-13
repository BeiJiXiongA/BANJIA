//
//  MoreViewController.m
//  School
//
//  Created by TeekerZW on 14-1-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "MoreViewController.h"
#import "XDTabViewController.h"
#import "ClassMoreCell.h"

#define ParentSendDiaryTag  1000
#define StudentSendDiaryTag  2000
#define StudentAccessTimeTag  3000
#define VisitorAccessTimeTag   4000

@interface MoreViewController ()<UITableViewDataSource,
                                UITableViewDelegate,
                                UIPickerViewDataSource,
                                UIPickerViewDelegate,
UIAlertViewDelegate,
UIActionSheetDelegate>
{
    UITableView *classSettingTableView;
    NSArray *sectionArray;
    NSArray *rowsArray;
    
    NSString *parentsPublish;
    NSString *studentsPublish;
    NSString *accessTime;
    NSString *accessClassZone;
    
    UIView *selectTimeView;
    UIPickerView *startPickerView;
    NSMutableArray *timeArray;
    
    UIView *examineView;
    
    NSMutableArray *optionArray;
    
    NSMutableDictionary *settingDict;
    
    NSArray *settingKeysArray;
    
    BOOL first;
    
    NSString *classID;
}
@end

@implementation MoreViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)moreClick
{
    UIActionSheet *moreAction = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"退出班级", nil];
    moreAction.tag = 2000;
    [moreAction showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DDLOG(@"button index %d",buttonIndex);
    if (actionSheet.tag == ParentSendDiaryTag)
    {
        if (buttonIndex == 0)
        {
            [self settingValue:@"1" forKay:ParentSendDiary];
        }
        else if(buttonIndex == 1)
        {
            [self settingValue:@"2" forKay:ParentSendDiary];
        }
    }
    else if(actionSheet.tag == StudentSendDiaryTag)
    {
        if (buttonIndex == 0)
        {
            [self settingValue:@"1" forKay:StudentSendDiary];
        }
        else if(buttonIndex == 1)
        {
            [self settingValue:@"2" forKay:StudentSendDiary];
        }
    }
    else if (actionSheet.tag == StudentAccessTimeTag)
    {
        if (buttonIndex == 0 || buttonIndex == 1 || buttonIndex == 2)
        {
            [self settingValue:[NSString stringWithFormat:@"%d",buttonIndex] forKay:StudentVisiteTime];
        }
    }
    else if(actionSheet.tag == VisitorAccessTimeTag)
    {
        if (buttonIndex == 0 || buttonIndex == 1)
        {
            [self settingValue:[NSString stringWithFormat:@"%d",buttonIndex] forKay:VisitorAccess];
        }
        
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.titleLabel.text = @"班级设置";
    
    first = YES;
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
        
    settingDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - CORNERMORERIGHT, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [inviteButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    
    sectionArray = @[@{@"count":@"4",@"name":@"家长权限"},
                    @{@"count":@"4",@"name":@"学生权限"},
                     @{@"count":@"3",@"name":@"管理员权限"},
                     @{@"count": @"1",@"name":@"访客权限"},
                     @{@"count": @"1",@"name":@""}];
    
    rowsArray = @[@"允许家长评论",
                  @"允许家长加老师为好友",
                  @"家长发表班级日志",
                  @"家长邀请其他成员",
                  @"允许学生加老师为好友",
                  @"学生发表班级日记",
                  @"学生邀请其他成员",
                  @"学生访问时间",
                  @"邀请其他成员",
                  @"审核成员申请",
                  @"发布公告",
                  @"查看班级空间"];
    
    settingKeysArray = [NSArray arrayWithObjects:@"p_com",@"p_t_f",@"p_s_d",@"p_i_m",@"s_t_f",@"s_s_d",@"s_i_m",@"s_v_t",@"a_i_m",@"a_c_a",@"a_s_n",@"o_v_d", nil];
    
//    settingKeysArray = [NSArray arrayWithObjects:ParentComment,ParentTeacherFriend,ParentSendDiary,ParentInviteMem,StudentTeacherFriend,StudentSendDiary,StudentInviteMem,StudentAccessTimeTag,AdminInviteMem,AdminCheckApply,AdminSendNotice,VisitorAccess, nil];
    
    timeArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<24; i++)
    {
        if (i<10)
        {
            [timeArray addObject:[NSString stringWithFormat:@"0%d:00",i]];
        }
        else
        {
            [timeArray addObject:[NSString stringWithFormat:@"%d:00",i]];
        }
    }
    
    
    parentsPublish = @"直接发布";
    studentsPublish = @"需要审核";
    accessClassZone = @"前5条可查看";
    accessTime = @"全时段";
    
    classSettingTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT-5) style:UITableViewStylePlain];
    classSettingTableView.delegate = self;
    classSettingTableView.dataSource = self;
    classSettingTableView.backgroundColor = self.bgView.backgroundColor;
    classSettingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:classSettingTableView];
    
    selectTimeView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 220)];
    selectTimeView.backgroundColor = [UIColor grayColor];
    [self.bgView addSubview:selectTimeView];
    
    startPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 40, SCREEN_WIDTH-20, 160)];
    startPickerView.backgroundColor = [UIColor whiteColor];
    startPickerView.delegate = self;
    startPickerView.showsSelectionIndicator = YES;
    [selectTimeView addSubview:startPickerView];
    
    UIButton *selectDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectDoneButton setTitle:@"完成" forState:UIControlStateNormal];
    [selectDoneButton addTarget:self action:@selector(selectTimeDoneClick) forControlEvents:UIControlEventTouchUpInside];
    selectDoneButton.frame = CGRectMake(SCREEN_WIDTH - 50, 5, 40, 30);
    [selectTimeView addSubview:selectDoneButton];
    
    optionArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [self getSettingValues];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)selectButtonClick
{
    [UIView animateWithDuration:0.2 animations:^{
        selectTimeView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-110-UI_TAB_BAR_HEIGHT);
    }];
}

-(void)selectTimeDoneClick
{
    [UIView animateWithDuration:0.2 animations:^{
        selectTimeView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT+110);
        [classSettingTableView reloadData];
    }];
}

-(void)getSettingValues
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSDictionary *responseDict = [ud objectForKey:@"set"];
    if ([responseDict count] > 0)
    {
        [settingDict setDictionary:responseDict];
    }
    DDLOG(@"class set values responsedict %@",settingDict);
    if ([[settingDict objectForKey:ParentSendDiary] intValue] == 0)
    {
        parentsPublish = @"需要审核";
    }
    else if([[settingDict objectForKey:ParentSendDiary] intValue] == 1)
    {
        parentsPublish = @"直接发布";
    }
    else if([[settingDict objectForKey:ParentSendDiary] intValue] == 2)
    {
        parentsPublish = @"不可发布";
    }
    
    if ([[settingDict objectForKey:StudentSendDiary] intValue] == 0)
    {
        studentsPublish = @"需要审核";
    }
    else if([[settingDict objectForKey:StudentSendDiary] intValue] == 1)
    {
        studentsPublish = @"直接发布";
    }
    else if([[settingDict objectForKey:StudentSendDiary] intValue] == 2)
    {
        studentsPublish = @"不可发布";
    }
    
    if ([[settingDict objectForKey:StudentVisiteTime] intValue] == 0)
    {
        accessTime = @"晚上17点后";
    }
    else if([[settingDict objectForKey:StudentVisiteTime] intValue] == 1)
    {
        accessTime = @"全时段";
    }
    else if([[settingDict objectForKey:StudentVisiteTime] intValue] == 2)
    {
        accessTime = @"晚上19点后";
    }

    if ([[settingDict objectForKey:VisitorAccess] intValue] == 0)
    {
        accessClassZone = @"不可查看";
    }
    else if([[settingDict objectForKey:VisitorAccess] intValue] == 1)
    {
        accessClassZone = @"可查看前10条";
    }

    [classSettingTableView reloadData];
}

#pragma mark - pickerViewDelegate
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [timeArray count];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [timeArray objectAtIndex:row];
}

-(void)backClick
{
    [self.navigationController popViewControllerAnimated:YES];
//    [[XDTabViewController sharedTabViewController] dismissViewControllerAnimated:YES completion:nil];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionArray count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[sectionArray objectAtIndex:section] objectForKey:@"count"] intValue];
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[sectionArray objectAtIndex:section] objectForKey:@"name"];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section < [sectionArray count] -1)
    {
        return 30;
    }
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 42;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    headerView.backgroundColor = self.bgView.backgroundColor;
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH, 20)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = TITLE_COLOR;
    headerLabel.font = [UIFont systemFontOfSize:16];
    headerLabel.text = [[sectionArray objectAtIndex:section] objectForKey:@"name"];
    [headerView addSubview:headerLabel];
    
    return headerView;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"cellName";
    ClassMoreCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (cell == nil)
    {
        cell = [[ClassMoreCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    int row = 0;
    int section = indexPath.section;
    while (section > 0)
    {
        row += [[[sectionArray objectAtIndex:section-1] objectForKey:@"count"] intValue];
        section--;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    cell.lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
    cell.lineImageView.backgroundColor = LineBackGroudColor;
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    cell.switchView.hidden = YES;
    cell.contentLabel.hidden = YES;
    cell.button.hidden = YES;
    cell.nameLabel.hidden = YES;
    
    cell.nameLabel.frame = CGRectMake(10, 7, 200, 30);
    cell.nameLabel.textColor = TITLE_COLOR;
    if (indexPath.row+row < [rowsArray count])
    {
        cell.nameLabel.text = [rowsArray objectAtIndex:indexPath.row+row];
    }
    
    
    cell.switchView.tag = indexPath.row + row;
    cell.switchView.frame = CGRectMake( SCREEN_WIDTH-60, 7, 50, 30);
    [cell.switchView addTarget:self action:@selector(switchViewChange:) forControlEvents:UIControlEventValueChanged];
    int adminNum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] intValue];
    if (adminNum < 2)
    {
        cell.switchView.enabled = NO;
    }
    cell.contentLabel.font = [UIFont systemFontOfSize:14];
    if ([settingDict count] > 0)
    {
        cell.lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
        cell.switchView.hidden = NO;
        cell.contentLabel.hidden = YES;
        cell.nameLabel.hidden = NO;
        if (indexPath.row+row == 0)
        {
            if ([[settingDict objectForKey:ParentComment] intValue] == 0)
            {
                [cell.switchView isOn:NO];
            }
            else if([[settingDict objectForKey:ParentComment] intValue] == 1)
            {
                [cell.switchView isOn:YES];
            }
        }
        else if (indexPath.row+row == 1)
        {
            if ([[settingDict objectForKey:ParentTeacherFriend] intValue] == 0)
            {
                [cell.switchView isOn:NO];
            }
            else if([[settingDict objectForKey:ParentTeacherFriend] intValue] == 1)
            {
                [cell.switchView isOn:YES];
            }
        }
        else if (indexPath.row+row == 3)
        {
            if ([[settingDict objectForKey:ParentInviteMem] intValue] == 0)
            {
                [cell.switchView isOn:NO];
            }
            else if([[settingDict objectForKey:ParentInviteMem] intValue] == 1)
            {
                [cell.switchView isOn:YES];
            }
        }
        else if (indexPath.row+row == 4)
        {
            if ([[settingDict objectForKey:StudentTeacherFriend] intValue] == 0)
            {
                [cell.switchView isOn:NO];
            }
            else if([[settingDict objectForKey:StudentTeacherFriend] intValue] == 1)
            {
                [cell.switchView isOn:YES];
            }
        }
        else if (indexPath.row+row == 6)
        {
            if ([[settingDict objectForKey:StudentInviteMem] intValue] == 0)
            {
                [cell.switchView isOn:NO];
            }
            else if([[settingDict objectForKey:StudentInviteMem] intValue] == 1)
            {
                [cell.switchView isOn:YES];
            }
        }
        else if (indexPath.row+row == 8)
        {
            if ([[settingDict objectForKey:AdminInviteMem] intValue] == 0)
            {
                [cell.switchView isOn:NO];
            }
            else if([[settingDict objectForKey:AdminInviteMem] intValue] == 1)
            {
                [cell.switchView isOn:YES];
            }
        }
        else if (indexPath.row+row == 9)
        {
            if ([[settingDict objectForKey:AdminCheckApply] intValue] == 0)
            {
                [cell.switchView isOn:NO];
            }
            else if([[settingDict objectForKey:AdminCheckApply] intValue] == 1)
            {
                [cell.switchView isOn:YES];
            }
        }
        else if (indexPath.row+row == 10)
        {
            if ([[settingDict objectForKey:AdminSendNotice] intValue] == 0)
            {
                [cell.switchView isOn:NO];
            }
            else if([[settingDict objectForKey:AdminSendNotice] intValue] == 1)
            {
                [cell.switchView isOn:YES];
            }
            first = NO;
        }
        else
        {
            cell.switchView.hidden = YES;
            cell.contentLabel.frame = CGRectMake(SCREEN_WIDTH - 110, 7, 100, 30);
            cell.contentLabel.textColor = [UIColor colorWithRed:22.00/255.00 green:157.00/255.00 blue:195.00/255.00 alpha:1.0f];
            cell.contentLabel.font = [UIFont systemFontOfSize:12.0];
            if(indexPath.row + row == 2)
            {
                cell.contentLabel.hidden = NO;
                cell.nameLabel.hidden = NO;
                if([[settingDict objectForKey:ParentSendDiary] intValue] == 2)
                {
                    parentsPublish = @"不可发布";
                }
                else if([[settingDict objectForKey:ParentSendDiary] intValue] == 1)
                {
                    parentsPublish = @"直接发布";
                }
                cell.contentLabel.text = parentsPublish;
            }
            else if(indexPath.row + row == 5)
            {
                cell.contentLabel.hidden = NO;
                cell.nameLabel.hidden = NO;
                if([[settingDict objectForKey:StudentSendDiary] intValue] == 2)
                {
                    studentsPublish = @"不可发布";
                }
                else if([[settingDict objectForKey:StudentSendDiary] intValue] == 1)
                {
                    studentsPublish = @"直接发布";
                }
                cell.contentLabel.text = studentsPublish;
            }
            else if(indexPath.row + row == 7)
            {
                cell.contentLabel.hidden = NO;
                cell.nameLabel.hidden = NO;
                if ([[settingDict objectForKey:StudentVisiteTime] intValue] == 0)
                {
                    accessTime = @"晚上17点后";
                }
                else if([[settingDict objectForKey:StudentVisiteTime] intValue] == 1)
                {
                    accessTime = @"全时段";
                }
                else if([[settingDict objectForKey:StudentVisiteTime] intValue] == 2)
                {
                    accessTime = @"晚上19点后";
                }
                cell.contentLabel.text = accessTime;
            }
            else if(indexPath.row + row == 11)
            {
                cell.contentLabel.hidden = NO;
                cell.nameLabel.hidden = NO;
                if ([[settingDict objectForKey:VisitorAccess] intValue] == 1)
                {
                    accessClassZone = @"可查看前5条";
                }
                else if([[settingDict objectForKey:VisitorAccess] intValue] == 0)
                {
                    accessClassZone = @"不可查看";
                }
                cell.contentLabel.text = accessClassZone;
            }
            else if(indexPath.row + row == 12)
            {
                cell.button.hidden = NO;
                cell.contentLabel.hidden = YES;
                cell.nameLabel.hidden = YES;
                
                cell.button.frame = CGRectMake(40, 0, SCREEN_WIDTH-80, 42);
                [cell.button setTitle:@"解散班级" forState:UIControlStateNormal];
                [cell.button setBackgroundImage:[UIImage imageNamed:@"logout"] forState:UIControlStateNormal];
                [cell.button addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside];
                cell.backgroundColor = self.bgView.backgroundColor;
                cell.contentView.backgroundColor = self.bgView.backgroundColor;
                
                cell.lineImageView.frame = CGRectMake(0, 0, 0, 0);
            }
        }
    }
    return cell;
}

-(void)switchViewChange:(UISwitch *)switchItem
{
    if ([switchItem isOn])
    {
        [self settingValue:@"0" forKay:[settingKeysArray objectAtIndex:switchItem.tag]];
    }
    else
    {
        [self settingValue:@"1" forKay:[settingKeysArray objectAtIndex:switchItem.tag]];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int adminNum = [[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] intValue];
    if (adminNum<2)
    {
        return;
    }
    if (indexPath.section == 0)
    {
        if (indexPath.row == 2)
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"家长发布空间" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"直接发布",@"不可发布", nil];
            ac.tag = ParentSendDiaryTag;
            [ac showInView:classSettingTableView];
        }
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row == 1)
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"学生发布空间" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"直接发布",@"不可发布", nil];
            ac.tag = StudentSendDiaryTag;
            [ac showInView:classSettingTableView];
        }
        else if(indexPath.row == 3)
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"学生访问空间时间" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"晚上17点后",@"全时段",@"晚上19点后", nil];
            ac.tag = StudentAccessTimeTag;
            [ac showInView:classSettingTableView];
        }
    }
    else if(indexPath.section == 3)
    {
        if (indexPath.row == 0)
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"访客查看班级空间" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"不可查看",@"可查看5条", nil];
            ac.tag = VisitorAccessTimeTag;
            [ac showInView:classSettingTableView];
        }
    }
}

-(void)signOut
{
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定要解散这个班级吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    al.tag = 2222;
    [al show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2222)
    {
        if (buttonIndex == 1)
        {
            if ([Tools NetworkReachable])
            {
                __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                              @"token":[Tools client_token],
                                                                              @"c_id":classID
                                                                              } API:DELCLASS];
                [request setCompletionBlock:^{
                    [Tools hideProgress:self.bgView];
                    NSString *responseString = [request responseString];
                    NSDictionary *responseDict = [Tools JSonFromString:responseString];
                    DDLOG(@"del class responsedict %@",responseString);
                    if ([[responseDict objectForKey:@"code"] intValue]== 1)
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:CHANGECLASSINFO object:nil];
                        [[XDTabViewController sharedTabViewController] dismissViewControllerAnimated:YES completion:^{
                            
                        }];
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
    }
}

-(void)settingValue:(NSString *)value forKay:(NSString *)key
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"s_k":key,
                                                                      @"s_v":value
                                                                      } API:CLASSSETTING];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"more setting responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [settingDict setObject:value forKey:key];
                
                [[NSUserDefaults standardUserDefaults] setObject:settingDict forKey:@"set"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [classSettingTableView reloadData];
                
                [Tools showTips:@"设置成功" toView:self.bgView];
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
