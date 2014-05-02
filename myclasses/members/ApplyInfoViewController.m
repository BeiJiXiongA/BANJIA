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

@interface ApplyInfoViewController ()<UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *headerImageView;
    UILabel *nameLabel;
    UIImageView *genderImageView;
    UILabel *titleLabel;
    NSMutableDictionary *dataDict;
    UIImageView *bgImageView;
    
    NSString *phoneNum;
    
    UILabel *infoLabel;
    
    UITableView *infoView;
    UIButton *phoneButton;
    UILabel *phoneNumLabel;
}
@end

@implementation ApplyInfoViewController
@synthesize classID,role,j_id,applyName,title,applyDel,headerImg;
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
    DDLOG(@"j_id id=%@,classid = %@",j_id,classID);
    self.titleLabel.text = @"个人信息";
    dataDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    headerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(33.5, UI_NAVIGATION_BAR_HEIGHT+11, 80, 80)];
    headerImageView.backgroundColor = [UIColor greenColor];
    headerImageView.layer.cornerRadius = headerImageView.frame.size.width/2;
    headerImageView.clipsToBounds = YES;
    if ([headerImg length]>0)
    {
        [Tools fillImageView:headerImageView withImageFromURL:headerImg andDefault:HEADERDEFAULT];
    }
    else
    {
        [headerImageView setImage:[UIImage imageNamed:HEADERDEFAULT]];
    }
    [self.bgView addSubview:headerImageView];
    
    nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(headerImageView.frame.size.width+headerImageView.frame.origin.x+20, UI_NAVIGATION_BAR_HEIGHT+36, [applyName length]*18>100?100:([applyName length]*18), 20)];
    nameLabel.text = applyName;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:18];
    [self.bgView addSubview:nameLabel];
    
    genderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(nameLabel.frame.size.width+nameLabel.frame.origin.x, headerImageView.frame.origin.y, 15, 15)];
    genderImageView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:genderImageView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameLabel.frame.origin.x, nameLabel.frame.size.height+nameLabel.frame.origin.y, 150, 30)];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor lightGrayColor];
    titleLabel.numberOfLines = 2;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = title;
    [self.bgView addSubview:titleLabel];
    
    bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, headerImageView.frame.size.height+headerImageView.frame.origin.y+20, SCREEN_WIDTH, SCREEN_HEIGHT - headerImageView.frame.size.height-headerImageView.frame.origin.y)];
    [bgImageView setImage:[UIImage imageNamed:@"bg.jpg"]];
    [self.bgView addSubview:bgImageView];
    
    infoView  = [[UITableView alloc] initWithFrame:CGRectMake(10, bgImageView.frame.origin.y+50, SCREEN_WIDTH-15, 100) style:UITableViewStylePlain];
    infoView.delegate = self;
    infoView.dataSource = self;
//    infoView.separatorStyle = UITableViewCellSeparatorStyleNone;
    infoView.tag = 1000;
    infoView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:infoView];
    
    infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(29, infoView.frame.size.height + infoView.frame.origin.y+10, SCREEN_WIDTH-58, 20)];
    infoLabel.backgroundColor = [UIColor clearColor];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.textColor = [UIColor whiteColor];
    infoLabel.font = [UIFont systemFontOfSize:18];
    if ([role isEqualToString:@"students"])
    {
        infoLabel.text = [NSString stringWithFormat:@"%@想申请成为本班的学生",applyName];
    }
    else if ([role isEqualToString:@"teachers"])
    {
        infoLabel.text = [NSString stringWithFormat:@"%@想申请成为本班的%@",applyName,title];
    }
    else if ([role isEqualToString:@"parents"])
    {
        infoLabel.text = [NSString stringWithFormat:@"%@想申请成为本班%@",applyName,title];
    }
    [self.bgView addSubview:infoLabel];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    UIButton *allowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [allowButton setTitle:@"同意申请" forState:UIControlStateNormal];
    [allowButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [allowButton addTarget:self action:@selector(allowApplyByUID:classID:) forControlEvents:UIControlEventTouchUpInside];
    allowButton.frame = CGRectMake(29,infoView.frame.size.height + infoView.frame.origin.y+40, SCREEN_WIDTH-58, 40);
    [self.bgView addSubview:allowButton];
    
    UIButton *refuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [refuseButton setTitle:@"忽略申请" forState:UIControlStateNormal];
    [refuseButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [refuseButton addTarget:self action:@selector(refuseApplyByUID:classID:) forControlEvents:UIControlEventTouchUpInside];
    refuseButton.frame = CGRectMake(29, allowButton.frame.origin.y+allowButton.frame.size.height+20, SCREEN_WIDTH-58, 40);
    [self.bgView addSubview:refuseButton];
    
    [self getUserInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
     return 30;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.text = @"     个人信息";
    //    headerLabel.font = [UIFont systemFontOfSize:14];
    headerLabel.textColor = [UIColor whiteColor];
    return headerLabel;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *infocell = @"infocell";
    InfoCell *cell = [tableView dequeueReusableCellWithIdentifier:infocell];
    if (cell == nil)
    {
        cell = [[InfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:infocell];
    }
    if (indexPath.row == 0)
    {
        cell.nameLabel.text = @"移动电话";
        cell.contentLabel.text = [dataDict objectForKey:@"phone"];
        //        [cell.button1 addTarget:self action:@selector(msgToUser) forControlEvents:UIControlEventTouchUpInside];
        [cell.button2 addTarget:self action:@selector(callToUser) forControlEvents:UIControlEventTouchUpInside];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
#define CALLBUTTONTAG  2000
-(void)callToUser
{
    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要拨打这个电话吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拨打", nil];
    al.tag = CALLBUTTONTAG;
    phoneNum = [dataDict objectForKey:@"phone"];
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
                    nameLabel.text = [[responseDict objectForKey:@"data"] objectForKey:@"r_name"];
                    phoneNumLabel.text = [dataDict objectForKey:@"phone"];
                    [dataDict setDictionary:[responseDict objectForKey:@"data"]];
                    [Tools fillImageView:headerImageView withImageFromURL:[[responseDict objectForKey:@"data"] objectForKey:@"img_icon"] andDefault:@"0.jpg"];
                    if ([[dataDict objectForKey:@"sex"] intValue] == 1)
                    {
                        //男
                        [genderImageView setImage:[UIImage imageNamed:@"male"]];
                    }
                    else if ([[dataDict objectForKey:@"sex"] intValue] == 2)
                    {
                        //
                        [genderImageView setImage:[UIImage imageNamed:@"female"]];
                    }
                }
                [infoView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
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

-(void)allowApplyByUID:(NSString *)u_id classID:(NSString *)c_id
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
                NSString *messageStr = [NSString stringWithFormat:@"您已经同意%@的申请",nameLabel.text];
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:messageStr delegate:self cancelButtonTitle:@"返回" otherButtonTitles: nil];
                [al show];
                if ([self.applyDel respondsToSelector:@selector(updateList:)])
                {
                    [self.applyDel updateList:YES];
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
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }
}

-(void)refuseApplyByUID:(NSString *)u_id classID:(NSString *)c_id
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
                NSString *messageStr = [NSString stringWithFormat:@"您已经忽略%@的申请",nameLabel.text];
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:messageStr delegate:self cancelButtonTitle:@"返回" otherButtonTitles: nil];
                [al show];
                
                if ([self.applyDel respondsToSelector:@selector(updateList:)])
                {
                    [self.applyDel updateList:YES];
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
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }
    
}

@end
