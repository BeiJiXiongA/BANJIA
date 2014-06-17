//
//  UserProtocolViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-5-21.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "UserProtocolViewController.h"

@interface UserProtocolViewController ()

@end

@implementation UserProtocolViewController

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
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",HOST_URL,USER_PROTOCOL]];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT)];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    [self.bgView addSubview:webView];
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
