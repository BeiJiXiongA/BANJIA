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
#import "NotificationDetailCell.h"
#import "StudentDetailViewController.h"

#define ChildTableViewTag  1000
#define RelateTableViewTag    2000
#define ChildTFTag   3000

#define CELLSTUDENTNUMTAG  10000

#define STUDENTALTERTAG   5000

#define StudentCellHeight  50

#define RestudentNumTag   4000

#define PhoneNumTftag   6000
#define CheckCodeTftag   7000
#define StudentNumTftag   8000

#define RelateActionTag  9000

@interface ParentApplyViewController ()<UIAlertViewDelegate,
UITextViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
UITableViewDelegate,
UIScrollViewDelegate,
UISearchBarDelegate,
UIActionSheetDelegate>
{
    UIScrollView *mainScrollView;
    
    UILabel *schoolInfoLabel;
    
    UILabel *tipLabel;
//    MyTextField *childNameTextField;
    
    UISearchBar *mySearchBar;
    
    MyTextField *phoneNumTextfield;
    MyTextField *codeTextField;
    
    MyTextField *studentNumField;
    
    UILabel *studentNumLabel;
    
    NSArray *relateArray;
    UIButton *relateButton;
    UITableView *relateTableView;
    BOOL showRelate;
    
    UIView *childView;
    UITableView *childTableView;
    NSMutableArray *childArray;
    UILabel *childLabel;
    
    UIView *childInfoView;
    
    UIView *phoneNumView;
    
    NSString *re_id;
    
    BOOL isOpen;
    
    NSString *checkCode;
    NSString *relateStr;
    NSString *student_num;
    
    UIButton *studentButton;
    UIButton *getCodeButton;
    UIButton *checkCodeButton;
    
    NSString *schoolName;
    NSString *className;
    NSString *classID;
    
    NSTimer *timer;
    int sec;
    
    UITapGestureRecognizer *tap;
    
    UIImageView *arrowImageView;
    
    OperatDB *db;
    
    UIView *selectStudentsView;
    UIImageView *selectStuIcon;
    UILabel *selectStuNameLabel;
    UILabel *selectStuMarkLabel;
    UIButton *selectStuButton;
    
    NSString *getCodePhoneNumber;

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

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.titleLabel.text = @"家长申请加入";
    db = [[OperatDB alloc] init];
    
    getCodePhoneNumber = @"";
    
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    
    childArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    checkCode = @"";
    re_id = @"";
    showRelate = NO;
    sec = 60;
    student_num = @"";
    
    mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT)];
    mainScrollView.delegate = self;
    [self.bgView addSubview:mainScrollView];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent)];
    mainScrollView.userInteractionEnabled = YES;
    
    NSString *schollInfo;
    if(schoolName && [schoolName length] > 0 && ![schoolName isEqualToString:@"未指定学校"])
    {
        schollInfo = [NSString stringWithFormat:@"您希望加入%@-%@",schoolName,className];
    }
    else
    {
        schollInfo = [NSString stringWithFormat:@"您希望加入%@",className];;
    }
    
    CGSize size = [Tools getSizeWithString:schollInfo andWidth:SCREEN_WIDTH-40 andFont:[UIFont systemFontOfSize:18]];
    
    schoolInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH-40, size.height)];
    schoolInfoLabel.numberOfLines = 2;
    schoolInfoLabel.font = [UIFont systemFontOfSize:18];
    schoolInfoLabel.text = schollInfo;
    schoolInfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    schoolInfoLabel.backgroundColor = [UIColor clearColor];
    schoolInfoLabel.textColor = TITLE_COLOR;
    [mainScrollView addSubview:schoolInfoLabel];
    
    
    UIImageView *lineImageView = [[UIImageView alloc] init];
    lineImageView.frame = CGRectMake( 0, schoolInfoLabel.frame.size.height+schoolInfoLabel.frame.origin.y+20, SCREEN_WIDTH, 0.5);
    lineImageView.backgroundColor = LineBackGroudColor;
    [mainScrollView addSubview:lineImageView];
    
    CGFloat lableL = 110;

    mySearchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, schoolInfoLabel.frame.size.height+schoolInfoLabel.frame.origin.y+40, SCREEN_WIDTH-40, 42)];
    mySearchBar.backgroundColor = [UIColor whiteColor];
    mySearchBar.tag = 1000;
    mySearchBar.layer.cornerRadius = 5;
    mySearchBar.clipsToBounds = YES;
    mySearchBar.keyboardType = UIKeyboardAppearanceDefault;
    mySearchBar.delegate = self;
    [mainScrollView addSubview:mySearchBar];
    mySearchBar.showsScopeBar = NO;
    [mySearchBar setContentMode:UIViewContentModeLeft];
    
    if (SYSVERSION >= 7.0)
    {
        mySearchBar.searchBarStyle = UISearchBarStyleMinimal;
        mySearchBar.placeholder = @"您孩子的姓名                                        ";
    }
    else
    {
        mySearchBar.placeholder = @"您孩子的姓名";
        UITextField* searchField = nil;
        for (UIView* subview in mySearchBar.subviews)
        {
            if ([subview isKindOfClass:[UITextField class]])
            {
                searchField = (UITextField*)subview;
                searchField.leftView=nil;
                [searchField setBackground:nil];
                [searchField setBackgroundColor:[UIColor whiteColor]];
                searchField.background = [Tools getImageFromImage:[UIImage imageNamed:@""] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
                break;
            }
        }
        
        for (UIView *subview in mySearchBar.subviews)
        {
            if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")])
            {
                subview.backgroundColor = [UIColor clearColor];
                [subview removeFromSuperview];
                break;
            }
        }

    }
    [mySearchBar setSearchFieldBackgroundImage:[UIImage imageNamed:@"searchbarbg"] forState:UIControlStateNormal];
    [mySearchBar setImage:[UIImage imageNamed:@"searchbarbg"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    
    selectStudentsView = [[UIView alloc] init];
    selectStudentsView.frame = CGRectMake(mySearchBar.frame.origin.x, mySearchBar.frame.origin.y, mySearchBar.frame.size.width, StudentCellHeight);
    selectStudentsView.backgroundColor = [UIColor whiteColor];
    selectStudentsView.layer.cornerRadius = 2;
    selectStudentsView.clipsToBounds = YES;
    [mainScrollView addSubview:selectStudentsView];
    selectStudentsView.hidden = YES;
    
    selectStuIcon = [[UIImageView alloc] init];
    selectStuIcon.frame = CGRectMake(10, 5, 40, 40);
    selectStuIcon.layer.cornerRadius = 5;
    selectStuIcon.clipsToBounds = YES;
    [selectStudentsView addSubview:selectStuIcon];
    
    selectStuNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 5, lableL, 20)];
    selectStuNameLabel.font = [UIFont systemFontOfSize:16];
    selectStuNameLabel.backgroundColor = [UIColor whiteColor];
    selectStuNameLabel.textColor = TITLE_COLOR;
    [selectStudentsView addSubview:selectStuNameLabel];
    
    selectStuMarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, lableL, 20)];
    selectStuMarkLabel.font = [UIFont systemFontOfSize:14];
    selectStuMarkLabel.backgroundColor = [UIColor whiteColor];
    selectStuMarkLabel.textColor = COMMENTCOLOR;
    [selectStudentsView addSubview:selectStuMarkLabel];
    
    selectStuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectStuButton setTitle:@"修改" forState:UIControlStateNormal];
    selectStuButton.frame = CGRectMake(mySearchBar.frame.size.width-60, 10, 40, 30);
    selectStuButton.backgroundColor = [UIColor whiteColor];
    [selectStuButton setTitleColor:LIGHT_BLUE_COLOR forState:UIControlStateNormal];
    [selectStudentsView addSubview:selectStuButton];
    [selectStuButton addTarget:self action:@selector(modifySelectStu) forControlEvents:UIControlEventTouchUpInside];
    
    childInfoView = [[UIView alloc] init];
    childInfoView.frame = CGRectMake(0, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+20, SCREEN_WIDTH, 0);
    childInfoView.hidden = YES;
    childInfoView.backgroundColor = [UIColor clearColor];
    [mainScrollView addSubview:childInfoView];
    
    UILabel *relateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, lableL, 30)];
    relateLabel.font = [UIFont systemFontOfSize:16];
    relateLabel.text = [NSString stringWithFormat:@"你是孩子的:"];
    relateLabel.backgroundColor = self.bgView.backgroundColor;
    relateLabel.textColor = TITLE_COLOR;
    relateLabel.textAlignment = NSTextAlignmentRight;
    [childInfoView addSubview:relateLabel];
    
    studentNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, relateLabel.frame.origin.y + relateLabel.frame.size.height+20, lableL, 30)];
    studentNumLabel.font = [UIFont systemFontOfSize:16];
    studentNumLabel.text = [NSString stringWithFormat:@"您孩子学号是:"];
    studentNumLabel.backgroundColor = self.bgView.backgroundColor;
    studentNumLabel.textColor = TITLE_COLOR;
    studentNumLabel.textAlignment = NSTextAlignmentRight;
    [childInfoView addSubview:studentNumLabel];
    
    studentNumField = [[MyTextField alloc] initWithFrame:CGRectMake(studentNumLabel.frame.size.width+studentNumLabel.frame.origin.x+10, studentNumLabel.frame.origin.y-6, SCREEN_WIDTH-145, 42)];
    studentNumField.background = nil;
    studentNumField.tag = StudentNumTftag;
    studentNumField.placeholder = @"选填";
    studentNumField.delegate = self;
    studentNumField.keyboardType = UIKeyboardTypeNumberPad;
    studentNumField.layer.cornerRadius = 5;
    studentNumField.clipsToBounds = YES;
    studentNumField.backgroundColor = [UIColor whiteColor];
    studentNumField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    studentNumField.clearButtonMode = UITextFieldViewModeWhileEditing;
    studentNumField.font = [UIFont systemFontOfSize:17];
    studentNumField.textColor = COMMENTCOLOR;
    [childInfoView addSubview:studentNumField];

    relateArray = RELATEARRAY;
    
    relateStr = [relateArray firstObject];
    
    relateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    relateButton.backgroundColor = [UIColor whiteColor];
    relateButton.layer.cornerRadius = 5;
    relateButton.clipsToBounds = YES;
    relateButton.frame = CGRectMake(relateLabel.frame.origin.x+relateLabel.frame.size.width+10, relateLabel.frame.origin.y - 6, SCREEN_WIDTH-145, 42);
    [relateButton setTitleColor:COMMENTCOLOR forState:UIControlStateNormal];
    relateButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [relateButton setTitle:[NSString stringWithFormat:@"  %@",[relateArray firstObject]] forState:UIControlStateNormal];
    [relateButton addTarget:self action:@selector(selectRelate) forControlEvents:UIControlEventTouchUpInside];
    [childInfoView addSubview:relateButton];
    
    arrowImageView = [[UIImageView alloc] init];
    arrowImageView.frame = CGRectMake(relateButton.frame.origin.x + relateButton.frame.size.width- 30, relateButton.frame.origin.y+11, 20, 20);
    arrowImageView.backgroundColor = [UIColor whiteColor];
    [arrowImageView setImage:[UIImage imageNamed:@"edit"]];
    [childInfoView addSubview:arrowImageView];
    
    relateTableView = [[UITableView alloc] initWithFrame:CGRectMake(relateButton.frame.origin.x, relateButton.frame.size.height+relateButton.frame.origin.y, relateButton.frame.size.width, 0) style:UITableViewStylePlain];
    relateTableView.delegate = self;
    relateTableView.dataSource = self;
    relateTableView.tag = RelateTableViewTag;
    relateTableView.layer.cornerRadius = 5;
    relateTableView.clipsToBounds = YES;
    relateTableView.backgroundColor = [UIColor whiteColor];
    relateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [childInfoView addSubview:relateTableView];
    
    childView = [[UIView alloc] init];
    childView.frame = CGRectMake(0, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+20, SCREEN_WIDTH, 0);
    childView.backgroundColor = self.bgView.backgroundColor;
    childView.hidden = YES;
    [mainScrollView addSubview:childView];
    
    childLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 200, 20)];
    childLabel.font = [UIFont systemFontOfSize:16];
    childLabel.text = [NSString stringWithFormat:@"您的孩子可能已在班级中:"];
    childLabel.backgroundColor = self.bgView.backgroundColor;
    childLabel.textColor = COMMENTCOLOR;
    [childView addSubview:childLabel];
    
    childTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 35, SCREEN_WIDTH-20, 0) style:UITableViewStylePlain];
    childTableView.delegate = self;
    childTableView.dataSource = self;
    childTableView.tag = ChildTableViewTag;
    childTableView.layer.cornerRadius = 5;
    childTableView.clipsToBounds = YES;
    childTableView.scrollEnabled = NO;
    childTableView.backgroundColor = [UIColor whiteColor];
    childTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [childView addSubview:childTableView];
    
    
    [self layoutPhoneView];
}

-(void)layoutPhoneView
{
    
    childInfoView.frame = CGRectMake(0, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+20, SCREEN_WIDTH, 100);
    
    phoneNumView = [[UIView alloc] init];
    phoneNumView.frame = CGRectMake(0, childInfoView.frame.size.height + childInfoView.frame.origin.y+10, SCREEN_WIDTH, 230);
    phoneNumView.backgroundColor = self.bgView.backgroundColor;
    [mainScrollView addSubview:phoneNumView];
    
    UIImageView *lineImageView1 = [[UIImageView alloc] init];
    lineImageView1.frame = CGRectMake( 0, 0, SCREEN_WIDTH, 0.5);
    lineImageView1.backgroundColor = LineBackGroudColor;
    [phoneNumView addSubview:lineImageView1];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    if ([[Tools phone_num] length] > 0)
    {
        tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, SCREEN_WIDTH-20, 0)];
        tipLabel.frame = CGRectMake(10, 20, SCREEN_WIDTH-20, 20);
        tipLabel.numberOfLines = 1;
        tipLabel.font = [UIFont systemFontOfSize:16];
        tipLabel.text = [NSString stringWithFormat:@"您已绑定手机：%@",[Tools phone_num]];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = COMMENTCOLOR;
        tipLabel.backgroundColor = [UIColor clearColor];
        [phoneNumView addSubview:tipLabel];
    }
    else
    {
        tipLabel = [[UILabel alloc] init];
        tipLabel.frame = CGRectMake(29, 20, SCREEN_WIDTH-58, 45);
        tipLabel.numberOfLines = 2;
        tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
        tipLabel.font = [UIFont systemFontOfSize:16];
        tipLabel.text = [NSString stringWithFormat:@"您还没有绑定手机号，重要的班级通知可能会发送到您的手机上"];
        tipLabel.textColor = COMMENTCOLOR;
        tipLabel.backgroundColor = [UIColor clearColor];
        [phoneNumView addSubview:tipLabel];
        
        phoneNumTextfield = [[MyTextField alloc] initWithFrame:CGRectMake(29, 75, SCREEN_WIDTH-58, 42)];
        phoneNumTextfield.delegate = self;
        phoneNumTextfield.keyboardType = UIKeyboardTypeNumberPad;
        phoneNumTextfield.clearButtonMode = UITextFieldViewModeWhileEditing;
        phoneNumTextfield.tag = PhoneNumTftag;
        phoneNumTextfield.layer.cornerRadius = 5;
        phoneNumTextfield.clipsToBounds = YES;
        phoneNumTextfield.backgroundColor = [UIColor whiteColor];
        phoneNumTextfield.placeholder = @"手机号码";
        phoneNumTextfield.background = nil;
        phoneNumTextfield.textColor = COMMENTCOLOR;
        phoneNumTextfield.enabled = YES;
        phoneNumTextfield.numericFormatter = [AKNumericFormatter formatterWithMask:PHONE_FORMAT placeholderCharacter:'*'];
        [phoneNumView addSubview:phoneNumTextfield];
        
        getCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        getCodeButton.frame = CGRectMake(SCREEN_WIDTH-91, phoneNumTextfield.frame.origin.y+5, 58, 32);
        [getCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [getCodeButton setTitle:@"短信验证" forState:UIControlStateNormal];
        getCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [getCodeButton addTarget:self action:@selector(getVerifyCode) forControlEvents:UIControlEventTouchUpInside];
        [phoneNumView addSubview:getCodeButton];
        
        codeTextField = [[MyTextField alloc] initWithFrame:CGRectMake(29, phoneNumTextfield.frame.size.height+phoneNumTextfield.frame.origin.y+3, SCREEN_WIDTH-58, 42)];
        codeTextField.delegate = self;
        codeTextField.layer.cornerRadius = 5;
        codeTextField.clipsToBounds = YES;
        codeTextField.backgroundColor = [UIColor whiteColor];
        codeTextField.background = nil;
        codeTextField.keyboardType = UIKeyboardTypeNumberPad;
        codeTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        codeTextField.tag = CheckCodeTftag;
        codeTextField.textColor = UIColorFromRGB(0x727171);
        codeTextField.placeholder = @"验证码";
        [phoneNumView addSubview:codeTextField];
        
        checkCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        checkCodeButton.frame = CGRectMake(SCREEN_WIDTH-91, codeTextField.frame.origin.y+5, 58, 32);
        [checkCodeButton setBackgroundImage:btnImage forState:UIControlStateNormal];
        [checkCodeButton setTitle:@"验证" forState:UIControlStateNormal];
        checkCodeButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [checkCodeButton addTarget:self action:@selector(verify) forControlEvents:UIControlEventTouchUpInside];
        [phoneNumView addSubview:checkCodeButton];
    }
    studentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [studentButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [studentButton setTitle:@"提交" forState:UIControlStateNormal];
    [phoneNumView addSubview:studentButton];
    
    if ([[Tools phone_num] length] > 0)
    {
        studentButton.frame = CGRectMake(38, tipLabel.frame.size.height + tipLabel.frame.origin.y+15, SCREEN_WIDTH-76, 40);
    }
    else
    {
        studentButton.frame = CGRectMake(38, codeTextField.frame.size.height + codeTextField.frame.origin.y+5, SCREEN_WIDTH-76, 40);
    }
    if ([selectStuNameLabel.text length] > 0)
    {
        studentButton.enabled = YES;
    }
    else
    {
        studentButton.enabled = NO;
    }
    [studentButton addTarget:self action:@selector(applyJoinClass) forControlEvents:UIControlEventTouchUpInside];
    studentButton.tag = 1000;
    studentButton.titleLabel.font = [UIFont systemFontOfSize:18];
    
    mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, phoneNumView.frame.size.height+phoneNumView.frame.origin.y + 80);
}

-(void)modifySelectStu
{
    mySearchBar.hidden = NO;
    selectStudentsView.hidden = YES;
    childInfoView.hidden = YES;
    childView.hidden = YES;
    
    student_num = @"";
    re_id = @"";
    mySearchBar.text = @"";
    studentButton.enabled = NO;
    
    childView.frame = CGRectMake(mySearchBar.frame.origin.x, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+20, mySearchBar.frame.size.width, 0);
    childInfoView.frame = CGRectMake(0, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+20, SCREEN_WIDTH, 0);
    [self changeHeight];
}

-(void)changeHeight
{
    if (childView.frame.size.height > 0)
    {
        phoneNumView.frame = CGRectMake(0, childView.frame.origin.y+childView.frame.size.height+10, SCREEN_WIDTH, 150);
    }
    else if(childInfoView.frame.size.height > 0)
    {
        phoneNumView.frame = CGRectMake(0, childInfoView.frame.origin.y+childInfoView.frame.size.height+10, SCREEN_WIDTH, 150);
    }
    else
    {
        phoneNumView.frame = CGRectMake(0, mySearchBar.frame.origin.y+mySearchBar.frame.size.height+10, SCREEN_WIDTH, 150);
    }
    CGSize size = CGSizeMake(SCREEN_WIDTH, phoneNumView.frame.size.height+phoneNumView.frame.origin.y+80);
    mainScrollView.contentSize = size;
}

-(void)cancelStudents
{
    [childArray removeAllObjects];
    [childTableView reloadData];
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

-(void)tapEvent
{
    [phoneNumTextfield resignFirstResponder];
    [mySearchBar resignFirstResponder];
    [codeTextField resignFirstResponder];
    [studentNumField resignFirstResponder];
}


-(void)unShowSelfViewController
{
    [timer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)getVerifyCode
{
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
        [timer invalidate];
        sec = 60;
    }
}


-(void)getcheckCode
{
    if (sec != 60)
    {
        return ;
    }
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
                [Tools showTips:@"绑定成功" toView:self.bgView];
                tipLabel.hidden = YES;
                phoneNumTextfield.enabled = NO;
                [[NSUserDefaults standardUserDefaults] setObject:phoneNumTextfield.text forKey:PHONENUM];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                getCodeButton.hidden = YES;
                checkCodeButton.hidden = YES;
                
                [phoneNumView removeFromSuperview];
                
                [self layoutPhoneView];
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

-(void)selectRelate
{
//    if (showRelate)
//    {
//        [UIView animateWithDuration:0.2 animations:^{
//            
//            relateTableView.frame = CGRectMake(relateButton.frame.origin.x, relateButton.frame.size.height+relateButton.frame.origin.y, relateButton.frame.size.width, 0);
//            [arrowImageView setImage:[UIImage imageNamed:@"arrow_down"]];
//        }];
//        [mainScrollView addGestureRecognizer:tap];
//    }
//    else
//    {
//        [UIView animateWithDuration:0.2 animations:^{
//            relateTableView.frame = CGRectMake(relateButton.frame.origin.x, relateButton.frame.size.height+relateButton.frame.origin.y, relateButton.frame.size.width, [relateArray count]*40);
//            [arrowImageView setImage:[UIImage imageNamed:@"arrow_up"]];
//        }];
//        [mainScrollView removeGestureRecognizer:tap];
//    }
//    [studentNumField resignFirstResponder];
//    [mySearchBar resignFirstResponder];
//    showRelate = !showRelate;
//    [relateTableView reloadData];
    
    UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"爸爸",@"妈妈",@"爷爷",@"奶奶",@"姥爷",@"姥姥",@"家长", nil];
    ac.tag = RelateActionTag;
    [ac showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if(buttonIndex < 7)
    {
        relateStr = [relateArray objectAtIndex:buttonIndex];
        [relateButton setTitle:[NSString stringWithFormat:@"  %@",relateStr] forState:UIControlStateNormal];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 1000)
    {
        if ([textField.text length]>2)
        {
            [self getStudentsByClassId:textField.text];
        }
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag == ChildTFTag)
    {
        if ([textField.text length]>2)
        {
            [self getStudentsByClassId:textField.text];
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

#pragma mark - searchbardelegate

-(void)cancelSearch
{
    mySearchBar.text = nil;
    [UIView animateWithDuration:0.2 animations:^{
    }];
    
    [mySearchBar resignFirstResponder];
}
-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [UIView animateWithDuration:0.2 animations:^{
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchBar.text length] >= 2)
    {
        [self getStudentsByClassId:searchText];
        childView.hidden = NO;
    }
    else
    {
        [childArray removeAllObjects];
        [childTableView reloadData];
        childView.hidden = YES;
    }
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self cancelSearch];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *searchContent = [searchBar text];
    [self getStudentsByClassId:searchContent];
    [mySearchBar resignFirstResponder];
}

-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    DDLOG_CURRENT_METHOD;
}


#pragma mark - tableview

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [mySearchBar resignFirstResponder];
    [studentNumField resignFirstResponder];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == RelateTableViewTag)
    {
        if (showRelate)
        {
            return [relateArray count];
        }
    }
    else if(tableView.tag == ChildTableViewTag)
    {
        
        CGFloat height = [childArray count]*50+80;
        
        childTableView.frame = CGRectMake(10, 35, SCREEN_WIDTH-40, height);
        childView.frame = CGRectMake(10, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+20,SCREEN_WIDTH-20, height+35);
        if ([childArray count] > 0)
        {
            childLabel.text = @"您的孩子可能已在班级中";
            
        }
        else
        {
            childLabel.text = @"您的孩子可能没在班级中";
        }
        [self changeHeight];
        return [childArray count]+1;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == RelateTableViewTag)
    {
        return 40;
    }
    else if (tableView.tag == ChildTableViewTag)
    {
        if(indexPath.row < [childArray count])
        {
            return 50;
        }
        return 80;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView.tag == ChildTableViewTag)
    {
        static NSString *childider = @"childider";
        NotificationDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:childider];
        if (cell == nil)
        {
            cell = [[NotificationDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:childider];
        }
        cell.nameLabel.frame = CGRectMake(10, 5, 200, 30);
        cell.nameLabel.backgroundColor = [UIColor whiteColor];
        cell.nameLabel.textColor = CONTENTCOLOR;
        cell.nameLabel.font = [UIFont systemFontOfSize:15];
        cell.headerImageView.frame = CGRectMake(10, 5, 40, 40);
        
        cell.nameLabel.frame = CGRectMake(60, 5, 200, 30);
        CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
        cell.lineImageView.backgroundColor = LineBackGroudColor;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.lineImageView.frame = CGRectMake(0, cellHeight-0.5, 0, 0);
        if (indexPath.row < [childArray count])
        {
            
            if (indexPath.row < [childArray count]-1)
            {
                cell.lineImageView.frame = CGRectMake(60, cellHeight-0.5, cell.frame.size.width, 0.5);
            }
            else
            {
                cell.lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
            }
            cell.headerImageView.hidden = NO;
            cell.nameLabel.hidden = NO;
            cell.button2.hidden = NO;
            cell.contactButton.hidden = NO;
            
            NSDictionary *studentDict = [childArray objectAtIndex:indexPath.row];
            cell.headerImageView.frame = CGRectMake(10, 5, 40, 40);
            cell.nameLabel.frame = CGRectMake(60, 5, 200, 30);
           
            [Tools fillImageView:cell.headerImageView withImageFromURL:[studentDict objectForKey:@"img_icon"] andDefault:HEADERICON];
            
            if ([studentDict objectForKey:@"sn"] &&
                ![[studentDict objectForKey:@"sn"] isEqual:[NSNull null]] &&
                [[studentDict objectForKey:@"sn"] length] > 0)
            {
                cell.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",[studentDict objectForKey:@"name"],[studentDict objectForKey:@"sn"]];
            }
            else
            {
                cell.nameLabel.text = [studentDict objectForKey:@"name"];
            }
            cell.numLabel.hidden = NO;
            cell.numLabel.font = [UIFont systemFontOfSize:14];
            if ([[studentDict objectForKey:@"parents"] count] > 0)
            {
                NSDictionary *parentDict = [[studentDict objectForKey:@"parents"] firstObject];
                NSString *markStr = [NSString stringWithFormat:@"家长：*%@",[[parentDict objectForKey:@"name"] substringFromIndex:1]];
                cell.numLabel.frame = CGRectMake(60, 30, 200, 20);
                cell.numLabel.text = markStr;
                cell.numLabel.textColor = COMMENTCOLOR;
            }
            else
            {
                cell.numLabel.text = @"";
            }
            
            cell.button2.frame = CGRectMake(mySearchBar.frame.size.width-50, 10, 40, 30);
            cell.button2.tag = indexPath.row;
            [cell.button2 setImage:[UIImage imageNamed:@"unchecked1"] forState:UIControlStateNormal];
            cell.button2.hidden = NO;
            [cell.button2 setTitleColor:RGB(136, 193, 95, 1) forState:UIControlStateNormal];
            [cell.button2 addTarget:self action:@selector(combine:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            cell.nameLabel.numberOfLines = 2;
            cell.nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
            if ([childArray count] > 0)
            {
                cell.nameLabel.frame = CGRectMake(60, 17, 200, 45);
                cell.nameLabel.text = @"如果您孩子不在列表中，可点击输入孩子信息";
            }
            else
            {
                cell.nameLabel.frame = CGRectMake(60, 20, 200, 40);
                cell.nameLabel.text = @"请输入孩子完整信息";
            }
            cell.numLabel.text = @"";
            cell.numLabel.hidden = YES;
            cell.nameLabel.textColor = COMMENTCOLOR;
            cell.nameLabel.font = [UIFont systemFontOfSize:16];
            cell.button2.hidden = YES;
            cell.contactButton.hidden = YES;
            cell.headerImageView.backgroundColor = [UIColor whiteColor];
            cell.headerImageView.frame = CGRectMake(10, 27.5, 25, 25);
            [cell.headerImageView setImage:[UIImage imageNamed:@"applyadd"]];
        }
        
        return cell;
    }
    return nil;
}

-(void)joinclass:(UIButton *)button
{
    [childArray removeAllObjects];
    [childTableView reloadData];
}

-(void)combine:(UIButton *)button
{
    NSDictionary *stuDict = [childArray objectAtIndex:button.tag];
    DDLOG(@"stu dict %@",stuDict);
    re_id = [stuDict objectForKey:@"_id"];
    if ([stuDict objectForKey:@"sn"] && ![[stuDict objectForKey:@"sn"] isEqual:[NSNull null]])
    {
        studentNumField.text = [stuDict objectForKey:@"sn"];
        student_num = [stuDict objectForKey:@"sn"];
    }
    
    selectStuIcon.hidden = NO;
    selectStuNameLabel.frame = CGRectMake(60, 10, 200, 30);
    selectStudentsView.hidden = NO;
    mySearchBar.hidden = YES;
    selectStuMarkLabel.hidden = NO;
    
    
    childInfoView.hidden = NO;
    studentNumField.hidden = YES;
    studentNumLabel.hidden = YES;
    
    [Tools fillImageView:selectStuIcon withImageFromURL:[stuDict objectForKey:@"img_icon"] andDefault:HEADERICON];
    
    if ([stuDict objectForKey:@"sn"] &&
        ![[stuDict objectForKey:@"sn"] isEqual:[NSNull null]] &&
        [[stuDict objectForKey:@"sn"] length] > 0)
    {
        student_num = [stuDict objectForKey:@"sn"];
        studentNumField.text = [stuDict objectForKey:@"sn"];
        selectStuNameLabel.text = [NSString stringWithFormat:@"%@(%@)",[stuDict objectForKey:@"name"],[stuDict objectForKey:@"sn"]];
    }
    else
    {
        selectStuNameLabel.text = [stuDict objectForKey:@"name"];
    }
    mySearchBar.text = [stuDict objectForKey:@"name"];
    childView.hidden = YES;
    childInfoView.frame = CGRectMake(0, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+20, SCREEN_WIDTH, 50);
    childView.frame = CGRectMake(10, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+20, SCREEN_WIDTH-20, 0);
    [self changeHeight];
    if ([[Tools phone_num] length] > 0)
    {
        studentButton.enabled = YES;
    }
    studentButton.enabled = YES;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DDLOG(@"didselect row");
    if(tableView.tag == ChildTableViewTag)
    {
        if (indexPath.row < [childArray count])
        {
            NSDictionary *stuDict = [childArray objectAtIndex:indexPath.row];
            DDLOG(@"stu dict %@",stuDict);
            re_id = [stuDict objectForKey:@"_id"];
            if ([stuDict objectForKey:@"sn"] && ![[stuDict objectForKey:@"sn"] isEqual:[NSNull null]])
            {
                studentNumField.text = [stuDict objectForKey:@"sn"];
                student_num = [stuDict objectForKey:@"sn"];
            }
            
            selectStuIcon.hidden = NO;
            selectStuNameLabel.frame = CGRectMake(60, 10, 200, 30);
            selectStudentsView.hidden = NO;
            mySearchBar.hidden = YES;
            selectStuMarkLabel.hidden = NO;
            
            
            childInfoView.hidden = NO;
            studentNumField.hidden = YES;
            studentNumLabel.hidden = YES;
            
            [Tools fillImageView:selectStuIcon withImageFromURL:[stuDict objectForKey:@"img_icon"] andDefault:HEADERICON];
            
            if ([stuDict objectForKey:@"sn"] &&
                ![[stuDict objectForKey:@"sn"] isEqual:[NSNull null]] &&
                [[stuDict objectForKey:@"sn"] length] > 0)
            {
                student_num = [stuDict objectForKey:@"sn"];
                studentNumField.text = [stuDict objectForKey:@"sn"];
                selectStuNameLabel.text = [NSString stringWithFormat:@"%@(%@)",[stuDict objectForKey:@"name"],[stuDict objectForKey:@"sn"]];
            }
            else
            {
                selectStuNameLabel.text = [stuDict objectForKey:@"name"];
            }
            mySearchBar.text = [stuDict objectForKey:@"name"];
            childInfoView.frame = CGRectMake(0, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+20, SCREEN_WIDTH, 50);
            childView.frame = CGRectMake(10, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+20, SCREEN_WIDTH-20, 0);
            [self changeHeight];
        }
        else
        {
            re_id = @"";
            selectStuIcon.hidden = YES;
            selectStuNameLabel.frame = CGRectMake(10, 10, 200, 30);
            selectStuNameLabel.text = [NSString stringWithFormat:@"姓名：%@",[mySearchBar text]];
            studentNumField.text = @"";
            student_num = @"";
            
            selectStudentsView.hidden = NO;
            mySearchBar.hidden = YES;
            selectStuMarkLabel.hidden = YES;
            
            childInfoView.hidden = NO;
            studentNumField.hidden = NO;
            studentNumLabel.hidden = NO;
            
            childInfoView.frame = CGRectMake(0, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+20, SCREEN_WIDTH, 100);
            childView.frame = CGRectMake(10, mySearchBar.frame.size.height+mySearchBar.frame.origin.y+20, SCREEN_WIDTH-20, 0);
            [self changeHeight];
        }
    }
    if ([[Tools phone_num] length] > 0)
    {
        studentButton.enabled = YES;
    }
    childView.hidden = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)viewStudentsDetail:(UIButton *)button
{
    NSDictionary *studentDict = [childArray objectAtIndex:button.tag];
    NSArray *tmpParentArray = [studentDict objectForKey:@"parents"];
    DDLOG(@"tmpParentArray %lu",(unsigned long)[tmpParentArray count]);
    NSMutableDictionary *pDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    for (int i=0; i<[tmpParentArray count]; i++)
    {
        pDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        NSDictionary *tmpD = [tmpParentArray objectAtIndex:i];
        [pDict setObject:[tmpD objectForKey:@"name"] forKey:@"name"];
        [pDict setObject:[tmpD objectForKey:@"_id"] forKey:@"uid"];
        if (![[tmpD objectForKey:@"img_icon"] isEqual:[NSNull null]])
        {
            [pDict setObject:[tmpD objectForKey:@"img_icon"] forKey:@"img_icon"];
        }
        else
        {
            [pDict setObject:@"" forKey:@"img_icon"];
        }
        [pDict setObject:[tmpD objectForKey:@"role"] forKey:@"role"];
        [pDict setObject:[tmpD objectForKey:@"title"] forKey:@"title"];
        [pDict setObject:[tmpD objectForKey:@"checked"] forKey:@"checked"];
        [pDict setObject:classID forKey:@"classid"];
        [pDict setObject:[tmpD objectForKey:@"re_name"] forKey:@"re_name"];
        [pDict setObject:[tmpD objectForKey:@"re_id"] forKey:@"re_id"];
        if ([[db findSetWithDictionary:@{@"uid":[tmpD objectForKey:@"_id"],@"classid":classID} andTableName:CLASSMEMBERTABLE] count] == 0)
        {
            if ([db insertRecord:pDict andTableName:CLASSMEMBERTABLE])
            {
                DDLOG(@"%@",pDict);
            }
        }
    }
    StudentDetailViewController *studentDetail = [[StudentDetailViewController alloc] init];
    if (![[studentDict objectForKey:@"_id"] isEqual:[NSNull null]])
    {
        studentDetail.studentID = [studentDict objectForKey:@"_id"];
    }
    if (![[studentDict objectForKey:@"title"] isEqual:[NSNull null]])
    {
        studentDetail.title = [studentDict objectForKey:@"title"];
    }
    studentDetail.studentName = [studentDict objectForKey:@"name"];
    if (![[studentDict objectForKey:@"title"] isEqual:[NSNull null]])
    {
        studentDetail.title = [studentDict objectForKey:@"title"];
    }
    if(![[studentDict objectForKey:@"img_icon"] isEqual:[NSNull null]] && [[studentDict objectForKey:@"img_icon"] length] > 15)
    {
        studentDetail.headerImg = [studentDict objectForKey:@"img_icon"];
    }
    else
    {
        studentDetail.headerImg = @"";
    }
    studentDetail.role = [studentDict objectForKey:@"role"];
    studentDetail.studentNum = [studentDict objectForKey:@"sn"];
    [self.navigationController pushViewController:studentDetail animated:YES];
}


-(void)applyJoinClass
{
    if (studentNumField.text && [studentNumField.text length] > 0)
    {
        student_num = studentNumField.text;
    }
    else
    {
        student_num = @"";
    }
    if ([mySearchBar.text length] == 0)
    {
        [Tools showAlertView:@"请输入孩子的姓名" delegateViewController:nil];
        return;
    }
    if ([relateStr length] <= 0)
    {
        [Tools showAlertView:@"请选择和孩子的关系" delegateViewController:nil];
        return ;
    }
    if ([student_num length] > 0 && ![Tools isStudentsNumber:student_num])
    {
        [Tools showAlertView:@"学号是由5-12位字母或数字组成" delegateViewController:nil];
        return ;
    }
    
    if ([re_id length] == 0)
    {
        for(NSDictionary *dict in childArray)
        {
            if ([student_num isEqualToString:[dict objectForKey:@"sn"]] &&
                [mySearchBar.text isEqualToString:[dict objectForKey:@"name"]])
            {
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:@"请输入学号加以区分" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                al.alertViewStyle = UIAlertViewStylePlainTextInput;
                ((UITextField *)[al textFieldAtIndex:0]).keyboardType = UIKeyboardTypeNumberPad;
                al.tag = RestudentNumTag;
                [al show];
                return ;
            }
        }
    }
    if ([Tools NetworkReachable])
    {
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"role":@"parents",
                                                                      @"re_id":re_id,
                                                                      @"re_name":mySearchBar.text,
                                                                      @"re_type":relateStr,
                                                                      @"sn":student_num
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
                                                                      @"name":studentName
                                                                      } API:GETCHILDBYNAME];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getStudentByClassId responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [childArray removeAllObjects];
                [childArray addObjectsFromArray:[responseDict objectForKey:@"data"]];
                [childTableView reloadData];
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
    if(textField.tag == StudentNumTftag)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-80);
        }];
    }
    else if(textField.tag == PhoneNumTftag)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-170);
        }];
    }
    else if(textField.tag == CheckCodeTftag)
    {
        [UIView animateWithDuration:0.2 animations:^{
            self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y-220);
        }];
    }
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
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
    else if (alertView.tag == STUDENTALTERTAG)
    {
        if (buttonIndex == 1)
        {
            DDLOG(@"alter text %@",[alertView textFieldAtIndex:0].text);
            relateStr = [NSString stringWithFormat:@"   %@",[alertView textFieldAtIndex:0].text];
            [relateButton setTitle:relateStr forState:UIControlStateNormal];
            showRelate = YES;
            [self selectRelate];
        }
    }
    else if(alertView.tag == RestudentNumTag)
    {
        if (buttonIndex == 1)
        {
            student_num = [alertView textFieldAtIndex:0].text;
            studentNumField.text = student_num;
        }
    }
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
        [mySearchBar resignFirstResponder];
        [mainScrollView removeGestureRecognizer:tap];
    }completion:^(BOOL finished) {
        
    }];
}

-(void)keyBoardWillShow:(NSNotification *)aNotification
{
    [mainScrollView addGestureRecognizer:tap];
}

@end
