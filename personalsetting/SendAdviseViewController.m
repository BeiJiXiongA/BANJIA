//
//  SendAdviseViewController.m
//  BANJIA
//
//  Created by TeekerZW on 5/3/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "SendAdviseViewController.h"

@interface SendAdviseViewController ()<UITextViewDelegate>
{
    UITextView *adviseTextView;
    UITextView *holderTextView;
}
@end

@implementation SendAdviseViewController

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
    
    self.titleLabel.text = @"意见反馈";
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendButton setTitle:@"提交" forState:UIControlStateNormal];
    sendButton.backgroundColor = [UIColor clearColor];
    [sendButton setBackgroundImage:[UIImage imageNamed:@"navbtn"] forState:UIControlStateNormal];
    sendButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [sendButton addTarget:self action:@selector(sendAdvise) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:sendButton];
    
    UIImage *inputImage = [Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)];
    UIImageView *inputImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, UI_NAVIGATION_BAR_HEIGHT+10, SCREEN_WIDTH-20, 170)];
    [inputImageView setImage:inputImage];
    inputImageView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:inputImageView];
    
    holderTextView = [[UITextView alloc] init];
    holderTextView.frame = CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, SCREEN_WIDTH-40, 30);
    holderTextView.text = @"请输入您的宝贵意见";
    holderTextView.editable = NO;
    holderTextView.backgroundColor = [UIColor clearColor];
    holderTextView.tag = 1000;
    holderTextView.textColor = TITLE_COLOR;
    holderTextView.font = [UIFont systemFontOfSize:18];
    [self.bgView addSubview:holderTextView];
    
    adviseTextView = [[UITextView alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, SCREEN_WIDTH-40, 150)];
    adviseTextView.delegate = self;
    adviseTextView.tag = 2000;
    adviseTextView.font = [UIFont systemFontOfSize:18];
    adviseTextView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:adviseTextView];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textViewDidChange:(UITextView *)textView
{
    if(textView.tag == 2000)
    {
        if ([textView.text length] > 0 && [textView.text length] < 300)
        {
            holderTextView.text = nil;
        }
        else if([textView.text length] > 300)
        {
            textView.text = [textView.text substringToIndex:301];
            [Tools showAlertView:@"字数控制在300字以内" delegateViewController:nil];
        }
        else
        {
            holderTextView.text = @"请输入您的宝贵意见";
        }
    }
}

-(void)sendAdvise
{
    
    if ([adviseTextView.text length] <= 0)
    {
        [Tools showAlertView:@"请留下您的意见" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"content":adviseTextView.text}
                                                                API:MB_ADVISE];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"sendadvise== responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"我们已经收到您的意见" toView:self.bgView];
                [self.navigationController popViewControllerAnimated:YES];
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
