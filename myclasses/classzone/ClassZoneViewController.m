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
#import "FooterView.h"

#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"

#define ImageViewTag  9999
#define HeaderImageTag  7777
#define CellButtonTag   33333

#define SectionTag  10000
#define RowTag     100

#define ImageHeight  60.0f

#define ImageCountPerRow  4

@interface ClassZoneViewController ()<UITableViewDataSource,
UITableViewDelegate,
UIScrollViewDelegate,
NewDongtaiDelegate,
ClassZoneDelegate,
EGORefreshTableHeaderDelegate,
DongTaiDetailAddCommentDelegate,
EGORefreshTableDelegate,
UIActionSheetDelegate>
{
    UITableView *classZoneTableView;
    NSMutableArray *DongTaiArray;
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
    FooterView *footerView;
    BOOL _reloading;
    
    UIButton *addButton;
    
    OperatDB *db;
    
    NSDictionary *waitTransmitDict;
    
    NSString *className;
    NSString *classID;
    NSString *schoolID;
    NSString *schoolName;
    NSString *classTopImage;
}
@end

@implementation ClassZoneViewController
@synthesize fromClasses,fromMsg,refreshDel;
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
    
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    className = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
    schoolID = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolid"];
    schoolName = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
    classTopImage = [[NSUserDefaults standardUserDefaults] objectForKey:@"classtopimage"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeClassInfo) name:@"changeClassInfo" object:nil];
    
    self.titleLabel.text = @"班级空间";
    monthStr = @"";
    
    db = [[OperatDB alloc] init];
    
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    page = 0;
    haveNew = NO;
    _reloading = NO;
    
    bgImageViewHeight = 150.0f;
    uncheckedCount = 0;
    
    self.stateView.hidden = YES;
    
    tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    DongTaiArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    addButton.hidden = YES;
    [addButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    [addButton setTitle:@"发布" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addDongTaiClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:addButton];
    
    noneDongTaiLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, bgImageViewHeight+76, SCREEN_WIDTH-40, 60)];
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
    if (fromClasses)
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
    
    [classZoneTableView addSubview:noneDongTaiLabel];
    
    if (!fromClasses)
    {
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
    
    if ([Tools NetworkReachable])
    {
        addButton.hidden = YES;
        [self getCacheSetting];
        [self getCLassSettings];
    }
    else
    {
        [self getCacheSetting];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.refreshDel = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeClassInfo
{
    [classZoneTableView reloadData];
}

-(void)unShowSelfViewController
{
    if (fromClasses)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [[XDTabViewController sharedTabViewController] dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - headerdelegate
-(void)refreshAction
{
    [self getDongTaiList];
}

#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    if (fromClasses)
    {
        [Tools showAlertView:@"您还没有进入这个班级，快去申请加入吧！" delegateViewController:self];
        return ;
    }
    page =0;
    monthStr = @"";
    [self getDongTaiList];
}

-(void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    if (fromClasses)
    {
        [Tools showAlertView:@"您还没有进入这个班级，快去申请加入吧！" delegateViewController:self];
        return ;
    }
    [self getMoreDongTai];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading;
}

-(BOOL)egoRefreshTableDataSourceIsLoading:(UIView *)view
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
    if (scrollView.contentOffset.y+(scrollView.frame.size.height) > scrollView.contentSize.height+65)
    {
        [footerView egoRefreshScrollViewDidScroll:classZoneTableView];
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:classZoneTableView];
    [footerView egoRefreshScrollViewDidEndDragging:classZoneTableView];
}

#pragma mark - classzoneDelegate
-(void)haveAddDonfTai:(BOOL)add
{
    if (add)
    {
        haveNew = YES;
        page = 0;
        monthStr = @"";
        [self getDongTaiList];
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
    [self.navigationController pushViewController:chooseClassInfo animated:YES];
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
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:addDongTaiViewController animated:YES];
//    [addDongTaiViewController showSelfViewController:[XDTabViewController sharedTabViewController]];
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
    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETSETTING,[Tools user_id],classID];
    NSString *key = [requestUrlStr MD5Hash];
    NSData *data = [FTWCache objectForKey:key];
    NSString *settingCacheString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *settingCacheDict = [Tools JSonFromString:settingCacheString];
    if ([settingCacheDict count] > 0)
    {
        [self dealClassSetting:settingCacheDict];
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
    
    if ([self isInAccessTime])
    {
        addButton.hidden = NO;
        if ([Tools NetworkReachable])
        {
            [self getCacheData];
            [self getDongTaiList];
        }
        else
        {
            [self getCacheData];
        }
    }
    else
    {
        addButton.hidden = YES;
    }
    
    if (fromClasses)
    {
        addButton.hidden = YES;
    }
}

#pragma mark - tableview
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (fromClasses)
    {
        return [tmpArray count]>0?2:1;
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
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, SCREEN_WIDTH-10, 45)];
        headerLabel.text = [NSString stringWithFormat:@"  %@",[dict objectForKey:@"date"]];
        headerLabel.textColor = TITLE_COLOR;
        headerLabel.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
        headerLabel.font = [UIFont systemFontOfSize:20];
        return headerLabel;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section > 0)
    {
        return 40;
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
        else if(([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:VisitorAccess] integerValue] == 1))
        {
            NSDictionary *dict = [tmpArray objectAtIndex:section-1];
            NSArray *array = [dict objectForKey:@"diaries"];
            return [array count];
        }
    }
    else
    {
        if (section >0)
        {
            NSDictionary *dict = [tmpArray objectAtIndex:section-1];
            NSArray *array = [dict objectForKey:@"diaries"];
            return [array count];
        }
        else
            return 2;
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat he=0;
    if (SYSVERSION>=7)
    {
        he = 5;
    }
    if (indexPath.section >0)
    {
        if (indexPath.section < [tmpArray count])
        {
            NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
            NSArray *array = [groupDict objectForKey:@"diaries"];
            CGFloat imageViewHeight = ImageHeight;
            NSDictionary *dict = [array objectAtIndex:indexPath.row];
            NSString *content = [dict objectForKey:@"content"];
            NSArray *imgsArray = [[dict objectForKey:@"img"] count]>0?[dict objectForKey:@"img"]:nil;
            NSInteger imageCount = [imgsArray count];
            NSInteger row = 0;
            if (imageCount % ImageCountPerRow > 0)
            {
                row = (imageCount/ImageCountPerRow+1) > 3 ? 3:(imageCount / ImageCountPerRow + 1);
            }
            else
            {
                row = (imageCount/ImageCountPerRow) > 3 ? 3:(imageCount / ImageCountPerRow);
            }
           
            CGFloat imgsHeight = row * (imageViewHeight+5);
            CGFloat contentHtight = [content length] > 0 ? (45+he):5;
            return 60+imgsHeight+contentHtight+60;
        }
        else
        {
            NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
            NSArray *array = [groupDict objectForKey:@"diaries"];
            if (indexPath.row < [array count])
            {
                //                CGFloat imageWidth = 60;
                CGFloat imageViewHeight = ImageHeight;
                NSDictionary *dict = [array objectAtIndex:indexPath.row];
                NSString *content = [dict objectForKey:@"content"];
                NSArray *imgsArray = [[dict objectForKey:@"img"] count]>0?[dict objectForKey:@"img"]:nil;
                NSInteger imageCount = [imgsArray count];
                NSInteger row = 0;
                if (imageCount % ImageCountPerRow > 0)
                {
                    row = (imageCount/ImageCountPerRow+1) > 3 ? 3:(imageCount / ImageCountPerRow + 1);
                }
                else
                {
                    row = (imageCount/ImageCountPerRow) > 3 ? 3:(imageCount / ImageCountPerRow);
                }

                CGFloat imgsHeight = row * (imageViewHeight+5);
                CGFloat contentHtight = [content length]>0?(45+he):5;
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
            cell.headerImageView.hidden = NO;
            cell.nameLabel.hidden = NO;
            cell.locationLabel.hidden = NO;
            
            cell.headerImageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, bgImageViewHeight);
            cell.headerImageView.layer.contentsGravity = kCAGravityResizeAspectFill;
            cell.headerImageView.clipsToBounds = YES;
            
            NSString *topurlstring = [[NSUserDefaults standardUserDefaults] objectForKey:@"classkbimage"];
            if ([topurlstring length] >10)
            {
                [Tools fillImageView:cell.headerImageView withImageFromURL:topurlstring andDefault:@"toppic.jpg"];
            }
            else
            {
                UIImage *topImage = [UIImage imageNamed:@"toppic.jpg"];
                cell.headerImageView.image = topImage;
            }
            cell.nameLabel.frame = CGRectMake(SCREEN_WIDTH-200, bgImageViewHeight-50, 190, 20);
            cell.locationLabel.frame = CGRectMake(SCREEN_WIDTH-200, bgImageViewHeight-30, 190, 20);
            cell.locationLabel.textAlignment = NSTextAlignmentCenter;
            cell.nameLabel.textAlignment = NSTextAlignmentCenter;
            cell.locationLabel.font = [UIFont systemFontOfSize:16];
            cell.nameLabel.font = [UIFont boldSystemFontOfSize:16];
            cell.nameLabel.textColor = [UIColor whiteColor];
            cell.locationLabel.textColor = [UIColor whiteColor];
            cell.nameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"classname"];
            if(SYSVERSION < 7)
            {
                cell.nameLabel.backgroundColor = [UIColor clearColor];
                cell.locationLabel.backgroundColor = [UIColor clearColor];
            }
            cell.locationLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"schoolname"];
            cell.backgroundColor = [UIColor clearColor];
            if (fromClasses)
            {
                cell.praiseButton.hidden = NO;
                cell.praiseButton.frame = CGRectMake(35, bgImageViewHeight+21, SCREEN_WIDTH-70, 35);
                [cell.praiseButton setTitle:@"申请加入" forState:UIControlStateNormal];
                [cell.praiseButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)] forState:UIControlStateNormal];
                [cell.praiseButton addTarget:self action:@selector(applyJoin) forControlEvents:UIControlEventTouchUpInside];
                cell.praiseButton.titleLabel.font = [UIFont systemFontOfSize:18];
                [cell.praiseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                cell.bgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, bgImageViewHeight+72.5);
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
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
            if (uncheckedCount > 0)
            {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            else
            {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            return cell;
        }
    }
    else if(indexPath.section > 0)
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
            
            NSString *nameStr;
            NSArray *classmen = [db findSetWithDictionary:@{@"uid":[[dict objectForKey:@"by"] objectForKey:@"_id"],@"classid":classID} andTableName:CLASSMEMBERTABLE];
            if ([classmen count]>0)
            {
                NSDictionary *memdict = [classmen firstObject];
                if (![[memdict objectForKey:@"title"] isEqual:[NSNull null]])
                {
                    if ([[memdict objectForKey:@"title"] length] >0)
                    {
                        nameStr = [NSString stringWithFormat:@"%@（%@）",name,[memdict objectForKey:@"title"]];
                    }
                    else
                        nameStr = name;
                }
                else
                {
                    nameStr = name;
                }
            }
            else
            {
                nameStr = name;
            }
            
            cell.headerImageView.hidden = NO;
            cell.nameLabel.hidden = NO;
            cell.timeLabel.hidden = NO;
            cell.locationLabel.hidden = NO;
            cell.praiseButton.hidden = NO;
            cell.praiseImageView.hidden = NO;
            cell.commentImageView.hidden = NO;
            cell.commentButton.hidden = NO;
            cell.transmitButton.hidden = NO;
            
            cell.nameLabel.frame = CGRectMake(60, 5, [nameStr length]*25>170?170:([nameStr length]*18), 30);
            cell.nameLabel.text = nameStr;
            cell.nameLabel.font = [UIFont systemFontOfSize:15];
            cell.nameLabel.textColor = LIGHT_BLUE_COLOR;
            cell.timeLabel.frame = CGRectMake(cell.nameLabel.frame.size.width+cell.nameLabel.frame.origin.x, 5, SCREEN_WIDTH-cell.nameLabel.frame.origin.x-cell.nameLabel.frame.size.width-20, 30);
            cell.timeLabel.textAlignment = NSTextAlignmentRight;
            cell.timeLabel.numberOfLines = 2;
            cell.timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
            cell.timeLabel.text = [Tools showTime:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]];
            cell.headerImageView.layer.cornerRadius = cell.headerImageView.frame.size.width/2;
            cell.headerImageView.clipsToBounds = YES;
            cell.headerImageView.backgroundColor = [UIColor clearColor];
            [Tools fillImageView:cell.headerImageView withImageFromURL:[[dict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERBG];
            cell.locationLabel.frame = CGRectMake(60, cell.nameLabel.frame.origin.y+cell.nameLabel.frame.size.height, SCREEN_WIDTH-80, 20);
            cell.locationLabel.text = [dict objectForKey:@"add"];
            
            cell.contentLabel.hidden = YES;
            for(UIView *v in cell.imagesView.subviews)
            {
                if ([v isKindOfClass:[UIImageView class]])
                {
                    [v removeFromSuperview];
                }
            }
            if (![[dict objectForKey:@"content"] length] <=0)
            {
                CGFloat he = 0;
                if (SYSVERSION >= 7)
                {
                    he = 5;
                }
                //有文字
                cell.contentLabel.hidden = NO;
                cell.contentLabel.editable = NO;
                cell.contentLabel.textColor = [UIColor blackColor];
                if ([[dict objectForKey:@"content"] length] > 40)
                {
                    cell.contentLabel.text  = [NSString stringWithFormat:@"%@...",[[dict objectForKey:@"content"] substringToIndex:37]];
                }
                else
                {
                    cell.contentLabel.text = [dict objectForKey:@"content"];
                }
                cell.contentLabel.frame = CGRectMake(10, 55, SCREEN_WIDTH-20, 45);
            }
            else
            {
                cell.contentLabel.frame = CGRectMake(10, 60, 0, 0);
            }
            CGFloat imageViewHeight = ImageHeight;
            CGFloat imageViewWidth = ImageHeight;
            if ([[dict objectForKey:@"img"] count] > 0)
            {
                //有图片
                
                NSArray *imgsArray = [dict objectForKey:@"img"];
                NSInteger imageCount = [imgsArray count];
                if (imageCount == -1)
                {
                    cell.imagesView.frame = CGRectMake((SCREEN_WIDTH-ImageHeight*ImageCountPerRow)/2,
                                                       cell.contentLabel.frame.size.height +
                                                       cell.contentLabel.frame.origin.y+7,
                                                       100, 100);
                    UIImageView *imageView = [[UIImageView alloc] init];
                    imageView.frame = CGRectMake(0, 0, 100, 100);
                    imageView.userInteractionEnabled = YES;
                    imageView.tag = (indexPath.section-1)*SectionTag+indexPath.row*RowTag+333;
                    
                    imageView.userInteractionEnabled = YES;
                    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                    
                    // 内容模式
                    imageView.clipsToBounds = YES;
                    imageView.contentMode = UIViewContentModeScaleAspectFill;
                    [Tools fillImageView:imageView withImageFromURL:[imgsArray firstObject] andDefault:@"3100"];
                    [cell.imagesView addSubview:imageView];
                }
                else
                {
                    NSInteger row = 0;
                    if (imageCount % ImageCountPerRow > 0)
                    {
                        row = (imageCount/ImageCountPerRow+1) > 3 ? 3:(imageCount / ImageCountPerRow + 1);
                    }
                    else
                    {
                        row = (imageCount/ImageCountPerRow) > 3 ? 3:(imageCount / ImageCountPerRow);
                    }
                    cell.imagesView.frame = CGRectMake((SCREEN_WIDTH-ImageHeight*ImageCountPerRow)/2,
                                                       cell.contentLabel.frame.size.height +
                                                       cell.contentLabel.frame.origin.y+7,
                                                       SCREEN_WIDTH-20, (imageViewHeight+5) * row);
                    
                    for (int i=0; i<[imgsArray count]; ++i)
                    {
                        UIImageView *imageView = [[UIImageView alloc] init];
                        imageView.frame = CGRectMake((i%(NSInteger)ImageCountPerRow)*(imageViewWidth+5), (imageViewWidth+5)*(i/(NSInteger)ImageCountPerRow), imageViewWidth, imageViewHeight);
                        imageView.userInteractionEnabled = YES;
                        imageView.tag = (indexPath.section-1)*SectionTag+indexPath.row*RowTag+i+333;
                        
                        imageView.userInteractionEnabled = YES;
                        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                        
                        // 内容模式
                        imageView.clipsToBounds = YES;
                        imageView.contentMode = UIViewContentModeScaleAspectFill;
                        [Tools fillImageView:imageView withImageFromURL:[imgsArray objectAtIndex:i] andDefault:@"3100"];
                        [cell.imagesView addSubview:imageView];
                    }

                }
            }
            else
            {
                cell.imagesView.frame = CGRectMake(5, cell.contentLabel.frame.size.height+cell.contentLabel.frame.origin.y, SCREEN_WIDTH-10, 0);
            }
            
            CGFloat cellHeight = cell.headerImageView.frame.size.height+cell.contentLabel.frame.size.height+cell.imagesView.frame.size.height+18;
            
            CGFloat he = 0;
//            if (SYSVERSION >= 7.0)
            {
                he = 5;
            }
            
            
            cell.transmitImageView.hidden = NO;
            
            cell.transmitButton.frame = CGRectMake(0, cellHeight+13, (SCREEN_WIDTH-0)/3, 30);
            [cell.transmitButton setTitle:@"转发" forState:UIControlStateNormal];
            cell.transmitButton.tag = indexPath.section*SectionTag+indexPath.row;
            [cell.transmitButton addTarget:self action:@selector(transmitDiary:) forControlEvents:UIControlEventTouchUpInside];
            cell.transmitImageView.frame = CGRectMake((SCREEN_WIDTH-20)/4-55, cell.transmitButton.frame.size.height+cell.transmitButton.frame.origin.y-22, 13, 13);
            
            
            [cell.praiseButton setTitle:[NSString stringWithFormat:@"赞(%d)",[[dict objectForKey:@"likes_num"] integerValue]] forState:UIControlStateNormal];
            [cell.praiseButton addTarget:self action:@selector(praiseDiary:) forControlEvents:UIControlEventTouchUpInside];
            cell.praiseButton.tag = indexPath.section*SectionTag+indexPath.row;
            cell.praiseButton.frame = CGRectMake((SCREEN_WIDTH-0)/3, cellHeight+13, (SCREEN_WIDTH-0)/3, 30);
            
            cell.praiseImageView.frame = CGRectMake((SCREEN_WIDTH-20)*2/4-20, cell.praiseButton.frame.size.height+cell.praiseButton.frame.origin.y-19, 13, 13);
            
            [cell.commentButton setTitle:[NSString stringWithFormat:@"评论(%d)",[[dict objectForKey:@"comments_num"] integerValue]] forState:UIControlStateNormal];
            cell.commentButton.frame = CGRectMake((SCREEN_WIDTH-0)/3*2, cellHeight+13, (SCREEN_WIDTH-0)/3, 30);
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.commentButton.tag = indexPath.section*SectionTag+indexPath.row;
            [cell.commentButton addTarget:self action:@selector(commentDiary:) forControlEvents:UIControlEventTouchUpInside];
            cell.commentImageView.frame = CGRectMake((SCREEN_WIDTH-20)*3/4, cell.commentButton.frame.size.height+cell.commentButton.frame.origin.y-20, 13, 13);
            
            cell.bgView.frame = CGRectMake(3, 1.5, SCREEN_WIDTH-6,
                                           cell.praiseButton.frame.size.height+
                                           cell.praiseButton.frame.origin.y);
            cell.bgView.backgroundColor = [UIColor whiteColor];
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
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
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url];
        photo.srcImageView = (UIImageView *)[self.bgView viewWithTag:tap.view.tag]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }

    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = ((tap.view.tag-333)%SectionTag)%RowTag; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}


-(void)transmitDiary:(UIButton *)button
{
    NSDictionary *groupDict = [tmpArray objectAtIndex:button.tag/SectionTag-1];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    waitTransmitDict = [array objectAtIndex:button.tag%SectionTag];
    [self shareAPP:nil];
}

#pragma mark - shareAPP
-(void)shareAPP:(UIButton *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"转发到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博",@"QQ空间",@"腾讯微博",@"QQ好友",@"微信朋友圈",@"人人网", nil];
    [actionSheet showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DDLOG(@"waittransdict %@",waitTransmitDict);
    switch (buttonIndex)
    {
        case 0:
            [self shareToSinaWeiboClickHandler:nil];
            break;
        case 1:
            [self shareToQQSpaceClickHandler:nil];
            break;
        case 2:
            [self shareToTencentWeiboClickHandler:nil];
            break;
        case 3:
            [self shareToQQFriendClickHandler:nil];
            break;
        case 4:
            [self shareToWeixinTimelineClickHandler:nil];
            break;
        case 5:
            [self shareToRenRenClickHandler:nil];
            break;
        default:
            break;
    }
}

/**
 *	@brief	分享到QQ空间
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToQQSpaceClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransmitDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    
    //创建分享内容
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:content
                                            mediaType:SSPublishContentMediaTypeText];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeQQSpace
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享到新浪微博
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToSinaWeiboClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransmitDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }

    //创建分享内容[ShareSDK imageWithUrl:imagePath]
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?content:ShareContent
                                            mediaType:SSPublishContentMediaTypeNews];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    [container setIPhoneContainerWithViewController:self];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeSinaWeibo
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享到腾讯微博
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToTencentWeiboClickHandler:(UIButton *)sender
{
    
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransmitDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?content:ShareContent
                                            mediaType:SSPublishContentMediaTypeText];
    
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeTencentWeibo
                          container:container
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@") , [error errorCode], [error errorDescription]);
                                 }
                             }];
}
/**
 *	@brief	分享给QQ好友
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToQQFriendClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransmitDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:content
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:content
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeQQ
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享给微信朋友圈
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToWeixinTimelineClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransmitDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?content:ShareContent
                                            mediaType:SSPublishContentMediaTypeNews];
    
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeWeixiTimeline
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:[NSArray defaultOneKeyShareList]
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_FAI", @"发布失败!error code == %d, error code == %@"), [error errorCode], [error errorDescription]);
                                 }
                             }];
}

/**
 *	@brief	分享到人人网
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToRenRenClickHandler:(UIButton *)sender
{
    NSString *content;
    if ([waitTransmitDict objectForKey:@"content"])
    {
        if ([[waitTransmitDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransmitDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransmitDict objectForKey:@"img"])
    {
        if ([[waitTransmitDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransmitDict objectForKey:@"img"] firstObject]];
        }
    }
    //创建分享内容
    id<ISSContent> publishContent = [ShareSDK content:[content length]>0?content:ShareContent
                                       defaultContent:@""
                                                image:[ShareSDK imageWithUrl:imagePath]
                                                title:@"班家"
                                                  url:ShareUrl
                                          description:[content length]>0?content:ShareContent
                                            mediaType:SSPublishContentMediaTypeText];
    
    //    //创建弹出菜单容器
    //    id<ISSContainer> container = [ShareSDK container];
    //    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    //
    id<ISSAuthOptions> authOptions = [ShareSDK authOptionsWithAutoAuth:YES
                                                         allowCallback:YES
                                                         authViewStyle:SSAuthViewStyleFullScreenPopup
                                                          viewDelegate:nil
                                               authManagerViewDelegate:nil];
    
    //在授权页面中添加关注官方微博
    [authOptions setFollowAccounts:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeSinaWeibo),
                                    [ShareSDK userFieldWithType:SSUserFieldTypeName value:@"ShareSDK"],
                                    SHARE_TYPE_NUMBER(ShareTypeTencentWeibo),
                                    nil]];
    
    //显示分享菜单
    [ShareSDK showShareViewWithType:ShareTypeRenren
                          container:nil
                            content:publishContent
                      statusBarTips:YES
                        authOptions:authOptions
                       shareOptions:[ShareSDK defaultShareOptionsWithTitle:nil
                                                           oneKeyShareList:nil
                                                            qqButtonHidden:NO
                                                     wxSessionButtonHidden:NO
                                                    wxTimelineButtonHidden:NO
                                                      showKeyboardOnAppear:NO
                                                         shareViewDelegate:nil
                                                       friendsViewDelegate:nil
                                                     picViewerViewDelegate:nil]
                             result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                 
                                 if (state == SSPublishContentStateSuccess)
                                 {
                                     NSLog(NSLocalizedString(@"TEXT_SHARE_SUC", @"发表成功"));
                                 }
                                 else if (state == SSPublishContentStateFail)
                                 {
                                     NSLog( @"发布失败!error code == %d, error code == %@", [error errorCode], [error errorDescription]);
                                 }
                             }];
}



-(void)praiseDiary:(UIButton *)button
{
    if (fromClasses)
    {
        [Tools showTips:@"游客不能赞班级日志,赶快加入吧!" toView:self.bgView];
        return ;
    }
    
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
    dongtaiDetailViewController.addComDel = self;
    [[XDTabViewController sharedTabViewController].navigationController pushViewController:dongtaiDetailViewController animated:YES];
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
            [[XDTabViewController sharedTabViewController].navigationController pushViewController:newDiary animated:YES];
        }
    }
    else
    {
        NSDictionary *groupDict = [tmpArray objectAtIndex:indexPath.section-1];
        NSArray *array = [groupDict objectForKey:@"diaries"];
        DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
        dongtaiDetailViewController.dongtaiId = [[array objectAtIndex:indexPath.row] objectForKey:@"_id"];
        dongtaiDetailViewController.addComDel = self;
        [[XDTabViewController sharedTabViewController].navigationController pushViewController:dongtaiDetailViewController animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - addCommetnDel
-(void)addComment:(BOOL)add
{
    if (add)
    {
        page = 0;
        monthStr = @"";
        [self getDongTaiList];
    }
}

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
                    [DongTaiArray removeAllObjects];
                    NSString *requestUrlStr = [NSString stringWithFormat:@"%@=%@=%@",GETDIARIESLIST,[Tools user_id],classID];
                    NSString *key = [requestUrlStr MD5Hash];
                    [FTWCache setObject:[responseString dataUsingEncoding:NSUTF8StringEncoding] forKey:key];
                    
                    if ([self.refreshDel respondsToSelector:@selector(reFreshClassZone:)])
                    {
                        [self.refreshDel reFreshClassZone:YES];
                    }
                }
                if ([[[responseDict objectForKey:@"data"] objectForKey:@"posts"] count]>0)
                {
                    NSArray *array = [[responseDict objectForKey:@"data"] objectForKey:@"posts"];
                    if ([array count] > 0)
                    {
                        classZoneTableView.hidden = NO;
                        [DongTaiArray addObjectsFromArray:array];
                        [self groupByTime:DongTaiArray];
                       
                    }
                    page = [[[responseDict objectForKey:@"data"] objectForKey:@"page"] intValue];
                    monthStr = [NSString stringWithFormat:@"%@",[[responseDict objectForKey:@"data"] objectForKey:@"month"]];
                }
                else if (page==0 && [monthStr length]==0 )
                {
                    noneDongTaiLabel.hidden = NO;
                }
                else if([monthStr length]>0 && page>0)
                {
                    [Tools showAlertView:@"没有更多动态了" delegateViewController:nil];
                }
                _reloading = NO;
                [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
                [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
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
        _reloading = NO;
        [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
        [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:classZoneTableView];
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)groupByTime:(NSArray *)array
{
    NSString *timeStr;
    int index = 0;
    [tmpArray removeAllObjects];
    for (int i=index; i<[array count]; i++)
    {
        NSDictionary *dict = [array objectAtIndex:i];
        if ([dict isEqual:[NSNull null]])
        {
            continue ;
        }
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
            if ([dict2 isEqual:[NSNull null]])
            {
                continue;
            }
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
    if ([tmpArray count]>0)
    {
        noneDongTaiLabel.hidden = YES;
    }
    else
    {
        noneDongTaiLabel.hidden = NO;
    }
    [classZoneTableView reloadData];
    if (footerView)
    {
        [footerView removeFromSuperview];
        footerView = [[FooterView alloc] initWithScrollView:classZoneTableView];
        footerView.delegate = self;
    }
    else
    {
        footerView = [[FooterView alloc] initWithScrollView:classZoneTableView];
        footerView.delegate = self;
    }
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
                else if ([timeLimit integerValue] ==0)
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
                else if ([timeLimit integerValue] ==0)
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
            else if ([timeLimit integerValue] ==0)
            {
                if ([hourStr integerValue] < 17)
                {
                    [Tools showAlertView:[NSString stringWithFormat:@"请晚上17点以后在访问空间"] delegateViewController:nil];
                    return NO;
                }
            }
        }
    }
    else if(([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"visitor"]) && ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:VisitorAccess] integerValue] == 0))
    {
        [Tools showAlertView:@"游客不可以查看班级空间！" delegateViewController:nil];
        return NO;
    }
    return YES;
}

-(void)getCacheData
{
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
                NSArray *array = [[responseDict objectForKey:@"data"] objectForKey:@"posts"];
                [self groupByTime:array];
            }
            else
            {
                noneDongTaiLabel.hidden = NO;
            }
        }
    }
    else
    {
        [self getDongTaiList];
    }
}
@end
