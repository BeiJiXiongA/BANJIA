//
//  ChangePhoneViewController.m
//  School
//
//  Created by TeekerZW on 4/3/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "ChangePhoneViewController.h"
#import "Header.h"

@interface ChangePhoneViewController ()<UITextFieldDelegate>
{
    MyTextField *phoneNumTextfield;
    MyTextField *codeTextField;
    
    NSString *checkCode;
    UIButton *changeButton;
    UIButton *getCodeButton;
    
    NSInteger sec;
    NSTimer *timer;
    NSString *codeStr;
    
    NSString *getCodePhoneNumber;
}
@end

@implementation ChangePhoneViewController
@synthesize changePhoneDel;
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
    self.titleLabel.text = @"绑定手机号";
    
    sec = 60;
    getCodePhoneNumber = @"";
    
    UIImage*inputImage = [Tools getImageFromImage:[UIImage imageNamed:@""] andInsets:UIEdgeInsetsMake(20, 3, 20, 2.3)];
    
    phoneNumTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(29, UI_NAVIGATION_BAR_HEIGHT+100, SCREEN_WIDTH-58, 42)];
    phoneNumTextfield.delegate = self;
    phoneNumTextfield.keyboardType = UIKeyboardTypeNumberPad;
    phoneNumTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneNumTextfield.tag = 3000;
    phoneNumTextfield.layer.cornerRadius = 5;
    phoneNumTextfield.clipsToBounds = YES;
    phoneNumTextfield.backgroundColor = [UIColor whiteColor];
    phoneNumTextfield.placeholder = @"手机号码";
    phoneNumTextfield.background = inputImage;
    phoneNumTextfield.textColor = UIColorFromRGB(0x727171);
    phoneNumTextfield.enabled = YES;
    phoneNumTextfield.numericFormatter = [AKNumericFormatter formatterWithMask:PHONE_FORMAT placeholderCharacter:'*'];
    [self.bgView addSubview:phoneNumTextfield];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getCodeButton.frame = CGRectMake(SCREEN_WIDTH-91, phoneNumTextfield.frame.origin.y+6, 58, 30);
    [getCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [getCodeButton setTitle:@"短信验证" forState:UIControlStateNormal];
    getCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [getCodeButton addTarget:self action:@selector(getVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:getCodeButton];
    
    codeTextField = [[MyTextField alloc] initWithFrame:CGRectMake(29, phoneNumTextfield.frame.size.height+phoneNumTextfield.frame.origin.y+5, SCREEN_WIDTH-58, 42)];
    codeTextField.delegate = self;
    codeTextField.backgroundColor = [UIColor whiteColor];
    codeTextField.layer.cornerRadius = 5;
    codeTextField.clipsToBounds = YES;
    codeTextField.background = inputImage;
    codeTextField.keyboardType = UIKeyboardTypeNumberPad;
    codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    codeTextField.tag = 4000;
    codeTextField.textColor = UIColorFromRGB(0x727171);
    codeTextField.placeholder = @"验证码";
    [self.bgView addSubview:codeTextField];
    
    changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    changeButton.frame = CGRectMake(30, codeTextField.frame.origin.y+codeTextField.frame.size.height + 25, SCREEN_WIDTH-60, 40);
    [changeButton setTitle:@"提交手机号" forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(verify) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:changeButton];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
    }
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)getVerifyCode
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
    if (![Tools isPhoneNumber:phoneNumTextfield.text])
    {
        [Tools showAlertView:@"请输入正确的手机号码！" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"phone":[Tools getPhoneNumFromString:phoneNumTextfield.text]} API:BINDPHONE];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"get code %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
                {
                    timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timeRefresh)userInfo:nil repeats:YES];
                    [[NSRunLoop  currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                    [self getcheckCode];
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

-(void)getcheckCode
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id]} API:MB_AUTHCODE];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"== responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                codeStr = [responseDict objectForKey:@"data"];
                codeTextField.text = [responseDict objectForKey:@"data"];
                getCodePhoneNumber = phoneNumTextfield.text;
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
    if (![Tools isPhoneNumber:phoneNumTextfield.text])
    {
        [Tools showAlertView:@"请输入正确的手机号码！" delegateViewController:nil];
        return ;
    }
    if ([codeTextField.text length] == 0)
    {
        [Tools showAlertView:@"请您填写验证码" delegateViewController:nil];
        return ;
    }
    if ([getCodePhoneNumber length] > 0 && ![phoneNumTextfield.text isEqualToString:getCodePhoneNumber])
    {
        [Tools showAlertView:@"手机号不正确" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"phone":phoneNumTextfield.text,
                                                                      @"auth_code":codeTextField.text}
                                                                API:BINDPHONE];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"verify responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"绑定成功,密码为手机号后6位，请牢记。" toView:self.bgView];
                [[NSUserDefaults standardUserDefaults] setObject:phoneNumTextfield.text forKey:PHONENUM];
                [[NSUserDefaults standardUserDefaults] synchronize];
                if ([self.changePhoneDel respondsToSelector:@selector(changePhoneNum:)])
                {
                    [self.changePhoneDel changePhoneNum:YES];
                }
                [self.navigationController popViewControllerAnimated:YES];
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
