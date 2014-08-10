//
//  SearchClassViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-6-26.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "SearchClassViewController.h"
#import "RelatedCell.h"
#import "SearchSchoolViewController.h"
#import "ClassZoneViewController.h"
#import "ZBarSDK.h"

@interface SearchClassViewController ()<
UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
ZBarReaderDelegate>
{
    UITableView *searchClassTableView;
    UIView* line;
}
@end

@implementation SearchClassViewController

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
    
    self.titleLabel.text = @"查找班级";
    
    searchClassTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, 237) style:UITableViewStylePlain];
    searchClassTableView.delegate = self;
    searchClassTableView.dataSource  = self;
    searchClassTableView.scrollEnabled = NO;
    searchClassTableView.backgroundColor = self.bgView.backgroundColor;
    [self.bgView addSubview:searchClassTableView];
    
    if ([searchClassTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        searchClassTableView.separatorInset = UIEdgeInsetsZero;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row % 2 == 0)
    {
        return 35;
    }
    
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *name = @"searchclasscell";
    RelatedCell *cell = [tableView dequeueReusableCellWithIdentifier:name];
    if (cell == nil)
    {
        cell = [[RelatedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:name];
    }
    cell.contentLabel.hidden = YES;
    cell.nametf.hidden = YES;
    cell.iconImageView.hidden = YES;
    cell.relateButton.hidden = YES;
    UIImageView *markView = [[UIImageView alloc] init];
    markView.hidden = YES;
    markView.frame = CGRectMake(SCREEN_WIDTH-20, 17, 8, 12);
    [markView setImage:[UIImage imageNamed:@"discovery_arrow"]];
    [cell.contentView addSubview:markView];
    
    if (indexPath.row == 1)
    {
        cell.nametf.hidden = NO;
        cell.nametf.tag = 4444;
        cell.nametf.delegate = self;
        cell.nametf.background = nil;
        cell.nametf.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.nametf.returnKeyType = UIReturnKeySearch;
        
        cell.nametf.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
        cell.nametf.textAlignment = NSTextAlignmentLeft;
        cell.nametf.placeholder = @"请输入班号";
    }
    else if(indexPath.row == 2 || indexPath.row == 4 || indexPath.row == 0)
    {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = self.bgView.backgroundColor;
        if (indexPath.row == 0)
        {
            cell.contentLabel.frame = CGRectMake(10, 5, 100, 25);
            cell.contentLabel.hidden = NO;
            cell.contentLabel.text = @"  输入班号";
            cell.contentLabel.backgroundColor = self.bgView.backgroundColor;
        }
    }
    else
    {
        cell.contentLabel.hidden = NO;
        cell.iconImageView.hidden = NO;
        cell.contentLabel.backgroundColor = [UIColor whiteColor];
        
        cell.iconImageView.frame = CGRectMake(15, 7, 30, 30);
        cell.iconImageView.backgroundColor = [UIColor greenColor];
        cell.iconImageView.layer.cornerRadius = 3;
        cell.iconImageView.clipsToBounds = YES;
        
        cell.contentLabel.frame = CGRectMake(60, 10, 100, 24);
        if (indexPath.row == 3)
        {
            [cell.iconImageView setImage:[UIImage imageNamed:@"icon_school"]];
            cell.contentLabel.text = @"按学校搜索";
        }
        else if (indexPath.row == 5)
        {
            [cell.iconImageView setImage:[UIImage imageNamed:@"icon_qr"]];
            cell.contentLabel.text = @"扫一扫";
        }
        markView.hidden = NO;
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [((UITextField *)[searchClassTableView viewWithTag:4444]) resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 11)
    {
        //扫一扫
    }
    else if(indexPath.row == 3)
    {
        //按学校搜索
        SearchSchoolViewController *searchSchoolVC = [[SearchSchoolViewController alloc] init];
        [[NSUserDefaults standardUserDefaults] setObject:CREATENEWCLASS forKey:SEARCHSCHOOLTYPE];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController pushViewController:searchSchoolVC animated:YES];
    }
    else if(indexPath.row == 5)
    {
        //扫一扫
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

- (void)dismissOverlayView:(id)sender{   
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
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
        DDLOG(@"%@",symbol.data);
        NSString *classNum = [symbol.data substringFromIndex:[symbol.data rangeOfString:@";"].location+1];
        [self searchClass:classNum];
    }];
    
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DDLOG(@"class number %@",textField.text);
    [((UITextField *)[searchClassTableView viewWithTag:4444]) resignFirstResponder];
    [self searchClass:((UITextField *)[searchClassTableView viewWithTag:4444]).text];
    
    return YES;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [((UITextField *)[searchClassTableView viewWithTag:4444]) resignFirstResponder];
}

-(void)searchClass:(NSString *)searchContent
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":@"",
                                                                      @"number":[NSString stringWithFormat:@"%d",[searchContent integerValue]]
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
