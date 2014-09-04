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
    UIImageView *line;
    
    int num;
    BOOL upOrdown;
    NSTimer * timer;
    
    ZBarReaderViewController *reader;
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
        num = 0;
        upOrdown = NO;
        reader = [ZBarReaderViewController new];
        reader.readerDelegate = self;
        reader.readerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        reader.readerView.torchMode = 0;
        reader.supportedOrientationsMask = ZBarOrientationMaskAll;
        reader.showsZBarControls = NO;
        [self setOverlayPickerView];
        ZBarImageScanner *scanner = reader.scanner;
        [scanner setSymbology: ZBAR_I25
                       config: ZBAR_CFG_ENABLE
                           to: 0];
        [self.navigationController pushViewController:reader animated:YES];
    }
}


- (void)setOverlayPickerView

{
    
    for (UIView *temp in [reader.view subviews])
    {
        if (temp.frame.size.height == 54)
        {
            [temp removeFromSuperview];
        }
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
    
    
    CGFloat height = SCREEN_WIDTH-100;
    
    UIColor *viewColor = [UIColor blackColor];
    
    //最上部view
    
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_HEIGHT-height)/2-40)];
    
    upView.alpha = 0.3;
    
    upView.backgroundColor = viewColor;
    
    [reader.view addSubview:upView];
    
    //left,up
    UIImageView *upLeftCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_1"]];
    upLeftCorner.frame = CGRectMake(50, (SCREEN_HEIGHT-height)/2-40, 25, 25);
    [reader.view addSubview:upLeftCorner];
    
    //right,up
    UIImageView *upRightCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_2"]];
    upRightCorner.frame = CGRectMake(SCREEN_WIDTH-50-25, (SCREEN_HEIGHT-height)/2-40, 25, 25);
    [reader.view addSubview:upRightCorner];
    
    
    //左侧的view
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, (SCREEN_HEIGHT-height)/2-40, 50, height)];
    
    leftView.alpha = 0.3;
    
    leftView.backgroundColor = viewColor;
    
    [reader.view addSubview:leftView];
    
    
    //右侧的view
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-50, (SCREEN_HEIGHT-height)/2-40, 50, height)];
    
    rightView.alpha = 0.3;
    
    rightView.backgroundColor = viewColor;
    
    [reader.view addSubview:rightView];
    
    //left,down
    UIImageView *downLeftCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_4"]];
    downLeftCorner.frame = CGRectMake(50, (SCREEN_HEIGHT-height)/2+height-25-40, 25, 25);
    [reader.view addSubview:downLeftCorner];
    
    //right,down
    UIImageView *downRightCorner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"corner_3"]];
    downRightCorner.frame = CGRectMake(SCREEN_WIDTH-50-25, (SCREEN_HEIGHT-height)/2+height-25-40, 25, 25);
    [reader.view addSubview:downRightCorner];
    
    
    //底部view
    
    UIView * downView = [[UIView alloc] initWithFrame:CGRectMake(0, height+(SCREEN_HEIGHT-height)/2-40, SCREEN_WIDTH, (SCREEN_HEIGHT-height)/2+80)];
    
    downView.alpha = 0.3;
    
    downView.backgroundColor = viewColor;
    
    [reader.view addSubview:downView];
    
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(20, (SCREEN_HEIGHT-height)/2+height+15-40, 280, 50)];
    label.text = @"请将班级二维码置于方框内";
    label.textColor = [UIColor whiteColor];
    label.textAlignment = 1;
    label.lineBreakMode = 0;
    label.numberOfLines = 2;
    label.backgroundColor = [UIColor clearColor];
    [reader.view addSubview:label];
    
    UIImageView * image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    image.frame = CGRectMake(20, (SCREEN_HEIGHT-height)/2-40, height, height);
    [reader.view addSubview:image];
    
    
    line = [[UIImageView alloc] initWithFrame:CGRectMake(30, 10, 220, 2)];
    line.image = [UIImage imageNamed:@"qrline"];
    [image addSubview:line];
    //定时器，设定时间过1.5秒，
    timer = [NSTimer scheduledTimerWithTimeInterval:.03 target:self selector:@selector(animation1) userInfo:nil repeats:YES];
    
    UIView *_navigationBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,
                                                                          UI_SCREEN_WIDTH,
                                                                          UI_NAVIGATION_BAR_HEIGHT)];
    _navigationBarView.backgroundColor = [UIColor yellowColor];
    [reader.view addSubview:_navigationBarView];
    
    UIImageView * _navigationBarBg = [[UIImageView alloc] init];
    _navigationBarBg.backgroundColor = UIColorFromRGB(0xffffff);
    _navigationBarBg.frame = CGRectMake(0, 0, UI_SCREEN_WIDTH, UI_NAVIGATION_BAR_HEIGHT);
    _navigationBarBg.image = [UIImage imageNamed:@"nav_bar_bg"];
    [_navigationBarView addSubview:_navigationBarBg];
    
    UILabel * _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-90, YSTART + 6, 180, 36)];
    _titleLabel.font = [UIFont fontWithName:@"Courier" size:19];
    _titleLabel.text = @"扫一扫";
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = UIColorFromRGB(0x666464);
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [_navigationBarView addSubview:_titleLabel];
    
    
    UIImageView *returnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, YSTART +13, 11, 18)];
    [returnImageView setImage:[UIImage imageNamed:@"icon_return"]];
    [_navigationBarView addSubview:returnImageView];
    
    UIButton *_backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, YSTART +2, 58 , NAV_RIGHT_BUTTON_HEIGHT)];
    [_backButton setTitle:@"返回" forState:UIControlStateNormal];
    [_backButton setBackgroundColor:[UIColor clearColor]];
    [_backButton setTitleColor:UIColorFromRGB(0x727171) forState:UIControlStateNormal];
    [_backButton addTarget:self action:@selector(unShowSelfViewController) forControlEvents:UIControlEventTouchUpInside];
    _backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _backButton.titleLabel.font = [UIFont systemFontOfSize:16.5];
    [_navigationBarView addSubview:_backButton];
    
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.alpha = 0.4;
    cancelButton.backgroundColor = [UIColor blackColor];
    [cancelButton setFrame:CGRectMake((SCREEN_WIDTH-100)/2, label.frame.size.height+label.frame.origin.y+20, 100, 40)];
    cancelButton.layer.cornerRadius = 15;
    cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    cancelButton.layer.borderWidth = 0.3;
    cancelButton.clipsToBounds = YES;
    [cancelButton setImage:[UIImage imageNamed:@"flash"] forState:UIControlStateNormal];
//    [cancelButton setTitle:@"开灯" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [cancelButton addTarget:self action:@selector(light)forControlEvents:UIControlEventTouchUpInside];
    [reader.view addSubview:cancelButton];
    
}


-(void)light
{
    if (reader.readerView.torchMode == 0)
    {
        reader.readerView.torchMode = 1;
    }
    else
    {
        reader.readerView.torchMode = 0;
    }
}
-(void)animation1
{
    if (upOrdown == NO) {
        num ++;
        line.frame = CGRectMake(30, 10+2*num, 220, 2);
        if (2*num == SCREEN_WIDTH-120) {
            upOrdown = YES;
        }
    }
    else {
        num --;
        line.frame = CGRectMake(30, 10+2*num, 220, 2);
        if (num == 0) {
            upOrdown = NO;
        }
    }
    
    
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
    
    DDLOG(@"%@",symbol.data);
    NSString *classNum = [symbol.data substringFromIndex:[symbol.data rangeOfString:@";"].location+1];
    [self searchClass:classNum];
    
    [self.navigationController popViewControllerAnimated:NO];
}

-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (!textField.window.isKeyWindow)
    {
        [textField.window makeKeyAndVisible];
    }
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
