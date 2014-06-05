//
//  ParentApplyViewController.m
//  School
//
//  Created by TeekerZW on 14-2-21.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ParentApplyViewController.h"
#import "Header.h"
#import "MyClassesViewController.h"
#import "MyClassesViewController.h"
#import "SideMenuViewController.h"
#import "JDSideMenu.h"
#import "KKNavigationController.h"

@interface ParentApplyViewController ()<UIAlertViewDelegate,
UITextViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
UITableViewDelegate,
UIScrollViewDelegate>
{
    UIScrollView *mainScrollView;
    
    UILabel *schoolInfoLabel;
    MyTextField *childNameTextField;
    
    MyTextField *relatetextField;
    
    MyTextField *phoneNumTextfield;
    MyTextField *codeTextField;
    
    NSArray *relateArray;
    UIButton *relateButton;
    UITableView *relateTableView;
    BOOL showRelate;
    
    UITableView *childTableView;
    
    NSString *re_id;
    
    BOOL isOpen;
    
    NSString *checkCode;
    NSString *relateStr;
    
    UIButton *studentButton;
    UIButton *getCodeButton;
    
    NSString *schoolName;
    NSString *className;
    NSString *classID;
}
@end

@implementation ParentApplyViewController
@synthesize real_name;
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
    self.titleLabel.text = @"家长申请加入";
    
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    checkCode = @"";
    re_id = @"";
    showRelate = YES;
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT)];
    mainScrollView.delegate = self;
    [self.bgView addSubview:mainScrollView];
    
//    UITapGestureRecognizer *scTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(returnKeyBoard)];
//    mainScrollView.userInteractionEnabled = YES;
//    [mainScrollView addGestureRecognizer:scTap];
    
    schoolInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 44, SCREEN_WIDTH-60, 90)];
    schoolInfoLabel.numberOfLines = 2;
    schoolInfoLabel.font = [UIFont systemFontOfSize:18];
    schoolInfoLabel.text = [NSString stringWithFormat:@"您希望加入%@-%@",schoolName,className];
    schoolInfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    schoolInfoLabel.textAlignment = NSTextAlignmentCenter;
    schoolInfoLabel.backgroundColor = [UIColor clearColor];
    schoolInfoLabel.textColor = TITLE_COLOR;
    [mainScrollView addSubview:schoolInfoLabel];
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    childNameTextField = [[MyTextField alloc] initWithFrame:CGRectMake(27.5, schoolInfoLabel.frame.size.height+schoolInfoLabel.frame.origin.y+20, SCREEN_WIDTH-55, 35)];
    childNameTextField.backgroundColor = [UIColor clearColor];
    childNameTextField.tag = 1000;
    childNameTextField.background = inputImage;
    childNameTextField.placeholder = @"请输入您的孩子姓名";
    childNameTextField.keyboardType = UIKeyboardAppearanceDefault;
    childNameTextField.delegate = self;
    childNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    childNameTextField.textColor = TITLE_COLOR;
    childNameTextField.returnKeyType = UIReturnKeyDone;
    childNameTextField.font = [UIFont systemFontOfSize:14];
    [mainScrollView addSubview:childNameTextField];
    
    UILabel *relateLabel = [[UILabel alloc] initWithFrame:CGRectMake(childNameTextField.frame.origin.x, childNameTextField.frame.origin.y+childNameTextField.frame.size.height+10, 85, 30)];
    relateLabel.numberOfLines = 3;
    relateLabel.font = [UIFont systemFontOfSize:16];
    relateLabel.text = [NSString stringWithFormat:@"你是孩子的"];
    relateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    relateLabel.backgroundColor = [UIColor clearColor];
    relateLabel.textColor = TITLE_COLOR;
    relateLabel.textAlignment = NSTextAlignmentLeft;
    [mainScrollView addSubview:relateLabel];
    
    relateArray = [[NSArray alloc] initWithObjects:@"爸爸",@"妈妈",@"爷爷",@"奶奶",@"其他", nil];

    relateStr = [relateArray firstObject];
    
    relateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    relateButton.backgroundColor = [UIColor clearColor];
    relateButton.frame = CGRectMake(relateLabel.frame.origin.x, relateLabel.frame.origin.y+relateLabel.frame.size.height, 95, 35);
    [relateButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [relateButton setBackgroundImage:inputImage forState:UIControlStateNormal];
    [relateButton setTitle:[relateArray firstObject] forState:UIControlStateNormal];
    [relateButton addTarget:self action:@selector(selectRelate) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:relateButton];

    relateTableView = [[UITableView alloc] initWithFrame:CGRectMake(relateButton.frame.origin.x, relateButton.frame.size.height+relateButton.frame.origin.y, relateButton.frame.size.width, 0) style:UITableViewStylePlain];
    relateTableView.delegate = self;
    relateTableView.dataSource = self;
    relateTableView.tag = 2000;
    relateTableView.backgroundColor = [UIColor whiteColor];
    relateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    

    relatetextField = [[MyTextField alloc] initWithFrame:CGRectMake(relateButton.frame.size.width+relateButton.frame.origin.x+10, relateButton.frame.origin.y, 83.5+relateLabel.frame.size.width, 35)];
    relatetextField.background = inputImage;
    relatetextField.tag = 2000;
    relatetextField.placeholder = @"请输入";
    relatetextField.delegate = self;
    relatetextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    relatetextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    relatetextField.font = [UIFont systemFontOfSize:17];
    relatetextField.textColor = TITLE_COLOR;
    [mainScrollView addSubview:relatetextField];
    
    relatetextField.hidden = YES;
    
    if ([[Tools phone_num] length] > 0)
    {
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, relatetextField.frame.size.height+relatetextField.frame.origin.y+40, SCREEN_WIDTH-20, 20)];
        tipLabel.numberOfLines = 1;
        tipLabel.font = [UIFont systemFontOfSize:14];
        tipLabel.text = [NSString stringWithFormat:@"您已绑定手机：%@",[Tools phone_num]];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = TITLE_COLOR;
        tipLabel.backgroundColor = [UIColor clearColor];
        [mainScrollView addSubview:tipLabel];
    }
    else
    {
        UIImage*inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 3, 20, 2.3)];
        
        phoneNumTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(29, relatetextField.frame.size.height+relatetextField.frame.origin.y+20, SCREEN_WIDTH-58, 35)];
        phoneNumTextfield.delegate = self;
        phoneNumTextfield.keyboardType = UIKeyboardTypeNumberPad;
        phoneNumTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
        phoneNumTextfield.tag = 3000;
        phoneNumTextfield.placeholder = @"手机号码";
        phoneNumTextfield.background = inputImage;
        phoneNumTextfield.textColor = UIColorFromRGB(0x727171);
        phoneNumTextfield.enabled = YES;
        phoneNumTextfield.numericFormatter = [AKNumericFormatter formatterWithMask:PHONE_FORMAT placeholderCharacter:'*'];
        [mainScrollView addSubview:phoneNumTextfield];
        
        UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        getCodeButton.frame = CGRectMake(SCREEN_WIDTH-91, phoneNumTextfield.frame.origin.y+5, 58, 25);
        [getCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [getCodeButton setTitle:@"短信验证" forState:UIControlStateNormal];
        getCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [getCodeButton addTarget:self action:@selector(getVerifyCode) forControlEvents:UIControlEventTouchUpInside];
        [mainScrollView addSubview:getCodeButton];
        
        codeTextField = [[MyTextField alloc] initWithFrame:CGRectMake(29, phoneNumTextfield.frame.size.height+phoneNumTextfield.frame.origin.y+3, SCREEN_WIDTH-58, 35)];
        codeTextField.delegate = self;
        codeTextField.background = inputImage;
        codeTextField.keyboardType = UIKeyboardTypeNumberPad;
        codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        codeTextField.tag = 4000;
        codeTextField.textColor = UIColorFromRGB(0x727171);
        codeTextField.placeholder = @"验证码";
        [mainScrollView addSubview:codeTextField];
        
        UIButton *checkCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        checkCodeButton.frame = CGRectMake(SCREEN_WIDTH-91, codeTextField.frame.origin.y+5, 58, 25);
        [checkCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [checkCodeButton setTitle:@"验证" forState:UIControlStateNormal];
        checkCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [checkCodeButton addTarget:self action:@selector(verify) forControlEvents:UIControlEventTouchUpInside];
        [mainScrollView addSubview:checkCodeButton];
    }
    
    UIImage *btnImage  =[Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    studentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [studentButton setTitle:@"提交" forState:UIControlStateNormal];
    studentButton.enabled = NO;
    if ([[Tools phone_num] length] > 0)
    {
        studentButton.enabled = YES;
        studentButton.frame = CGRectMake(38, relatetextField.frame.size.height+relatetextField.frame.origin.y+100, SCREEN_WIDTH-76, 40);
    }
    else
    {
        studentButton.frame = CGRectMake(38, relatetextField.frame.size.height+relatetextField.frame.origin.y+130, SCREEN_WIDTH-76, 40);
    }
    studentButton.layer.cornerRadius = 2;
    studentButton.clipsToBounds = YES;
    [studentButton addTarget:self action:@selector(applyJoinClass) forControlEvents:UIControlEventTouchUpInside];
    studentButton.tag = 1000;
    studentButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [studentButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [mainScrollView addSubview:studentButton];
    
    mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, studentButton.frame.size.height+studentButton.frame.origin.y+30);
    
    [mainScrollView addSubview:relateTableView];
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

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)returnKeyBoard
{
    for(UIView *v in mainScrollView.subviews)
    {
        if ([v isKindOfClass:[UITextField class]])
        {
            [v resignFirstResponder];
        }
    }
}

-(void)getCheckCode
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
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],@"phone":phoneNumTextfield.text} API:CHECKPHONE];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"check phone responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [self getVerifyCode];
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

-(void)getVerifyCode
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":phoneNumTextfield.text} API:MB_AUTHCODE];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"checkphone responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
                {
                    checkCode = [responseDict objectForKey:@"data"];
                    codeTextField.text = checkCode;
                }
                else
                {
                    [Tools showAlertView:@"获取验证码失败" delegateViewController:nil];
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
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":[Tools getPhoneNumFromString:phoneNumTextfield.text],@"auth_code":codeTextField.text} API:MB_CHECKOUT];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"verify responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showAlertView:@"验证成功！" delegateViewController:nil];
                studentButton.enabled = YES;
                phoneNumTextfield.enabled = NO;
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

-(void)selectRelate
{
    if (showRelate)
    {
        [UIView animateWithDuration:0.2 animations:^{
            
            relateTableView.frame = CGRectMake(relateButton.frame.origin.x, relateButton.frame.size.height+relateButton.frame.origin.y, relateButton.frame.size.width, [relateArray count]*40);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            relateTableView.frame = CGRectMake(relateButton.frame.origin.x, relateButton.frame.size.height+relateButton.frame.origin.y, relateButton.frame.size.width, 0);
        }];
    }
    showRelate = !showRelate;
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 1000)
    {
//        [self getStudentsByClassId:textField.text];
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == 1000)
    {
        if ([textField.text length]>2)
        {
//            [self getStudentsByClassId:textField.text];
        }
    }
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (showRelate)
    {
        return [relateArray count];
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *relateCell = @"relateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:relateCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:relateCell];
    }
    cell.textLabel.textColor = TITLE_COLOR;
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = [relateArray objectAtIndex:indexPath.row];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    UIImageView *bgImageBG = [[UIImageView alloc] init];
    bgImageBG.image = [UIImage imageNamed:@"line3"];
    bgImageBG.backgroundColor = [UIColor clearColor];
    cell.backgroundView = bgImageBG;
    return  cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [relateArray count]-1)
    {
        relatetextField.hidden = NO;
        relatetextField.enabled = YES;
        [relateButton setTitle:@"" forState:UIControlStateNormal];
        [relatetextField becomeFirstResponder];
    }
    else
    {
        relateStr = [relateArray objectAtIndex:indexPath.row];
        [relateButton setTitle:relateStr forState:UIControlStateNormal];
        relatetextField.text = @"";
        relatetextField.enabled = NO;
        relatetextField.hidden = YES;
    }
    [self selectRelate];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)applyJoinClass
{
    if ([childNameTextField.text length] == 0)
    {
        [Tools showAlertView:@"请输入孩子的姓名" delegateViewController:nil];
        return;
    }
    if ([relateStr length] <= 0 && [relatetextField.text length] <= 0)
    {
        [Tools showAlertView:@"请选择和孩子的关系" delegateViewController:nil];
        return ;
    }
    if ([relatetextField.text length] > 0)
    {
        relateStr = relatetextField.text;
    }
    if ([Tools NetworkReachable])
    {
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"role":@"parents",
                                                                      @"re_id":re_id,
                                                                      @"re_name":childNameTextField.text,
                                                                      @"re_type":relateStr
                                                                      }
                                                                API:JOINCLASS];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"studentJoinClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的申请已成功提交，请等待班主任老师审核。" delegate:self cancelButtonTitle:@"返回我的班级" otherButtonTitles: nil];
                al.tag = 1111;
                [al show];
            }
            else if ([[responseDict objectForKey:@"code"] intValue]== 0)
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

-(void)getStudentsByClassId:(NSString *)studentName
{
    if ([studentName length] <= 0)
    {
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"role":@"students",
                                                                      @"content":studentName
                                                                      } API:GETUSERSBYCLASS];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getStudentByClassId responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([[responseDict objectForKey:@"data"] count] >0)
                {
                    NSArray *array = [[responseDict objectForKey:@"data"] allValues];
                    for (int i=0; i<[array count]; ++i)
                    {
                        NSDictionary *dict = [array objectAtIndex:i];
                        if ([[dict objectForKey:@"name"] isEqualToString:studentName])
                        {
                            re_id = [dict objectForKey:@"_id"];
                        }
                    }
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

}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 1000)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-30);
        }];
    }
    else if(textField.tag == 2000)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-80);
        }];
    }
    else if(textField.tag == 3000)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-120);
        }];
    }
    else if(textField.tag == 4000)
    {
        [UIView animateWithDuration:0.25 animations:^{
            self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-170);
        }];
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1111)
    {
        SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
        MyClassesViewController *myClassesViewController = [[MyClassesViewController alloc] init];
        KKNavigationController *myClassesNav = [[KKNavigationController alloc] initWithRootViewController:myClassesViewController];
        JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:myClassesNav menuController:sideMenuViewController];
        [self.navigationController presentViewController:sideMenu animated:YES completion:^{
            
        }];
    }
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2+YSTART);
    }completion:^(BOOL finished) {
        
    }];
}

@end
