//
//  SettingPasswordViewController.m
//  School
//
//  Created by TeekerZW on 3/17/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "SettingPasswordViewController.h"
#import "FillInfoViewController.h"
#import "MyClassesViewController.h"
#import "SideMenuViewController.h"
#import "JDSideMenu.h"
#import "MyTextField.h"

@interface SettingPasswordViewController ()<UITextFieldDelegate>
{
    MyTextField *phoneNumTextfield;
    MyTextField *codeTextField;
    MyTextField *passwordTextField;
    MyTextField *verifyTextField;
    
    NSString *checkCode;
    UIButton *startButton;
    
    UIButton *getCodeButton;
    NSTimer *timer;
    
    NSInteger sec;
}

@end

@implementation SettingPasswordViewController
@synthesize phoneNum,user_id,forgetPwd;
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
    
    self.titleLabel.text = @"重置密码";
    
    DDLOG(@"phone=%@ user=%@",phoneNum,user_id);
    checkCode = @"";
    
    sec = 60;
    
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    self.view.backgroundColor = [UIColor blackColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(SCREEN_WIDTH/2-130, UI_NAVIGATION_BAR_HEIGHT+50, 200, 20);
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = COMMENTCOLOR;
    label.text = @"您的登录账号:";
    [self.bgView addSubview:label];
    
    
    phoneNumTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(29, label.frame.size.height+label.frame.origin.y+20, SCREEN_WIDTH-58, 42)];
    phoneNumTextfield.delegate = self;
    phoneNumTextfield.backgroundColor = [UIColor whiteColor];
    phoneNumTextfield.keyboardType = UIKeyboardTypeNumberPad;
    phoneNumTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneNumTextfield.tag = 1000;
    phoneNumTextfield.layer.cornerRadius = 5;
    phoneNumTextfield.background = nil;
    phoneNumTextfield.textColor = UIColorFromRGB(0x727171);
    phoneNumTextfield.text = phoneNum;
    phoneNumTextfield.enabled = NO;
    [self.bgView addSubview:phoneNumTextfield];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getCodeButton.frame = CGRectMake(SCREEN_WIDTH-91, phoneNumTextfield.frame.origin.y+5, 58, 32);
    [getCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [getCodeButton setTitle:@"短信验证" forState:UIControlStateNormal];
    getCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [getCodeButton addTarget:self action:@selector(getCheckCode) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:getCodeButton];
    
    codeTextField = [[MyTextField alloc] initWithFrame:CGRectMake(29, phoneNumTextfield.frame.size.height+phoneNumTextfield.frame.origin.y+4, SCREEN_WIDTH-58, 42)];
    codeTextField.delegate = self;
    codeTextField.backgroundColor = [UIColor whiteColor];
    codeTextField.background = nil;
    codeTextField.layer.cornerRadius = 5;
    codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    codeTextField.tag = 1000;
    codeTextField.textColor = UIColorFromRGB(0x727171);
    codeTextField.placeholder = @"验证码";
    [self.bgView addSubview:codeTextField];
    
    UIButton *checkCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    checkCodeButton.frame = CGRectMake(SCREEN_WIDTH-91, codeTextField.frame.origin.y+5, 58, 32);
    [checkCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [checkCodeButton setTitle:@"验证" forState:UIControlStateNormal];
    checkCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [checkCodeButton addTarget:self action:@selector(verify) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:checkCodeButton];
    
    passwordTextField = [[MyTextField alloc] initWithFrame:CGRectMake(29, codeTextField.frame.origin.y+codeTextField.frame.size.height+4, SCREEN_WIDTH-58, 42)];
    passwordTextField.delegate = self;
    passwordTextField.backgroundColor = [UIColor whiteColor];
    passwordTextField.secureTextEntry = YES;
    passwordTextField.placeholder = @"密码";
    passwordTextField.tag = 1000;
    passwordTextField.layer.cornerRadius = 5;
    passwordTextField.background = nil;
    passwordTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.bgView addSubview:passwordTextField];
    
    verifyTextField = [[MyTextField alloc] initWithFrame:CGRectMake(29, passwordTextField.frame.origin.y+passwordTextField.frame.size.height+4, SCREEN_WIDTH-58, 42)];
    verifyTextField.delegate = self;
    verifyTextField.secureTextEntry = YES;
    verifyTextField.tag = 1001;
    verifyTextField.backgroundColor = [UIColor whiteColor];
    verifyTextField.layer.cornerRadius = 5;
    verifyTextField.background = nil;
    verifyTextField.placeholder = @"再次输入密码";
    verifyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.bgView addSubview:verifyTextField];
    
    startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(SCREEN_WIDTH/2-60, verifyTextField.frame.origin.y+verifyTextField.frame.size.height+20, 120, 30);
    [startButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [startButton setTitle:@"提交" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    startButton.enabled = NO;
    [self.bgView addSubview:startButton];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [timer invalidate];
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
-(void)start
{
    if ([codeTextField.text length] == 0)
    {
        [Tools showAlertView:@"请您填写验证码" delegateViewController:nil];
        return ;
    }
//    if (![codeTextField.text isEqualToString:checkCode])
//    {
//        [Tools showAlertView:@"验证码错误" delegateViewController:nil];
//        return ;
//    }
    if ([passwordTextField.text length] == 0)
    {
        [Tools showAlertView:@"密码不能为空" delegateViewController:nil];
        return ;
    }
    if(![Tools isPassWord:passwordTextField.text])
    {
        [Tools showAlertView:@"密码由6-20位字母或数字组成" delegateViewController:nil];
        return ;
    }
    if ([verifyTextField.text length] == 0)
    {
        [Tools showAlertView:@"再次输入密码" delegateViewController:nil];
        return ;
    }
    if (![passwordTextField.text isEqualToString:verifyTextField.text])
    {
        [Tools showAlertView:@"两次密码不一致" delegateViewController:nil];
        return ;
    }
    
    
    NSString *userStr = @"";
    
    if ([[APService registrionID] length] > 0)
    {
        userStr = [APService registrionID];
//        [Tools showAlertView:userStr delegateViewController:nil];
    }

    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":user_id,
                                                                      @"pwd":verifyTextField.text,
                                                                      @"reg_method":[Tools reg_method],
                                                                      @"d_name":@"anonymity",@"d_name":[Tools device_name],
                                                                      @"d_imei":[Tools device_uid],
                                                                      @"c_ver":[Tools client_ver],
                                                                      @"c_os":[Tools device_version],
                                                                      @"d_type":@"iOS",
                                                                      @"registrationID":userStr,
                                                                      @"account":@"0"}
                                                                API:MB_SUBPWD];
        [request setCompletionBlock:^{
            
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"pass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (forgetPwd)
                {
                    [Tools showAlertView:@"密码重置成功" delegateViewController:nil];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                else
                {
                    [Tools showAlertView:@"密码重置成功" delegateViewController:nil];
                    [self.navigationController popViewControllerAnimated:YES];
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)getCheckCode
{
    if (sec != 60)
    {
        return ;
    }
    if ([phoneNumTextfield.text length] == 0)
    {
        [Tools showAlertView:@"请输入手机号码！" delegateViewController:nil];
        return ;
    }
    if (![Tools isPhoneNumber:[Tools getPhoneNumFromString:phoneNumTextfield.text]])
    {
        [Tools showAlertView:@"手机号格式不正确！" delegateViewController:nil];
        return ;
    }
    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":phoneNum} API:CHECKPHONE];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"login responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timeRefresh)userInfo:nil repeats:YES];
                [[NSRunLoop  currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                
//                getCodeButton.enabled = NO;
//                [[NSUserDefaults standardUserDefaults] setObject:[responseDict objectForKey:@"data"]forKey:USERID];
//                [[NSUserDefaults standardUserDefaults] synchronize];
                [self getVerifyCode];
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}
-(void)timeRefresh
{
    if (sec > 0)
    {
        sec--;
        [getCodeButton setTitle:[NSString stringWithFormat:@"等待%d",sec] forState:UIControlStateNormal];
    }
    else
    {
        [getCodeButton setTitle:@"重新获取" forState:UIControlStateNormal];
        getCodeButton.enabled = YES;
        [timer invalidate];
        sec = 60;
    }
}
-(void)getVerifyCode
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":phoneNum} API:MB_AUTHCODE];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"checkphone responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                checkCode = [responseDict objectForKey:@"data"];
                codeTextField.text = checkCode;
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
    
}
-(void)verify
{
    if ([codeTextField.text length] == 0)
    {
        [Tools showAlertView:@"请您填写验证码" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":[Tools getPhoneNumFromString:phoneNumTextfield.text],@"auth_code":codeTextField.text} API:MB_CHECKOUT];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"verify responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                user_id = [[responseDict objectForKey:@"data"] objectForKey:@"u_id"];
                startButton.enabled = YES;
                [Tools showAlertView:@"验证成功！" delegateViewController:nil];
                getCodeButton.hidden = YES;
                codeTextField.enabled = NO;
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}


@end
