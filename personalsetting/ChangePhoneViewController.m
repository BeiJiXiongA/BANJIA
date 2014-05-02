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
    
    UIImage*inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 3, 20, 2.3)];
    
    phoneNumTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(29, UI_NAVIGATION_BAR_HEIGHT+100, SCREEN_WIDTH-58, 35)];
    phoneNumTextfield.delegate = self;
    phoneNumTextfield.keyboardType = UIKeyboardTypeNumberPad;
    phoneNumTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    phoneNumTextfield.tag = 3000;
    phoneNumTextfield.placeholder = @"手机号码";
    phoneNumTextfield.background = inputImage;
    phoneNumTextfield.textColor = UIColorFromRGB(0x727171);
    phoneNumTextfield.enabled = YES;
    phoneNumTextfield.numericFormatter = [AKNumericFormatter formatterWithMask:PHONE_FORMAT placeholderCharacter:'*'];
    [self.bgView addSubview:phoneNumTextfield];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIButton *getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    getCodeButton.frame = CGRectMake(SCREEN_WIDTH-91, phoneNumTextfield.frame.origin.y+5, 58, 25);
    [getCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [getCodeButton setTitle:@"短信验证" forState:UIControlStateNormal];
    getCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    [getCodeButton addTarget:self action:@selector(getVerifyCode) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:getCodeButton];
    
    codeTextField = [[MyTextField alloc] initWithFrame:CGRectMake(29, phoneNumTextfield.frame.size.height+phoneNumTextfield.frame.origin.y+3, SCREEN_WIDTH-58, 35)];
    codeTextField.delegate = self;
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
    changeButton.enabled = NO;
    [self.bgView addSubview:changeButton];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getVerifyCode
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id]} API:MB_AUTHCODE];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"get code %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
                {
//                    codeTextField.text = [responseDict objectForKey:@"data"];
                    changeButton.enabled = YES;
                }
                else
                {
                    [Tools dealRequestError:responseDict fromViewController:nil];
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
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],@"auth_code":codeTextField.text} API:MB_CHECKOUT];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"verify responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"绑定成功" toView:self.bgView];
                [self unShowSelfViewController];
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}


//-(void)getCheckCode
//{
//    if ([phoneNumTextfield.text length] == 0)
//    {
//        [Tools showAlertView:@"请输入手机号码！" delegateViewController:nil];
//        return ;
//    }
//    if (![Tools isPhoneNumber:[Tools getPhoneNumFromString:phoneNumTextfield.text]])
//    {
//        [Tools showAlertView:@"手机号格式不正确！" delegateViewController:nil];
//        return ;
//    }
//    
//    if ([Tools NetworkReachable])
//    {
//        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":phoneNumTextfield.text} API:CHECKPHONE];
//        
//        [request setCompletionBlock:^{
//            [Tools hideProgress:self.bgView];
//            NSString *responseString = [request responseString];
//            NSDictionary *responseDict = [Tools JSonFromString:responseString];
//            DDLOG(@"check phone responsedict %@",responseString);
//            if ([[responseDict objectForKey:@"code"] intValue]== 1)
//            {
//                //                [[NSUserDefaults standardUserDefaults] setObject:[responseDict objectForKey:@"data"]forKey:USERID];
//                //                [[NSUserDefaults standardUserDefaults] synchronize];
//                [self getVerifyCode];
//            }
//            else
//            {
//                [Tools dealRequestError:responseDict fromViewController:self];
//            }
//            
//        }];
//        
//        [request setFailedBlock:^{
//            NSError *error = [request error];
//            DDLOG(@"error %@",error);
//            [Tools hideProgress:self.bgView];
//        }];
//        [Tools showProgress:self.bgView];
//        [request startAsynchronous];
//    }
//    else
//    {
//        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
//    }
//}
//
//-(void)getVerifyCode
//{
//    if ([Tools NetworkReachable])
//    {
//        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":phoneNumTextfield.text} API:@"/users/mbAuthCode2"];
//        
//        [request setCompletionBlock:^{
//            [Tools hideProgress:self.bgView];
//            NSString *responseString = [request responseString];
//            NSDictionary *responseDict = [Tools JSonFromString:responseString];
//            DDLOG(@"checkphone responsedict %@",responseString);
//            if ([[responseDict objectForKey:@"code"] intValue]== 1)
//            {
//                checkCode = [responseDict objectForKey:@"data"];
//                codeTextField.text = checkCode;
//            }
//            else
//            {
//                [Tools dealRequestError:responseDict fromViewController:self];
//            }
//            
//        }];
//        
//        [request setFailedBlock:^{
//            NSError *error = [request error];
//            DDLOG(@"error %@",error);
//            [Tools hideProgress:self.bgView];
//        }];
//        [Tools showProgress:self.bgView];
//        [request startAsynchronous];
//    }
//    else
//    {
//        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
//    }
//    
//}
//-(void)verify
//{
//    if ([codeTextField.text length] == 0)
//    {
//        [Tools showAlertView:@"请您填写验证码" delegateViewController:nil];
//        return ;
//    }
//    if ([Tools NetworkReachable])
//    {
//        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":[Tools getPhoneNumFromString:phoneNumTextfield.text],@"auth_code":codeTextField.text} API:MB_CHECKOUT];
//        
//        [request setCompletionBlock:^{
//            [Tools hideProgress:self.bgView];
//            NSString *responseString = [request responseString];
//            NSDictionary *responseDict = [Tools JSonFromString:responseString];
//            DDLOG(@"verify responsedict %@",responseDict);
//            if ([[responseDict objectForKey:@"code"] intValue]== 1)
//            {
//                [Tools showAlertView:@"验证成功！" delegateViewController:nil];
//                
//                if ([self.changePhoneDel respondsToSelector:@selector(changePhoneNum:)])
//                {
//                    [self.changePhoneDel changePhoneNum:YES];
//                }
//                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
//                [ud setObject:phoneNumTextfield.text forKey:PHONENUM];
//                [ud synchronize];
//                
//                [self unShowSelfViewController];
//            }
//            else
//            {
//                [Tools dealRequestError:responseDict fromViewController:self];
//            }
//            
//        }];
//        
//        [request setFailedBlock:^{
//            NSError *error = [request error];
//            DDLOG(@"error %@",error);
//            [Tools hideProgress:self.bgView];
//        }];
//        [Tools showProgress:self.bgView];
//        [request startAsynchronous];
//    }
//    else
//    {
//        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
//    }
//}
//

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
