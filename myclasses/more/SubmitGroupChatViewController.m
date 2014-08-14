//
//  SubmitGroupChatViewController.m
//  BANJIA
//
//  Created by TeekerZW on 7/22/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "SubmitGroupChatViewController.h"

@interface SubmitGroupChatViewController ()<UITextFieldDelegate>
{
    MyTextField *nameTextField;
    NSMutableString *nameStr;
}
@end
@implementation SubmitGroupChatViewController

@synthesize selectArray;

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
    // Do any additional setup after loading the view from its nib.
    
    self.titleLabel.text = @"创建群聊";
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"完成" forState:UIControlStateNormal];
    [inviteButton setBackgroundColor:[UIColor clearColor]];
    [inviteButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [inviteButton addTarget:self action:@selector(createClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:inviteButton];
    
    CGFloat left = 30;
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, UI_NAVIGATION_BAR_HEIGHT+30, SCREEN_WIDTH-left*2, 20)];
    tipLabel.font = [UIFont systemFontOfSize:18];
    tipLabel.textColor = TITLE_COLOR;
    tipLabel.text = @"你可以给这次群聊起个名字";
    [self.bgView addSubview:tipLabel];
    
    nameStr = [[NSMutableString alloc] initWithCapacity:0];
    for (int i=0 ; i< [selectArray count] ;i++)
    {
        NSDictionary *dict = [selectArray objectAtIndex:i];
        [nameStr insertString:[dict objectForKey:@"name"] atIndex:[nameStr length]];
        [nameStr insertString:@"、" atIndex:[nameStr length]];
        if (i == 2)
        {
            break;
        }
    }
    
    nameTextField = [[MyTextField alloc] initWithFrame:CGRectMake(left, UI_NAVIGATION_BAR_HEIGHT+60, SCREEN_WIDTH-left*2, 42)];
    nameTextField.layer.cornerRadius = 5;
    nameTextField.clipsToBounds = YES;
    nameTextField.background = nil;
    nameTextField.delegate = self;
    nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    nameTextField.placeholder = @"群聊名称";
    if ([selectArray count] > 3)
    {
        nameTextField.text = [NSString stringWithFormat:@"%@等(%d人)",[nameStr substringToIndex:[nameStr length]-1],[selectArray count]+1];
    }
    else
    {
        nameTextField.text = [nameStr substringToIndex:[nameStr length]-1];
    }
    nameTextField.backgroundColor = [UIColor whiteColor];
    [self.bgView addSubview:nameTextField];
    
    UILabel *tipLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(left, UI_NAVIGATION_BAR_HEIGHT+110, SCREEN_WIDTH-left*2, 20)];
    tipLabel2.font = [UIFont systemFontOfSize:18];
    tipLabel2.textColor = TITLE_COLOR;
    tipLabel2.text = [NSString stringWithFormat:@"您邀请了%d名班级成员",[selectArray count]];
    [self.bgView addSubview:tipLabel2];
    
    UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    submitButton.frame = CGRectMake(left, UI_NAVIGATION_BAR_HEIGHT+140, SCREEN_WIDTH-left*2, 40);
    [submitButton setTitle:@"完成" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(createClick) forControlEvents:UIControlEventTouchUpInside];
    [submitButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:NAVBTNBG] andInsets:UIEdgeInsetsMake(5, 5, 5, 5)] forState:UIControlStateNormal];
    [self.bgView addSubview:submitButton];
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

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

-(void)createClick
{
    if ([nameTextField.text length] == 0)
    {
        [Tools showAlertView:@"请输入群聊名字" delegateViewController:nil];
        return ;
    }
    
    NSString *textFieldStr = nameTextField.text;
    NSString *countStr = [NSString stringWithFormat:@"(%d人)",[selectArray count]+1];
    NSRange range = [textFieldStr rangeOfString:countStr];
    
    if (range.length == 0)
    {
        textFieldStr = [NSString stringWithFormat:@"%@%@",nameTextField.text,countStr];
    }
    NSMutableString *userIds = [[NSMutableString alloc] initWithCapacity:0];
    for (int i=0 ; i< [selectArray count] ;i++)
    {
        NSDictionary *dict = [selectArray objectAtIndex:i];
        [userIds insertString:[dict objectForKey:@"uid"] atIndex:[userIds length]];
        [userIds insertString:@"," atIndex:[userIds length]];
    }
    
    
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"users":[userIds substringToIndex:[userIds length]-1],
                                                                      @"name":textFieldStr,
                                                                      @"c_id":[[NSUserDefaults standardUserDefaults] objectForKey:@"classid"]
                                                                      } API:CREATEGROUPCHAT];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"create group chat responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:UPDATEGROUPCHATLIST object:nil];
                [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
            
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

@end
