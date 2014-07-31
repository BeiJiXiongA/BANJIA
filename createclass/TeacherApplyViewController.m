//
//  StudentApplyViewController.m
//  School
//
//  Created by TeekerZW on 14-2-21.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "TeacherApplyViewController.h"
#import "Header.h"
#import "MyClassesViewController.h"
#import "SideMenuViewController.h"
#import "JDSideMenu.h"
#import "KKNavigationController.h"

@interface TeacherApplyViewController()<UIAlertViewDelegate,
UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate>
{
    
    UIScrollView *mainScrollView;
    
    UILabel *schoolInfoLabel;
    
    MyTextField *nameTextField;
    
    UIButton *showObjectButton;
    BOOL showObjects;
    UITableView *objectsTableView;
    NSArray *objectArray;
    MyTextField *objectTextField;
    NSString *objectStr;
    
    UILabel *teacherLabel;
    
    MyTextField *phoneNumTextfield;
    MyTextField *codeTextField;
    
    NSString *checkCode;
    
    
    NSString *adminID;
    
    UIButton *studentButton;
    
    NSString *schoolName;
    NSString *className;
    NSString *classID;
    
    UIButton *getCodeButton;
    
    NSTimer *timer;
    int sec;
    
    UITapGestureRecognizer *tapTgr;
}
@end

@implementation TeacherApplyViewController
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
    self.titleLabel.text = @"老师申请加入";
    
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    
    sec = 60;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
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
    
    nameTextField = [[MyTextField alloc] initWithFrame:CGRectMake(27.5, schoolInfoLabel.frame.size.height+schoolInfoLabel.frame.origin.y+10, SCREEN_WIDTH-55, 45)];
    nameTextField.layer.cornerRadius = 5;
    nameTextField.clipsToBounds = YES;
    nameTextField.backgroundColor = [UIColor whiteColor];
    nameTextField.tag = 1000;
    nameTextField.background = nil;
    nameTextField.placeholder = @"请确认您的姓名";
    nameTextField.text = [Tools user_name];
    nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nameTextField.keyboardType = UIKeyboardAppearanceDefault;
    nameTextField.delegate = self;
    nameTextField.textColor = COMMENTCOLOR;
    nameTextField.returnKeyType = UIReturnKeyDone;
    nameTextField.font = [UIFont systemFontOfSize:16];
    [mainScrollView addSubview:nameTextField];
    
    UILabel *tip1 = [[UILabel alloc] init];
    tip1.frame = CGRectMake(nameTextField.frame.origin.x, nameTextField.frame.origin.y+nameTextField.frame.size.height+10, 18*7, 24);
    tip1.text = @"您教授的课程是";
    tip1.backgroundColor = [UIColor clearColor];
    tip1.font = [UIFont systemFontOfSize:18];
    tip1.textColor = COMMENTCOLOR;
    [mainScrollView addSubview:tip1];
    
    showObjects = YES;
    checkCode = @"";
    
    objectArray = @[@"语文老师",@"数学老师",@"英语老师",@"历史老师",@"其他"];
    objectStr = [objectArray firstObject];
    
    
    
    showObjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showObjectButton.backgroundColor = [UIColor whiteColor];
    showObjectButton.frame = CGRectMake(tip1.frame.origin.x, tip1.frame.origin.y+tip1.frame.size.height+5, 130, 42);
    [showObjectButton setTitleColor:COMMENTCOLOR forState:UIControlStateNormal];
    showObjectButton.layer.cornerRadius = 5;
    showObjectButton.clipsToBounds = YES;
    [showObjectButton setTitle:[objectArray firstObject] forState:UIControlStateNormal];
    [showObjectButton addTarget:self action:@selector(showObject) forControlEvents:UIControlEventTouchUpInside];
    [mainScrollView addSubview:showObjectButton];
    
    objectsTableView = [[UITableView alloc] initWithFrame:CGRectMake(showObjectButton.frame.origin.x, showObjectButton.frame.size.height+showObjectButton.frame.origin.y, showObjectButton.frame.size.width, 0) style:UITableViewStylePlain];
    objectsTableView.layer.cornerRadius = 5;
    objectsTableView.clipsToBounds = YES;
    objectsTableView.delegate = self;
    objectsTableView.dataSource = self;
    objectsTableView.tag = 2000;
    objectsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    objectsTableView.backgroundColor = [UIColor whiteColor];
    objectsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    objectTextField = [[MyTextField alloc] initWithFrame:CGRectMake(showObjectButton.frame.size.width+showObjectButton.frame.origin.x+10, showObjectButton.frame.origin.y, 130, 42)];
    objectTextField.tag = 2000;
    objectTextField.background = nil;
    objectTextField.backgroundColor = [UIColor whiteColor];
    objectTextField.layer.cornerRadius = 5;
    objectTextField.clipsToBounds = YES;
    objectTextField.textColor = COMMENTCOLOR;
    objectTextField.enabled = NO;
    objectTextField.delegate = self;
    objectTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    objectTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    objectTextField.font = [UIFont systemFontOfSize:17];
    objectTextField.placeholder = @"输入";
    objectTextField.hidden = YES;
    [mainScrollView addSubview:objectTextField];
    
//    [self getAdmins];
    
    if ([[Tools phone_num] length] > 0)
    {
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, objectTextField.frame.size.height+objectTextField.frame.origin.y+40, SCREEN_WIDTH-20, 20)];
        tipLabel.numberOfLines = 1;
        tipLabel.font = [UIFont systemFontOfSize:16];
        tipLabel.text = [NSString stringWithFormat:@"您已绑定手机：%@",[Tools phone_num]];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = COMMENTCOLOR;
        tipLabel.backgroundColor = [UIColor clearColor];
        [mainScrollView addSubview:tipLabel];
    }
    else
    {
        
        phoneNumTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(29, objectTextField.frame.size.height+objectTextField.frame.origin.y+20, SCREEN_WIDTH-58, 42)];
        phoneNumTextfield.delegate = self;
        phoneNumTextfield.keyboardType = UIKeyboardTypeNumberPad;
        phoneNumTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
        phoneNumTextfield.tag = 3000;
        phoneNumTextfield.layer.cornerRadius = 5;
        phoneNumTextfield.clipsToBounds = YES;
        phoneNumTextfield.backgroundColor = [UIColor whiteColor];
        phoneNumTextfield.placeholder = @"手机号码";
        phoneNumTextfield.background = nil;
        phoneNumTextfield.textColor = COMMENTCOLOR;
        phoneNumTextfield.enabled = YES;
        phoneNumTextfield.numericFormatter = [AKNumericFormatter formatterWithMask:PHONE_FORMAT placeholderCharacter:'*'];
        [mainScrollView addSubview:phoneNumTextfield];
        
        UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        getCodeButton.frame = CGRectMake(SCREEN_WIDTH-91, phoneNumTextfield.frame.origin.y+5, 58, 32);
        [getCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [getCodeButton setTitle:@"短信验证" forState:UIControlStateNormal];
        getCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [getCodeButton addTarget:self action:@selector(getVerifyCode) forControlEvents:UIControlEventTouchUpInside];
        [mainScrollView addSubview:getCodeButton];
        
        codeTextField = [[MyTextField alloc] initWithFrame:CGRectMake(29, phoneNumTextfield.frame.size.height+phoneNumTextfield.frame.origin.y+3, SCREEN_WIDTH-58, 42)];
        codeTextField.delegate = self;
        codeTextField.background = nil;
        codeTextField.keyboardType = UIKeyboardTypeNumberPad;
        codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        codeTextField.tag = 4000;
        codeTextField.layer.cornerRadius = 5;
        codeTextField.clipsToBounds = YES;
        codeTextField.backgroundColor = [UIColor whiteColor];
        codeTextField.textColor = COMMENTCOLOR;
        codeTextField.placeholder = @"验证码";
        [mainScrollView addSubview:codeTextField];
        
        UIButton *checkCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        checkCodeButton.frame = CGRectMake(SCREEN_WIDTH-91, codeTextField.frame.origin.y+5, 58, 32);
        [checkCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [checkCodeButton setTitle:@"验证" forState:UIControlStateNormal];
        checkCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [checkCodeButton addTarget:self action:@selector(verify) forControlEvents:UIControlEventTouchUpInside];
        [mainScrollView addSubview:checkCodeButton];
    }

    
    
    UIImage *btnImage  =[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    studentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [studentButton setTitle:@"提交" forState:UIControlStateNormal];
    studentButton.enabled = NO;
    if ([[Tools phone_num] length] > 0)
    {
        studentButton.frame = CGRectMake(38, objectTextField.frame.size.height+objectTextField.frame.origin.y+100, SCREEN_WIDTH-76, 40);
        studentButton.enabled = YES;
    }
    else
    {
        studentButton.frame = CGRectMake(38, objectTextField.frame.size.height+objectTextField.frame.origin.y+130, SCREEN_WIDTH-76, 40);
    }
    
    studentButton.layer.cornerRadius = 2;
    studentButton.clipsToBounds = YES;
    [studentButton addTarget:self action:@selector(applyForJoinClass) forControlEvents:UIControlEventTouchUpInside];
    studentButton.tag = 1000;
    studentButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [studentButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [mainScrollView addSubview:studentButton];
    
    mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, studentButton.frame.size.height+studentButton.frame.origin.y+30);
    
    [mainScrollView addSubview:objectsTableView];
    
    tapTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent)];
    mainScrollView.userInteractionEnabled = YES;
    [mainScrollView addGestureRecognizer:tapTgr];
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
    [timer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tapEvent
{
    for(UIView *v in mainScrollView.subviews)
    {
        if ([v isKindOfClass:[UITextField class]] || [v isKindOfClass:[UITextView class]])
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

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    for(UIView *v in mainScrollView.subviews)
    {
        if ([v isKindOfClass:[UITextField class]])
        {
            [v resignFirstResponder];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 验证码
-(void)getVerifyCode
{
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
                timer = [NSTimer timerWithTimeInterval:1.0 target:self selector:@selector(timeRefresh)userInfo:nil repeats:YES];
                [[NSRunLoop  currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
                [self getcheckCode];
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
                //                codeStr = [responseDict objectForKey:@"data"];
                codeTextField.text = [responseDict objectForKey:@"data"];
                
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
                [Tools showTips:@"绑定成功" toView:self.bgView];
                
                [[NSUserDefaults standardUserDefaults] setObject:phoneNumTextfield.text forKey:PHONENUM];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                studentButton.enabled = YES;
                [studentButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
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

#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [objectArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *objectCell = @"applyObject";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:objectCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:objectCell];
    }
    cell.textLabel.textColor = COMMENTCOLOR;
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = [objectArray objectAtIndex:indexPath.row];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    UIImageView *bgImageBG = [[UIImageView alloc] init];
    bgImageBG.image = [UIImage imageNamed:@"line3"];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundView = bgImageBG;
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [objectArray count]-1)
    {
        objectTextField.hidden = NO;
        objectTextField.enabled = YES;
        [showObjectButton setTitle:@"" forState:UIControlStateNormal];
        [objectTextField becomeFirstResponder];
    }
    else
    {
        objectStr = [objectArray objectAtIndex:indexPath.row];
        [showObjectButton setTitle:objectStr forState:UIControlStateNormal];
        objectTextField.text = @"";
        objectTextField.hidden = YES;
        objectTextField.enabled = NO;
    }
    [self showObject];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 输入
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
- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CGPointMake(UI_SCREEN_WIDTH/2, UI_SCREEN_HEIGHT/2+YSTART);
    }completion:^(BOOL finished) {
        
    }];
}


-(void)showObject
{
    if (showObjects)
    {
        [UIView animateWithDuration:0.2 animations:^{
            
            objectsTableView.frame = CGRectMake(showObjectButton.frame.origin.x, showObjectButton.frame.size.height+showObjectButton.frame.origin.y, showObjectButton.frame.size.width, [objectArray count]*40);
        }];
        [mainScrollView removeGestureRecognizer:tapTgr];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            objectsTableView.frame = CGRectMake(showObjectButton.frame.origin.x, showObjectButton.frame.size.height+showObjectButton.frame.origin.y, showObjectButton.frame.size.width, 0);
        }];
        [mainScrollView addGestureRecognizer:tapTgr];
    }
    showObjects = !showObjects;
}


-(void)applyForJoinClass
{
    
    if ([objectStr length] <= 0 && [objectTextField.text length] <= 0)
    {
        [Tools showAlertView:@"请填写您的任教科目" delegateViewController:nil];
        return ;
    }
    if ([objectTextField.text length] > 0)
    {
        objectStr = objectTextField.text;
    }

    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"role":@"teachers",
                                                                      @"title":[NSString stringWithFormat:@"%@",objectStr]
                                                                      } API:JOINCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classInfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你的申请已经提交，请等待班主任的审核！" delegate:self cancelButtonTitle:@"回到班级列表" otherButtonTitles: nil];
                al.tag = 3333;
                [al show];
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

-(void)getAdmins
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      } API:MB_ADMINLIST];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"adminslist responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([[responseDict objectForKey:@"data"] count] > 0)
                {
                    NSDictionary *adminDict = [responseDict objectForKey:@"data"];
                    for(NSString *key in adminDict)
                    {
                        if ([[adminDict objectForKey:key] integerValue] ==2)
                        {
                            adminID = key;
                        }
                    }
                    [self getClassInfo];
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
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
    }
}

-(void)getClassInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID
                                                                      } API:CLASSINFO];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classInfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSDictionary *teachersDict = [[[responseDict objectForKey:@"data"] objectForKey:@"members"] objectForKey:@"teachers"];
                teacherLabel.text = [NSString stringWithFormat:@"班主任:%@",[[teachersDict objectForKey:adminID] objectForKey:@"name"]];
            }
            else if([[responseDict objectForKey:@"code"] intValue]== 0)
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 3333)
    {
        SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
        MyClassesViewController *myClassesViewController = [[MyClassesViewController alloc] init];
        KKNavigationController *myClassesNav = [[KKNavigationController alloc] initWithRootViewController:myClassesViewController];
        JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:myClassesNav menuController:sideMenuViewController];
        [self.navigationController presentViewController:sideMenu animated:YES completion:^{
            
        }];
    }
    else if(alertView.tag == 5555)
    {
        
    }
}

@end
