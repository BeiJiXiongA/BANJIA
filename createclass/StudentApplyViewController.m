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

@interface StudentApplyViewController ()<UIAlertViewDelegate>
{
    UILabel *tipLabel;
}
@end

@implementation StudentApplyViewController
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
    self.titleLabel.text = @"学生申请加入";
    
    tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+110, SCREEN_WIDTH-20, 60)];
    tipLabel.numberOfLines = 3;
    tipLabel.font = [UIFont systemFontOfSize:18];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textColor = TITLE_COLOR;
    tipLabel.text = [NSString stringWithFormat:@"%@,你将要申请加入%@-%@，如班主任老师同意您的申请，您将加入该班级。",real_name,schoolName,className];
    tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:tipLabel];
    
    UIImage *btnImage  =[Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
    UIButton *studentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [studentButton setTitle:@"提交申请" forState:UIControlStateNormal];
    studentButton.frame = CGRectMake(38, SCREEN_HEIGHT-260, SCREEN_WIDTH-76, 40);
    studentButton.layer.cornerRadius = 2;
    studentButton.clipsToBounds = YES;
    [studentButton addTarget:self action:@selector(applyJoinClass) forControlEvents:UIControlEventTouchUpInside];
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
    JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:myClassesViewController menuController:sideMenuViewController];
    [self presentViewController:sideMenu animated:YES completion:^{
        
    }];
}

@end
