//
//  StudentApplyViewController.m
//  School
//
//  Created by TeekerZW on 14-2-21.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "StudentApplyViewController.h"
#import "Header.h"
#import "MyClassesViewController.h"
#import "SideMenuViewController.h"
#import "JDSideMenu.h"
#import "KKNavigationController.h"
#import "NotificationDetailCell.h"
#import "StudentDetailViewController.h"

#define CELLSTUDENTNUMTAG  10000
#define RestudentNumTag   4000

@interface StudentApplyViewController ()<
UIAlertViewDelegate,
UITextFieldDelegate,
UITableViewDataSource,
UITableViewDelegate>
{
    UILabel *tipLabel;
    
    UILabel *studentNameLabel;
    MyTextField *studentNameField;
    
    UILabel *studentNumLabel;
    MyTextField *studentNumField;
    
    NSString *schoolName;
    NSString *className;
    NSString *classID;
    
    UIView *studentInfoView;
    NSString *studentNum;
    
    UIView *studentsView;
    UILabel *headerLabel;
    NSMutableArray *studentsArray;
    UITableView *studentsTableView;
    
    OperatDB *db;
    UITapGestureRecognizer *tap;
}
@end

@implementation StudentApplyViewController
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
    self.titleLabel.text = @"学生申请加入";
    
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    
    db = [[OperatDB alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    studentNum = @"";
    
    NSString *tipString;
    if(schoolName && [schoolName length] > 0 && ![schoolName isEqualToString:@"未指定学校"])
    {
        tipString = [NSString stringWithFormat:@"你将要申请加入%@-%@，如班主任老师同意您的申请，您将加入该班级。",schoolName,className];
    }
    else
    {
        tipString = [NSString stringWithFormat:@"你将要申请加入%@，如班主任老师同意您的申请，您将加入该班级。",className];
    }
    
    CGSize size = [Tools getSizeWithString:tipString andWidth:SCREEN_WIDTH-40 andFont:[UIFont systemFontOfSize:18]];
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+40, size.width, size.height)];
    tipLabel.text = tipString;
    tipLabel.numberOfLines  = 100;
    tipLabel.font = [UIFont systemFontOfSize:18];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = TITLE_COLOR;
    tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.bgView addSubview:tipLabel];
    
    studentNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, tipLabel.frame.origin.y+tipLabel.frame.size.height+10, 150, 30)];
    studentNameLabel.font = [UIFont systemFontOfSize:16];
    studentNameLabel.text = [NSString stringWithFormat:@"姓名：%@",[Tools user_name]];
    studentNameLabel.backgroundColor = self.bgView.backgroundColor;
    studentNameLabel.textColor = TITLE_COLOR;
    [self.bgView addSubview:studentNameLabel];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent)];
    self.bgView.userInteractionEnabled = YES;
    
    studentInfoView = [[UIView alloc] init];
    studentInfoView.frame = CGRectMake(10, studentNameLabel.frame.size.height+studentNameLabel.frame.origin.y+10, SCREEN_WIDTH-20, 200);
    studentInfoView.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:studentInfoView];
    
    studentNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 50, 30)];
    studentNumLabel.font = [UIFont systemFontOfSize:16];
    studentNumLabel.text = [NSString stringWithFormat:@"学号："];
    studentNumLabel.backgroundColor = self.bgView.backgroundColor;
    studentNumLabel.textColor = TITLE_COLOR;
//    studentNumLabel.textAlignment = NSTextAlignmentCenter;
    [studentInfoView addSubview:studentNumLabel];
    
    studentNumField = [[MyTextField alloc] initWithFrame:CGRectMake(60, studentNumLabel.frame.origin.y-6, SCREEN_WIDTH-80, 42)];
    studentNumField.background = nil;
    studentNumField.tag = 2000;
    studentNumField.keyboardType = UIKeyboardTypeNumberPad;
    studentNumField.placeholder = @"如果有学号，记得写学号哦";
    studentNumField.delegate = self;
    studentNumField.layer.cornerRadius = 5;
    studentNumField.clipsToBounds = YES;
    studentNumField.backgroundColor = [UIColor whiteColor];
    studentNumField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    studentNumField.clearButtonMode = UITextFieldViewModeWhileEditing;
    studentNumField.font = [UIFont systemFontOfSize:16];
    studentNumField.textColor = TITLE_COLOR;
    [studentInfoView addSubview:studentNumField];
    
    UIImage *btnImage  =[Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIButton *studentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [studentButton setTitle:@"提交申请" forState:UIControlStateNormal];
    studentButton.frame = CGRectMake(38, studentNumField.frame.size.height+studentNumField.frame.origin.y+20, SCREEN_WIDTH-76, 40);
    studentButton.layer.cornerRadius = 2;
    studentButton.clipsToBounds = YES;
    [studentButton addTarget:self action:@selector(getStudentsByClassId) forControlEvents:UIControlEventTouchUpInside];
    studentButton.tag = 1000;
    studentButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [studentButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [studentInfoView addSubview:studentButton];
    
    studentsView  = [[UIView alloc] initWithFrame:CGRectMake(10, tipLabel.frame.size.height+tipLabel.frame.origin.y+10, SCREEN_WIDTH-20, SCREEN_HEIGHT-tipLabel.frame.size.height-tipLabel.frame.origin.y-30)];
    studentsView.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:studentsView];
    
//    UITapGestureRecognizer *tagpTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelStudents)];
//    self.bgView.userInteractionEnabled = YES;
//    [self.bgView addGestureRecognizer:tagpTgr];
    
    studentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    studentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, studentsView.frame.size.width, 0) style:UITableViewStylePlain];
    studentsTableView.dataSource = self;
    studentsTableView.delegate = self;
    studentsTableView.backgroundColor = self.bgView.backgroundColor;
    studentsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [studentsView addSubview:studentsTableView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:@"PageOne"];
}

-(void)cancelStudents
{
    [studentsArray removeAllObjects];
    [studentsTableView reloadData];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
}

-(void)tapEvent
{
    [studentNumField resignFirstResponder];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
    }
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

-(void)applyJoinClass:(NSString *)role  andUninID:(NSString *)uninId
{
    
    if ([uninId length] == 0)
    {
        for(NSDictionary *dict in studentsArray)
        {
            if ([studentNum isEqualToString:[dict objectForKey:@"sn"]] &&
                [[Tools user_name] isEqualToString:[dict objectForKey:@"name"]])
            {
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:@"请输入学号加以区分" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                al.alertViewStyle = UIAlertViewStylePlainTextInput;
                ((UITextField *)[al textFieldAtIndex:0]).keyboardType= UIKeyboardTypeNumberPad;
                al.tag = RestudentNumTag;
                [al show];
                return ;
            }
        }
    }
    if ([studentNum length] > 0 &&  ![Tools isStudentsNumber:studentNum])
    {
        [Tools showAlertView:@"学号是由5-12位字母或数字组成" delegateViewController:nil];
        return ;
    }


    if ([Tools NetworkReachable])
    {
        
        
        NSDictionary *paraDict;
        if ([uninId length] > 0)
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"c_id":classID,
                         @"role":role,
                         @"title":@"",
                         @"unin_id":uninId,
                         @"sn":studentNum
                         };
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"c_id":classID,
                         @"role":role,
                         @"title":@"",
                         @"sn":studentNum
                         };
        }
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict
                                                                API:JOINCLASS];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"studentJoinClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您的申请已成功提交，请等待班主任老师审核。" delegate:self cancelButtonTitle:@"返回我的班级" otherButtonTitles: nil];
                al.tag = 1000;
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == RestudentNumTag)
    {
        if (buttonIndex == 1)
        {
            studentNum = [alertView textFieldAtIndex:0].text;
            studentNumField.text = studentNum;
        }
        studentsView.alpha = 0;
        studentInfoView.alpha = 1;
    }
    else
    {
        SideMenuViewController *sideMenuViewController = [[SideMenuViewController alloc] init];
        MyClassesViewController *myClassesViewController = [[MyClassesViewController alloc] init];
        KKNavigationController *myClassesNav = [[KKNavigationController alloc] initWithRootViewController:myClassesViewController];
        JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:myClassesNav menuController:sideMenuViewController];
        [self.navigationController presentViewController:sideMenu animated:YES completion:^{
            
        }];
    }
}

#pragma mark - tableview

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [studentNumField resignFirstResponder];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = self.bgView.backgroundColor;
    headerLabel = [[UILabel alloc] init];
    if (section == 0)
    {
        headerLabel.text = @"您的信息可能已经在班级中从在";
    }
    else
    {
        headerLabel.text = @"上面没有你？请点击这里申请";
    }
    headerLabel.frame = CGRectMake(10, 5, 260, 20);
    headerLabel.textColor = COMMENTCOLOR;
    headerLabel.backgroundColor = self.bgView.backgroundColor;
    [headerView addSubview:headerLabel];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        [UIView animateWithDuration:0.2 animations:^{
            if ([studentsArray count] > 0)
            {
                studentsView.alpha = 1;
                studentInfoView.alpha = 0;
                
                CGFloat height = SCREEN_HEIGHT-tipLabel.frame.size.height-tipLabel.frame.origin.y-30;
                CGFloat tableH = ([studentsArray count]*60+120) > height? height: ([studentsArray count]*60+120);
                studentsTableView.frame = CGRectMake(0, 30, studentsView.frame.size.width, tableH);
            }
            else
            {
                studentsView.alpha = 0;
                studentInfoView.alpha = 1;
                
//                studentsTableView.frame = CGRectMake(0, 30, studentsView.frame.size.width, 0);
            }
        }];
        return [studentsArray count];
    }
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *childider = @"childider";
    NotificationDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:childider];
    if (cell == nil)
    {
        cell = [[NotificationDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:childider];
    }
    
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    UIImageView *lineImageView = [[UIImageView alloc] init];
    lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
    lineImageView.image = [UIImage imageNamed:@"sepretorline"];
    [cell.contentView addSubview:lineImageView];
    
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    cell.nameLabel.frame = CGRectMake(10, 5, 200, 30);
    cell.nameLabel.backgroundColor = [UIColor whiteColor];
    cell.nameLabel.textColor = CONTENTCOLOR;
    cell.nameLabel.font = [UIFont systemFontOfSize:15];
    cell.nameLabel.textAlignment = NSTextAlignmentLeft;
    if (indexPath.section == 0)
    {
        cell.headerImageView.frame = CGRectMake(10, 10, 40, 40);
        
        cell.nameLabel.frame = CGRectMake(60, 5, 200, 30);
        NSDictionary *studentDict = [studentsArray objectAtIndex:indexPath.row];
        
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
        cell.nameLabel.textColor = TITLE_COLOR;
        
        
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
        
        cell.button2.frame = CGRectMake(SCREEN_WIDTH-80, 15, 40, 30);
        [cell.button2 setTitle:@"选择" forState:UIControlStateNormal];
        cell.button2.tag = indexPath.row;
        cell.button2.hidden = NO;
        [cell.button2 setTitleColor:RGB(136, 193, 95, 1) forState:UIControlStateNormal];
        [cell.button2 addTarget:self action:@selector(combine:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    else
    {
        cell.headerImageView.frame = CGRectMake(10, 10, 40, 40);
        
        cell.nameLabel.frame = CGRectMake(60, 5, 200, 30);
        
        [Tools fillImageView:cell.headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERICON];
        
        cell.nameLabel.text = [Tools user_name];
        cell.nameLabel.textColor = TITLE_COLOR;
        
        cell.numLabel.frame = CGRectMake(60, 35, 200, 30);
        if ([studentNumField.text length] > 0)
        {
            cell.nameLabel.text = [NSString stringWithFormat:@"%@(%@)",[Tools user_name],studentNumField.text];
        }
        else
        {
            cell.nameLabel.text = [Tools user_name];
        }
        cell.button2.frame = CGRectMake(studentsView.frame.size.width-90, 15, 90, 30);
        [cell.button2 setTitle:@"申请加入" forState:UIControlStateNormal];
        cell.button2.tag = indexPath.row;
        cell.button2.hidden = NO;
        [cell.button2 setTitleColor:RGB(136, 193, 95, 1) forState:UIControlStateNormal];
        [cell.button2 addTarget:self action:@selector(joinclass) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        NSDictionary *studentDict = [studentsArray objectAtIndex:indexPath.row];
        studentNumField.text = [studentDict objectForKey:@"sn"];
        studentNum = [studentDict objectForKey:@"sn"];
        if ([[studentDict objectForKey:@"role"] isEqualToString:@"unin_students"] || [[studentDict objectForKey:@"role"] isEqualToString:@"students"])
        {
            [self applyJoinClass:[studentDict objectForKey:@"role"] andUninID:[studentDict objectForKey:@"_id"]];
        }
        else
        {
            [self applyJoinClass:[studentDict objectForKey:@"role"] andUninID:@""];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)joinclass
{
    if (studentNumField.text)
    {
        studentNum = studentNumField.text;
    }
    
    [self applyJoinClass:@"students" andUninID:@""];
}

-(void)combine:(UIButton *)button
{
    NSDictionary *dict = [studentsArray objectAtIndex:button.tag];
    studentNumField.text = [dict objectForKey:@"sn"];
    studentNum = [dict objectForKey:@"sn"];
    if ([[dict objectForKey:@"role"] isEqualToString:@"unin_students"] || [[dict objectForKey:@"role"] isEqualToString:@"students"])
    {
        [self applyJoinClass:[dict objectForKey:@"role"] andUninID:[dict objectForKey:@"_id"]];
    }
    else
    {
        [self applyJoinClass:[dict objectForKey:@"role"] andUninID:@""];
    }
}

-(void)viewStudentsDetail:(UIButton *)button
{
    NSDictionary *studentDict = [studentsArray objectAtIndex:button.tag];
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

-(void)getStudentsByClassId
{
    if (studentNumField.text)
    {
         studentNum = studentNumField.text;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"name":[Tools user_name]
                                                                      } API:GETCHILDBYNAME];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getStudentByClassId responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                    [studentsArray removeAllObjects];
                    NSArray *tmpArray = [responseDict objectForKey:@"data"];
                    for(NSDictionary *dict in tmpArray)
                    {
                        if ([[dict objectForKey:@"name"]isEqualToString:[Tools user_name]] &&
                              [[dict objectForKey:@"sn"] isEqualToString:studentNum] &&
                            [[dict objectForKey:@"role"] isEqualToString:@"students"])
                        {
                            [Tools showAlertView:@"班级中已存在同名同学号学生，请输入学号加以区分" delegateViewController:nil];
                            return ;
                        }
                        else if([[dict objectForKey:@"role"]isEqualToString:@"unin_students"])
                        {
                            [studentsArray addObject:dict];
                        }
                    }
                    if ([studentsArray count] > 0)
                    {
                        [studentsTableView reloadData];
                    }
                    else
                    {
                        [self applyJoinClass:@"students" andUninID:@""];
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

- (void)keyBoardWillHide:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        self.bgView.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
        [self.bgView removeGestureRecognizer:tap];
    }completion:^(BOOL finished) {
        
    }];
}

-(void)keyBoardWillShow:(NSNotification *)aNotification
{
    [self.bgView addGestureRecognizer:tap];
}

@end
//studentNameField = [[MyTextField alloc] initWithFrame:CGRectMake(60, studentNameLabel.frame.origin.y-6, SCREEN_WIDTH-80, 42)];
//studentNameField.background = nil;
//studentNameField.tag = 2000;
//studentNameField.placeholder = @"";
//studentNameField.text = [Tools user_name];
//studentNameField.delegate = self;
//studentNameField.layer.cornerRadius = 5;
//studentNameField.clipsToBounds = YES;
//studentNameField.backgroundColor = [UIColor whiteColor];
//studentNameField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//studentNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
//studentNameField.font = [UIFont systemFontOfSize:17];
//studentNameField.textColor = TITLE_COLOR;
//[self.bgView addSubview:studentNameField];
