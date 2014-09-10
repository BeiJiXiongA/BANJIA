//
//  ApplyInfoViewController.m
//  School
//
//  Created by TeekerZW on 14-2-22.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ApplyInfoViewController.h"
#import "Header.h"
#import "InfoCell.h"
#import "AlreadyInStudentsListViewController.h"

#define INFOLABELTAG  1000
#define CALLBUTTONTAG  2000
#define MSGBUTTONTAG  3000
#define KICKALTAG    4000

#define BGIMAGEHEIGHT  150

#define RepeatStuTag   5000

@interface ApplyInfoViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,StuListDelegate>
{
    
    OperatDB *db;
    
    UITableView *infoView;
    NSString *classID;
    
    NSDictionary *applyDict;
    NSString *qqnum;
    NSString *birth;
    NSString *sexureimage;
    NSString *phoneNum;
    NSString *headerImg;
    
    NSString *studentNum;
    NSString *re_id;
    NSString *re_sn;
    NSString *userid;
    
    NSMutableArray *studentsArray;
    
    NSString *otherId;
    
    NSString *newsn;
}
@end

@implementation ApplyInfoViewController
@synthesize role,j_id,applyName,title;
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
    self.titleLabel.text = @"个人信息";
    qqnum = @"未绑定";
    birth = @"";
    sexureimage = @"";
    headerImg = @"";
    
    otherId = @"";
    newsn = @"";
    userid = @"";
    re_id = @"";

    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    db = [[OperatDB alloc] init];
    
    studentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    NSArray *apply = [db findSetWithDictionary:@{@"uid":j_id,@"classid":classID} andTableName:CLASSMEMBERTABLE];
    applyDict = [apply firstObject];
    
    if ([applyDict objectForKey:@"cb_id"] &&
        ![[applyDict objectForKey:@"cb_id"] isEqual:[NSNull null]] &&
        [[applyDict objectForKey:@"cb_id"] length] > 0)
    {
        userid = [applyDict objectForKey:@"cb_id"];
    }
    else if([applyDict objectForKey:@"re_id"] &&
            ![[applyDict objectForKey:@"re_id"] isEqual:[NSNull null]] &&
            [[applyDict objectForKey:@"re_id"] length] > 0)
    {
        re_id = [applyDict objectForKey:@"re_id"];
    }
    else
    {
        userid = j_id;
    }
    if (![j_id isEqual:[NSNull null]])
    {
        if ([j_id length] > 10)
        {
            DDLOG(@"database dict %@",applyDict);
            if (![EmptyTools isEmpty:applyDict key:@"phone"])
            {
                phoneNum = [applyDict objectForKey:@"phone"];
            }
            else
            {
                phoneNum = @"";
            }
            if (![EmptyTools isEmpty:applyDict key:@"img_icon"])
            {
                headerImg = [applyDict objectForKey:@"img_icon"];
            }
            else
            {
                headerImg = @"";
            }
            if ([applyDict objectForKey:@"sn"] && ![[applyDict objectForKey:@"sn"] isEqual:[NSNull null]])
            {
                studentNum = [applyDict objectForKey:@"sn"];
            }
            else
            {
                studentNum = @"";
            }
            if (![EmptyTools isEmpty:applyDict key:@"re_sn"])
            {
                re_sn = [applyDict objectForKey:@"re_sn"];
            }
            else
            {
                re_sn = @"";
            }
//            if (![EmptyTools isEmpty:applyDict key:@"sex"])
            if ([applyDict objectForKey:@"sex"] && ![[applyDict objectForKey:@"sex"] isEqual:[NSNull null]])
            {
                if ([[applyDict objectForKey:@"sex"] intValue] == 1)
                {
                    //男
                    sexureimage = @"male";
                }
                else
                {
                    //
                    sexureimage = @"female";
                }
            }
            
            if (![EmptyTools isEmpty:applyDict key:@"cb_id"])
            {
                otherId = [applyDict objectForKey:@"cb_id"];
            }
        }
    }
    
    infoView  = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    infoView.delegate = self;
    infoView.dataSource = self;
    infoView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:infoView];
    
    [self getUserInfo];
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

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        return 35;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if(section == 1)
    {
        return 5;
    }
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1)
    {
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.text = @"   个人信息";
        headerLabel.textColor = TITLE_COLOR;
        return headerLabel;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return BGIMAGEHEIGHT;
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row < 4)
        {
            if (indexPath.row == 0 && [phoneNum length] > 0)
            {
                return 40;
            }
            else if(indexPath.row == 1 && [birth length] > 0)
            {
                return 40;
            }
            else if(indexPath.row == 2 && [studentNum length] > 0)
            {
                return 40;
            }
            else if (indexPath.row == 2 &&[re_sn length] > 0)
            {
                return 40;
            }
            else if(indexPath.row == 3)
            {
                return 60;
            }
        }
        else
        {
            return 60;
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *infocell = @"applyinfocell";
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
        if ([headerImg isEqualToString:HEADERICON])
        {
            [cell.headerImageView setImage:[UIImage imageNamed:HEADERICON]];
        }
        else
        {
            [Tools fillImageView:cell.headerImageView withImageFromURL:headerImg andDefault:HEADERICON];
        }
        
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;
        cell.headerImageView.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.headerImageView.layer.borderWidth = 2;
        
        cell.nameLabel.frame = CGRectMake(DetailHeaderHeight+30, cell.headerImageView.frame.origin.y+10, [applyName length]*18, 20);
        cell.nameLabel.text = applyName;
        cell.nameLabel.shadowColor = TITLE_COLOR;
        cell.nameLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        cell.nameLabel.font = [UIFont boldSystemFontOfSize:18];
        
        cell.sexureImageView.frame = CGRectMake(cell.nameLabel.frame.origin.x+cell.nameLabel.frame.size.width+10, cell.nameLabel.frame.origin.y, 20, 20);
        [cell.sexureImageView setImage:[UIImage imageNamed:sexureimage]];
        
        NSMutableString *titlestr = [[NSMutableString alloc] initWithString:title];
        NSRange dotRange = [title rangeOfString:@"."];
        if (dotRange.length > 0)
        {
             [titlestr replaceCharactersInRange:[title rangeOfString:@"."] withString:@"的"];
        }
        
        cell.contentLabel.frame = CGRectMake(DetailHeaderHeight+30, cell.headerImageView.frame.origin.y+35, 100, 20);
//        cell.contentLabel.text = titlestr;
        cell.contentLabel.shadowOffset = CGSizeMake(0.5, 0.5);
        cell.contentLabel.shadowColor = TITLE_COLOR;
        cell.contentLabel.font = [UIFont boldSystemFontOfSize:14];
        cell.backgroundColor = [UIColor whiteColor];
    }
    else if (indexPath.section == 1)
    {
        if (indexPath.row < 3)
        {
            cell.nameLabel.frame = CGRectMake(15, 5, 100, 30);
            cell.nameLabel.textColor = TITLE_COLOR;
            cell.contentLabel.frame = CGRectMake(SCREEN_WIDTH-150, 5, 140, 30);
            cell.contentLabel.textColor = TITLE_COLOR;
            cell.contentLabel.textAlignment = NSTextAlignmentRight;
            if (indexPath.row == 0)
            {
                if ([phoneNum length] > 0)
                {
                    cell.nameLabel.text = @"手机号";
                    cell.contentLabel.text = phoneNum;
                }
                else
                {
                    cell.nameLabel.text = @"";
                    cell.contentLabel.text = phoneNum;
                }
            }
            else if(indexPath.row == 1)
            {
                if ([birth length] > 0)
                {
                    cell.nameLabel.text = @"生日";
                    cell.contentLabel.text = birth;

                }
                else
                {
                    cell.nameLabel.text = @"";
                    cell.contentLabel.text = birth;
                }
            }
            else if (indexPath.row == 2)
            {
                if ([studentNum length] > 0)
                {
                    cell.nameLabel.text = @"学号";
                    cell.contentLabel.text = studentNum;
                }
                else if ([re_sn length] > 0)
                {
                    cell.nameLabel.text = @"学生学号";
                    cell.contentLabel.text = re_sn;
                }
                else
                {
                    cell.nameLabel.text = @"";
                    cell.contentLabel.text = studentNum;
                }
            }
            
            CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
            UIImageView *lineImageView = [[UIImageView alloc] init];
            lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            lineImageView.image = [UIImage imageNamed:@"sepretorline"];
            [cell.contentView addSubview:lineImageView];
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        else if(indexPath.row == 3)
        {
            cell.nameLabel.frame = CGRectMake(15, 10, SCREEN_WIDTH-30, 40);
            cell.nameLabel.backgroundColor = self.bgView.backgroundColor;
            cell.nameLabel.textColor = TITLE_COLOR;
            cell.nameLabel.textAlignment = NSTextAlignmentCenter;
            cell.nameLabel.numberOfLines = 2;
            cell.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.contentView.backgroundColor = self.bgView.backgroundColor;
            cell.backgroundColor = self.bgView.backgroundColor;
            
            
            if (![role isEqual:[NSNull null]])
            {
                if ([role isEqualToString:@"students"] || [role isEqualToString:@"unin_students"])
                {
                    cell.nameLabel.text = [NSString stringWithFormat:@"%@想申请成为本班的学生",applyName];
                }
                else if ([role isEqualToString:@"teachers"])
                {
                    cell.nameLabel.text = [NSString stringWithFormat:@"%@想申请成为本班的%@",applyName,title];
                }
                else if ([role isEqualToString:@"parents"])
                {
                    cell.nameLabel.text = [NSString stringWithFormat:@"%@想申请成为本班%@",applyName,title];
                }
            }
            
            cell.contentView.backgroundColor = self.bgView.backgroundColor;
        }
        else
        {
            cell.button1.frame = CGRectMake(10, 10, 145, 43.5);
            [cell.button1 setTitle:ADDFRIEND forState:UIControlStateNormal];
            [cell.button1 setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
            
            [cell.button1 setTitle:@"同意申请" forState:UIControlStateNormal];
            
            [cell.button1 addTarget:self action:@selector(getStudentsByClassId) forControlEvents:UIControlEventTouchUpInside];
            
            cell.button2.frame = CGRectMake(165, 10, 145, 43.5);
            [cell.button2 setTitle:CHATTO forState:UIControlStateNormal];
            [cell.button2 setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
            [cell.button2 setTitle:@"忽略申请" forState:UIControlStateNormal];
            
            cell.button1.hidden = NO;
            cell.button2.hidden = NO;
            
            
            
            cell.button1.iconImageView.frame = CGRectMake(ALEFT, ATOP, CHATW, CHATH);
//            [cell.button1.iconImageView setImage:[UIImage imageNamed:@"add_friend"]];
            
            cell.button2.iconImageView.frame = CGRectMake(CLEFT, CTOP, ADDFRIW, ADDFRIH);
//            [cell.button2.iconImageView setImage:[UIImage imageNamed:@"chatto"]];
            
            [cell.button2 addTarget:self action:@selector(refuseApply) forControlEvents:UIControlEventTouchUpInside];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;

}
#define CALLBUTTONTAG  2000
-(void)callToUser
{
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要拨打这个电话吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    al.tag = CALLBUTTONTAG;
    [al show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == CALLBUTTONTAG)
    {
        if (buttonIndex == 1)
        {
            DDLOG(@"===%@",phoneNum);
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNum]]];
        }
    }
    else if(alertView.tag == RepeatStuTag)
    {
        if (buttonIndex == 1)
        {
            if ([[alertView textFieldAtIndex:0].text length] > 0)
            {
                newsn = [alertView textFieldAtIndex:0].text;
                [self allowApply];
            }
        }
    }
    else
    {
        [self unShowSelfViewController];
    }
}

-(void)getUserInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"other_id":userid,
                                                                      @"c_id":classID
                                                                      } API:MB_GETUSERINFO];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"apply info responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (![[responseDict objectForKey:@"data" ] isEqual:[NSNull null]])
                {
                    NSDictionary *dict = [responseDict objectForKey:@"data"];
                    
                    if ([dict objectForKey:@"phone"] && ![[dict objectForKey:@"phone"] isEqual:[NSNull null]])
                    {
                        if ([db updeteKey:@"phone" toValue:[dict objectForKey:@"phone"] withParaDict:@{@"uid":j_id,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"teach phone update success!");
                        }
                        phoneNum = [dict objectForKey:@"phone"];
                    }
                    
                    if ([dict objectForKey:@"sex"] && ![[dict objectForKey:@"sex"] isEqual:[NSNull null]])
                    {
                        if ([[dict objectForKey:@"sex"] integerValue] == 1)
                        {
                            //男
                            sexureimage = @"male";
                        }
                        else
                        {
                            //
                            sexureimage = @"female";
                        }
                        
                        if ([db updeteKey:@"sex" toValue:[dict objectForKey:@"sex"] withParaDict:@{@"uid":j_id,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"update sex success");
                        }
                    }
                    
                    if ([dict objectForKey:@"birth"] && ![[dict objectForKey:@"birth"] isEqualToString:@"请设置生日"])
                    {
                        if ([db updeteKey:@"birth" toValue:[dict objectForKey:@"birth"] withParaDict:@{@"uid":j_id,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"teach birth update success!");
                        }
                        birth = [dict objectForKey:@"birth"];
                    }
                    if ([dict objectForKey:@"img_icon"] && ![[dict objectForKey:@"img_icon"] isEqual:[NSNull null]])
                    {
                        headerImg = [dict objectForKey:@"img_icon"];
                    }
                }
                [infoView reloadData];
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

-(void)getStudentsByClassId
{
    NSString *name = @"";
    if ([Tools NetworkReachable])
    {
        if ([role isEqualToString:@"parents"])
        {
            name = [applyDict objectForKey:@"re_name"];
        }
        else
        {
            name = applyName;
        }
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"name":name
                                                                      } API:GETCHILDBYNAME];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getStudentByClassId responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                [studentsArray removeAllObjects];
                NSArray *tmpArray = [responseDict objectForKey:@"data"];
                for(NSDictionary *dict in tmpArray)
                {
                    if ([role isEqualToString:@"students"])
                    {
                        [studentsArray addObject:dict];
                    }
                    else if([role isEqualToString:@"students"] &&
                            [role isEqualToString:[dict objectForKey:@"role"]] &&
                            [[dict objectForKey:@"name"] isEqualToString:applyName] &&
                            [[dict objectForKey:@"sn"] isEqualToString:[applyDict objectForKey:@"sn"]])
                    {
                        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:@"班级中已存在同名同学号学生，请输入学号加以区分" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                        al.alertViewStyle = UIAlertViewStylePlainTextInput;
                        ((UITextField *)[al textFieldAtIndex:0]).keyboardType = UIKeyboardTypeNumberPad;
                        al.tag = RepeatStuTag;
                        [al show];
                        return ;
                    }
                    else if([role isEqualToString:@"parents"])
                    {
                        [studentsArray addObject:dict];
                    }
                }
                
                if ([studentsArray count] > 0 && [re_id length] == 0)
                {
                    AlreadyInStudentsListViewController *alreadyStu = [[AlreadyInStudentsListViewController alloc] init];
                    [alreadyStu.studentsArray addObjectsFromArray:studentsArray];
                    alreadyStu.stulistdel = self;
                    alreadyStu.applyDict = applyDict;
                    [self.navigationController pushViewController:alreadyStu animated:YES];
                }
                else
                {
                    [self allowApply];
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

-(void)selectUninstu:(NSString *)uninstuId
{
    otherId = uninstuId;
    [self allowApply];
}


-(void)allowApply
{
    if ([Tools NetworkReachable])
    {
        
        NSDictionary *paraDict;
        if ([otherId length] > 0)
        {
            if ([role isEqualToString:@"students"] || [role isEqualToString:@"unin_students"])
            {
                paraDict = @{@"u_id":[Tools user_id],
                             @"token":[Tools client_token],
                             @"c_id":classID,
                             @"role":role,
                             @"j_id":j_id,
                             @"unin_id":otherId
                             };
                
            }
            else if([role isEqualToString:@"parents"])
            {
                paraDict = @{@"u_id":[Tools user_id],
                             @"token":[Tools client_token],
                             @"c_id":classID,
                             @"role":role,
                             @"j_id":j_id,
                             @"re_id":otherId
                             };
            }
        }
        else if([newsn length] == 0 || [re_id length] > 0)
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"c_id":classID,
                         @"role":role,
                         @"j_id":j_id
                         };
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"c_id":classID,
                         @"role":role,
                         @"j_id":j_id,
                         @"sn":newsn
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
                if ([db updeteKey:@"checked" toValue:@"1" withParaDict:@{@"uid":j_id,@"classid":classID,@"checked":@"0"} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"c_apply %@ delete success!",[Tools user_id]);
                    if ([[applyDict objectForKey:@"role"] isEqualToString:@"parents"])
                    {
                         NSDictionary *studentDict = [[db findSetWithDictionary:@{@"classid":classID,@"name":[applyDict objectForKey:@"re_name"],@"sn":re_sn} andTableName:CLASSMEMBERTABLE] firstObject];
                        if ([[studentDict objectForKey:@"checked"] integerValue] == 0)
                        {
                            if ([db updeteKey:@"checked" toValue:@"1" withParaDict:@{@"classid":classID,@"name":[applyDict objectForKey:@"re_name"],@"sn":re_sn} andTableName:CLASSMEMBERTABLE])
                            {
                                DDLOG(@"allow parent update student checked success!");
                            }
                        }
                    }
                    else if([[applyDict objectForKey:@"role"] isEqualToString:@"teachers"])
                    {
                        if ([db updeteKey:@"admin" toValue:@"1" withParaDict:@{@"uid":j_id,@"classid":classID} andTableName:CLASSMEMBERTABLE])
                        {
                            DDLOG(@"update teacher admin");
                        }
                    }
                    else if([[applyDict objectForKey:@"role"] isEqualToString:@"students"] )
                    {
                        if ([db deleteRecordWithDict:@{@"classid":classID,@"name":applyName,@"sn":studentNum} andTableName:CLASSMEMBERTABLE])
                        {
                            NSDictionary *dict = @{@"classid":classID,
                                                   @"name":applyName,
                                                   @"uid":j_id,
                                                   @"img_icon":headerImg,
                                                   @"re_name":@"",
                                                   @"re_id":@"",
                                                   @"title":@"",
                                                   @"phone":phoneNum,
                                                   @"checked":@"1",
                                                   @"role":@"students",
                                                   @"re_type":@"",
                                                   @"birth":birth,
                                                   @"admin":@"0",
                                                   @"sn":studentNum,
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

-(void)refuseApply
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"role":role,
                                                                      @"j_id":j_id
                                                                      } API:REFUSEJOIN];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSString *messageStr = [NSString stringWithFormat:@"您已经忽略%@的申请",applyName];
                [Tools showTips:messageStr toView:self.bgView];
                
                if ([db deleteRecordWithDict:@{@"uid":j_id,@"classid":classID,@"checked":@"0"} andTableName:CLASSMEMBERTABLE])
                {
                    DDLOG(@"c_apply %@ delete success!",[Tools user_id]);
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

@end
