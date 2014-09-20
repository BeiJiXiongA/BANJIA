//
//  GroupInfoViewController.m
//  BANJIA
//
//  Created by TeekerZW on 7/23/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "GroupInfoViewController.h"
#import "BlankCell.h"
#import "OjectCell.h"
#import "LimitCell.h"
#import "PersonDetailViewController.h"
#import "QRCodeGenerator.h"

@interface GroupInfoViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView *groupInfoTableView;
    int row;
    CGFloat space;
    int columperrow;
    CGFloat headersize;
    
    NSDictionary *waitDeleteDict;
    
    UITapGestureRecognizer *imageTapTgr;
    
    OperatDB *db;
}
@end

#define EXITALTERTAG  1000
#define DELETEALTERTAG 2000

@implementation GroupInfoViewController
@synthesize groupID,groupUsers,builderID,updateGroupInfoDel,g_r_a,g_a_f;
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
        groupUsers = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = @"成员";
    
    DDLOG(@"users %d",[groupUsers count]);
    
    db = [[OperatDB alloc] init];
    if ([groupUsers count] > 0)
    {
        int count = [groupUsers count];
        columperrow = 4;
        headersize = 60;
        row = count%columperrow==0?(count/columperrow):(count/columperrow+1);
        space = (SCREEN_WIDTH-(columperrow*headersize))/(columperrow+1);
    }
    else
    {
        [self getGroupInfo];
    }
    
    groupInfoTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    groupInfoTableView.delegate = self;
    groupInfoTableView.dataSource = self;
    groupInfoTableView.backgroundColor = self.bgView.backgroundColor;
//    groupInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:groupInfoTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getGroupInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"g_id":groupID
                                                                      } API:GETGROUPINFO];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"get froup info responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                groupUsers = [[responseDict objectForKey:@"data"] objectForKey:@"users"];
                int count = [groupUsers count];
                columperrow = 4;
                headersize = 60;
                row = count%columperrow==0?(count/columperrow):(count/columperrow+1);
                space = (SCREEN_WIDTH-(columperrow*headersize))/(columperrow+1);
                for(NSDictionary *dict in groupUsers)
                {
                    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    [tmpDict setObject:[dict objectForKey:@"_id"]forKey:@"uid"];
                    if ([dict objectForKey:@"img_icon"])
                    {
                        [tmpDict setObject:[dict objectForKey:@"img_icon"] forKey:@"uicon"];
                    }
                    else
                    {
                        [tmpDict setObject:@"" forKey:@"uicon"];
                    }
                    [tmpDict setObject:[dict objectForKey:@"r_name"] forKey:@"username"];
                    if ([[db findSetWithDictionary:@{@"uid":[dict objectForKey:@"_id"]} andTableName:USERICONTABLE] count]>0)
                    {
                        [db deleteRecordWithDict:@{@"uid":[dict objectForKey:@"_id"]} andTableName:USERICONTABLE];
                        [db insertRecord:tmpDict andTableName:USERICONTABLE];
                    }
                    else
                    {
                        [db insertRecord:tmpDict andTableName:USERICONTABLE];
                    }
                    builderID = [[responseDict objectForKey:@"data"] objectForKey:@"builder"];
                    g_a_f = [[[responseDict objectForKey:@"data"] objectForKey:@"opt"] objectForKey:@"g_a_f"];
                    g_r_a = [[[responseDict objectForKey:@"data"] objectForKey:@"opt"] objectForKey:@"g_r_a"];
                }
                [groupInfoTableView reloadData];
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


#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 2;
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section < 3)
    {
        return 48;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = self.bgView.backgroundColor;
    UILabel *headerlabel = [[UILabel alloc] init];
    headerlabel.backgroundColor = self.bgView.backgroundColor;
    headerlabel.frame = CGRectMake(15, 12, 100, 30);
    [headerView addSubview:headerlabel];
    headerlabel.textColor = COMMENTCOLOR;
    if (section == 0)
    {
        headerlabel.text = @"群聊成员";
    }
    else if(section == 1)
    {
        headerlabel.text = @"设置";
    }
    else if(section == 2)
    {
        headerlabel.text = @"群聊二维码";
    }
    
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return row * (headersize+space+15)+space;
    }
    else if(indexPath.section == 2)
    {
        return 280;
    }
    else if(indexPath.section == 3)
    {
        return 60;
    }
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *cellid = @"blankcell";
        BlankCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil)
        {
            cell = [[BlankCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        }
        
        for(UIView *v in cell.contentView.subviews)
        {
            [v removeFromSuperview];
        }
        
        for (int i=0; i<[groupUsers count]; i++)
        {
            NSDictionary *dict = [groupUsers objectAtIndex:i];
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(space+(headersize+space)*(i%columperrow),space+(headersize+space+15)*(i/columperrow), headersize, headersize);
            imageView.layer.cornerRadius = 5;
            imageView.clipsToBounds = YES;
            imageView.layer.contentsGravity = kCAGravityResizeAspectFill;
            imageView.tag = i;
            [Tools fillImageView:imageView withImageFromURL:[dict objectForKey:@"img_icon"] andDefault:HEADERICON];
            [cell.contentView addSubview:imageView];
            
            UILabel *nameLabel = [[UILabel alloc] init];
            nameLabel.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y+imageView.frame.size.height, imageView.frame.size.width, 18);
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.textColor = COMMENTCOLOR;
            nameLabel.textAlignment = NSTextAlignmentCenter;
            nameLabel.text = [dict objectForKey:@"r_name"];
            [cell.contentView addSubview:nameLabel];
            nameLabel.font = [UIFont systemFontOfSize:12];
            
            imageTapTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerImageClick:)];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:imageTapTgr];
            
            if ([builderID isEqualToString:[Tools user_id]])
            {
                UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
                deleteButton.frame = CGRectMake(imageView.frame.origin.x-15, imageView.frame.origin.y-15, 30, 30);
                deleteButton.backgroundColor = [UIColor clearColor];
                [deleteButton setImage:[UIImage imageNamed:@"set_del"] forState:UIControlStateNormal];
                if (![[dict objectForKey:@"_id"] isEqualToString:builderID])
                {
                    [cell.contentView addSubview:deleteButton];
                }
                deleteButton.tag = i;
                [deleteButton addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            else if([[dict objectForKey:@"_id"] isEqualToString:builderID])
            {
                UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
                deleteButton.frame = CGRectMake(imageView.frame.origin.x+imageView.frame.size.width-15, imageView.frame.origin.y+imageView.frame.size.height-15, 20, 20);
                deleteButton.backgroundColor = RGB(228, 211, 134, 1);
                [deleteButton setImage:[UIImage imageNamed:@"builder"] forState:UIControlStateNormal];
                deleteButton.layer.cornerRadius = 3;
                deleteButton.clipsToBounds = YES;
                [cell.contentView addSubview:deleteButton];
            }
        }
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else  if (indexPath.section == 2)
    {
        static NSString *cellid = @"qrcodecell";
        BlankCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil)
        {
            cell = [[BlankCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        }

        
        UIImage *image = [ImageTools getQrImageWithString:[NSString stringWithFormat:@"%@?groupid=%@",@"http://www.banjiaedu.com/welcome/mobile",groupID] width:480];
        UIImageView *qrImageView = [[UIImageView alloc] init];
        qrImageView.frame = CGRectMake((SCREEN_WIDTH-240)/2, 0, 240, 240);
        [qrImageView setImage:image];
        [cell.contentView addSubview:qrImageView];
        
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, qrImageView.frame.size.height+qrImageView.frame.origin.y-5, SCREEN_WIDTH-40, 25)];
        tipLabel.text = @"让你的好友扫一扫二维码即可加入群聊";
        tipLabel.font = [UIFont systemFontOfSize:16];
        tipLabel.textColor = COMMENTCOLOR;
        [cell.contentView addSubview:tipLabel];
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.section == 3)
    {
        static NSString *cellid = @"exitgroupcell";
        OjectCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
        if (cell == nil)
        {
            cell = [[OjectCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
        }
        cell.nameLabel.hidden = YES;
        cell.selectButton.frame = CGRectMake(35, 10, SCREEN_WIDTH - 70, 40);
        cell.selectButton.layer.cornerRadius = 5;
        [cell.selectButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:@"exitgroupbtn"] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
        if ([builderID isEqualToString:[Tools user_id]])
        {
            [cell.selectButton setTitle:@"解散群聊" forState:UIControlStateNormal];
        }
        else
        {
            [cell.selectButton setTitle:@"退出群聊" forState:UIControlStateNormal];
        }
        
        if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        {
            [cell setSeparatorInset:UIEdgeInsetsMake(1000, 1001, 10011, 0)];
        }
        cell.backgroundColor = self.bgView.backgroundColor;
        [cell.selectButton addTarget:self action:@selector(exitButtonClick) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    static NSString *cellid = @"groupsetcell";
    LimitCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil)
    {
        cell = [[LimitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellid];
    }
    cell.markLabel.frame = CGRectMake(16, 10, 180, 30);
    cell.markLabel.textAlignment = NSTextAlignmentLeft;
    cell.markLabel.font = [UIFont systemFontOfSize:16];
    cell.markLabel.textColor = COMMENTCOLOR;
    if (indexPath.row == 0)
    {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        cell.markLabel.text = @"新消息提醒";
    }
    else if(indexPath.row == 1)
    {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)])
        {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        cell.markLabel.text = @"保存到我的好友";
    }
    cell.mySwitch.tag = indexPath.row;
    cell.mySwitch.frame = CGRectMake( SCREEN_WIDTH-60, 7, 50, 30);
    [cell.mySwitch addTarget:self action:@selector(switchViewChange:) forControlEvents:UIControlEventValueChanged];
    
    if (indexPath.row == 0)
    {
        if ([g_r_a integerValue] == 1)
        {
            [cell.mySwitch isOn:YES];
        }
        else
        {
            [cell.mySwitch isOn:NO];
        }
    }
    else if (indexPath.row == 1)
    {
        if ([g_a_f integerValue] == 1)
        {
            [cell.mySwitch isOn:YES];
        }
        else
        {
            [cell.mySwitch isOn:NO];
        }
    }
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)switchViewChange:(KLSwitch *)sw
{
    if (sw.tag == 0)
    {
        if ([sw isOn])
        {
            [self settingValue:@"1" forKay:@"g_r_a"];
        }
        else
        {
            [self settingValue:@"0" forKay:@"g_r_a"];
        }
    }
    else if(sw.tag == 1)
    {
        if ([sw isOn])
        {
            [self settingValue:@"1" forKay:@"g_a_f"];
        }
        else
        {
            [self settingValue:@"0" forKay:@"g_a_f"];
        }
    }
}

-(void)headerImageClick:(UITapGestureRecognizer *)tap
{
    NSDictionary *userDict = [groupUsers objectAtIndex:tap.view.tag];
    PersonDetailViewController *personDetailVC = [[PersonDetailViewController alloc] init];
    personDetailVC.personName = [userDict objectForKey:@"r_name"];
    personDetailVC.personID = [userDict objectForKey:@"_id"];
    personDetailVC.fromChat = NO;
    NSDictionary *iconDict = [[db findSetWithDictionary:@{@"uid":[userDict objectForKey:@"_id"]} andTableName:USERICONTABLE] firstObject];
    if (iconDict)
    {
        personDetailVC.headerImg = [iconDict objectForKey:@"uicon"];
    }
    [self.navigationController pushViewController:personDetailVC animated:YES];
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)deleteClick:(UIButton *)button
{
    waitDeleteDict = [groupUsers objectAtIndex:button.tag];
    DDLOG(@"delete dict %@",waitDeleteDict);
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"你确定要把[%@]从此群聊中移除吗？",[waitDeleteDict objectForKey:@"r_name"]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    al.tag = DELETEALTERTAG;
    [al show];
}

-(void)exitButtonClick
{
    NSString *msg;
    if (![builderID isEqualToString:[Tools user_id]])
    {
        msg = @"您确定要退出该闲群吗?";
    }
    else
    {
        msg = @"您确定要解散该闲群吗?";
    }
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    al.tag = EXITALTERTAG;
    [al show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == EXITALTERTAG)
    {
        if (buttonIndex == 1)
        {
            [self exitGroup];
        }
    }
    else if(alertView.tag == DELETEALTERTAG)
    {
        if (buttonIndex == 1)
        {
            [self deleteGroupUser:waitDeleteDict];
        }
    }
}

-(void)deleteGroupUser:(NSDictionary *)dict
{
    if ([Tools NetworkReachable])
    {
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"g_id":groupID,
                                                                      @"o_id":[dict objectForKey:@"_id"]
                                                                      } API:EXITGROUPCHAT];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"delete user responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([self.updateGroupInfoDel respondsToSelector:@selector(updateGroupInfo:)])
                {
                    [self.updateGroupInfoDel updateGroupInfo:YES];
                }
                [Tools showTips:@"踢出成功!" toView:groupInfoTableView];
                [groupUsers removeObject:dict];
                int count = [groupUsers count];
                row = count%columperrow==0?(count/columperrow):(count/columperrow+1);
                [groupInfoTableView reloadData];
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


-(void)exitGroup
{
    if ([Tools NetworkReachable])
    {
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"g_id":groupID,
                                                                      } API:EXITGROUPCHAT];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"friendsList responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                if ([db deleteRecordWithDict:@{@"userid":[Tools user_id],@"fid":groupID,@"direct":@"f"} andTableName:CHATTABLE] &&
                    [db deleteRecordWithDict:@{@"userid":[Tools user_id],@"tid":groupID,@"direct":@"t"} andTableName:CHATTABLE])
                {
                    DDLOG(@"exit group success!");
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATEGROUPCHATLIST object:nil];
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                if([[ud objectForKey:FROMWHERE]isEqualToString:FROMCLASS])
                {
                    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
                }
                else
                {
                    
                    if ([[db findSetWithDictionary:@{@"fid":groupID,@"userid":[Tools user_id]} andTableName:FRIENDSTABLE] count] > 0)
                    {
                        [db deleteRecordWithDict:@{@"fid":groupID,@"userid":[Tools user_id]} andTableName:FRIENDSTABLE];
                    }
                    [self.navigationController popToRootViewControllerAnimated:YES];
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
-(void)settingValue:(NSString *)value forKay:(NSString *)key
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"g_id":groupID,
                                                                      @"s_k":key,
                                                                      @"s_v":value
                                                                      } API:SETGROUPCHAT];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"group chat setting responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
//                [settingDict setObject:value forKey:key];
//                [classSettingTableView reloadData];
//                
//                [[NSUserDefaults standardUserDefaults] setObject:settingDict forKey:@"set"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [Tools showTips:@"设置成功" toView:groupInfoTableView];
                if ([self.updateGroupInfoDel respondsToSelector:@selector(updateGroupInfo:)])
                {
                    [self.updateGroupInfoDel updateGroupInfo:YES];
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
