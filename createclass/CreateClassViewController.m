//
//  CreateClassViewController.m
//  School
//
//  Created by TeekerZW on 1/15/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "CreateClassViewController.h"
#import "Header.h"
#import "MySwitchView.h"
#import "MyClassesViewController.h"
#import "SideMenuViewController.h"
#import "JDSideMenu.h"
#import "KKNavigationController.h"

@interface CreateClassViewController ()<MySwitchDel,
UITextFieldDelegate,
UIPickerViewDelegate,
UIPickerViewDataSource,
UIAlertViewDelegate>
{
    MySwitchView *schoolTypeSwitch;
    MyTextField *classNameTextField;
    MyTextField *nickNameTextField;
    
    UIButton *establishButton;
    NSString *joinYear;
    NSString *establishYear;
    UIButton *joinButton;
    UIButton *classNumberButton;
    NSString *classNumber;
    
    UIView *selectDateView;
    UIPickerView *yearPicker;
    
    NSMutableArray *yearArray;
    
    NSString *dateType;
    NSString *classType;
    NSString *classTypeStr;
    
    UIPickerView *classNumberPickerView;
    NSMutableArray *classNumberArray;
    
    CGFloat pickerViewWidth;
    CGFloat pickerViewHeight;
    
    NSString *className;
    
    BOOL isEditing;
}
@end

@implementation CreateClassViewController
@synthesize schoollID,schoolName,schoolLevel;
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
    self.titleLabel.text = @"创建班级";
    
    dateType = @"";
    establishYear = @"请选择";
    joinYear = @"请选择";
    classNumber = @"请选择";
    className = @"";
    classType = @"1";
    classTypeStr = schoolLevel;
 
    pickerViewWidth = 120;
    pickerViewHeight = 90;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    NSArray *schoolLevelArray = [NSArray arrayWithObjects:@"幼儿园",@"小学",@"中学",@"中专技校",@"培训机构",@"其他", nil];
    
    UILabel *schoolNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+25, SCREEN_WIDTH-40, 35)];
    if ([schoolName rangeOfString:@"（"].length > 0)
    {
        schoolNameLabel.text = [NSString stringWithFormat:@"%@",schoolName];
    }
    else
    {
        schoolNameLabel.text = [NSString stringWithFormat:@"%@（%@）",schoolName,[schoolLevelArray objectAtIndex:[schoolLevel integerValue]]];
    }
    
    schoolNameLabel.numberOfLines = 2;
    schoolNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
//    schoolNameLabel.textColor = TITLE_COLOR;
    schoolNameLabel.backgroundColor = [UIColor clearColor];
    schoolNameLabel.font = [UIFont systemFontOfSize:16];
    [self.bgView addSubview:schoolNameLabel];
    
    schoolTypeSwitch = [[MySwitchView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-50, schoolNameLabel.frame.origin.y+schoolNameLabel.frame.size.height+10, 100, 30)];
    schoolTypeSwitch.mySwitchDel = self;
    if ([schoolLevel intValue] == 2)
    {
        [self.bgView addSubview:schoolTypeSwitch];
    }
    schoolTypeSwitch.selectView.frame = CGRectMake(schoolTypeSwitch.frame.size.width/2, 0, schoolTypeSwitch.frame.size.width/2, schoolTypeSwitch.frame.size.height);
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    leftLabel.text = @"初中";
    leftLabel.font = [UIFont systemFontOfSize:14];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.backgroundColor = LIGHT_BLUE_COLOR;
    leftLabel.textColor = [UIColor whiteColor];
    [schoolTypeSwitch.leftView addSubview:leftLabel];
    
    schoolTypeSwitch.leftView.layer.borderColor = [UIColor whiteColor].CGColor;
    schoolTypeSwitch.rightView.layer.borderColor = [UIColor whiteColor].CGColor;
    schoolTypeSwitch.selectView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 30)];
    rightLabel.text = @"高中";
    rightLabel.textColor = [UIColor whiteColor];
    rightLabel.font = [UIFont systemFontOfSize:14];
    rightLabel.textAlignment = NSTextAlignmentCenter;
    rightLabel.backgroundColor = LIGHT_BLUE_COLOR;
    [schoolTypeSwitch.rightView addSubview:rightLabel];
    
    UILabel *joinLabel = [[UILabel alloc] initWithFrame:CGRectMake(schoolNameLabel.frame.origin.x+5, schoolNameLabel.frame.size.height+schoolNameLabel.frame.origin.y+60, 75, 30)];
    joinLabel.text = @"入学年份";
    joinLabel.backgroundColor = [UIColor clearColor];
    joinLabel.textAlignment = NSTextAlignmentRight;
    joinLabel.textColor = TITLE_COLOR;
    joinLabel.font = [UIFont systemFontOfSize:18];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(joinLabel.frame.origin.x-5, joinLabel.frame.origin.y-5, SCREEN_WIDTH-joinLabel.frame.origin.x*2, 40)];
    [imageView1 setImage:inputImage];
    [self.bgView addSubview:imageView1];
    
    [self.bgView addSubview:joinLabel];
    
    joinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    joinButton.frame = CGRectMake(imageView1.frame.size.width+imageView1.frame.origin.x-80, joinLabel.frame.origin.y, 60, 30);
    joinButton.tag = 1000;
    [joinButton addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
    [joinButton setTitle:@"请选择" forState:UIControlStateNormal];
    [joinButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    joinButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.bgView addSubview:joinButton];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    button1.frame = imageView1.frame;
    button1.tag = 1000;
    button1.backgroundColor = [UIColor clearColor];
    [button1 addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:button1];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(imageView1.frame.origin.x, imageView1.frame.origin.y+42, SCREEN_WIDTH-joinLabel.frame.origin.x*2, 40)];
    [imageView2 setImage:inputImage];
    [self.bgView addSubview:imageView2];
    
    UILabel *establishLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView2.frame.origin.x, imageView2.frame.origin.y+5, 80, 30)];
    establishLabel.text = @"成立年份";
    establishLabel.backgroundColor = [UIColor clearColor];
    establishLabel.textColor = TITLE_COLOR;
    establishLabel.textAlignment = NSTextAlignmentRight;
    establishLabel.font = [UIFont systemFontOfSize:18];
    [self.bgView addSubview:establishLabel];
    
    establishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    establishButton.frame = CGRectMake(imageView2.frame.size.width+imageView2.frame.origin.x-80, establishLabel.frame.origin.y, 60, 30);
    establishButton.tag = 2000;
    [establishButton addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
    [establishButton setTitle:@"请选择" forState:UIControlStateNormal];
    establishButton.backgroundColor = [UIColor clearColor];
    [establishButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    establishButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.bgView addSubview:establishButton];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = imageView2.frame;
    button2.tag = 2000;
    button2.backgroundColor = [UIColor clearColor];
    [button2 addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:button2];
    
    
    UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(imageView2.frame.origin.x, imageView2.frame.origin.y+42, SCREEN_WIDTH-joinLabel.frame.origin.x*2, 40)];
    [imageView3 setImage:inputImage];
    [self.bgView addSubview:imageView3];

    UILabel *classNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView3.frame.origin.x+5, imageView3.frame.origin.y+5, 40, 30)];
    classNumberLabel.text = @"班号";
    classNumberLabel.backgroundColor = [UIColor clearColor];
    classNumberLabel.textAlignment = NSTextAlignmentRight;
    classNumberLabel.font = [UIFont systemFontOfSize:18];
    classNumberLabel.textColor = TITLE_COLOR;
    [self.bgView addSubview:classNumberLabel];
    
    classNumberButton = [UIButton buttonWithType:UIButtonTypeCustom];
    classNumberButton.frame = CGRectMake(imageView3.frame.size.width+imageView3.frame.origin.x-80, imageView3.frame.origin.y+5, 60, 30);
    classNumberButton.tag = 2000;
    [classNumberButton addTarget:self action:@selector(selectClassNumber) forControlEvents:UIControlEventTouchUpInside];
    [classNumberButton setTitle:@"请选择" forState:UIControlStateNormal];
    classNumberButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [classNumberButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [self.bgView addSubview:classNumberButton];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = imageView3.frame;
    button3.tag = 2000;
    button3.backgroundColor = [UIColor clearColor];
    [button3 addTarget:self action:@selector(selectClassNumber) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:button3];
    
    UILabel *classLabel = [[UILabel alloc] initWithFrame:CGRectMake(imageView3.frame.origin.x, classNumberLabel.frame.size.height+classNumberLabel.frame.origin.y+20, 80, 30)];
    classLabel.text = @"班级名称:";
    classLabel.backgroundColor = [UIColor clearColor];
    classLabel.textAlignment = NSTextAlignmentRight;
    classLabel.font = [UIFont systemFontOfSize:18];
    classLabel.textColor = TITLE_COLOR;
    [self.bgView addSubview:classLabel];
    
    classNameTextField = [[MyTextField alloc] initWithFrame:CGRectMake(classLabel.frame.origin.x, classLabel.frame.origin.y+30, 225, 30)];
    classNameTextField.text = @"";
    classNameTextField.returnKeyType = UIReturnKeyDone;
    classNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    classNameTextField.backgroundColor = [UIColor clearColor];
    classNameTextField.textAlignment = NSTextAlignmentLeft;
    classNameTextField.textColor = TITLE_COLOR;
    classNameTextField.delegate = self;
    classNameTextField.background= nil;
    classNameTextField.placeholder = @"班级名称";
    classNameTextField.font = [UIFont systemFontOfSize:18];
    [self.bgView addSubview:classNameTextField];
    
    UIButton *editButton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton1.frame = CGRectMake(classNameTextField.frame.origin.x+classNameTextField.frame.size.width, classNameTextField.frame.origin.y, 30, 30);
    [editButton1 setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    editButton1.backgroundColor = [UIColor clearColor];
    [editButton1 addTarget:self action:@selector(editClassName) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:editButton1];
    
    nickNameTextField = [[MyTextField alloc] initWithFrame:CGRectMake(schoolNameLabel.frame.origin.x, classNameTextField.frame.size.height+classNameTextField.frame.origin.y+15, 225, 30)];
    nickNameTextField.backgroundColor = [UIColor clearColor];
    nickNameTextField.returnKeyType = UIReturnKeyDone;
    nickNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    nickNameTextField.font = [UIFont systemFontOfSize:18];
    nickNameTextField.placeholder = @"请填写班级昵称";
    nickNameTextField.delegate = self;
    nickNameTextField.background = nil;
    nickNameTextField.textColor = TITLE_COLOR;
    nickNameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
//    [self.bgView addSubview:nickNameTextField];
    
    UIButton *editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(nickNameTextField.frame.origin.x+nickNameTextField.frame.size.width, classNameTextField.frame.size.height+classNameTextField.frame.origin.y+15, 30, 30);
    [editButton setImage:[UIImage imageNamed:@"edit"] forState:UIControlStateNormal];
    editButton.backgroundColor = [UIColor clearColor];
    [editButton addTarget:self action:@selector(editNickName) forControlEvents:UIControlEventTouchUpInside];
//    [self.bgView addSubview:editButton];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createButton.backgroundColor = [UIColor greenColor];
    createButton.frame = CGRectMake(40,nickNameTextField.frame.size.height+nickNameTextField.frame.origin.y+25, SCREEN_WIDTH-80, 35);
    [createButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(createClass) forControlEvents:UIControlEventTouchUpInside];
    [createButton setTitle:@"创建" forState:UIControlStateNormal];
    [self.bgView addSubview:createButton];
    
    
    selectDateView = [[UIView alloc] initWithFrame:CGRectMake(CENTER_POINT.x, CENTER_POINT.y, 0, 0)];
    selectDateView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [self.bgView addSubview:selectDateView];
    
    UITapGestureRecognizer *cancelSelectDateTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelectDate)];
    selectDateView.userInteractionEnabled = YES;
    [selectDateView addGestureRecognizer:cancelSelectDateTgr];
    
    yearPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*2, SCREEN_WIDTH, pickerViewHeight)];
    yearPicker.backgroundColor = [UIColor whiteColor];
    yearPicker.delegate = self;
    yearPicker.tag = 1001;
    yearPicker.hidden = YES;
    yearPicker.showsSelectionIndicator = YES;
    [self.bgView addSubview:yearPicker];
    
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
    comp.timeZone = [NSTimeZone defaultTimeZone];
    yearArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=[comp year]-30; i<=[comp year]; ++i)
    {
        [yearArray addObject:[NSString stringWithFormat:@"%d年",i]];
    }
    
    [yearPicker selectRow:[yearArray count]/2+15 inComponent:0 animated:NO];
    
    classNumberArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=1; i<=20; ++i)
    {
        [classNumberArray addObject:[NSString stringWithFormat:@"%d班",i]];
    }
    
    classNumberPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*2, SCREEN_WIDTH, pickerViewHeight)];
    classNumberPickerView.backgroundColor = [UIColor whiteColor];
    classNumberPickerView.delegate = self;
    classNumberPickerView.tag = 1002;
    classNumberPickerView.hidden = YES;
    classNumberPickerView.showsSelectionIndicator = YES;
    [self.bgView addSubview:classNumberPickerView];
    
    [classNumberPickerView selectRow:10 inComponent:0 animated:YES];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}


-(void)selectClassNumber
{
    dateType = @"classNum";
    [UIView animateWithDuration:.2 animations:^{
        classNumberPickerView.hidden = NO;
        selectDateView.frame = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
        classNumberPickerView.frame = CGRectMake((SCREEN_WIDTH-pickerViewWidth)/2, SCREEN_HEIGHT - pickerViewHeight-100, pickerViewWidth, pickerViewHeight);
//        [classNumberPickerView selectRow:[classNumberArray count]/2 inComponent:0 animated:NO];
    }];
}

-(void)selectDate:(UIButton *)button
{
    if (button.tag == 1000)
    {
        dateType = @"join";
    }
    else if (button.tag == 2000)
    {
        dateType = @"establish";
    }
    [UIView animateWithDuration:.2 animations:^{
        selectDateView.frame = CGRectMake(0,0,SCREEN_WIDTH,SCREEN_HEIGHT);
        yearPicker.hidden = NO;
        yearPicker.frame = CGRectMake((SCREEN_WIDTH-pickerViewWidth)/2, SCREEN_HEIGHT - pickerViewHeight-100, pickerViewWidth, pickerViewHeight);
//        [yearPicker selectRow:[yearArray count]/2 inComponent:0 animated:NO];
    }];
}

-(void)cancelSelectDate
{
    [UIView animateWithDuration:0.2 animations:^{
        yearPicker.frame = CGRectMake((SCREEN_WIDTH-pickerViewWidth)/2, SCREEN_HEIGHT, pickerViewWidth, pickerViewHeight);
        classNumberPickerView.hidden = NO;
        classNumberPickerView.frame = CGRectMake((SCREEN_WIDTH-pickerViewWidth)/2, SCREEN_HEIGHT*2, pickerViewWidth, pickerViewHeight);
        if ([dateType isEqualToString:@"join"])
        {
            joinYear = [yearArray objectAtIndex:[yearPicker selectedRowInComponent:0]];
            establishYear = [yearArray objectAtIndex:[yearPicker selectedRowInComponent:0]];
        }
        else if ([dateType isEqualToString:@"establish"])
        {
            establishYear = [yearArray objectAtIndex:[yearPicker selectedRowInComponent:0]];
        }
        else
        {
            classNumber = [classNumberArray objectAtIndex:[classNumberPickerView selectedRowInComponent:0]];
        }
    } completion:^(BOOL finished) {
        yearPicker.hidden = YES;
        classNumberPickerView.hidden = YES;
        selectDateView.frame = CGRectMake(CENTER_POINT.x, CENTER_POINT.y, 0, 0);
        [joinButton setTitle:joinYear forState:UIControlStateNormal];
        [establishButton setTitle:establishYear forState:UIControlStateNormal];
        [classNumberButton setTitle:classNumber forState:UIControlStateNormal];
        if ([classTypeStr length] > 0 && ([classTypeStr isEqualToString:@"初中"] || [classTypeStr isEqualToString:@"高中"]))
        {
            className = [NSString stringWithFormat:@"%@级%@(%@)",[joinYear substringToIndex:4],classNumber,classTypeStr];
        }
        else
        {
            className = [NSString stringWithFormat:@"%@级%@",[joinYear substringToIndex:4],classNumber];
        }
        classNameTextField.text = className;
    }];
}

-(void)createClass
{
    
    if([joinYear isEqualToString:@"请选择"])
    {
        [Tools showAlertView:@"请选择入学年份" delegateViewController:nil];
        return ;
    }
    if ([classNumber isEqualToString:@"请选择"])
    {
        [Tools showAlertView:@"请选择班号" delegateViewController:nil];
        return ;
    }
    
    className = classNameTextField.text;
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"s_id":[schoollID length]>0?schoollID:@"0",
                                                                      @"name":[NSString stringWithFormat:@"%@",className],
                                                                      @"enter_t":[NSString stringWithFormat:@"%d",[joinYear intValue]],
                                                                      @"build_t":[NSString stringWithFormat:@"%d",[establishYear intValue]],
                                                                      @"role":@"teachers",
                                                                      @"code":[NSString stringWithFormat:@"%d",[classNumber intValue]],
                                                                      @"level":schoolLevel} API:CREATECLASS];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"createclass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [BPush setTag:[responseDict objectForKey:@"data"]];
                
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您班级创建成功，快去查看吧！" delegate:self cancelButtonTitle:@"返回我的班级" otherButtonTitles: nil];
                al.delegate = self;
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
    MyClassesViewController *myClassesViewController = [[MyClassesViewController alloc] init];
    KKNavigationController *myClassesNav = [[KKNavigationController alloc] initWithRootViewController:myClassesViewController];
    JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:myClassesNav menuController:sideMenuViewController];
    [self.navigationController presentViewController:sideMenu animated:YES completion:^{
        
    }];
}

#pragma mark - pickerViewDelegate
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag == 1001)
    {
        return [yearArray count];
    }
    else if(pickerView.tag == 1002)
    {
        return [classNumberArray count];
    }
    return 0;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag == 1001)
    {
        return [yearArray objectAtIndex:row];
    }
    else if(pickerView.tag == 1002)
    {
        return [classNumberArray objectAtIndex:row];
    }
    return 0;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag == 1001)
    {
        if ([dateType isEqualToString:@"join"])
        {
            joinYear = [yearArray objectAtIndex:row];
            establishYear = [yearArray objectAtIndex:row];
        }
        else if([dateType isEqualToString:@"establish"])
        {
            establishYear = [yearArray objectAtIndex:row];
        }
    }
    else
    {
        classNumber = [classNumberArray objectAtIndex:row];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)switchStateChanged:(MySwitchView *)mySwitchView
{
    if ([mySwitchView isOpen])
    {
        classType = @"1";
        classTypeStr = @"高中";
    }
    else
    {
        classType = @"2";
        classTypeStr = @"初中";
    }
    className = [NSString stringWithFormat:@"%@级%@(%@)",joinYear,classNumber,classTypeStr];
    classNameTextField.text = className;
}
-(void)editClassName
{
    classNameTextField.enabled = YES;
    [classNameTextField becomeFirstResponder];
}

-(void)editNickName
{
    nickNameTextField.enabled = YES;
    [nickNameTextField becomeFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-200);
    }];
}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CENTER_POINT;
    }completion:^(BOOL finished) {
        
    }];
}
@end
