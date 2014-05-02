//
//  AboutUsViewController.m
//  BANJIA
//
//  Created by TeekerZW on 4/30/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()

@end

@implementation AboutUsViewController

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
    
    self.titleLabel.text = @"关于我们";
    
    UIImage *logo = [UIImage imageNamed:@"icon20"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2-45, UI_NAVIGATION_BAR_HEIGHT+50, 90, 90)];
    [logoImageView setImage:logo];
    logoImageView.layer.cornerRadius = 10;
    logoImageView.clipsToBounds = YES;
    logoImageView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:logoImageView];
    
    UILabel *tipLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(70, UI_NAVIGATION_BAR_HEIGHT+160, SCREEN_WIDTH-140, 30)];
    tipLabel1.backgroundColor = [UIColor clearColor];
    tipLabel1.textAlignment = NSTextAlignmentCenter;
    tipLabel1.font = [UIFont systemFontOfSize:17];
    tipLabel1.text = [NSString stringWithFormat:@"班家%.1f For iPhone",[[Tools client_ver] floatValue]];
    [self.bgView addSubview:tipLabel1];
    
    UILabel *tipLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(25, SCREEN_HEIGHT-130, SCREEN_WIDTH-50, 30)];
    tipLabel2.backgroundColor = [UIColor clearColor];
    tipLabel2.textAlignment = NSTextAlignmentCenter;
    tipLabel2.font = [UIFont systemFontOfSize:20];
    tipLabel2.text = [NSString stringWithFormat:@"天津蓝景同创科技有限公司"];
    [self.bgView addSubview:tipLabel2];
    
    UILabel *tipLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(80, SCREEN_HEIGHT-100, SCREEN_WIDTH-160, 60)];
    tipLabel3.backgroundColor = [UIColor clearColor];
    tipLabel3.textAlignment = NSTextAlignmentCenter;
    tipLabel3.font = [UIFont systemFontOfSize:14];
    tipLabel3.numberOfLines = 3;
    tipLabel3.lineBreakMode = NSLineBreakByWordWrapping;
    tipLabel3.textColor = TITLE_COLOR;
    tipLabel3.text = [NSString stringWithFormat:@"Copyright 2014 LanJingTongChuang(TianJin) Technology & Development All Rights Reserved"];
    [self.bgView addSubview:tipLabel3];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
