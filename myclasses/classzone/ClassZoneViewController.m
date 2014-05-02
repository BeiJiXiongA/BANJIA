//
//  ClassZoneViewController.m
//  School
//
//  Created by TeekerZW on 14-1-17.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ClassZoneViewController.h"
#import "XDTabViewController.h"
#import "AddDongTaiViewController.h"
#import "HeaderCell.h"
#import "XDTabViewController.h"
#import "TrendsCell.h"
#import "DongTaiDetailViewController.h"
#import "ChooseClassInfoViewController.h"
#import "XDContentViewController+JDSideMenu.h"
#import "NewDiariesViewController.h"
#import "EGORefreshTableHeaderView.h"

#import "UIImage+URBImageEffects.h"

#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#define ImageViewTag  9999
#define HeaderImageTag  7777
#define CellButtonTag   33333

#define SectionTag  10000
#define RowTag     100

@interface ClassZoneViewController ()<UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
ClassZoneDelegate,
EGORefreshTableHeaderDelegate>
{
    UITableView *classZoneTableView;
    NSMutableArray *tmpArray;
    NSMutableDictionary *tmpDict;
    int page;
    NSString *monthStr;
    CGFloat bgImageViewHeight;
    
    UIImageView *bgImageView;
    
    BOOL isRefresh;
    
    UILabel *noneDongTaiLabel;
    
    BOOL haveNew;
    
    int uncheckedCount;
    
    EGORefreshTableHeaderView *pullRefreshView;
    BOOL _reloading;
    
    NSString *schoolName;
    NSString *className;
}
@end

@implementation ClassZoneViewController
@synthesize classID,className,schoolID,schoolName,fromClasses,fromMsg;
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
    self.titleLabel.text = @"班级空间";
    monthStr = @"";
    
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    page = 0;
    haveNew = NO;
    _reloading = NO;
    
    bgImageViewHeight = 150.0f;
    uncheckedCount = 0;
    
    tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
//    [addButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    addButton.hidden = YES;
    [addButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    [addButton setTitle:@"发布" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addDongTaiClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:addButton];
    
    noneDongTaiLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, UI_NAVIGATION_BAR_HEIGHT+bgImageViewHeight+90, SCREEN_WIDTH-40, 60)];
    noneDongTaiLabel.text = @"这个班级还没有任何动态，你可以成为第一人发布动态的人哦！";
    noneDongTaiLabel.numberOfLines = 2;
    noneDongTaiLabel.lineBreakMode = NSLineBreakByWordWrapping;
    noneDongTaiLabel.hidden = YES;
    noneDongTaiLabel.textColor = TITLE_COLOR;
    noneDongTaiLabel.textAlignment = NSTextAlignmentCenter;
    noneDongTaiLabel.backgroundColor = [UIColor clearColor];
    
    UITapGestureRecognizer *tapFresh = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(getDongTaiList)];
    noneDongTaiLabel.userInteractionEnabled = YES;
    [noneDongTaiLabel addGestureRecognizer:tapFresh];
    
    classZoneTableView = [[UITableView alloc] init];
    if (fromMsg || fromClasses)
    {
        classZoneTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT);
    }
    else
    {
        classZoneTableView.frame = CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - UI_NAVIGATION_BAR_HEIGHT-UI_TAB_BAR_HEIGHT);
    }
    
    classZoneTableView.delegate = self;
    classZoneTableView.dataSource = self;
    classZoneTableView.tag = 10000;
    classZoneTableView.backgroundColor = self.bgView.backgroundColor;
//    classZoneTableView.backgroundColor = RGB(205, 205, 205, 1);;
    classZoneTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    classZoneTableView.showsVerticalScrollIndicator = NO;
    
    [self.bgView addSubview:classZoneTableView];
    
    [self.bgView addSubview:noneDongTaiLabel];
    
    if (fromMsg)
    {
        [self.backButton addTarget:self action:@selector(mybackClick) forControlEvents:UIControlEventTouchUpInside];
        addButton.hidden = NO;
    }
    else if (!fromClasses)
    {
        [self.backButton addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
        addButton.hidden = NO;
    }
    if(([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"]) &&
       ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentSendDiary] integerValue]== 2))
    {
        addButton.hidden = YES;
    }
    else if(([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"]) &&
            ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentSendDiary] integerValue]== 2))
    {
        addButton.hidden = YES;
    }
    
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:classZoneTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    if (fromClasses)
    {
        [self getClassInfo];
        [self getCLassSettings];
    }
    else
    {
        [self getCLassInfoCache];
        [self getCacheSetting];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)mybackClick
{
    [self unShowSelfViewController];
}

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    if (fromClasses)
    {
        [Tools showAlertView:@"您还没有计入这个班级，快去申请加入吧！" delegateViewController:self];
        return ;
    }
    page =0;
    monthStr = @"";
    [self getDongTaiList];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [pullRefreshView egoRefreshScrollViewDidScroll:classZoneTableView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:classZoneTableView];
}

#pragma mark - classzoneDelegate
-(void)haveAddDonfTai:(BOOL)add
{
    if (add)
    {
        haveNew = YES;
        page = 0;
        monthStr = @"";
        [self getCLassSettings];
    }
}

#pragma mark - applyJoin
-(void)applyJoin
{
    ChooseClassInfoViewController *chooseClassInfo = [[ChooseClassInfoViewController alloc] init];
    chooseClassInfo.classID = classID;
    chooseClassInfo.className = className;
    chooseClassInfo.schoolName = schoolName;
    chooseClassInfo.schoolID = schoolID;
    [chooseClassInfo showSelfViewController:self];
}

-(void)backClick
{
    [[XDTabViewController sharedTabViewController] unShowSelfViewController];
//    [[XDTabViewController sharedTabViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)addDongTaiClick
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"])
    {
        if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentSendDiary] integerValue] == 2)
        {
            [Tools showAlertView:@"本班不允许家长发表班级日志" delegateViewController:nil];
            return ;
        }
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"])
    {
        if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentSendDiary] integerValue] == 2)
        {
            [Tools showAlertView:@"本班不允许学生发表班级日志" delegateViewController:nil];
            return ;
        }
    }
    
    AddDongTaiViewController *addDongTaiViewController = [[AddDongTaiViewController alloc] init];
    addDongTaiViewController.classID = classID;
    addDongTaiViewController.classZoneDelegate = self;
    [addDongTaiViewController showSelfViewController:[XDTabViewController sharedTabViewController]];
}
#pragma mark - getclassInfo
-(void)getClassInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID
                                                                      } API:CLASSINFO];
        [request setCompletionBlock:^{
            isRefresh = NO;
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classInfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if(![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
                {
                    className = [[responseDict objectForKey:@"data"] objectForKey:@"name"];
                    schoolName =[[[responseDict objectForKey:@"data"] objectForKey:@"school"] objectForKey:@"name"];
                }
                NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",CLASSINFO,[Tools user_id],classID];
                NSString *key = [requestUrlStr MD5Hash];
                [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
}

-(void)getCLassSettings
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID
                                                                      } API:GETSETTING];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classsetttings responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETSETTING,[Tools user_id],classID];
                NSString *key = [requestUrlStr MD5Hash];
                [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                
                [self dealClassSetting:responseDict];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
}
-(void)getCacheSetting
{
    if ([Tools NetworkReachable])
    {
        [self getCLassSettings];
    }
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETSETTING,[Tools user_id],classID];
    NSString *key = [requestUrlStr MD5Hash];
    NSData *data = [FTWCache objectForKey:key];
    NSString *settingCacheString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *settingCacheDict = [Tools JSonFromString:settingCacheString];
    if ([settingCacheDict count] > 0)
    {
        [self dealClassSetting:settingCacheDict];
    }
    else
    {
        [self getCLassSettings];
    }
}

-(void)dealClassSetting:(NSDictionary *)responseDict
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[[responseDict objectForKey:@"data"] objectForKey:@"set"] forKey:@"set"];
    
    [ud setObject:[[responseDict objectForKey:@"data"] objectForKey:@"role"] forKey:@"role"];
    [ud setObject:[[responseDict objectForKey:@"data"] objectForKey:@"admin"] forKey:@"admin"];
    if (![[[responseDict objectForKey:@"data"] objectForKey:@"opt"] isEqual:[NSNull null]])
    {
        if ([[[responseDict objectForKey:@"data"] objectForKey:@"opt"] count] > 0)
        {
            [ud setObject:[[responseDict objectForKey:@"data"] objectForKey:@"opt"] forKey:@"opt"];
        }
    }
    
    [ud synchronize];
    if (fromClasses)
    {
        [self getDongTaiList];
    }
    else
    {
        [self getCacheData];
    }
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (fromClasses)
    {
        return [tmpArray count]>0?([tmpArray count]+1):1;
    }
    else
    {
        return [tmpArray count]+1;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section > 0)
    {
        NSDictionary *dict = [tmpArray objectAtIndex:section-1];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, SCREEN_WIDTH-10, 60)];
        headerLabel.text = [dict objectForKey:@"date"];
        headerLabel.textColor = TITLE_COLOR;
        headerLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        headerLabel.font = [UIFont systemFontOfSize:30];
        return headerLabel;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section > 0)
    {
        return 60;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (fromClasses)
    {
        if(section == 0)
        {
            return 1;
        }
        else if(([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:VisitorAccess] integerValue] == 0))
        {
            NSArray *array = [[tmpArray objectAtIndex:section] objectForKey:@"diaries"];
            DDLOG(@"from class diaries %@",array);
            return [array count] > 5 ? 5 : ([array count]);
        }
       
    }
    else
    {
        if (section >0)
        {
            if (section<[tmpArray count])
            {
                NSDictionary *dict = [tmpArray objectAtIndex:section-1];
                NSArray *array = [dict objectForKey:@"diaries"];
                return [array count];
            }
            else
            {
                NSDictionary *dict = [tmpArray objectAtIndex:section-1];
                NSArray *array = [dict objectForKey:@"diaries"];
                return [array count]+1;
            }
        }
        else
            return 2;
        
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >0)
    {
        if (indexPath.section < [tmpArray count])
        {
            NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
            NSArray *array = [groupDict objectForKey:@"diaries"];
            CGFloat imageViewHeight = 134;
            NSDictionary *dict = [array objectAtIndex:indexPath.row];
            NSString *content = [dict objectForKey:@"content"];
            NSArray *imgsArray = [[dict objectForKey:@"img"] count]>0?[dict objectForKey:@"img"]:nil;
            CGFloat imgsHeight = [imgsArray count]>0?(imageViewHeight+10):10;
            CGFloat contentHtight = [content length]>0?35:0;
            return 60+imgsHeight+contentHtight+50;
        }
        else
        {
            NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
            NSArray *array = [groupDict objectForKey:@"diaries"];
            if (indexPath.row < [array count])
            {
                CGFloat imageViewHeight = 134;
                NSDictionary *dict = [array objectAtIndex:indexPath.row];
                NSString *content = [dict objectForKey:@"content"];
                NSArray *imgsArray = [[dict objectForKey:@"img"] count]>0?[dict objectForKey:@"img"]:nil;
                CGFloat imgsHeight = [imgsArray count]>0?(imageViewHeight+10):10;
                CGFloat contentHtight = [content length]>0?35:0;
                return 60+imgsHeight+contentHtight+50;
            }
            else
            {
                return 40;
            }
        }
        
    }
    else if(indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            if (fromClasses)
            {
                return bgImageViewHeight+72.5;
            }
            return bgImageViewHeight;
        }
        else if (uncheckedCount > 0)
        {
            return 30;
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            static NSString *headeViewCell = @"headerViewCell";
            TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:headeViewCell];
            if (cell == nil)
            {
                cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headeViewCell];
            }
            cell.headerImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, bgImageViewHeight);
            UIImage *topImage = [UIImage imageNamed:@"toppic.jpg"];
            topImage = [topImage boxblurImageWithBlur:0.2];
            cell.headerImageView.image = topImage;
            
            cell.nameLabel.frame = CGRectMake(SCREEN_WIDTH-200, bgImageViewHeight-50, 190, 20);
            cell.locationLabel.frame = CGRectMake(SCREEN_WIDTH-200, bgImageViewHeight-30, 190, 20);
            cell.locationLabel.textAlignment = NSTextAlignmentCenter;
            cell.nameLabel.textAlignment = NSTextAlignmentCenter;
            cell.locationLabel.font = [UIFont systemFontOfSize:16];
            cell.nameLabel.font = [UIFont systemFontOfSize:16];
            cell.nameLabel.textColor = [UIColor whiteColor];
            cell.locationLabel.textColor = [UIColor whiteColor];
            cell.nameLabel.text = className;
            cell.locationLabel.text = schoolName;
            cell.backgroundColor = [UIColor clearColor];
            if (fromClasses)
            {
                cell.praiseButton.frame = CGRectMake(35, bgImageViewHeight+21, SCREEN_WIDTH-70, 35);
                
                UIImage *btnImage = [Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
                [cell.praiseButton setBackgroundImage:btnImage forState:UIControlStateNormal];
                [cell.praiseButton setTitle:@"申请加入" forState:UIControlStateNormal];
                [cell.praiseButton addTarget:self action:@selector(applyJoin) forControlEvents:UIControlEventTouchUpInside];
                cell.praiseButton.titleLabel.font = [UIFont systemFontOfSize:18];
                [cell.praiseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                cell.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, bgImageViewHeight+72.5);
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else if (indexPath.row == 1)
        {
            static NSString *newDiary = @"newdiary";
            UITableViewCell *cell  = [tableView dequeueReusableCellWithIdentifier:newDiary];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newDiary];
            }
            cell.textLabel.font = [UIFont systemFontOfSize:12];
            cell.textLabel.text = [NSString stringWithFormat:@"有%d条待审核日志",uncheckedCount];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            return cell;
        }
    }
    else if(indexPath.section > 0)
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
        NSArray *array = [groupDict objectForKey:@"diaries"];
        if ((indexPath.section == [tmpArray count]) && (indexPath.row==[array count]))
        {
            
            static NSString *buttomCell = @"buttom";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:buttomCell];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:buttomCell];
            }
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
            button.backgroundColor = [UIColor clearColor];
            if (classZoneTableView.contentSize.height > classZoneTableView.frame.size.height)
            {
                button.enabled = YES;
                [button setTitle:@"加载更多" forState:UIControlStateNormal];
            }
            else
            {
                button.enabled = NO;
                [button setTitle:@"" forState:UIControlStateNormal];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(getMoreDongTai) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:button];
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
        else
        {
            static NSString *topImageView = @"trendcell";
            TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:topImageView];
            if (cell == nil)
            {
                cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topImageView];
            }
            NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
            NSArray *array = [groupDict objectForKey:@"diaries"];
            NSDictionary *dict = [array objectAtIndex:indexPath.row];
            NSString *name = [[dict objectForKey:@"by"] objectForKey:@"name"];
            cell.nameLabel.frame = CGRectMake(60, 5, [name length]*25>100?100:([name length]*25), 30);
            cell.nameLabel.text = name;
            cell.timeLabel.frame = CGRectMake(cell.nameLabel.frame.size.width+cell.nameLabel.frame.origin.x+10, 5, SCREEN_WIDTH-cell.nameLabel.frame.origin.x-cell.nameLabel.frame.size.width-20, 30);
            cell.timeLabel.textAlignment = NSTextAlignmentRight;
            cell.timeLabel.text = [Tools showTime:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]];
            cell.headerImageView.layer.cornerRadius = 5;
            cell.headerImageView.clipsToBounds = YES;
            cell.headerImageView.backgroundColor = [UIColor clearColor];
            [Tools fillImageView:cell.headerImageView withImageFromURL:[[dict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:@"header_pic.jpg"];
            cell.locationLabel.frame = CGRectMake(60, cell.nameLabel.frame.origin.y+cell.nameLabel.frame.size.height, SCREEN_WIDTH-80, 20);
            cell.locationLabel.text = [dict objectForKey:@"add"];
            
            cell.contentLabel.hidden = YES;
            for(UIView *v in cell.imagesScrollView.subviews)
            {
                if ([v isKindOfClass:[UIImageView class]])
                {
                    [v removeFromSuperview];
                }
            }
            if (![[dict objectForKey:@"content"] length] <=0)
            {
                //有文字
                cell.contentLabel.hidden = NO;
                cell.contentLabel.textColor = TITLE_COLOR;
                cell.contentLabel.text = [dict objectForKey:@"content"];
                cell.contentLabel.frame = CGRectMake(10, 60, SCREEN_WIDTH-20, 35);
            }
            else
            {
                cell.contentLabel.frame = CGRectMake(10, 60, 0, 0);
            }
            CGFloat imageViewHeight = 134;
            CGFloat imageViewWidth = 134;
            if ([[dict objectForKey:@"img"] count] > 0)
            {
                //有图片
                
                NSArray *imgsArray = [dict objectForKey:@"img"];                
                cell.imagesScrollView.frame = CGRectMake(5, cell.contentLabel.frame.size.height+cell.contentLabel.frame.origin.y+3, SCREEN_WIDTH-10, imageViewHeight);
                cell.imagesScrollView.contentSize = CGSizeMake((imageViewWidth+5)*[imgsArray count], imageViewHeight);
                for (int i=0; i<[imgsArray count]; ++i)
                {
                    UIImageView *imageView = [[UIImageView alloc] init];
                    imageView.frame = CGRectMake(i*(imageViewWidth+5), 0, imageViewWidth, imageViewHeight);
                    imageView.userInteractionEnabled = YES;
                    imageView.tag = (indexPath.section-1)*SectionTag+indexPath.row*RowTag+i+333;
                    
                    imageView.userInteractionEnabled = YES;
                    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                    
                    // 内容模式
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    [Tools fillImageView:imageView withImageFromURL:[imgsArray objectAtIndex:i] andDefault:@""];
                    [cell.imagesScrollView addSubview:imageView];
                }
            }
            else
            {
                cell.imagesScrollView.frame = CGRectMake(5, cell.contentLabel.frame.size.height+cell.contentLabel.frame.origin.y, SCREEN_WIDTH-10, 0);
            }
            cell.transmitButton.frame = CGRectMake(5,cell.imagesScrollView.frame.size.height+cell.imagesScrollView.frame.origin.y+10, 40, 30);
            [cell.transmitButton setTitle:@"转发" forState:UIControlStateNormal];
            [cell.praiseButton setTitle:[NSString stringWithFormat:@"赞(%d)",[[dict objectForKey:@"likes_num"] integerValue]] forState:UIControlStateNormal];
            [cell.praiseButton addTarget:self action:@selector(praiseDiary:) forControlEvents:UIControlEventTouchUpInside];
            cell.praiseButton.tag = indexPath.section*SectionTag+indexPath.row;
            cell.praiseImageView.frame = CGRectMake((SCREEN_WIDTH-20)/4-20, cell.imagesScrollView.frame.size.height+cell.imagesScrollView.frame.origin.y+18, 13, 13);
            cell.praiseButton.frame = CGRectMake(10, cell.imagesScrollView.frame.size.height+cell.imagesScrollView.frame.origin.y+10, (SCREEN_WIDTH-20)/2, 30);
            cell.commentImageView.frame = CGRectMake((SCREEN_WIDTH-20)*3/4-35, cell.imagesScrollView.frame.size.height+cell.imagesScrollView.frame.origin.y+18, 13, 13);
            [cell.commentButton setTitle:[NSString stringWithFormat:@"评论(%d)",[[dict objectForKey:@"comments_num"] integerValue]] forState:UIControlStateNormal];
            cell.commentButton.frame = CGRectMake((SCREEN_WIDTH-20)/2, cell.imagesScrollView.frame.size.height+cell.imagesScrollView.frame.origin.y+10, (SCREEN_WIDTH-20)/2, 30);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.commentButton.tag = indexPath.section*SectionTag+indexPath.row;
            [cell.commentButton addTarget:self action:@selector(commentDiary:) forControlEvents:UIControlEventTouchUpInside];
            cell.bgView.frame = CGRectMake(3, 1.5, SCREEN_WIDTH-6, cell.headerImageView.frame.size.height+cell.contentLabel.frame.size.height+cell.imagesScrollView.frame.size.height+cell.praiseButton.frame.size.height+30);
            cell.bgView.backgroundColor = [UIColor whiteColor];
            cell.backgroundColor = [UIColor clearColor];
            return cell;
        }
    }
    return nil;
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    NSDictionary *groupDict = [tmpArray objectAtIndex:(tap.view.tag-333)/SectionTag];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [array objectAtIndex:(tap.view.tag-333)%SectionTag/RowTag];
    NSArray *imgs = [dict objectForKey:@"img"];
    int count = [imgs count];
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [NSString stringWithFormat:@"%@%@",IMAGEURL,imgs[i]];
        NSData *imgData = [FTWCache objectForKey:[url MD5Hash]];
        UIImage *img = [UIImage imageWithData:imgData];
        MJPhoto *photo = [[MJPhoto alloc] init];
//        photo.image = ((UIImageView *)[self.bgView viewWithTag:tap.view.tag]).image; // 图片路径
        photo.image = img;
        photo.srcImageView = (UIImageView *)[self.bgView viewWithTag:tap.view.tag]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }

    // 2.显示相册
    DDLOG(@"+++%d",((tap.view.tag-333)%SectionTag)%RowTag);
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = ((tap.view.tag-333)%SectionTag)%RowTag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}


-(void)praiseDiary:(UIButton *)button
{
    if ([Tools NetworkReachable])
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:button.tag/SectionTag-1];
        NSArray *array = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [array objectAtIndex:button.tag%SectionTag];
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":[dict objectForKey:@"_id"],
                                                                      @"c_id":classID,
                                                                      } API:LIKE_DIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"赞成功" toView:classZoneTableView];
                page = 0;
                monthStr = @"";
                NSString *title = [[button titleForState:UIControlStateNormal] substringFromIndex:2];
                DDLOG(@"like count==%d",[title integerValue]);
                [button setTitle:[NSString stringWithFormat:@"赞(%d)",[title integerValue]+1] forState:UIControlStateNormal];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
    
}

-(void)commentDiary:(UIButton *)button
{
    NSDictionary *groupDict = [tmpArray objectAtIndex:button.tag/SectionTag-1];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [array objectAtIndex:button.tag%SectionTag];
    
    DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
    dongtaiDetailViewController.dongtaiId = [dict objectForKey:@"_id"];
    dongtaiDetailViewController.classID = classID;
    [dongtaiDetailViewController showSelfViewController:[XDTabViewController sharedTabViewController]];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 1)
        {
            NewDiariesViewController *newDiary = [[NewDiariesViewController alloc] init];
            newDiary.classID = classID;
            newDiary.classZoneDelegate = self;
            if (fromMsg)
            {
                [newDiary showSelfViewController:self];
            }
            else
            {
                [newDiary showSelfViewController:[XDTabViewController sharedTabViewController]];
            }
        }
    }
    else
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
        NSArray *array = [groupDict objectForKey:@"diaries"];
        DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
        dongtaiDetailViewController.dongtaiId = [[array objectAtIndex:indexPath.row] objectForKey:@"_id"];
        dongtaiDetailViewController.classID = classID;
        [dongtaiDetailViewController showSelfViewController:[XDTabViewController sharedTabViewController]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark -

-(void)getMoreDongTai
{
    page++;
    [self getDongTaiList];
}

#pragma mark - aboutNetWork
-(void)getDongTaiList
{
    if (![self isInAccessTime])
    {
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"page":[NSNumber numberWithInt:page],
                                                                      @"month":[monthStr length]>0?monthStr:@""
                                                                      } API:GETDIARIESLIST];
        [request setCompletionBlock:^{
            
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"diaries list responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if (page == 0)
                {
                    [tmpArray removeAllObjects];
                    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETDIARIESLIST,[Tools user_id],classID];
                    NSString *key = [requestUrlStr MD5Hash];
                    [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                }
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"posts"] count]>0)
                {
                    NSArray *array = [[responseDict objectForKey:@"data"] objectForKey:@"posts"];
                    if ([array count] > 0)
                    {
                        classZoneTableView.hidden = NO;
                        noneDongTaiLabel.hidden = YES;
                        [self groupByTime:array];
                        _reloading = NO;
                        [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
                    }
                    page = [[[responseDict objectForKey:@"data"] objectForKey:@"page"] intValue];
                    monthStr = [NSString stringWithFormat:@"%@",[[responseDict objectForKey:@"data"] objectForKey:@"month"]];
                }
                else if (page == 0)
                {
                    noneDongTaiLabel.hidden = NO;
                }
                else
                {
                    [Tools showAlertView:@"没有更多动态了" delegateViewController:nil];
                }
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
            _reloading = NO;
            [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
        [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
    }
}

-(void)groupByTime:(NSArray *)array
{
    NSString *timeStr;
    int index = 0;
    if (page == 0)
    {
        [tmpArray removeAllObjects];
    }
    for (int i=index; i<[array count]; i++)
    {
        DDLOG(@"index =%d,%d",index,[array count]);
        NSDictionary *dict = [array objectAtIndex:i];
        CGFloat sec = [[[dict objectForKey:@"created"] objectForKey:@"sec"] floatValue];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MM月dd日"];
        NSDate *datetimeDate = [NSDate dateWithTimeIntervalSince1970:sec];
        timeStr = [dateFormatter stringFromDate:datetimeDate];
        
        NSMutableDictionary *groupDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        [groupDict setObject:timeStr forKey:@"date"];
        NSMutableArray *array2 = [[NSMutableArray alloc] initWithCapacity:0];
        [array2 addObject:dict];
        for (int j=i+1; j<[array count]; j++)
        {
            NSDictionary *dict2 = [array objectAtIndex:j];
            CGFloat sec2 = [[[dict2 objectForKey:@"created"] objectForKey:@"sec"] floatValue];
            NSDate *datetimeDate2 = [NSDate dateWithTimeIntervalSince1970:sec2];
            NSString * timeStr2 = [dateFormatter stringFromDate:datetimeDate2];
            if ([timeStr2 isEqualToString:timeStr])
            {
                [array2 addObject:dict2];
            }
            else
            {
                index = j;
                break;
            }
        }
        if ([array2 count] > 0)
        {
            if (![self haveThisTime:timeStr])
            {
                [groupDict setObject:array2 forKey:@"diaries"];
                [tmpArray addObject:groupDict];
            }
        }
    }
    [classZoneTableView reloadData];
}

-(BOOL)haveThisTime:(NSString *)timeStr
{
    for (int i=0; i<[tmpArray count]; i++)
    {
        NSDictionary *dict = [tmpArray objectAtIndex:i];
        if ([[dict objectForKey:@"date"] isEqualToString:timeStr])
        {
            return YES;
        }
    }
    return NO;
}

-(BOOL)isInAccessTime
{
    DDLOG(@"role=%@ accessTime=%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"role"],[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentVisiteTime]);
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"students"])
    {
        NSDate *date = [NSDate date];
        NSDateFormatter *fromatter = [[NSDateFormatter alloc] init];
        [fromatter setTimeStyle:NSDateFormatterShortStyle];
        NSString *timeStr = [fromatter stringFromDate:date];
        DDLOG(@"timeStr==%@",timeStr);
        NSString *hourStr;
        NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
        NSRange containsA = [formatStringForHours rangeOfString:@"a"];
        BOOL hasAMPM = containsA.location != NSNotFound;
        
        if (hasAMPM)
        {
            //12
            [fromatter setDateFormat:@"KK"];
            hourStr = [fromatter stringFromDate:date];
            if ([timeStr rangeOfString:@"下午"].length > 0 || [timeStr rangeOfString:@"PM"].length > 0)
            {
                NSString *timeLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentVisiteTime];
                if ([timeLimit integerValue] ==2)
                {
                    if ([hourStr integerValue] < 7)
                    {
                        [Tools showAlertView:[NSString stringWithFormat:@"请晚上7点以后在访问空间"] delegateViewController:nil];
                        return NO;
                    }
                }
                else if ([timeLimit integerValue] ==1)
                {
                    if ([hourStr integerValue] < 5)
                    {
                        [Tools showAlertView:[NSString stringWithFormat:@"请晚上5点以后在访问空间"] delegateViewController:nil];
                        return NO;
                    }
                }
            }
            else
            {
                NSString *timeLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentVisiteTime];
                if ([timeLimit integerValue] ==2)
                {
                    if ([hourStr integerValue] < 7+12)
                    {
                        [Tools showAlertView:[NSString stringWithFormat:@"请晚上7点以后在访问空间"] delegateViewController:nil];
                        return NO;
                    }
                }
                else if ([timeLimit integerValue] ==1)
                {
                    if ([hourStr integerValue] < 5+12)
                    {
                        [Tools showAlertView:[NSString stringWithFormat:@"请晚上5点以后在访问空间"] delegateViewController:nil];
                        return NO;
                    }
                }

            }
        }
        else
        {
            //24
            [fromatter setDateFormat:@"HH"];
            hourStr = [fromatter stringFromDate:date];
            
            NSString *timeLimit = [[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:StudentVisiteTime];
            if ([timeLimit integerValue] ==2)
            {
                if ([hourStr integerValue] < 19)
                {
                    [Tools showAlertView:[NSString stringWithFormat:@"请晚上19点以后在访问空间"] delegateViewController:nil];
                    return NO;
                }
            }
            else if ([timeLimit integerValue] ==1)
            {
                if ([hourStr integerValue] < 17)
                {
                    [Tools showAlertView:[NSString stringWithFormat:@"请晚上17点以后在访问空间"] delegateViewController:nil];
                    return NO;
                }
            }
        }
    }
    else if(([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"visitor"]) && ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:VisitorAccess] integerValue] == 1))
    {
        [Tools showAlertView:@"游客不可以查看班级空间！" delegateViewController:nil];
        return NO;
    }
    return YES;
}

-(void)getCacheData
{
    if (![self isInAccessTime])
    {
        return ;
    }
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETDIARIESLIST,[Tools user_id],classID];
    NSString *key = [requestUrlStr MD5Hash];
    NSData *cacheData = [FTWCache objectForKey:key];
    if ([cacheData length] > 0)
    {
        NSString *responseString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [Tools JSonFromString:responseString];
        if ([[responseDict objectForKey:@"code"] intValue]== 1)
        {
            if ([[[responseDict objectForKey:@"data"] objectForKey:@"posts"] count] > 0)
            {
                classZoneTableView.hidden = NO;
                noneDongTaiLabel.hidden = YES;
                NSArray *array = [[responseDict objectForKey:@"data"] objectForKey:@"posts"];
                [self groupByTime:array];
            }
            else
            {
                [self getDongTaiList];
            }
        }
    }
    else
    {
        [self getDongTaiList];
    }
}

-(void)getCLassInfoCache
{
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",CLASSINFO,[Tools user_id],classID];
    NSString *key = [requestUrlStr MD5Hash];
    NSData *cacheData = [FTWCache objectForKey:key];
    if ([cacheData length] > 0)
    {
        NSString *responseString = [[NSString alloc] initWithData:cacheData encoding:NSUTF8StringEncoding];
        NSDictionary *responseDict = [Tools JSonFromString:responseString];
        if ([[responseDict objectForKey:@"code"] intValue]== 1)
        {
            if(![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
            {
                className = [[responseDict objectForKey:@"data"] objectForKey:@"name"];
                schoolName = [[[responseDict objectForKey:@"data"] objectForKey:@"school"] objectForKey:@"name"];
            }
        }
        else
        {
            [Tools dealRequestError:responseDict fromViewController:self];
        }
    }
    else
    {
        [self getClassInfo];
    }
}

@end
