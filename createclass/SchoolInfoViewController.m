//
//  SchoolInfoViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-7-2.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "SchoolInfoViewController.h"

@interface SchoolInfoViewController ()
{
    NSString *classID;
}
@end

@implementation SchoolInfoViewController
@synthesize schoolid,schoolName;
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
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    NSString *className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, UI_NAVIGATION_BAR_HEIGHT+40, SCREEN_WIDTH-80, 200)];
    tipLabel.backgroundColor = self.bgView.backgroundColor;
    tipLabel.textColor = COMMENTCOLOR;
    tipLabel.numberOfLines = 5;
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tipLabel.text = [NSString stringWithFormat:@"您确定把班级(%@)绑定到(%@)吗？",className,schoolName];
    [self.bgView addSubview:tipLabel];
    
    UIButton *bindButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bindButton.frame = CGRectMake(50, tipLabel.frame.size.height+tipLabel.frame.origin.y, SCREEN_WIDTH-100, 40);
    [bindButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [bindButton setTitle:@"绑定" forState:UIControlStateNormal];
    [bindButton addTarget:self action:@selector(bindSchool) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:bindButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)bindSchool
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"s_id":schoolid
                                                                      } API:BINDSCHOOL];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"bindschool responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"成功绑定学校" toView:self.bgView];
                [[NSNotificationCenter defaultCenter] postNotificationName:CHANGECLASSINFO object:nil];
                [self.navigationController popToRootViewControllerAnimated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
