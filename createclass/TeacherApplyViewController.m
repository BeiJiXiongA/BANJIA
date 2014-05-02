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

@interface TeacherApplyViewController()<UIAlertViewDelegate,
UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate>
{
    
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
    NSString *checkCode;;
    
    
    NSString *adminID;
}
@end

@implementation TeacherApplyViewController
@synthesize schoolName,schoolID,className,classID,real_name;
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    schoolInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(63, UI_NAVIGATION_BAR_HEIGHT+44, SCREEN_WIDTH-126, 90)];
    schoolInfoLabel.numberOfLines = 2;
    schoolInfoLabel.font = [UIFont systemFontOfSize:18];
    schoolInfoLabel.text = [NSString stringWithFormat:@"您希望加入%@-%@",schoolName,className];
    schoolInfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    schoolInfoLabel.textAlignment = NSTextAlignmentCenter;
    schoolInfoLabel.backgroundColor = [UIColor clearColor];
    schoolInfoLabel.textColor = TITLE_COLOR;
    [self.bgView addSubview:schoolInfoLabel];
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    nameTextField = [[MyTextField alloc] initWithFrame:CGRectMake(27.5, UI_NAVIGATION_BAR_HEIGHT+143, SCREEN_WIDTH-55, 35)];
    nameTextField.backgroundColor = [UIColor clearColor];
    nameTextField.tag = 1000;
    nameTextField.background = inputImage;
    nameTextField.placeholder = @"请输入您的姓名";
    nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nameTextField.keyboardType = UIKeyboardAppearanceDefault;
    nameTextField.delegate = self;
    nameTextField.textColor = TITLE_COLOR;
    nameTextField.returnKeyType = UIReturnKeyDone;
    nameTextField.font = [UIFont systemFontOfSize:14];
    [self.bgView addSubview:nameTextField];
    
    UILabel *tip1 = [[UILabel alloc] init];
    tip1.frame = CGRectMake(nameTextField.frame.origin.x, nameTextField.frame.origin.y+nameTextField.frame.size.height+10, 16*7, 24);
    tip1.text = @"您教授的课程是";
    tip1.backgroundColor = [UIColor clearColor];
    tip1.font = [UIFont systemFontOfSize:16];
    tip1.textColor = TITLE_COLOR;
    [self.bgView addSubview:tip1];
    
    showObjects = YES;
    checkCode = @"";
    
    objectArray = [[NSArray alloc] initWithObjects:@"语文",@"数学",@"英语",@"输入", nil];
    
    showObjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    showObjectButton.backgroundColor = [UIColor clearColor];
    showObjectButton.frame = CGRectMake(tip1.frame.origin.x, tip1.frame.origin.y+tip1.frame.size.height+2, 130, 35);
    [showObjectButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [showObjectButton setBackgroundImage:inputImage forState:UIControlStateNormal];
    [showObjectButton setTitle:[objectArray firstObject] forState:UIControlStateNormal];
    [showObjectButton addTarget:self action:@selector(showObject) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:showObjectButton];
    
    objectsTableView = [[UITableView alloc] initWithFrame:CGRectMake(showObjectButton.frame.origin.x, showObjectButton.frame.size.height+showObjectButton.frame.origin.y, showObjectButton.frame.size.width, 0) style:UITableViewStylePlain];
    objectsTableView.delegate = self;
    objectsTableView.dataSource = self;
    objectsTableView.tag = 2000;
    objectsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:objectsTableView];
    
    objectTextField = [[MyTextField alloc] initWithFrame:CGRectMake(showObjectButton.frame.size.width+showObjectButton.frame.origin.x+10, showObjectButton.frame.origin.y, 130, 35)];
    objectTextField.background = inputImage;
    objectTextField.tag = 2000;
    objectTextField.enabled = NO;
    objectTextField.delegate = self;
    objectTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    objectTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    objectTextField.font = [UIFont systemFontOfSize:14];
    [self.bgView addSubview:objectTextField];
    
//    [self getAdmins];
    
    if ([[Tools phone_num] length] > 0)
    {
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, SCREEN_HEIGHT-150, SCREEN_WIDTH-20, 20)];
        tipLabel.numberOfLines = 1;
        tipLabel.font = [UIFont systemFontOfSize:14];
        tipLabel.text = [NSString stringWithFormat:@"您已绑定手机：%@",[Tools phone_num]];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = TITLE_COLOR;
        tipLabel.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:tipLabel];
    }
    else
    {
        UIImage*inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 3, 20, 2.3)];
        
        phoneNumTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(29, SCREEN_HEIGHT-205, SCREEN_WIDTH-58, 35)];
        phoneNumTextfield.delegate = self;
        phoneNumTextfield.keyboardType = UIKeyboardTypeNumberPad;
        phoneNumTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
        phoneNumTextfield.tag = 3000;
        phoneNumTextfield.placeholder = @"手机号码";
        phoneNumTextfield.background = inputImage;
        phoneNumTextfield.textColor = UIColorFromRGB(0x727171);
        phoneNumTextfield.enabled = YES;
        [self.bgView addSubview:phoneNumTextfield];
        
        UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
        UIButton *getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        getCodeButton.frame = CGRectMake(SCREEN_WIDTH-91, phoneNumTextfield.frame.origin.y+5, 58, 25);
        [getCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [getCodeButton setTitle:@"短信验证" forState:UIControlStateNormal];
        getCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [getCodeButton addTarget:self action:@selector(getCheckCode) forControlEvents:UIControlEventTouchUpInside];
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
        
        UIButton *checkCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        checkCodeButton.frame = CGRectMake(SCREEN_WIDTH-91, codeTextField.frame.origin.y+5, 58, 25);
        [checkCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [checkCodeButton setTitle:@"验证" forState:UIControlStateNormal];
        checkCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [checkCodeButton addTarget:self action:@selector(verify) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:checkCodeButton];
    }

    
    
    UIImage *btnImage  =[Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIButton *studentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [studentButton setTitle:@"提交" forState:UIControlStateNormal];
    studentButton.frame = CGRectMake(38, SCREEN_HEIGHT-105, SCREEN_WIDTH-76, 40);
    studentButton.layer.cornerRadius = 2;
    studentButton.clipsToBounds = YES;
    [studentButton addTarget:self action:@selector(applyForJoinClass) forControlEvents:UIControlEventTouchUpInside];
    studentButton.tag = 1000;
    studentButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [studentButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.bgView addSubview:studentButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 验证码
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
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":phoneNumTextfield.text} API:CHECKPHONE];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"login responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                //                [[NSUserDefaults standardUserDefaults] setObject:[responseDict objectForKey:@"data"]forKey:USERID];
                //                [[NSUserDefaults standardUserDefaults] synchronize];
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
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"phone":phoneNumTextfield.text} API:@"/users/mbAuthCode2"];
        
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


#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [objectArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *objectCell = @"applyObject";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:objectCell];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:objectCell];
    }
    cell.textLabel.textColor = TITLE_COLOR;
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.text = [objectArray objectAtIndex:indexPath.row];
    UIImageView *bgImageBG = [[UIImageView alloc] init];
    bgImageBG.image = [UIImage imageNamed:@"cell_bg"];
    bgImageBG.backgroundColor = [UIColor clearColor];
    cell.backgroundView = bgImageBG;
    return  cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [objectArray count]-1)
    {
        objectTextField.enabled = YES;
        [showObjectButton setTitle:@"" forState:UIControlStateNormal];
        [objectTextField becomeFirstResponder];
    }
    else
    {
        objectStr = [objectArray objectAtIndex:indexPath.row];
        [showObjectButton setTitle:objectStr forState:UIControlStateNormal];
        objectTextField.text = @"";
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
            
            objectsTableView.frame = CGRectMake(showObjectButton.frame.origin.x, showObjectButton.frame.size.height+showObjectButton.frame.origin.y, showObjectButton.frame.size.width, 60);
        }];
    }
    else
    {
        [UIView animateWithDuration:0.2 animations:^{
            objectsTableView.frame = CGRectMake(showObjectButton.frame.origin.x, showObjectButton.frame.size.height+showObjectButton.frame.origin.y, showObjectButton.frame.size.width, 0);
        }];
    }
    showObjects = !showObjects;
}


-(void)applyForJoinClass
{
    
    if ([objectStr length] <= 0 && [objectTextField.text length] <= 0)
    {
        [Tools showAlertView:@"请选择和孩子的关系" delegateViewController:nil];
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
                                                                      @"title":[NSString stringWithFormat:@"%@老师",objectStr]
                                                                      } API:JOINCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classInfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"你的申请已经提交，请等待班主任的审核！" delegate:self cancelButtonTitle:@"回到班级列表" otherButtonTitles: nil];
                [al show];
                
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
                [Tools dealRequestError:responseDict fromViewController:self];
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
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
    MyClassesViewController *myClassesViewController = [[MyClassesViewController alloc] init];
    JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:myClassesViewController menuController:sideMenuViewController];
    [self presentViewController:sideMenu animated:YES completion:^{
        
    }];
}

@end
