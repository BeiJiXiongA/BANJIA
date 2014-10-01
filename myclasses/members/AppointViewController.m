//
//  AppointViewController.m
//  School
//
//  Created by TeekerZW on 14-2-20.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "AppointViewController.h"
#import "Header.h"
#import "OtherAppointViewController.h"
#import "ClassMemberViewController.h"


@interface AppointViewController ()<UIAlertViewDelegate>
{
    NSArray *jobArray;
}
@end

@implementation AppointViewController
@synthesize otherUserID,classID,otherUserName,titleStr;
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
    self.titleLabel.text = @"任命班干部";
    
    DDLOG(@"name name %@",otherUserName);
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, SCREEN_WIDTH-40, 30)];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = [NSString stringWithFormat:@"%@已被任命为%@，%@",@"王一",@"班长",@"学习委员"];
    label1.font = [UIFont systemFontOfSize:14];
    [self.bgView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(20, label1.frame.origin.y+label1.frame.size.height+20, SCREEN_WIDTH-40, 30)];
    label2.backgroundColor = [UIColor clearColor];
    label2.font = [UIFont systemFontOfSize:14];
    label2.text = [NSString stringWithFormat:@"继续任命%@为",@"王一"];
    [self.bgView addSubview:label2];
    
    jobArray = [NSArray arrayWithObjects:@"副班长",@"文体委员",@"生活委员",@"其他", nil];
    for (int i=0; i<[jobArray count]; ++i)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(30, label2.frame.size.height+label2.frame.origin.y+10+50*i, SCREEN_WIDTH-60, 30);
        [button setTitle:[jobArray objectAtIndex:i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button.tag = 1000+i;
        [button addTarget:self action:@selector(appointButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgView addSubview:button];
    }
    
    UILabel *notificateMemLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, label2.frame.size.height+label2.frame.origin.y+30+50*([jobArray count]-1)+30, 90, 30)];
    notificateMemLabel.backgroundColor = [UIColor clearColor];
    notificateMemLabel.text = [NSString stringWithFormat:@"通知班级成员"];
    notificateMemLabel.font = [UIFont systemFontOfSize:14];
    [self.bgView addSubview:notificateMemLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)appointButtonClick:(UIButton *)button
{
    DDLOG(@"%@",[jobArray objectAtIndex:button.tag%1000]);
    if (button.tag%1000 == 3)
    {
        OtherAppointViewController *otherAppoint = [[OtherAppointViewController alloc] init];
        
        [otherAppoint showSelfViewController:self];
    }
    else
    {
        NSString *msg = [NSString stringWithFormat:@"您确定要任命%@为%@吗？",otherUserName,[jobArray objectAtIndex:button.tag%1000]];
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"任命", nil];
        al.tag = button.tag;
        [al show];
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self appointJod:[jobArray objectAtIndex:alertView.tag%1000]];
    }
}

-(void)appointJod:(NSString *)jobTitle
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"m_id":otherUserID,
                                                                      @"c_id":classID,
                                                                      @"title":jobTitle
                                                                      } API:CHANGE_MEM_TITLE];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [self unShowSelfViewController];
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
        [request startAsynchronous];
    }

}

@end
