//
//  CheckQRCodeViewController.m
//  BANJIA
//
//  Created by TeekerZW on 7/28/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "CheckQRCodeViewController.h"
#import "ZBarReaderViewController.h"
#import "ZBarSDK.h"
#import "ChatViewController.h"
#import "ClassZoneViewController.h"

@interface CheckQRCodeViewController ()<ZBarReaderDelegate>
{
    UIView *line;
}
@end

@implementation CheckQRCodeViewController

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
    
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    reader.showsZBarControls = NO;
    reader.readerView.torchMode = 0;
    [self setOverlayPickerView:reader];
    
    ZBarImageScanner *scanner = reader.scanner;
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    [self.navigationController presentViewController:reader animated:YES completion:nil];
}

- (void)setOverlayPickerView:(ZBarReaderViewController *)reader

{
    
    //清除原有控件
    
    for (UIView *temp in [reader.view subviews])
    {
        for (UIButton *button in [temp subviews])
        {
            if ([button isKindOfClass:[UIButton class]])
            {
                [button removeFromSuperview];
            }
        }
        
        for (UIToolbar *toolbar in [temp subviews])
        {
            if ([toolbar isKindOfClass:[UIToolbar class]])
            {
                [toolbar setHidden:YES];
                
                [toolbar removeFromSuperview];
            }
        }
    }
    
    //    CGFloat width = 280.0f;
    
    //画中间的基准线
    
    line = [[UIView alloc] init];
    line.frame = CGRectMake(40, (SCREEN_HEIGHT+20)/2, 240, 1);
    line.backgroundColor = [UIColor greenColor];
    //    [reader.view addSubview:line];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(20, 80)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(20, 220)];
    animation.duration = 0.5;
    animation.autoreverses = YES;
    animation.repeatCount = INFINITY;
    [line.layer addAnimation:animation forKey:@"123"];
    
    //最上部view
    
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, (SCREEN_HEIGHT-240)/2)];
    
    upView.alpha = 0.3;
    
    upView.backgroundColor = [UIColor blackColor];
    
    [reader.view addSubview:upView];
    
    //用于说明的label
    
    UILabel * labIntroudction= [[UILabel alloc] init];
    
    labIntroudction.backgroundColor = [UIColor clearColor];
    
    labIntroudction.frame=CGRectMake(15, 20, 290, 50);
    
    labIntroudction.numberOfLines=2;
    
    labIntroudction.textColor=[UIColor whiteColor];
    
    labIntroudction.text=@"";
    
    [upView addSubview:labIntroudction];
    
    
    //左侧的view
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-240)/2, 20, 280)];
    
    leftView.alpha = 0.3;
    
    leftView.backgroundColor = [UIColor blackColor];
    
    [reader.view addSubview:leftView];
    
    
    //右侧的view
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(300, (SCREEN_HEIGHT-240)/2, 20, 280)];
    
    rightView.alpha = 0.3;
    
    rightView.backgroundColor = [UIColor blackColor];
    
    [reader.view addSubview:rightView];
    
    
    //底部view
    
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-(SCREEN_HEIGHT-240)/2+40, 320, (SCREEN_HEIGHT-240)/2+20)];
    
    downView.alpha = 0.3;
    
    downView.backgroundColor = [UIColor blackColor];
    
    [reader.view addSubview:downView];
    
    UIImageView *upLeftCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_1"]];
    upLeftCorner.frame = CGRectMake(20, (SCREEN_HEIGHT-240)/2, 30, 30);
    [reader.view addSubview:upLeftCorner];
    
    UIImageView *upRightCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_2"]];
    upRightCorner.frame = CGRectMake(20+280-30, (SCREEN_HEIGHT-240)/2, 30, 30);
    [reader.view addSubview:upRightCorner];
    
    UIImageView *downLeftCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_4"]];
    downLeftCorner.frame = CGRectMake(20, (SCREEN_HEIGHT+YSTART-240)/2+240, 30, 30);
    [reader.view addSubview:downLeftCorner];
    
    UIImageView *downRightCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_3"]];
    downRightCorner.frame = CGRectMake(300-30, (SCREEN_HEIGHT+YSTART-240)/2+240, 30, 30);
    [reader.view addSubview:downRightCorner];
    
    
    //用于取消操作的button
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    cancelButton.alpha = 0.4;
    
    [cancelButton setFrame:CGRectMake(20, SCREEN_HEIGHT-40, 40, 40)];
    
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    
    //    [cancelButton setImage:[UIImage imageNamed:@"outer_nav_backbtn_s"] forState:UIControlStateNormal];
    
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    
    [cancelButton addTarget:self action:@selector(dismissOverlayView:)forControlEvents:UIControlEventTouchUpInside];
    
    [reader.view addSubview:cancelButton];
    
}

//取消button方法

- (void)dismissOverlayView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) imagePickerController: (UIImagePickerController*) picker
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
    [picker dismissViewControllerAnimated:YES completion:^{
//        [self.navigationController popViewControllerAnimated:YES];
        DDLOG(@"%@",symbol.data);
        NSString *resultStr = symbol.data;
        if ([resultStr rangeOfString:@";"].length > 0)
        {
            [self searchClass:[resultStr substringFromIndex:[resultStr rangeOfString:@";"].location+1]];
        }
        else
        {
            NSRange range1 = [resultStr rangeOfString:@"?"];
            NSRange range2 = [resultStr rangeOfString:@"="];
            if (range1.length > 0 && range2.length > 0)
            {
                NSString *key = [resultStr substringWithRange:NSMakeRange(range1.location+1, range2.location-range1.location-1)];
                NSString *value = [resultStr substringWithRange:NSMakeRange(range2.location+1, [resultStr length]-range2.location-1)];
                DDLOG(@"key = %@  value = %@",key,value);
                if([key isEqualToString:@"groupid"])
                {
                    [self joinGroupChat:value];
                }
                else if([key isEqualToString:@"classid"])
                {
                    [self searchClass:value];
                }
            }
        }
    }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)joinGroupChat:(NSString *)groupID
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"g_id":groupID,
                                                                      } API:JOINGROUPCHAR];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"searchclass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                ChatViewController *chatVC = [[ChatViewController alloc] init];
                chatVC.toID = groupID;
                chatVC.isGroup = YES;
                [self.navigationController pushViewController:chatVC animated:YES];
            }
            else
            {
                [self.navigationController popViewControllerAnimated:YES];
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

-(void)searchClass:(NSString *)searchContent
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":@"",
                                                                      @"number":[NSString stringWithFormat:@"%ld",(long)[searchContent integerValue]]
                                                                      } API:SEARCHCLASS];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"searchclass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
                {
                    if ([[responseDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
                    {
                        NSString *classID = [[responseDict objectForKey:@"data"] objectForKey:@"_id"];
                        NSString *className = [[responseDict objectForKey:@"data"] objectForKey:@"name"];
                        
                        OperatDB *db = [[OperatDB alloc] init];
                        if ([[db findSetWithDictionary:@{@"uid":[Tools user_id],@"classid":classID} andTableName:MYCLASSTABLE] count]> 0)
                        {
                            [Tools showAlertView:@"您已经是这个班的一员了" delegateViewController:nil];
                            return ;
                        }
                        
                        NSString *schoolName;
                        if (![[[responseDict objectForKey:@"data"] objectForKey:@"school"] isEqual:[NSNull null]])
                        {
                            schoolName = [[[responseDict objectForKey:@"data"] objectForKey:@"school"] objectForKey:@"name"];
                        }
                        else
                        {
                            schoolName = @"未指定学校";
                        }
                        
                        ClassZoneViewController *classZone = [[ClassZoneViewController alloc] init];
                        classZone.isApply = YES;
                        [[NSUserDefaults standardUserDefaults] setObject:classID forKey:@"classid"];
                        [[NSUserDefaults standardUserDefaults] setObject:className forKey:@"classname"];
                        [[NSUserDefaults standardUserDefaults] setObject:schoolName forKey:@"schoolname"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        [self.navigationController pushViewController:classZone animated:YES];
                    }
                    
                    else
                    {
                        [Tools showTips:@"未找到任何班级" toView:self.bgView];
                    }
                }
                else
                {
                    [Tools showTips:@"未找到任何班级" toView:self.bgView];
                }
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
