//
//  ClassQRViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-7-9.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "ClassQRViewController.h"
#import "QRCodeGenerator.h"

@interface ClassQRViewController ()

@end

@implementation ClassQRViewController
@synthesize classNumber;
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
    
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    self.view.backgroundColor = [UIColor blackColor];
    
    self.titleLabel.text = @"班级二维码";
    
//    UIImage *image = [QRCodeGenerator qrImageForString:classNumber imageSize:240];
    
    UIImage *image = [self getImage];
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.frame = CGRectMake(40, UI_NAVIGATION_BAR_HEIGHT+50, 240, 240);
    [imageView setImage:image];
    [self.bgView addSubview:imageView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UIImage *)getImage
{
    UIImage *image = [QRCodeGenerator qrImageForString:[NSString stringWithFormat:@"%@;%@",@"http://www.banjiaedu.com/welcome/mobile",classNumber] imageSize:480];
    UIImage *banjiaIcon = [UIImage imageNamed:@"logo58"];
    UIGraphicsBeginImageContext(CGSizeMake(480, 480));
    [image drawAtPoint:CGPointMake(0, 0)];
    [banjiaIcon drawAtPoint:CGPointMake(211, 211)];
    UIImage *qrimage = UIGraphicsGetImageFromCurrentImageContext();
    return qrimage;
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
