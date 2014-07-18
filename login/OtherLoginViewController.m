//
//  OtherLoginViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-6-26.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "OtherLoginViewController.h"
#import "FillInfo2ViewController.h"
#import "SideMenuViewController.h"
#import "MyClassesViewController.h"
#import "HomeViewController.h"
#import "KKNavigationController.h"

@interface OtherLoginViewController ()
{
    NSMutableDictionary *accountDict;
    int reg;
}
@end

@implementation OtherLoginViewController

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
    
    self.titleLabel.text = @"其他方式登录";
    
    reg = 0;
    UIButton *sinaLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sinaLoginButton.backgroundColor = [UIColor clearColor];
    sinaLoginButton.frame = CGRectMake(40, UI_NAVIGATION_BAR_HEIGHT+37, SCREEN_WIDTH-80, 43);
    [sinaLoginButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    sinaLoginButton.tag=100;
    [sinaLoginButton setImage:[UIImage imageNamed:@"sina"] forState:UIControlStateNormal];
    [self.bgView addSubview:sinaLoginButton];
    
    UIButton *qqLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    qqLoginButton.backgroundColor = [UIColor clearColor];
    qqLoginButton.frame = CGRectMake(40, UI_NAVIGATION_BAR_HEIGHT+37+55, SCREEN_WIDTH-80, 43);
    [qqLoginButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    qqLoginButton.tag=101;
    [qqLoginButton setImage:[UIImage imageNamed:@"qq"] forState:UIControlStateNormal];
    [self.bgView addSubview:qqLoginButton];
    
    UIButton *renrenLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    renrenLoginButton.backgroundColor = [UIColor clearColor];
    renrenLoginButton.frame = CGRectMake(40, UI_NAVIGATION_BAR_HEIGHT+37+57+55, SCREEN_WIDTH-80, 43);
    [renrenLoginButton setImage:[UIImage imageNamed:@"rr"] forState:UIControlStateNormal];
    [renrenLoginButton addTarget:self action:@selector(clickedThirdLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    renrenLoginButton.tag=102;
    [self.bgView addSubview:renrenLoginButton];
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

#pragma mark - loginAccount
static int loginID;
- (void)clickedThirdLoginButton:(UIButton *)button{
    
    switch (button.tag-100) {
        case 0:
            
            loginID=1;
            
            break;
        case 1:
            loginID=6;
            
            break;
        case 2:
            loginID=7;
            break;
            
        default:
            break;
    }
    //[ShareSDK cancelAuthWithType:loginID];
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    [ShareSDK getUserInfoWithType:loginID
                      authOptions:authOptions
                           result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error){
                               if (result)
                               {
                                   DDLOG(@"success==%@",[userInfo sourceData]);
                                   
                                   accountDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                                   [accountDict setObject:[userInfo uid] forKey:@"a_id"];
                                   [accountDict setObject:[userInfo nickname] forKey:@"nickname"];
                                   [accountDict setObject:[userInfo profileImage] forKey:@"header_icon"];
                                   if (loginID == ShareTypeSinaWeibo)
                                   {
                                       //sina
                                       
                                       [accountDict setObject:@"sw" forKey:@"a_type"];
                                       
                                       [self loginWithName:[userInfo nickname]];
                                   }
                                   else if(loginID == ShareTypeQQSpace)
                                   {
                                       //qq
                                       
                                       [accountDict setObject:@"qq" forKey:@"a_type"];
                                       [self loginWithName:[userInfo nickname]];
                                   }
                                   else if(loginID == ShareTypeRenren)
                                   {
                                       //ren ren
                                       
                                       DDLOG(@"rrnickname  %@",RRNICKNAME);
                                       [accountDict setObject:@"rr" forKey:@"a_type"];
                                       [self loginWithName:[userInfo nickname]];
                                   }
                               }
                               else
                               {
                                   DDLOG(@"faile==%@==%ld==%d",[error errorDescription],(long)[error errorCode],[error errorLevel]);
                               }
                           }];
}

-(void)loginWithName:(NSString *)name   //AccountID:(NSString *)accountID accountType:(NSString *)accountType andName:(NSString *)name
{
    
    NSString *userStr = @"";
    if ([[APService registrionID] length] > 0)
    {
        userStr = [APService registrionID];
//        [Tools showAlertView:userStr delegateViewController:nil];
    }
    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"a_id":[accountDict objectForKey:@"a_id"],
                                                                      @"a_type":[accountDict objectForKey:@"a_type"],
                                                                      @"c_ver":[Tools client_ver],
                                                                      @"d_name":[Tools device_name],
                                                                      @"d_imei":[Tools device_uid],
                                                                      @"c_os":[Tools device_os],
                                                                      @"d_type":@"iOS",
                                                                      @"registrationID":userStr,
                                                                      @"n_name":name,
                                                                      @"r_name":name,
                                                                      @"sex":@"1",
                                                                      @"reg":[NSString stringWithFormat:@"%d",reg]
                                                                      } API:LOGINBYAUTHOR];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"account login responsedict %@",responseDict);
            
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *dict = [responseDict objectForKey:@"data"];
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:[dict objectForKey:@"u_id"] forKey:USERID];
                if ([Tools isPhoneNumber:[dict objectForKey:@"phone"]])
                {
                    [ud setObject:[dict objectForKey:@"phone"] forKey:PHONENUM];
                }
                [ud setObject:[dict objectForKey:@"token"] forKey:CLIENT_TOKEN];
                [ud setObject:[dict objectForKey:@"img_icon"] forKey:HEADERIMAGE];
                [ud setObject:[dict objectForKey:@"r_name"] forKey:USERNAME];
                [ud setObject:[dict objectForKey:@"opt"] forKey:@"useropt"];
                
                NSString *a_type = [accountDict objectForKey:@"a_type"];
                if ([a_type isEqualToString:@"qq"])
                {
                    [ud setObject:name forKey:QQNICKNAME];
                }
                else if([a_type isEqualToString:@"rr"])
                {
                    [ud setObject:name forKey:RRNICKNAME];
                }
                else if([a_type isEqualToString:@"sw"])
                {
                    [ud setObject:name forKey:SINANICKNAME];
                }
                
                [ud synchronize];
                
                SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
                HomeViewController *homeViewController = [[HomeViewController alloc] init];
                KKNavigationController *homeNav = [[KKNavigationController alloc] initWithRootViewController:homeViewController];
                JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:homeNav menuController:sideMenuViewController];
                [self.navigationController presentViewController:sideMenu animated:YES completion:^{
                    
                }];
                
            }
            else if([[responseDict objectForKey:@"code"] intValue] == 0 && [[[responseDict objectForKey:@"message"] objectForKey:@"NO_THE_ACCOUNT"] length]>0)
            {
                FillInfo2ViewController *fillInfo = [[FillInfo2ViewController alloc] init];
                fillInfo.headerIcon = [accountDict objectForKey:@"header_icon"];
                fillInfo.accountID = [accountDict objectForKey:@"a_id"];
                fillInfo.accountType = [accountDict objectForKey:@"a_type"];
                fillInfo.account = @"1";
                fillInfo.nickName = [accountDict objectForKey:@"nickname"];
                [self.navigationController pushViewController:fillInfo animated:YES];
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
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
