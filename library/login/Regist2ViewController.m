//
//  Regist2ViewController.m
//  School
//
//  Created by TeekerZW on 1/13/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "Regist2ViewController.h"
#import "Regist3ViewController.h"
#import "Header.h"

@interface Regist2ViewController ()<UITextFieldDelegate>
{
    UITextField *verifyNumTextfield;
}
@end

@implementation Regist2ViewController
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
    
    self.titleLabel.text = @"注册验证";
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(SCREEN_WIDTH/2-100, UI_NAVIGATION_BAR_HEIGHT+50, 200, 30);
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"我们已向您的手机发送验证码";
    [self.bgView addSubview:label];
    
    verifyNumTextfield = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-100, label.frame.origin.y+label.frame.size.height+15, 200, 30)];
    verifyNumTextfield.backgroundColor = [UIColor yellowColor];
    verifyNumTextfield.delegate = self;
    verifyNumTextfield.placeholder = @"验证码";
    verifyNumTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.bgView addSubview:verifyNumTextfield];
    
    UIButton *nextStepButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextStepButton.frame = CGRectMake(SCREEN_WIDTH/2-60, verifyNumTextfield.frame.origin.y+verifyNumTextfield.frame.size.height+20, 120, 30);
    nextStepButton.backgroundColor = [UIColor grayColor];
    [nextStepButton setTitle:@"验证" forState:UIControlStateNormal];
    [nextStepButton addTarget:self action:@selector(verify) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:nextStepButton];
    
    [self getVerifyCode];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
            DDLOG(@"== responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                verifyNumTextfield.text = [responseDict objectForKey:@"data"];
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
    if ([verifyNumTextfield.text length] == 0)
    {
        [Tools showAlertView:@"请您填写验证码" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],@"auth_code":verifyNumTextfield.text} API:MB_CHECKOUT];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"verify responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                Regist3ViewController *regist3ViewController = [[Regist3ViewController alloc] init];
                regist3ViewController.phoneNum = [[responseDict objectForKey:@"data"] objectForKey:@"phone"];
                [regist3ViewController showSelfViewController:self];
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

#pragma mark - textfield
- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CENTER_POINT;
    }completion:^(BOOL finished) {
        
    }];
}


@end
