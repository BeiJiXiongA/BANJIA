//
//  Regist3ViewController.m
//  School
//
//  Created by TeekerZW on 1/13/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "Regist3ViewController.h"
#import "Header.h"
#import "FillInfoViewController.h"
#import "APService.h"

@interface Regist3ViewController ()<UITextFieldDelegate>
{
    UIScrollView *mainScrollView;
    MyTextField *nameTextfield;
    MyTextField *passwordTextField;
    MyTextField *verifyTextField;
}
@end

@implementation Regist3ViewController
@synthesize phoneNum,userid;
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
    
    self.titleLabel.text = @"填写密码";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT)];
    mainScrollView.backgroundColor = [UIColor clearColor];
    mainScrollView.showsVerticalScrollIndicator = NO;
    [self.bgView addSubview:mainScrollView];
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(SCREEN_WIDTH/2-130, UI_NAVIGATION_BAR_HEIGHT+30, 200, 20);
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = TITLE_COLOR;
    label.text = @"您的登录账号:";
    [mainScrollView addSubview:label];
        
    nameTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(29, label.frame.origin.y+label.frame.size.height+5, SCREEN_WIDTH-58, 40)];
    nameTextfield.backgroundColor = [UIColor clearColor];
    nameTextfield.delegate = self;
    nameTextfield.font = [UIFont systemFontOfSize:18];
    nameTextfield.textColor = TITLE_COLOR;
    nameTextfield.text = phoneNum;
    nameTextfield.enabled = NO;
    nameTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
    [mainScrollView addSubview:nameTextfield];
    
//    passwordTextField = [[MyTextField alloc] initWithFrame:CGRectMake(29, nameTextfield.frame.origin.y+nameTextfield.frame.size.height+5, SCREEN_WIDTH-58, 40)];
//    passwordTextField.delegate = self;
//    passwordTextField.secureTextEntry = YES;
//    passwordTextField.background = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
//    passwordTextField.placeholder = @"密码";
//    passwordTextField.tag = 1000;
//    passwordTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    [mainScrollView addSubview:passwordTextField];
    
    verifyTextField = [[MyTextField alloc] initWithFrame:CGRectMake(29, nameTextfield.frame.origin.y+nameTextfield.frame.size.height+5, SCREEN_WIDTH-58, 40)];
    verifyTextField.delegate = self;
    verifyTextField.secureTextEntry = YES;
    verifyTextField.tag = 1001;
    verifyTextField.backgroundColor = [UIColor clearColor];
    verifyTextField.background = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    verifyTextField.placeholder = @"请设置密码";
    verifyTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [mainScrollView addSubview:verifyTextField];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startButton.frame = CGRectMake(51, verifyTextField.frame.origin.y+verifyTextField.frame.size.height+20, SCREEN_WIDTH-102, 40);
    [startButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [startButton setTitle:@"提交" forState:UIControlStateNormal];
    [startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:startButton];
    
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
    logoImageView.frame = CGRectMake((SCREEN_WIDTH-imageW)/2,startButton.frame.size.height+startButton.frame.origin.y+oriY, imageW, imageH);
    [mainScrollView addSubview:logoImageView];
    
    mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, logoImageView.frame.origin.y+logoImageView.frame.size.height+30);
    DDLOG(@"contentsize=%@",NSStringFromCGSize(mainScrollView.contentSize));
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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
    if ([verifyTextField.text length] == 0)
    {
        [Tools showAlertView:@"密码不能为空" delegateViewController:nil];
        return ;
    }
    else if(![Tools isPassWord:verifyTextField.text])
    {
        [Tools showAlertView:@"密码由6-20位字母或数字组成" delegateViewController:nil];
        return ;
    }
    
    NSString *userStr = @"";
    if ([[APService registrionID] length] > 0)
    {
        userStr = [APService registrionID];
    }
    
    NSDictionary *paraDict;
    paraDict = @{@"u_id":userid,
                     @"pwd":verifyTextField.text,
                     @"reg_method":[Tools reg_method],
                     @"d_name":[Tools device_name],
                     @"d_imei":[Tools device_uid],
                     @"c_ver":[Tools client_ver],
                     @"c_os":[Tools device_version],
                     @"d_type":@"iOS",
                     @"registrationID":userStr,
                     @"account":@"0"
                     };

    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict
                                                                API:MB_SUBPWD];
        [request setCompletionBlock:^{
            
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"pass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                NSDictionary *dict = [responseDict objectForKey:@"data"];
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                [ud setObject:[dict objectForKey:@"u_id"] forKey:USERID];
                [ud setObject:[dict objectForKey:@"token"] forKey:CLIENT_TOKEN];
                [ud setObject:phoneNum forKey:PHONENUM];
                [ud setObject:verifyTextField.text forKey:PASSWORD];
                [ud synchronize];
                FillInfoViewController *fillInfoViewController = [[FillInfoViewController alloc] init];
                if ([accountID length] > 0)
                {
                    fillInfoViewController.headerIcon = headerIcon;
                    fillInfoViewController.fromRoot = NO;
                    fillInfoViewController.nickName = nickName;
                }
                [passwordTextField resignFirstResponder];
                [verifyTextField resignFirstResponder];
                [self.navigationController pushViewController:fillInfoViewController animated:YES];
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
        if (textField.tag == 1000)
        {
            self.bgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-20);
        }
        else if(textField.tag == 1001)
        {
            self.bgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-40);
        }
    }completion:^(BOOL finished) {
        
    }];
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
    }
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

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    //获取键盘的高度
//    NSDictionary *userInfo = [aNotification userInfo];
//    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect keyboardRect = [aValue CGRectValue];
////    int height = keyboardRect.size.height;
//    
//    [UIView animateWithDuration:0.25 animations:^{
////        if (iPhone5)
////        {
////            self.bgView.center = CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2-height+100);
////        }
////        else
////        {
////            self.bgView.center = CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2-height+50);
////        }
//        
//    }completion:^(BOOL finished) {
//    }];
}


@end
