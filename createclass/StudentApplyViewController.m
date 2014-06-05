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

@interface StudentApplyViewController ()<UIAlertViewDelegate>
{
    UILabel *tipLabel;
    MyTextField *nameTextField;
    
    NSString *schoolName;
    NSString *className;
    NSString *classID;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.titleLabel.text = @"学生申请加入";
    
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    
//    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
//    nameTextField = [[MyTextField alloc] initWithFrame:CGRectMake(27.5, UI_NAVIGATION_BAR_HEIGHT+75, SCREEN_WIDTH-55, 35)];
//    nameTextField.backgroundColor = [UIColor clearColor];
//    nameTextField.tag = 1000;
//    nameTextField.background = inputImage;
//    nameTextField.placeholder = @"请确认您的姓名";
//    nameTextField.text = [Tools user_name];
//    nameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    nameTextField.keyboardType = UIKeyboardAppearanceDefault;
//    nameTextField.textColor = TITLE_COLOR;
//    nameTextField.returnKeyType = UIReturnKeyDone;
//    nameTextField.font = [UIFont systemFontOfSize:14];
//    [self.bgView addSubview:nameTextField];
    
    NSString *tipString = [NSString stringWithFormat:@"%@,你将要申请加入%@-%@，如班主任老师同意您的申请，您将加入该班级。",[Tools user_name],schoolName,className];
    CGSize size = [Tools getSizeWithString:tipString andWidth:SCREEN_WIDTH-20 andFont:[UIFont systemFontOfSize:18]];
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+110, size.width, size.height)];
    tipLabel.text = tipString;
    tipLabel.numberOfLines  = 100;
    tipLabel.font = [UIFont systemFontOfSize:18];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = TITLE_COLOR;
    tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:tipLabel];
    
    UIImage *btnImage  =[Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIButton *studentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [studentButton setTitle:@"提交申请" forState:UIControlStateNormal];
    studentButton.frame = CGRectMake(38, tipLabel.frame.size.height+tipLabel.frame.origin.y+20, SCREEN_WIDTH-76, 40);
    studentButton.layer.cornerRadius = 2;
    studentButton.clipsToBounds = YES;
    [studentButton addTarget:self action:@selector(applyJoinClass) forControlEvents:UIControlEventTouchUpInside];
    studentButton.tag = 1000;
    studentButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [studentButton setBackgroundImage:btnImage forState:UIControlStateNormal];
    [self.bgView addSubview:studentButton];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)applyJoinClass
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"role":@"students",
                                                                      @"title":@""
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
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

@end
