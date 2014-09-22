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

#import "ClassCell.h"

#define SCHOOLTYPE  @"schoolType"
#define JOINYEAR    @"joinyear"
#define NIANJI      @"nianji"

#define CreateClassTableViewTag  3000
#define TmpTableViewTag    4000

@interface CreateClassViewController ()<MySwitchDel,
UITextFieldDelegate,
UIPickerViewDelegate,
UIPickerViewDataSource,
UIAlertViewDelegate,
UITableViewDataSource,
UITableViewDelegate>
{
    MyTextField *classNameTextField;
    MyTextField *nickNameTextField;
    
    UIView *selectView;
    UIPickerView *pickerView;
    
    NSMutableArray *yearArray;
    
    CGFloat pickerViewWidth;
    CGFloat pickerViewHeight;
    
    NSArray *xiaoxue;
    NSArray *chuzhong;
    NSArray *gaozhong;
    NSArray *cellNameArray;
    
    UITableView *createTableView;
    NSArray *schoolLevelArray;
    
    NSString *selectType;
    NSString *joinYear;
    NSString *schoolType;
    NSString *className;
    NSString *nianji;
    
    BOOL isEditing;
    BOOL isSelect;
    
    NSArray *dataSourceArray;
    UITapGestureRecognizer *cancelSelectTgr;
    
    UITableView *tmpTableView;
    
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
    
    joinYear = @"请选择";
    className = @"";
    schoolType = @"2";
    isSelect = NO;
 
    pickerViewWidth = 120;
    pickerViewHeight = 150;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    schoolLevelArray = [NSArray arrayWithObjects:@"小学",@"中学",@"夏令营",@"社团",@"职业学校",@"幼儿园",@"其他", nil];

    cellNameArray = @[@"学校类型",@"入学时间"];
    
    createTableView = [[UITableView alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+40, SCREEN_WIDTH-40, 100) style:UITableViewStylePlain];
    createTableView.delegate = self;
    createTableView.dataSource = self;
    createTableView.scrollEnabled = NO;
    createTableView.tag = CreateClassTableViewTag;
    createTableView.backgroundColor = self.bgView.backgroundColor;
    createTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:createTableView];
    
    tmpTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStylePlain];
    tmpTableView.delegate = self;
    tmpTableView.dataSource = self;
    tmpTableView.tag = TmpTableViewTag;
    tmpTableView.backgroundColor = [UIColor whiteColor];
    tmpTableView.layer.cornerRadius = 8;
    tmpTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    UILabel *classLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, createTableView.frame.size.height+createTableView.frame.origin.y+10, SCREEN_WIDTH-40, 42.5)];
    classLabel.text = @"  班级名称";
    classLabel.backgroundColor = [UIColor whiteColor];
    classLabel.layer.cornerRadius = 5;
    classLabel.clipsToBounds = YES;
    classLabel.font = [UIFont systemFontOfSize:18];
    classLabel.textColor = TITLE_COLOR;
    [self.bgView addSubview:classLabel];
    
    classNameTextField = [[MyTextField alloc] initWithFrame:CGRectMake(103, classLabel.frame.origin.y+6.2, SCREEN_WIDTH-127, 30)];
    classNameTextField.text = @"";
    classNameTextField.returnKeyType = UIReturnKeyDone;
    classNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    classNameTextField.backgroundColor = [UIColor whiteColor];
    classNameTextField.textAlignment = NSTextAlignmentRight;
    classNameTextField.textColor = TITLE_COLOR;
    classNameTextField.delegate = self;
    classNameTextField.background= nil;
    classNameTextField.placeholder = @"班级名称";
    classNameTextField.font = [UIFont systemFontOfSize:18];
    [self.bgView addSubview:classNameTextField];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    UIButton *createButton = [UIButton buttonWithType:UIButtonTypeCustom];
    createButton.backgroundColor = self.bgView.backgroundColor;
    createButton.frame = CGRectMake(40,classNameTextField.frame.size.height+classNameTextField.frame.origin.y+35, SCREEN_WIDTH-80, 40);
    [createButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [createButton addTarget:self action:@selector(createClass) forControlEvents:UIControlEventTouchUpInside];
    [createButton setTitle:@"确定" forState:UIControlStateNormal];
    [self.bgView addSubview:createButton];
    
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [addButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [addButton setTitle:@"创建" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(createClass) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:addButton];

    
    NSDateComponents *comp = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:[NSDate date]];
    comp.timeZone = [NSTimeZone defaultTimeZone];
    yearArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=[comp year]; i >= [comp year]-15; --i)
    {
        [yearArray addObject:[NSString stringWithFormat:@"%d年",i]];
    }
    
    selectView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*2, SCREEN_WIDTH, pickerViewHeight+40)];
    selectView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:1];
    [self.bgView addSubview:selectView];
    
    cancelSelectTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSelect)];
    selectView.userInteractionEnabled = YES;
    [selectView addGestureRecognizer:cancelSelectTgr];
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, pickerViewHeight)];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.delegate = self;
    pickerView.tag = 1001;
    pickerView.showsSelectionIndicator = YES;
    [selectView addSubview:pickerView];
    
    UIButton *selectDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectDoneButton setTitle:@"完成" forState:UIControlStateNormal];
    selectDoneButton.showsTouchWhenHighlighted = YES;
    [selectDoneButton addTarget:self action:@selector(cancelSelect) forControlEvents:UIControlEventTouchUpInside];
//    [selectDoneButton setTitleColor:NAMECOLOR forState:UIControlStateNormal];
    selectDoneButton.frame = CGRectMake(SCREEN_WIDTH-70, 0, 60, 40);
    [selectView addSubview:selectDoneButton];
    
    [self.bgView addSubview:tmpTableView];
    
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

#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == CreateClassTableViewTag)
    {
        return [cellNameArray count];
    }
    return [dataSourceArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == CreateClassTableViewTag)
    {
        if (indexPath.row == 0 || indexPath.row == 1)
        {
            return 50;
        }
        else if([schoolType isEqualToString:@"0"] ||
                [schoolType isEqualToString:@"1"] ||
                [schoolType isEqualToString:@"2"])
        {
            return 50;
        }

    }
    else
    {
        return 40;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == CreateClassTableViewTag)
    {
        static NSString *iderstr = @"buttoncell";
        ClassCell *cell  = [tableView dequeueReusableCellWithIdentifier:iderstr];
        if (cell == nil)
        {
            cell = [[ClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iderstr];
        }
        cell.nameLabel.frame = CGRectMake(10, 11, 100, 20);
        cell.nameLabel.text = [cellNameArray objectAtIndex:indexPath.row];
        cell.contentLable.frame = CGRectMake(SCREEN_WIDTH-255, 11, 170, 20);
        cell.contentLable.font = cell.nameLabel.font;
        cell.contentLable.textAlignment = NSTextAlignmentRight;
        
        cell.arrowImageView.frame = CGRectMake(SCREEN_WIDTH-75, 16, 18, 10);
        [cell.arrowImageView setImage:[UIImage imageNamed:@"arrow_down"]];
        
        
        if (indexPath.row == 0)
        {
            cell.contentLable.text = [schoolLevelArray objectAtIndex:[schoolType integerValue]-1];
        }
        else if(indexPath.row == 1)
        {
            cell.contentLable.text = joinYear;
        }
        else if (indexPath.row == 2)
        {
            if ([schoolType isEqualToString:@"1"] || [schoolType isEqualToString:@"2"])
            {
                cell.contentLable.text = nianji;
            }
            else
            {
                cell.contentLable.text = @"";
            }
        }
        
        cell.bgView.frame = CGRectMake(0, 7.5, SCREEN_WIDTH-40, 42.5);
        cell.bgView.backgroundColor = [UIColor whiteColor];
        cell.bgView.layer.cornerRadius = 5;
        cell.bgView.clipsToBounds = YES;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = self.bgView.backgroundColor;
        return cell;
    }
    else
    {
        static NSString *iderstr = @"tmpbuttoncell";
        ClassCell *cell  = [tableView dequeueReusableCellWithIdentifier:iderstr];
        if (cell == nil)
        {
            cell = [[ClassCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iderstr];
        }
        cell.nameLabel.frame = CGRectMake(10, 10, 100, 20);
        cell.nameLabel.text = [dataSourceArray objectAtIndex:indexPath.row];
        
        cell.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH-40, 40);
        cell.bgView.backgroundColor = [UIColor whiteColor];
        
        
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = self.bgView.backgroundColor;
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.tag == CreateClassTableViewTag)
    {
        if (indexPath.row == 0)
        {
            selectType = SCHOOLTYPE;
            dataSourceArray = schoolLevelArray;
        }
        else if(indexPath.row == 1)
        {
            selectType = JOINYEAR;
            dataSourceArray = yearArray;
        }
        else if (indexPath.row == 2)
        {
            selectType = NIANJI;
            if ([schoolType isEqualToString:@"1"])
            {
                dataSourceArray = xiaoxue;
            }
            else if([schoolType isEqualToString:@"2"])
            {
                dataSourceArray = chuzhong;
            }
            else
                dataSourceArray = nil;
        }
        [tmpTableView reloadData];
        
        if (!isSelect)
        {
            CGFloat height = [dataSourceArray count]*40>280?280:([dataSourceArray count]*40);
            tmpTableView.frame = CGRectMake(20, createTableView.frame.origin.y+(indexPath.row+1)*50+5, SCREEN_WIDTH-40, 0);
            [UIView animateWithDuration:0.2 animations:^{
                tmpTableView.frame = CGRectMake(20, createTableView.frame.origin.y+(indexPath.row+1)*50+5, SCREEN_WIDTH-40, height);
            }];
        }
        else
        {
            tmpTableView.frame = CGRectMake(0, 0, 0, 0);
        }
        isSelect = !isSelect;
    }
    else
    {
        if([selectType isEqualToString:SCHOOLTYPE])
        {
            schoolType = [NSString stringWithFormat:@"%d",indexPath.row+1];
        }
        else if([selectType isEqualToString:JOINYEAR])
        {
            joinYear = [yearArray objectAtIndex:indexPath.row];
        }
        [createTableView reloadData];
        isSelect = NO;
        [UIView animateWithDuration:0.2 animations:^{
            tmpTableView.frame = CGRectMake(20, tmpTableView.frame.origin.y, SCREEN_WIDTH-40, 0);
        }];
    }
}

-(void)showSelectView
{
    if (!dataSourceArray)
    {
        return ;
    }
    [self.bgView addGestureRecognizer:cancelSelectTgr];
    [UIView animateWithDuration:.2 animations:^{
        selectView.frame = CGRectMake(0,SCREEN_HEIGHT - pickerViewHeight-40,SCREEN_WIDTH,pickerViewHeight+40);
        selectView.alpha = 1;
        if ([selectType isEqualToString:SCHOOLTYPE])
        {
            [pickerView selectRow:[schoolType integerValue] inComponent:0 animated:YES];
        }
        else if([selectType isEqualToString:JOINYEAR])
        {
            [pickerView selectRow:[joinYear integerValue] inComponent:0 animated:YES];
        }
        else if([selectType isEqualToString:NIANJI])
        {
            
        }
//        [classNumberPickerView selectRow:[classNumberArray count]/2 inComponent:0 animated:NO];
    }];
}

-(void)cancelSelect
{
    [self.bgView removeGestureRecognizer:cancelSelectTgr];
    [UIView animateWithDuration:.2 animations:^{
        selectView.frame = CGRectMake(0,SCREEN_HEIGHT*2,SCREEN_WIDTH,pickerViewHeight+40);
        selectView.alpha = 0;
        //        [classNumberPickerView selectRow:[classNumberArray count]/2 inComponent:0 animated:NO];
    }];
}

-(void)createClass
{
    
    if([joinYear isEqualToString:@"请选择"])
    {
        [Tools showAlertView:@"请选择入学时间" delegateViewController:nil];
        return ;
    }
    
    className = classNameTextField.text;
    if ([className length] <4 || [className length] > 20)
    {
        [Tools showAlertView:@"学校名称应该在4~20个字符之间" delegateViewController:nil];
        return ;
    }
    if(!schoollID)
    {
        schoollID = @"";
    }
    NSDictionary *paraDict= @{@"u_id":[Tools user_id],
                     @"token":[Tools client_token],
                     @"s_level":schoolType,
                     @"name":className,
                     @"enter_t":[NSString stringWithFormat:@"%d",[joinYear integerValue]],
                     @"s_id":schoollID};
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict API:NEWCEATECLASS];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"createclass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
//                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您班级创建成功，快去查看吧！" delegate:self cancelButtonTitle:@"返回我的班级" otherButtonTitles: nil];
//                al.delegate = self;
//                [al show];
                
                SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
                MyClassesViewController *myClassesViewController = [[MyClassesViewController alloc] init];
                KKNavigationController *myClassesNav = [[KKNavigationController alloc] initWithRootViewController:myClassesViewController];
                JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:myClassesNav menuController:sideMenuViewController];
                [self.navigationController presentViewController:sideMenu animated:YES completion:^{
                    
                }];
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
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000)
    {
        SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
        MyClassesViewController *myClassesViewController = [[MyClassesViewController alloc] init];
        KKNavigationController *myClassesNav = [[KKNavigationController alloc] initWithRootViewController:myClassesViewController];
        JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:myClassesNav menuController:sideMenuViewController];
        [self.navigationController presentViewController:sideMenu animated:YES completion:^{
            
        }];
    }
}

//#pragma mark - pickerViewDelegate
//-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
//{
//    return 1;
//}
//-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
//{
//    return [dataSourceArray count];
//}
//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
//{
//    return [dataSourceArray objectAtIndex:row];
//}
//
//-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
//{
//    if ([selectType isEqualToString:SCHOOLTYPE])
//    {
//        schoolType = [NSString stringWithFormat:@"%d",row];
//       
//    }
//    else if ([selectType isEqualToString:JOINYEAR])
//    {
//        joinYear = [yearArray objectAtIndex:row];
//    }
//    else if ([selectType isEqualToString:NIANJI])
//    {
//        if ([schoolType isEqualToString:@"1"])
//        {
//            nianji = [dataSourceArray objectAtIndex:row];
//        }
//        else if([schoolType isEqualToString:@"2"])
//        {
//            nianji = [dataSourceArray objectAtIndex:row];
//        }
//        else
//        {
//            nianji = @"";
//        }
//        
//        if ([nianji length] == 0)
//        {
//            nianji = [schoolLevelArray objectAtIndex:[schoolType integerValue]];
//        }
//        classNameTextField.text = nianji;
//    }
//    [createTableView reloadData];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        self.bgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2-70);
    }];
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
    }

}

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CENTER_POINT;
    }completion:^(BOOL finished) {
        
    }];
}
@end
