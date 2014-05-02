//
//  OtherAppointViewController.m
//  School
//
//  Created by TeekerZW on 14-2-20.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "OtherAppointViewController.h"
#import "Header.h"

@interface OtherAppointViewController ()
{
    UITextField *jobTextField;
}
@end

@implementation OtherAppointViewController
@synthesize otherUserID;
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
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+20, SCREEN_WIDTH-40, 30)];
    label1.backgroundColor = [UIColor clearColor];
    label1.text = [NSString stringWithFormat:@"请输入帮干部职位名称"];
    label1.font = [UIFont systemFontOfSize:14];
    [self.bgView addSubview:label1];
    
    jobTextField = [[UITextField alloc] initWithFrame:CGRectMake(30, label1.frame.origin.y+label1.frame.size.height+20, SCREEN_WIDTH-60, 30)];
    jobTextField.backgroundColor = [UIColor grayColor];
    jobTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.bgView addSubview:jobTextField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
