//
//  SetClassInfoViewController.m
//  BANJIA
//
//  Created by TeekerZW on 5/12/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "SetClassInfoViewController.h"

@interface SetClassInfoViewController ()<UITextFieldDelegate,UITextViewDelegate>
{
    MyTextField *nameTextField;
    UITextView *placeHolderTextView;
    UITextView *infoTextView;
    
    UILabel *countLabel;
}
@end

@implementation SetClassInfoViewController
@synthesize infoKey,infoStr,classID,setClassInfoDel;
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
    
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"保存" forState:UIControlStateNormal];
    [inviteButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [inviteButton addTarget:self action:@selector(setClassInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:inviteButton];

    
    if ([infoKey isEqualToString:@"name"])
    {
        self.titleLabel.text = @"设置班级名称";
        
        nameTextField = [[MyTextField alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+10, SCREEN_WIDTH - 20, 45)];
        nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        nameTextField.textColor = TITLE_COLOR;
        nameTextField.background = nil;
        nameTextField.layer.cornerRadius = 5;
        nameTextField.backgroundColor = [UIColor whiteColor];
        nameTextField.font = [UIFont systemFontOfSize:16];
        nameTextField.text = infoStr;
        [self.bgView addSubview:nameTextField];
    }
    else if([infoKey isEqualToString:@"info"])
    {
        
        UIImageView *inputBg = [[UIImageView alloc] init];
        inputBg.frame = CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+10, SCREEN_WIDTH - 20, 210);
        [inputBg setImage:[Tools getImageFromImage:[UIImage imageNamed:@""] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)]];
        inputBg.backgroundColor = [UIColor whiteColor];
        inputBg.layer.cornerRadius = 5;
        [self.bgView addSubview:inputBg];
        
        placeHolderTextView = [[UITextView alloc] init];
        placeHolderTextView.frame = CGRectMake(15, UI_NAVIGATION_BAR_HEIGHT+15, SCREEN_WIDTH-30, 30);
        if ([infoStr length] > 0)
        {
            placeHolderTextView.text = @"";
        }
        else
        {
            placeHolderTextView.text = @"填写班级介绍";
        }
        placeHolderTextView.editable = NO;
        placeHolderTextView.tag = 1000;
        placeHolderTextView.delegate = self;
        placeHolderTextView.font = [UIFont systemFontOfSize:16];
        placeHolderTextView.backgroundColor = [UIColor clearColor];
        placeHolderTextView.textColor = COMMENTCOLOR;
        [self.bgView addSubview:placeHolderTextView];
        
        self.titleLabel.text = @"设置班级介绍";
        infoTextView = [[UITextView alloc] initWithFrame:CGRectMake(15, UI_NAVIGATION_BAR_HEIGHT+15, SCREEN_WIDTH - 30, 200)];
        infoTextView.textColor = COMMENTCOLOR;
        infoTextView.font = [UIFont systemFontOfSize:16];
        infoTextView.text = infoStr;
        infoTextView.tag = 2000;
        
        infoTextView.delegate = self;
        infoTextView.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:infoTextView];
        
        countLabel = [[UILabel alloc] initWithFrame:CGRectMake(infoTextView.frame.size.width+infoTextView.frame.origin.x-50, infoTextView.frame.size.height+infoTextView.frame.origin.y-15, 70, 20)];
        countLabel.backgroundColor = [UIColor clearColor];
//        countLabel.font = [UIFont systemFontOfSize:12];
        countLabel.font = [UIFont fontWithName:@"Futura" size:14];
        countLabel.textColor = COMMENTCOLOR;
        countLabel.text = [NSString stringWithFormat:@"%d/50",[infoStr length]];
        [self.bgView addSubview:countLabel];
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

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.tag == 2000)
    {
        if ([textView.text length] > 0)
        {
            placeHolderTextView.text = @"";
        }
        else
        {
            placeHolderTextView.text = @"填写班级介绍";
        }
        countLabel.text = [NSString stringWithFormat:@"%d/50",[infoTextView.text length]];
        if ([textView.text length] > 50)
        {
            countLabel.textColor = [UIColor redColor];
        }
        else
        {
            countLabel.textColor = COMMENTCOLOR;
        }
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
    }
}

-(void)setClassInfo
{
    if ([Tools NetworkReachable])
    {
        if ([infoKey isEqualToString:@"name"])
        {
            if ([nameTextField.text isEqualToString:infoStr])
            {
                [Tools showAlertView:@"名称没做任何更改哦" delegateViewController:nil];
                return ;
            }
            
            if ([nameTextField.text length] < 4 || [nameTextField.text length] > 20)
            {
                [Tools showAlertView:@"学校名称应该在4~10个字符之间" delegateViewController:nil];
                return ;
            }
            infoStr = nameTextField.text;
        }
        else if ([infoKey isEqualToString:@"info"])
        {
            if ([infoTextView.text length] > 50)
            {
                [Tools showAlertView:@"请把班级介绍字数控制在50个字符内" delegateViewController:nil];
                return ;
            }
            
            if ([infoTextView.text isEqualToString:infoStr])
            {
                [Tools showAlertView:@"班级介绍没做任何更改哦" delegateViewController:nil];
                return ;
            }
            infoStr = infoTextView.text;
        }
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      infoKey:infoStr,
                                                                      @"c_id":[[NSUserDefaults standardUserDefaults] objectForKey:@"classid"]
                                                                      } API:SETCLASSINFO];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"signout responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([infoKey isEqualToString:@"name"])
                {
                    [[NSUserDefaults standardUserDefaults] setObject:infoStr forKey:@"classname"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                
                if ([self.setClassInfoDel respondsToSelector:@selector(updateClassInfo:value:)])
                {
                    [self.setClassInfoDel updateClassInfo:infoKey value:infoStr];
                }
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
            [Tools hideProgress:self.bgView];
        }];
        [Tools showProgress:self.bgView];
        [request startAsynchronous];
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
