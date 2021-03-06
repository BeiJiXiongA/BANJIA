//
//  ChooseClassInfoViewController.m
//  School
//
//  Created by TeekerZW on 14-2-20.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ChooseClassInfoViewController.h"
#import "Header.h"
#import "MyClassesViewController.h"
#import "StudentApplyViewController.h"
#import "ParentApplyViewController.h"
#import "TeacherApplyViewController.h"

@interface ChooseClassInfoViewController ()<UIAlertViewDelegate>
{
    UILabel *teacherLabel;
    UITextField *titleTextField;
    UILabel *label;
    NSString *real_name;
}
@end

@implementation ChooseClassInfoViewController
@synthesize schoolName,schoolID,className,classID;
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
    
    self.titleLabel.text = @"申请加入";
    
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(25, UI_NAVIGATION_BAR_HEIGHT+85, SCREEN_WIDTH-50, 80)];
    label.numberOfLines = 3;
    label.textColor = TITLE_COLOR;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:18];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.textAlignment = NSTextAlignmentCenter;
    if(schoolName && [schoolName length] > 0 && ![schoolName isEqualToString:@"未指定学校"])
    {
        label.text = [NSString stringWithFormat:@"%@，您希望加入%@-%@，您的身份是？",[Tools user_name],schoolName,className];
    }
    else
    {
        label.text = [NSString stringWithFormat:@"%@，您希望加入%@，您的身份是？",[Tools user_name],className];
    }
    
    [self.bgView addSubview:label];
    
    UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    
    UIButton *studentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [studentButton setTitle:@"我是老师" forState:UIControlStateNormal];
    studentButton.frame = CGRectMake(39, UI_NAVIGATION_BAR_HEIGHT+170, SCREEN_WIDTH-78, 42);
    [studentButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    studentButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [studentButton addTarget:self action:@selector(applyForJoinClass:) forControlEvents:UIControlEventTouchUpInside];
    studentButton.tag = 3000;
    [self.bgView addSubview:studentButton];
    
    UIButton *parentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [parentButton setTitle:@"我是家长" forState:UIControlStateNormal];
    parentButton.frame = CGRectMake(39, UI_NAVIGATION_BAR_HEIGHT+216, SCREEN_WIDTH-78, 42);
    parentButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [parentButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [parentButton addTarget:self action:@selector(applyForJoinClass:) forControlEvents:UIControlEventTouchUpInside];
    parentButton.tag = 2000;
    [self.bgView addSubview:parentButton];
    
    UIButton *teacherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [teacherButton setTitle:@"我是学生" forState:UIControlStateNormal];
    teacherButton.frame = CGRectMake(39, UI_NAVIGATION_BAR_HEIGHT+262, SCREEN_WIDTH-78, 42);
    [teacherButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    teacherButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [teacherButton addTarget:self action:@selector(applyForJoinClass:) forControlEvents:UIControlEventTouchUpInside];
    teacherButton.tag = 1000;
    [teacherButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.bgView addSubview:teacherButton];
    
//    [self getUserInfo];
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

-(void)applyForJoinClass:(UIButton *)button
{
    if (button.tag == 1000)
    {
        //学生加入
        StudentApplyViewController *studentApply = [[StudentApplyViewController alloc] init];
        studentApply.real_name = real_name;
        [self.navigationController pushViewController:studentApply animated:YES];
    }
    else if(button.tag == 2000)
    {
        //家长加入
        ParentApplyViewController *parentApply = [[ParentApplyViewController alloc] init];
        parentApply.real_name = real_name;
        [self.navigationController pushViewController:parentApply animated:YES];
    }
    
    else if(button.tag == 3000)
    {
        TeacherApplyViewController *teacherApply = [[TeacherApplyViewController alloc] init];
        teacherApply.real_name = real_name;
        [self.navigationController pushViewController:teacherApply animated:YES];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    MyClassesViewController *myClassViewController = [[MyClassesViewController alloc] init];
    [self presentViewController:myClassViewController animated:YES completion:^{
        
    }];
//    [self.navigationController popToViewController:myClassViewController animated:YES];
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
                
                NSString *teacherName = [[[[[responseDict objectForKey:@"data"] objectForKey:@"members"] objectForKey:@"teachers"] firstObject] objectForKey:@"name"];
                teacherLabel.text = teacherName;
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

-(void)getUserInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],@"token":[Tools client_token]} API:MB_GETUSERINFO];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getuserinfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                real_name = [[responseDict objectForKey:@"data"] objectForKey:@"r_name"];
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

@end
