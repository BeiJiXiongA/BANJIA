//
//  LoginViewController.m
//  School
//
//  Created by TeekerZW on 1/13/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "LoginViewController.h"
#import "RegistViewController.h"
#import "Header.h"
#import "SideMenuViewController.h"
#import "JDSideMenu.h"
#import "MyClassesViewController.h"
#import "NSString+MD5.h"
#import "UITextField+AKNumericFormatter.h"
#import "NSString+AKNumericFormatter.h"
#import "AKNumericFormatter.h"
#import "SettingPasswordViewController.h"
#import "UIImage+URBImageEffects.h"
#import "UIImage-Helpers.h"

@interface LoginViewController ()<UITextFieldDelegate,UIAlertViewDelegate>
{
    MyTextField *phoneNumTextfield;
    UITextField *passwordTextfield;
    NSString *phoneNum;
    NSString *u_id;
}
@end

@implementation LoginViewController

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
    self.titleLabel.text = @"手机号登陆";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    UITextField *labelTf = [[UITextField alloc] init];
    labelTf.frame = CGRectMake(SCREEN_WIDTH/2-100, UI_NAVIGATION_BAR_HEIGHT+50, 35, 30);
    labelTf.backgroundColor = [UIColor yellowColor];
    labelTf.text = @"+86";
    labelTf.enabled = NO;
    labelTf.textAlignment = NSTextAlignmentRight;
//    [self.bgView addSubview:labelTf];
    
    UIImage*inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 3, 20, 2.3)];
    phoneNumTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(28, UI_NAVIGATION_BAR_HEIGHT+105, SCREEN_WIDTH-56, 36)];
    phoneNumTextfield.backgroundColor = [UIColor clearColor];
    phoneNumTextfield.delegate = self;
    phoneNumTextfield.keyboardType = UIKeyboardTypeNumberPad;
    phoneNumTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneNumTextfield.tag = 1000;
    phoneNumTextfield.textColor = TITLE_COLOR;
    phoneNumTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    phoneNumTextfield.background = inputImage;
    phoneNumTextfield.numericFormatter = [AKNumericFormatter formatterWithMask:@"***-****-****" placeholderCharacter:'*'];
    phoneNumTextfield.placeholder = @"手机号码";
    [self.bgView addSubview:phoneNumTextfield];
    
    
    passwordTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(28, phoneNumTextfield.frame.origin.y+phoneNumTextfield.frame.size.height+3, SCREEN_WIDTH-56, 36)];
    passwordTextfield.backgroundColor = [UIColor clearColor];
    passwordTextfield.delegate = self;
    passwordTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    passwordTextfield.secureTextEntry = YES;
    passwordTextfield.placeholder = @"密码";
    passwordTextfield.textColor = TITLE_COLOR;
    passwordTextfield.text = @"111111";
    passwordTextfield.background = inputImage;
    passwordTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    passwordTextfield.tag = 1001;
    [self.bgView addSubview:passwordTextfield];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loginButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    loginButton.frame = CGRectMake(28, passwordTextfield.frame.origin.y+passwordTextfield.frame.size.height + 25, 120, 40);
    [loginButton setTitle:@"登陆" forState:UIControlStateNormal];
    [loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:loginButton];
    
    UIImage *greenBtn = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg_green"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    
    UIButton *registButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [registButton setBackgroundImage:greenBtn forState:UIControlStateNormal];
    registButton.frame = CGRectMake(SCREEN_WIDTH/2 + 10, passwordTextfield.frame.size.height + passwordTextfield.frame.origin.y+ 25, 120, 40);
    [registButton setTitle:@"新用户注册" forState:UIControlStateNormal];
    [registButton addTarget:self action:@selector(regist) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:registButton];
    
    UIButton *forgetPasswordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetPasswordButton.backgroundColor = [UIColor clearColor];
    forgetPasswordButton.frame = CGRectMake(SCREEN_WIDTH/2 - 70, registButton.frame.size.height + registButton.frame.origin.y+ 10, 140, 30);
    [forgetPasswordButton setTitle:@"忘记密码？" forState:UIControlStateNormal];
    forgetPasswordButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [forgetPasswordButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [forgetPasswordButton addTarget:self action:@selector(forgetPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:forgetPasswordButton];
    
    CGFloat oriY = 0;
    if (FOURS)
    {
        oriY = 10;
    }
    else
    {
        oriY = 20;
    }
    
    UIImage *logoImage = [UIImage imageNamed:@"logo"];
    CGFloat imageH = logoImage.size.height-5;
    CGFloat imageW = logoImage.size.width-5;
//    
//    float quality = .00001f;
//    float blurred = .5f;
//    
//    NSData *imageData = UIImageJPEGRepresentation(logoImage, quality);
//    UIImage *blurredImage = [[UIImage imageWithData:imageData] blurredImage:blurred];
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.image = logoImage;
    logoImageView.backgroundColor = [UIColor clearColor];
    logoImageView.alpha = 0.5;
    logoImageView.frame = CGRectMake((SCREEN_WIDTH-imageW)/2,forgetPasswordButton.frame.size.height+forgetPasswordButton.frame.origin.y+oriY, imageW, imageH);
    [self.bgView addSubview:logoImageView];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)login
{
    if ([phoneNumTextfield.text length] == 0)
    {
        [Tools showAlertView:@"手机号不能为空！" delegateViewController:nil];
        return ;
    }
    phoneNum = [Tools getPhoneNumFromString:phoneNumTextfield.text];
    if (![Tools isPhoneNumber:phoneNum])
    {
        [Tools showAlertView:@"手机号格式不正确！" delegateViewController:nil];
        return ;
    }
    
    if ([passwordTextfield.text length] == 0)
    {
        [Tools showAlertView:@"密码不能为空" delegateViewController:nil];
        return ;
    }
    if (![Tools isPassWord:passwordTextfield.text])
    {
        [Tools showAlertView:@"密码由6-8位数字和字母组成！" delegateViewController:nil];
        return ;
    }
    
    if ([Tools NetworkReachable])
    {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        NSString *channelStr,*userStr;
        
        id channel = [ud objectForKey:BPushRequestChannelIdKey];
        if (channel == nil)
        {
            channelStr = @"0";
        }
        else
        {
            channelStr = [ud objectForKey:BPushRequestChannelIdKey];
        }
        id user_id = [ud objectForKey:BPushRequestUserIdKey];
        
        if (user_id == nil)
        {
            userStr = @"0";
        }
        else
        {
            userStr = [ud objectForKey:BPushRequestUserIdKey];
        }
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":phoneNum,
                                                                      @"pwd":passwordTextfield.text,
                                                                      @"c_ver":[Tools client_ver],
                                                                      @"d_name":[Tools device_name],
                                                                      @"d_imei":[Tools device_uid],
                                                                      @"c_os":[Tools device_os],
                                                                      @"d_type":@"iOS",
                                                                      @"p_cid":channelStr,
                                                                      @"p_uid":userStr
                                                                      } API:MB_LOGIN];
        
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"login responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *dict = [responseDict objectForKey:@"data"];
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:[dict objectForKey:@"u_id"] forKey:USERID];
                [ud setObject:phoneNum forKey:PHONENUM];
                [ud setObject:passwordTextfield.text forKey:PASSWORD];
                [ud setObject:[dict objectForKey:@"token"] forKey:CLIENT_TOKEN];
                [ud setObject:[dict objectForKey:@"img_icon"] forKey:HEADERIMAGE];
                [ud setObject:[dict objectForKey:@"r_name"] forKey:USERNAME];
                [ud setObject:[dict objectForKey:@"opt"] forKey:@"useropt"];
                [ud synchronize];
                
                SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
                MyClassesViewController *myClassesViewController = [[MyClassesViewController alloc] init];
                JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:myClassesViewController menuController:sideMenuViewController];
                [self presentViewController:sideMenu animated:YES completion:^{
                    
                }];
            }
            else
            {
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:[[[responseDict objectForKey:@"message"] allValues] firstObject] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去设置密码", nil];
                [al show];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        SettingPasswordViewController *setPw = [[SettingPasswordViewController alloc] init];
        setPw.phoneNum = phoneNum;
        setPw.forgetPwd =  NO;
        [setPw showSelfViewController:self];
    }
}

-(void)regist
{
    RegistViewController *registViewController = [[RegistViewController alloc] init];
    [registViewController showSelfViewController:self];
}

-(void)forgetPassword
{
    if ([phoneNumTextfield.text length] <= 0)
    {
        [Tools showAlertView:@"请填写手机号码" delegateViewController:nil];
        return ;
    }
    if (![Tools isPhoneNumber:[Tools getPhoneNumFromString:phoneNumTextfield.text]])
    {
        [Tools showAlertView:@"手机号格式不正确" delegateViewController:nil];
        return ;
    }
    SettingPasswordViewController *setpwd = [[SettingPasswordViewController alloc] init];
    setpwd.phoneNum = [Tools getPhoneNumFromString:phoneNumTextfield.text];
    setpwd.forgetPwd = YES;
    [setpwd showSelfViewController:self];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UIView *v in self.bgView.subviews)
    {
        if ([v isKindOfClass:[UITextField class]])
        {
            if (![v isExclusiveTouch])
            {
                [v resignFirstResponder];
                [UIView animateWithDuration:0.25 animations:^{
                    self.bgView.center = CENTER_POINT;
                }completion:^(BOOL finished) {
                    
                }];
            }
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.25 animations:^{
        
    }completion:^(BOOL finished) {
        
    }];
}
-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CENTER_POINT;
    }completion:^(BOOL finished) {
        
    }];
}

@end
