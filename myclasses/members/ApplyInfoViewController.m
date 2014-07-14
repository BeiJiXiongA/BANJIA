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

#define INFOLABELTAG  1000
#define CALLBUTTONTAG  2000
#define MSGBUTTONTAG  3000
#define KICKALTAG    4000

#define BGIMAGEHEIGHT  150

@interface ApplyInfoViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
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
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    self.view.backgroundColor = [UIColor blackColor];
    
    qqnum = @"未绑定";
    birth = @"未设置";
    sexureimage = @"";
    headerImg = @"";

    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    db = [[OperatDB alloc] init];
    
    applyDict = [[db findSetWithDictionary:@{@"uid":j_id,@"classid":classID} andTableName:CLASSMEMBERTABLE] firstObject];
//    headerImg = [applyDict objectForKey:@"img_icon"];
//    if ([[applyDict objectForKey:@"birth"] isEqual:[NSNull null]])
//    {
//        birth = [applyDict objectForKey:@"birth"];
//    };
//    
//    role = [applyDict objectForKey:@"role"];

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
        return 4;
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
        if (indexPath.row < 3)
        {
            return 40;
        }
    }
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *infocell = @"onfocell";
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
        if (indexPath.row < 2)
        {
            cell.nameLabel.frame = CGRectMake(15, 5, 100, 30);
            cell.nameLabel.textColor = TITLE_COLOR;
            cell.contentLabel.frame = CGRectMake(SCREEN_WIDTH-150, 5, 140, 30);
            cell.contentLabel.textColor = TITLE_COLOR;
            cell.contentLabel.textAlignment = NSTextAlignmentRight;
            if (indexPath.row == 0)
            {
                cell.nameLabel.text = @"手机号";
                cell.contentLabel.text = phoneNum;
            }
            else if(indexPath.row == 1)
            {
                cell.nameLabel.text = @"生日";
                cell.contentLabel.text = birth;
            }
            UIImageView *bgImageBG = [[UIImageView alloc] init];
            bgImageBG.image = [UIImage imageNamed:@"line3"];
            bgImageBG.backgroundColor = [UIColor clearColor];
            cell.backgroundView = bgImageBG;
            cell.backgroundColor = [UIColor whiteColor];
        }
        else if(indexPath.row == 2)
        {
            cell.nameLabel.frame = CGRectMake(15, 5, SCREEN_WIDTH-30, 30);
            cell.nameLabel.backgroundColor = [UIColor whiteColor];
            cell.nameLabel.textColor = TITLE_COLOR;
            cell.contentView.backgroundColor = [UIColor whiteColor];
            
            
            if (![role isEqual:[NSNull null]])
            {
                if ([role isEqualToString:@"students"])
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
        }
        else
        {
            
            cell.button1.frame = CGRectMake(10, 10, 145, 43.5);
            [cell.button1 setTitle:ADDFRIEND forState:UIControlStateNormal];
            [cell.button1 setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
            
            [cell.button1 setTitle:@"同意申请" forState:UIControlStateNormal];
            
            [cell.button1 addTarget:self action:@selector(allowApply) forControlEvents:UIControlEventTouchUpInside];
            
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
                                                                      @"other_id":j_id,
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
                    
                    phoneNum = [[responseDict objectForKey:@"data"] objectForKey:@"phone"];
                    headerImg = [[responseDict objectForKey:@"data"] objectForKey:@"img_icon"];
                    
                    if ([[[responseDict objectForKey:@"data"] objectForKey:@"sex"] intValue] == 1)
                    {
                        //男
                        sexureimage = @"male";
                    }
                    else if ([[[responseDict objectForKey:@"data"] objectForKey:@"sex"] intValue] == 0)
                    {
                        //
                        sexureimage = @"famale";
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

-(void)allowApply
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"role":role,
                                                                      @"j_id":j_id
                                                                      } API:ALLOWJOIN];
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
                         NSDictionary *studentDict = [[db findSetWithDictionary:@{@"classid":classID,@"name":[applyDict objectForKey:@"re_name"],@"role":@"students"} andTableName:CLASSMEMBERTABLE] firstObject];
                        if ([[studentDict objectForKey:@"checked"] integerValue] == 0)
                        {
                            if ([db updeteKey:@"checked" toValue:@"1" withParaDict:@{@"classid":classID,@"name":[applyDict objectForKey:@"re_name"],@"role":@"students"} andTableName:CLASSMEMBERTABLE])
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
                    else if([[applyDict objectForKey:@"role"] isEqualToString:@"students"])
                    {
                        if ([db deleteRecordWithDict:@{@"classid":classID,@"name":applyName} andTableName:CLASSMEMBERTABLE])
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
                                                   @"admin":@"0"};
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
