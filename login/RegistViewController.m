//
//  RegistViewController.m
//  School
//
//  Created by TeekerZW on 1/13/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "RegistViewController.h"
#import "Header.h"
#import "Regist3ViewController.h"
#import "UITextField+AKNumericFormatter.h"
#import "NSString+AKNumericFormatter.h"
#import "AKNumericFormatter.h"
#import "UserProtocolViewController.h"
#import "FillInfo2ViewController.h"

@interface RegistViewController ()<UITextFieldDelegate>
{
    MyTextField *phoneNumTextfield;
    MyTextField *codeTextField;
    NSString *codeStr;
    NSString *userid;
    
    UIButton *getCodeButton;
    
    NSTimer *timer;
    
    int sec;
}
@end

@implementation RegistViewController
@synthesize headerIcon,nickName,accountID,accountType,account;
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
    self.titleLabel.text = @"注册";
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    self.view.backgroundColor = [UIColor blackColor];
    
    sec = 60;
    
//    UIImage*inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 3, 20, 2.3)];
    
    phoneNumTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(29, 104+UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH-29-24.5, 42)];
    phoneNumTextfield.delegate = self;
    phoneNumTextfield.background = nil;
    phoneNumTextfield.layer.cornerRadius = 5;
    
    phoneNumTextfield.backgroundColor = [UIColor whiteColor];
    phoneNumTextfield.keyboardType = UIKeyboardTypeNumberPad;
    phoneNumTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneNumTextfield.tag = 1000;
    phoneNumTextfield.font = [UIFont systemFontOfSize:15];
    phoneNumTextfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    phoneNumTextfield.textColor = UIColorFromRGB(0x727171);
    phoneNumTextfield.placeholder = @"手机号码";
    phoneNumTextfield.numericFormatter = [AKNumericFormatter formatterWithMask:@"***********" placeholderCharacter:'*'];
    [self.bgView addSubview:phoneNumTextfield];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getCodeButton.frame = CGRectMake(SCREEN_WIDTH-100, phoneNumTextfield.frame.origin.y+5, 70, 32);
    [getCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [getCodeButton setTitle:@"短信验证" forState:UIControlStateNormal];
    getCodeButton.layer.cornerRadius = 1;
    getCodeButton.clipsToBounds = YES;
    getCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [getCodeButton addTarget:self action:@selector(nextStep) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:getCodeButton];
    
    codeTextField = [[MyTextField alloc] initWithFrame:CGRectMake(29, phoneNumTextfield.frame.origin.y+phoneNumTextfield.frame.size.height+5, SCREEN_WIDTH-29-24.5, 42)];
    codeTextField.delegate = self;
    codeTextField.background = nil;
    codeTextField.backgroundColor = [UIColor whiteColor];
    codeTextField.layer.cornerRadius = 5;
    codeTextField.font = [UIFont systemFontOfSize:15];
    codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    codeTextField.tag = 1000;
    codeTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    codeTextField.textColor = UIColorFromRGB(0x727171);
    codeTextField.placeholder = @"验证码";
    [self.bgView addSubview:codeTextField];
    
    UIButton *nextStepButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextStepButton.frame = CGRectMake(51, codeTextField.frame.origin.y+codeTextField.frame.size.height+46, SCREEN_WIDTH-102, 40);
    nextStepButton.backgroundColor = self.bgView.backgroundColor;
    [nextStepButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextStepButton addTarget:self action:@selector(verify) forControlEvents:
    UIControlEventTouchUpInside];
    [nextStepButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.bgView addSubview:nextStepButton];
    
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
    UIImageView *logoImageView = [[UIImageView alloc] init];
    logoImageView.image = logoImage;
    logoImageView.backgroundColor = [UIColor clearColor];
    logoImageView.alpha = 0.5;
    logoImageView.frame = CGRectMake((SCREEN_WIDTH-imageW)/2,nextStepButton.frame.size.height+nextStepButton.frame.origin.y+oriY, imageW, imageH);
    [self.bgView addSubview:logoImageView];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(51, nextStepButton.frame.size.height+nextStepButton.frame.origin.y+10, 135, 20)];
    tipLabel.text = @"注册本软件默认您已同意";
    tipLabel.textColor = TITLE_COLOR;
    tipLabel.backgroundColor = self.bgView.backgroundColor;
    tipLabel.font = [UIFont systemFontOfSize:12];
    [self.bgView addSubview:tipLabel];
    
    UIButton *proButton = [UIButton buttonWithType:UIButtonTypeCustom];
    proButton.frame = CGRectMake(185, nextStepButton.frame.size.height+nextStepButton.frame.origin.y+11, 100, 20);
    proButton.backgroundColor = self.bgView.backgroundColor;
    proButton.titleLabel.font = [UIFont systemFontOfSize:12.5];
    [proButton setTitle:@"《软件用户协议》" forState:UIControlStateNormal];
    [proButton setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
    [proButton addTarget:self action:@selector(openPro) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:proButton];
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)openPro
{
    UserProtocolViewController *userprotocol = [[UserProtocolViewController alloc] init];
    [self.navigationController pushViewController:userprotocol animated:YES];
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
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":[Tools getPhoneNumFromString:phoneNumTextfield.text],
                                                                      @"auth_code":codeTextField.text,
                                                                      @"regist":@"1"}
                                                                API:MB_CHECKOUT];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"verify responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                [[NSUserDefaults standardUserDefaults] setObject:[[responseDict objectForKey:@"data"] objectForKey:@"u_id"] forKey:USERID];
                [[NSUserDefaults standardUserDefaults] setObject:[[responseDict objectForKey:@"data"] objectForKey:@"token"] forKey:CLIENT_TOKEN];
                [[NSUserDefaults standardUserDefaults] setObject:phoneNumTextfield.text forKey:PHONENUM];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                FillInfo2ViewController *fillInfo = [[FillInfo2ViewController alloc] init];
                fillInfo.userid = [[responseDict objectForKey:@"data"] objectForKey:@"u_id"];
                fillInfo.token = [[responseDict objectForKey:@"data"] objectForKey:@"token"];
                [self.navigationController pushViewController:fillInfo animated:YES];
//                Regist3ViewController *regist3ViewController = [[Regist3ViewController alloc] init];
//                regist3ViewController.phoneNum = phoneNumTextfield.text;
//                regist3ViewController.userid = userid;
//                
//                if ([accountID length] > 0)
//                {
//                    regist3ViewController.accountID = accountID;
//                    regist3ViewController.accountType = accountType;
//                    regist3ViewController.nickName = nickName;
//                    regist3ViewController.headerIcon = headerIcon;
//                    regist3ViewController.account = account;
//                }
//                [self.navigationController pushViewController:regist3ViewController animated:YES];
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


-(void)getVerifyCode
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":userid} API:MB_AUTHCODE];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"== responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                codeStr = [responseDict objectForKey:@"data"];
                codeTextField.text = codeStr;
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


-(void)nextStep
{
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
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":[Tools getPhoneNumFromString:phoneNumTextfield.text]} API:MB_REG];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"uploadPhoneNum responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                userid = [responseDict objectForKey:@"data"];
                timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timeRefresh)userInfo:nil repeats:YES];
                [[NSRunLoop  currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - textfield
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
