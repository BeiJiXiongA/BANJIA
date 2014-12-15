//
//  ResetPwdViewController.m
//  BANJIA
//
//  Created by TeekerZW on 5/13/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "ResetPwdViewController.h"

@interface ResetPwdViewController ()
{
    MyTextField *oldPwdTextField;
    MyTextField *newPwdTextField;
    BOOL showPwds;
    UIButton *showPwdButton;
    UIImageView *showPwdImageView;
}
@end

@implementation ResetPwdViewController

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
    
    self.titleLabel.text = @"修改密码";
    
    showPwds = YES;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"保存" forState:UIControlStateNormal];
    sendButton.backgroundColor = [UIColor clearColor];
    [sendButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [sendButton addTarget:self action:@selector(submitPwdChange) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:sendButton];

    
    oldPwdTextField = [[MyTextField alloc] initWithFrame:CGRectMake(30, UI_NAVIGATION_BAR_HEIGHT+30, SCREEN_WIDTH-60, 40)];
    oldPwdTextField.placeholder = @"原密码";
    oldPwdTextField.secureTextEntry = YES;
    oldPwdTextField.layer.cornerRadius = 5;
    oldPwdTextField.clipsToBounds = YES;
    oldPwdTextField.background = nil;
    oldPwdTextField.textColor = COMMENTCOLOR;
    oldPwdTextField.backgroundColor = [UIColor whiteColor];
    oldPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.bgView addSubview:oldPwdTextField];
    
    newPwdTextField = [[MyTextField alloc] initWithFrame:CGRectMake(30, UI_NAVIGATION_BAR_HEIGHT+90, SCREEN_WIDTH-60, 40)];
    newPwdTextField.placeholder = @"新密码";
    newPwdTextField.secureTextEntry = YES;
    newPwdTextField.layer.cornerRadius = 5;
    newPwdTextField.clipsToBounds = YES;
    newPwdTextField.background = nil;
    newPwdTextField.textColor = COMMENTCOLOR;
    newPwdTextField.backgroundColor = [UIColor whiteColor];
    newPwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.bgView addSubview:newPwdTextField];
    
    showPwdImageView = [[UIImageView alloc] init];
    showPwdImageView.backgroundColor = [UIColor clearColor];
    showPwdImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    showPwdImageView.layer.borderWidth = 0.5;
    [self.bgView addSubview:showPwdImageView];
    
    showPwdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showPwdButton.frame = CGRectMake(SCREEN_WIDTH-130, UI_NAVIGATION_BAR_HEIGHT+140, 110, 35);
    showPwdButton.backgroundColor = [UIColor clearColor];
    showPwdButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [showPwdButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [showPwdButton setTitle:@"显示密码" forState:UIControlStateNormal];
    [showPwdButton addTarget:self action:@selector(showPwd) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:showPwdButton];
    
    showPwdImageView.frame = CGRectMake(SCREEN_WIDTH-130, UI_NAVIGATION_BAR_HEIGHT+147, 20, 20);
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

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
    }
}

-(void)showPwd
{
    if (showPwds)
    {
        oldPwdTextField.secureTextEntry = NO;
        newPwdTextField.secureTextEntry = NO;
        [showPwdButton setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
        showPwdImageView.backgroundColor = LIGHT_BLUE_COLOR;
    }
    else
    {
        
        oldPwdTextField.secureTextEntry = YES;
        newPwdTextField.secureTextEntry = YES;
        [showPwdButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        showPwdImageView.backgroundColor = [UIColor clearColor];
    }
    showPwds = !showPwds;
}

-(void)submitPwdChange
{
    if ([oldPwdTextField.text length] <= 0)
    {
        [Tools showAlertView:@"请填写旧密码" delegateViewController:nil];
        return;
    }
    if (![Tools isPassWord:oldPwdTextField.text])
    {
        [Tools showAlertView:@"原密码有6-8位字母或数字组成" delegateViewController:nil];
        return ;
    }
    if ([newPwdTextField.text length] <= 0)
    {
        [Tools showAlertView:@"请填写新密码" delegateViewController:nil];
        return;
    }
    if (![Tools isPassWord:newPwdTextField.text])
    {
        [Tools showAlertView:@"新密码有6-8位字母或数字组成" delegateViewController:nil];
        return ;
    }
    
    if ([newPwdTextField.text isEqualToString:oldPwdTextField.text])
    {
        [Tools showAlertView:@"新旧密码是一样的，请重新输入。" delegateViewController:nil];
        return ;
    }
    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"opwd":oldPwdTextField.text,
                                                                      @"npwd":newPwdTextField.text}
                                                                API:MB_RESETPWD];
        [request setCompletionBlock:^{
            
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"resetpwd responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"密码修改成功" toView:self.bgView];
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
