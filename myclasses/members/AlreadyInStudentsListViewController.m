//
//  AlreadyInStudentsListViewController.m
//  BANJIA
//
//  Created by TeekerZW on 8/6/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "AlreadyInStudentsListViewController.h"
#import "NotificationDetailCell.h"
#define RestudentNumTag 1000


@interface AlreadyInStudentsListViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    UITableView *studentsTableView;
    OperatDB *db;
    NSString *classid;
}
@end

@implementation AlreadyInStudentsListViewController
@synthesize studentsArray,stulistdel,applyDict;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        studentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = @"确认学生身份";
    
    db = [[OperatDB alloc] init];
    classid = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    studentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-40, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    studentsTableView.delegate = self;
    studentsTableView.dataSource = self;
    studentsTableView.backgroundColor = self.bgView.backgroundColor;
    studentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:studentsTableView];
    
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

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 60;
    }
    else if (section == 1)
    {
        return 30;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = self.bgView.backgroundColor;
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.textColor = TITLE_COLOR;
    headerLabel.backgroundColor = self.bgView.backgroundColor;
    headerLabel.font = [UIFont systemFontOfSize:16];
    if (section == 0)
    {
        headerLabel.frame = CGRectMake(0, 10, SCREEN_WIDTH-60, 40);
        headerLabel.numberOfLines = 2;
        headerLabel.lineBreakMode = NSLineBreakByWordWrapping;
        headerLabel.text = @"我们发现申请人可能是您班级中一下学生的家长！请您确认";
    }
    else if(section == 1)
    {
        headerLabel.frame = CGRectMake(0, 5, SCREEN_WIDTH-60, 20);
        headerLabel.numberOfLines = 1;
        headerLabel.text = @"以上都不是该学生";
    }
    [headerView addSubview:headerLabel];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return [studentsArray count];
    }
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *childider = @"surestu";
        NotificationDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:childider];
        if (cell == nil)
        {
            cell = [[NotificationDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:childider];
        }
        cell.nameLabel.backgroundColor = [UIColor whiteColor];
        cell.nameLabel.textColor = CONTENTCOLOR;
        cell.nameLabel.font = [UIFont systemFontOfSize:15];
        
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        
        lineImageView.image = [UIImage imageNamed:@"sepretorline"];
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
        cell.headerImageView.hidden = NO;
        cell.nameLabel.hidden = NO;
        cell.button2.hidden = NO;
        cell.contactButton.hidden = NO;
        
        NSDictionary *studentDict = [studentsArray objectAtIndex:indexPath.row];
        DDLOG(@"students dict %@",studentDict);
        
        cell.headerImageView.frame = CGRectMake(10, 5, 40, 40);
        cell.nameLabel.frame = CGRectMake(60, 5, 200, 20);
        
        [Tools fillImageView:cell.headerImageView withImageFromURL:[studentDict objectForKey:@"img_icon"] andDefault:HEADERICON];
        
        if ([studentDict objectForKey:@"sn"] &&
            ![[studentDict objectForKey:@"sn"] isEqual:[NSNull null]] &&
            [[studentDict objectForKey:@"sn"] length] > 0)
        {
            cell.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",[studentDict objectForKey:@"name"],[studentDict objectForKey:@"sn"]];
        }
        else
        {
            cell.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",[studentDict objectForKey:@"name"],@"无学号"];
        }
        cell.numLabel.hidden = NO;
        if ([[studentDict objectForKey:@"parents"] count] > 0)
        {
            NSDictionary *parentDict = [[studentDict objectForKey:@"parents"] firstObject];
            NSString *markStr = [NSString stringWithFormat:@"家长：*%@",[[parentDict objectForKey:@"name"] substringFromIndex:1]];
            cell.numLabel.frame = CGRectMake(60, 25, 200, 20);
            cell.numLabel.text = markStr;
            cell.numLabel.font = [UIFont systemFontOfSize:15];
            cell.numLabel.textColor = COMMENTCOLOR;
        }
        else
        {
            cell.numLabel.text = @"";
        }
        
        cell.button2.frame = CGRectMake(SCREEN_WIDTH-90, 10, 40, 30);
        cell.button2.tag = indexPath.row;
        [cell.button2 setTitleColor:RGB(136, 193, 95, 1) forState:UIControlStateNormal];
        [cell.button2 setTitle:@"选择" forState:UIControlStateNormal];
        cell.button2.hidden = YES;
        [cell.button2 addTarget:self action:@selector(selealstu:) forControlEvents:UIControlEventTouchUpInside];
        if ([[studentDict objectForKey:@"role"] isEqualToString:@"unin_students"] || [[applyDict objectForKey:@"role"] isEqualToString:@"parents"])
        {
            cell.button2.hidden = NO;
        }
        return cell;
    }
    else if (indexPath.section == 1)
    {
        static NSString *childider = @"surestu";
        NotificationDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:childider];
        if (cell == nil)
        {
            cell = [[NotificationDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:childider];
        }
        cell.nameLabel.backgroundColor = [UIColor whiteColor];
        cell.nameLabel.textColor = CONTENTCOLOR;
        cell.nameLabel.font = [UIFont systemFontOfSize:15];
        cell.headerImageView.frame = CGRectMake(10, 5, 40, 40);
        
        cell.nameLabel.frame = CGRectMake(60, 5, 200, 30);
        
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        UIImageView *lineImageView = [[UIImageView alloc] init];
        
        lineImageView.image = [UIImage imageNamed:@"sepretorline"];
        [cell.contentView addSubview:lineImageView];
        cell.contentView.backgroundColor = [UIColor whiteColor];
        
        lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
        cell.headerImageView.hidden = NO;
        cell.nameLabel.hidden = NO;
        cell.button2.hidden = NO;
        cell.contactButton.hidden = NO;
        
        cell.headerImageView.frame = CGRectMake(10, 5, 40, 40);
        cell.nameLabel.frame = CGRectMake(60, 5, 200, 30);
        
        [cell.headerImageView setImage:[UIImage imageNamed:@"diary_add_image"]];
        
        NSString *studentsnum = @"";
        NSString *studentsname = @"";
        if ([[applyDict objectForKey:@"role"] isEqualToString:@"parents"])
        {
            if ([applyDict objectForKey:@"re_sn"] &&
                ![[applyDict objectForKey:@"re_sn"] isEqual:[NSNull null]] &&
                [[applyDict objectForKey:@"re_sn"] length] > 0)
            {
                
                studentsnum = [applyDict objectForKey:@"re_sn"];
            }
            studentsname = [applyDict objectForKey:@"re_name"];
        }
        else if([[applyDict objectForKey:@"role"] isEqualToString:@"students"])
        {
            if ([applyDict objectForKey:@"sn"] &&
                ![[applyDict objectForKey:@"sn"] isEqual:[NSNull null]] &&
                [[applyDict objectForKey:@"sn"] length] > 0)
            {
                
                studentsnum = [applyDict objectForKey:@"sn"];
            }
            studentsname = [applyDict objectForKey:@"name"];
        }
        if ([studentsnum length] > 0)
        {
            cell.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",studentsname,studentsnum];
        }
        else
        {
            cell.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",studentsname,@"无学号"];
        }
        
        cell.contactButton.frame = CGRectMake(60, 10, 200, 30);
        [cell.contactButton setTitle:@"" forState:UIControlStateNormal];
        cell.contactButton.hidden = NO;
        
        cell.contactButton.tag = indexPath.row;
        [cell.contactButton setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
        
        cell.button2.frame = CGRectMake(SCREEN_WIDTH-90, 10, 40, 30);
        cell.button2.tag = indexPath.row;
        [cell.button2 setTitle:@"创建" forState:UIControlStateNormal];
        cell.button2.hidden = NO;
        [cell.button2 addTarget:self action:@selector(create) forControlEvents:UIControlEventTouchUpInside];
        [cell.button2 setTitleColor:RGB(136, 193, 95, 1) forState:UIControlStateNormal];
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSDictionary *dict = [studentsArray objectAtIndex:indexPath.row];
        if ([[dict objectForKey:@"role"] isEqualToString:@"unin_students"] || [[applyDict objectForKey:@"role"] isEqualToString:@"parents"])
        {
            [self allowApplyWithReid:[dict objectForKey:@"_id"]];
        }
    }
    else
    {
        [self create];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)create
{
    for(NSDictionary *dict in studentsArray)
    {
        NSString *name = @"";
        NSString *stunum = @"";
        if ([[applyDict objectForKey:@"role"] isEqualToString:@"students"])
        {
            name = [applyDict objectForKey:@"name"];
            stunum = [applyDict objectForKey:@"sn"];
        }
        else if([[applyDict objectForKey:@"role"] isEqualToString:@"parents"])
        {
            name = [applyDict objectForKey:@"re_name"];
            stunum = [applyDict objectForKey:@"re_sn"];
        }
        if ([stunum isEqualToString:[dict objectForKey:@"sn"]] &&
            [name isEqualToString:[dict objectForKey:@"name"]])
        {
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:@"请输入学号加以区分" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            al.alertViewStyle = UIAlertViewStylePlainTextInput;
            al.tag = RestudentNumTag;
            [al show];
            return ;
        }
    }
    [self allowApplyWithReid:@""];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == RestudentNumTag)
    {
        if (buttonIndex == 1)
        {
            DDLOG(@"input stunum %@",[alertView textFieldAtIndex:0].text);
            NSString *stunum = [alertView textFieldAtIndex:0].text;
            if ([[applyDict objectForKey:@"role"] isEqualToString:@"students"])
            {
                [db updeteKey:@"sn" toValue:stunum withParaDict:@{@"classid":classid,@"uid":[applyDict objectForKey:@"uid"]} andTableName:CLASSMEMBERTABLE];
            }
            else if([[applyDict objectForKey:@"role"] isEqualToString:@"parents"])
            {
                [db updeteKey:@"re_sn" toValue:stunum withParaDict:@{@"classid":classid,@"uid":[applyDict objectForKey:@"uid"]} andTableName:CLASSMEMBERTABLE];
            }
            applyDict = [[db findSetWithDictionary:@{@"classid":classid,@"uid":[applyDict objectForKey:@"uid"]} andTableName:CLASSMEMBERTABLE] firstObject];
            [studentsTableView reloadData];
            
            [self allowApplyWithReid:@""];
        }
    }
}

-(void)selealstu:(UIButton *)button
{
    NSDictionary *dict = [studentsArray objectAtIndex:button.tag];
    [self allowApplyWithReid:[dict objectForKey:@"_id"]];
}

-(void)selestu:(NSString *)stuid
{
    if ([self.stulistdel respondsToSelector:@selector(selectUninstu:)])
    {
        [self.stulistdel selectUninstu:stuid];
    }
}

-(void)allowApplyWithReid:(NSString *)re_id
{
    if ([Tools NetworkReachable])
    {
        NSString *j_id = [applyDict objectForKey:@"uid"];
        NSString *applyName = [applyDict objectForKey:@"name"];
        
        NSDictionary *paraDict;
        if ([re_id length] > 0)
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"c_id":classid,
                         @"role":[applyDict objectForKey:@"role"],
                         @"j_id":[applyDict objectForKey:@"uid"],
                         @"sn":[applyDict objectForKey:@"re_sn"],
                         @"re_id":re_id
                         };
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"c_id":classid,
                         @"role":[applyDict objectForKey:@"role"],
                         @"j_id":[applyDict objectForKey:@"uid"],
                         @"sn":[applyDict objectForKey:@"sn"],
                         };
        }
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict API:ALLOWJOIN];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([db updeteKey:@"checked" toValue:@"1" withParaDict:@{@"uid":j_id,@"classid":classid,@"checked":@"0"} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"c_apply %@ delete success!",[Tools user_id]);
                    if ([[applyDict objectForKey:@"role"] isEqualToString:@"parents"])
                    {
                        NSDictionary *studentDict = [[db findSetWithDictionary:@{@"classid":classid,@"name":[applyDict objectForKey:@"re_name"],@"sn":[applyDict objectForKey:@"re_sn"]} andTableName:CLASSMEMBERTABLE] firstObject];
                        if ([[studentDict objectForKey:@"checked"] integerValue] == 0)
                        {
                            if ([db updeteKey:@"checked" toValue:@"1" withParaDict:@{@"classid":classid,@"name":[applyDict objectForKey:@"re_name"],@"sn":[applyDict objectForKey:@"re_sn"]} andTableName:CLASSMEMBERTABLE])
                            {
                                DDLOG(@"allow parent update student checked success!");
                            }
                        }
                    }
                    else if([[applyDict objectForKey:@"role"] isEqualToString:@"teachers"])
                    {
                        if ([db updeteKey:@"admin" toValue:@"1" withParaDict:@{@"uid":j_id,@"classid":classid} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"update teacher admin");
                        }
                    }
                    else if([[applyDict objectForKey:@"role"] isEqualToString:@"students"] )
                    {
                        if ([db deleteRecordWithDict:@{@"classid":classid,@"name":applyName,@"sn":[applyDict objectForKey:@"sn"]} andTableName:CLASSMEMBERTABLE])
                        {
                            NSDictionary *dict = @{@"classid":classid,
                                                   @"name":applyName,
                                                   @"uid":j_id,
                                                   @"img_icon":[applyDict objectForKey:@"img_icon"],
                                                   @"re_name":@"",
                                                   @"re_id":@"",
                                                   @"title":@"",
                                                   @"phone":[applyDict objectForKey:@"phone"],
                                                   @"checked":@"1",
                                                   @"role":@"students",
                                                   @"re_type":@"",
                                                   @"birth":[EmptyTools isEmpty:applyDict key:@"birth"]?@"":[applyDict objectForKey:@"birth"],
                                                   @"admin":@"0",
                                                   @"sn":[applyDict objectForKey:@"sn"],
                                                   @"re_sn":@""};
                            if ([db insertRecord:dict andTableName:CLASSMEMBERTABLE])
                            {
                                DDLOG(@"update students success");
                            }
                        }
                        //                        if ([db updeteKey:@"admin" toValue:@"1" withParaDict:@{@"uid":j_id,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        //                        {
                        //                            DDLOG(@"update students admin");
                        //                        }
                    }
                }
                [Tools showTips:[NSString stringWithFormat:@"您已经同意%@的申请",applyName] toView:self.bgView];
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
