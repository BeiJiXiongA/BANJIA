//
//  HomeViewController.m
//  BANJIA
//
//  Created by TeekerZW on 14-5-31.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import "HomeViewController.h"
#import "MMProgressHUD.h"
#import "MMProgressHUDOverlayView.h"
#import "KKNavigationController.h"
#import "KKNavigationController+JDSideMenu.h"
#import "UINavigationController+JDSideMenu.h"
#import "PopView.h"
#import "DemoVIew.h"
#import "NotificationCell.h"
#import "AddDongTaiViewController.h"
#import "AddNotificationViewController.h"
#import "NotificationDetailViewController.h"
#import "TrendsCell.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "InputTableBar.h"

#define ImageViewTag  9999
#define HeaderImageTag  7777
#define CellButtonTag   33333

#define SectionTag  999999
#define RowTag     100

#define ImageHeight  60.0f

#define ImageCountPerRow  4

@interface HomeViewController ()<
UITableViewDataSource,
UITableViewDelegate,
EGORefreshTableHeaderDelegate,
EGORefreshTableDelegate,
UIActionSheetDelegate,
ReturnFunctionDelegate>
{
    NSString *page;
    
    CGFloat commentHeight;
    
    BOOL addOpen;
    PopView *addView;
    UIButton *addNoticeButton;
    UIButton *addDiaryButton;
    NSDictionary *waitTransmitDict;
    DemoVIew *demoView;
    
    CGFloat tmpheight;
    CGSize inputSize;
    CGFloat faceViewHeight;
    
    
    UITapGestureRecognizer *tapTgr;
    
    UITableView *classTableView;
    
    UIImageView *navImageView;
    
    NSMutableArray *noticeArray;
    NSMutableArray *diariesArray;
    NSMutableArray *groupDiaries;
    OperatDB *db;
    
    EGORefreshTableHeaderView *egoheaderView;
    FooterView *footerView;
    
    BOOL _reloading;
    
    InputTableBar *inputTabBar;
    
    UITapGestureRecognizer *backTgr;
}
@end

@implementation HomeViewController

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
    
    page = @"0";
    
    commentHeight = 0;
    tmpheight = 0;
    
    db = [[OperatDB alloc]init];
    
    self.backButton.hidden = YES;
    self.returnImageView.hidden = YES;
    self.titleLabel.text = @"首页";
    self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - [self.titleLabel.text length]*19)/2, self.titleLabel.frame.origin.y, [self.titleLabel.text length]*19, 30);
    self.titleLabel.hidden = YES;
    
    addOpen = NO;
    
    backTgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backInput)];
    
    noticeArray = [[NSMutableArray alloc] initWithCapacity:0];
    diariesArray = [[NSMutableArray alloc] initWithCapacity:0];
    groupDiaries = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *navButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navButton setTitle:@"首页" forState:UIControlStateNormal];
    navButton.frame = CGRectMake((SCREEN_WIDTH - [self.titleLabel.text length]*20)/2, self.titleLabel.frame.origin.y, [self.titleLabel.text length]*20, 30);
    navButton.titleLabel.font = [UIFont systemFontOfSize:20];
    [navButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [self.navigationBarView addSubview:navButton];
    
    UIButton *moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(5, 4, 42, 34);
    [moreButton setImage:[UIImage imageNamed:@"icon_list"] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreOpen) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.backgroundColor = [UIColor clearColor];
    [addButton setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [addButton addTarget:self action:@selector(addButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:addButton];
    
    classTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    classTableView.delegate = self;
    classTableView.dataSource = self;
    classTableView.showsVerticalScrollIndicator = NO;
    classTableView.backgroundColor = [UIColor clearColor];
    classTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:classTableView];
    if ([classTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [classTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    egoheaderView = [[EGORefreshTableHeaderView alloc] initWithScrollView:classTableView orientation:EGOPullOrientationDown];
    egoheaderView.delegate = self;
    
    footerView = [[FooterView alloc] initWithScrollView:classTableView];
    footerView.delegate = self;
    
    addView = [[PopView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-125, UI_NAVIGATION_BAR_HEIGHT-10, 120, 85)];
    addView.point = CGPointMake(90, 0);
    addView.wid = 2;
    addView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:addView];
    
    
    addNoticeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addNoticeButton.frame = CGRectMake(35, 15, 80, 30);
    addNoticeButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    addNoticeButton.alpha = 0;
    [addNoticeButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [addNoticeButton setTitle:@"添加通知" forState:UIControlStateNormal];
    [addView addSubview:addNoticeButton];
    [addNoticeButton addTarget:self action:@selector(addNotice) forControlEvents:UIControlEventTouchUpInside];
    
    addDiaryButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addDiaryButton.frame = CGRectMake(35, 50, 80, 30);
    addDiaryButton.alpha = 0;
    [addDiaryButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    addDiaryButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    [addDiaryButton setTitle:@"添加空间" forState:UIControlStateNormal];
    [addView addSubview:addDiaryButton];
    [addDiaryButton addTarget:self action:@selector(addDongtai) forControlEvents:UIControlEventTouchUpInside];
    
    
    addView.alpha = 0;
    addNoticeButton.alpha = 0;
    addDiaryButton.alpha = 0;
    
    [self getHomeData];
    
    
    inputTabBar = [[InputTableBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 40)];
    inputTabBar.backgroundColor = [UIColor grayColor];
    inputTabBar.returnFunDel = self;
    [self.bgView addSubview:inputTabBar];
    inputSize = CGSizeMake(250, 30);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    inputTabBar.returnFunDel = nil;
}

-(void)getHomeData
{
    if ([Tools NetworkReachable])
    {
        NSDictionary *paraDict;
        if ([page intValue] == 0)
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token]};
        }
        else
        {
            paraDict = @{@"u_id":[Tools user_id],
                         @"token":[Tools client_token],
                         @"page":page};
        }
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:paraDict
                                                                API:HOMEDATA];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"home responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([page integerValue] == 0)
                {
                    [noticeArray removeAllObjects];
                    [diariesArray removeAllObjects];
                }
                [noticeArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"notices"]];
                [diariesArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"diaries"]];
                [self groupByTime:diariesArray];
//                [classTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
            _reloading = NO;
            [egoheaderView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
            [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
            if ([page integerValue] > 0)
            {
                if (footerView)
                {
                    [footerView removeFromSuperview];
                    footerView = [[FooterView alloc] initWithScrollView:classTableView];
                    footerView.delegate = self;
                }
                else
                {
                    footerView = [[FooterView alloc] initWithScrollView:classTableView];
                    footerView.delegate = self;
                }
                _reloading = NO;
                [footerView egoRefreshScrollViewDataSourceDidFinishedLoading:classTableView];
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

#pragma mark - inputtabbardel
-(void)myReturnFunction
{
//    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"])
//    {
//        if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentComment] integerValue] == 0)
//        {
//            [Tools showAlertView:@"本班日志不允许家长发表评论" delegateViewController:nil];
//            return ;
//        }
//        else
//        {
////            [self commentdiary];
//        }
//    }
//    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"opt"] objectForKey:UserSendComment] == 0)
//    {
//        [Tools showAlertView:@"您没有评论日志的权限" delegateViewController:nil];
//        return ;
//    }
//    else
//    {
////        [self commentdiary];
//    }
    DDLOG(@"comment content in home %@",inputTabBar.inputTextView.text);
    inputSize = CGSizeMake(250, 30);
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10, SCREEN_WIDTH, inputSize.height+10);
        [self backInput];
    }];
}


#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    page = @"0";
    [self getHomeData];
}

-(void)egoRefreshTableDidTriggerRefresh:(EGORefreshPos)aRefreshPos
{
    NSInteger pageNum = [page integerValue];
    page = [NSString stringWithFormat:@"%d",++pageNum];
    [self getHomeData];
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
    [egoheaderView egoRefreshScrollViewDidScroll:classTableView];
    if (scrollView.contentOffset.y+(scrollView.frame.size.height) > scrollView.contentSize.height+65)
    {
        [footerView egoRefreshScrollViewDidScroll:classTableView];
    }
    [self backInput];
    [inputTabBar backKeyBoard];
}
-(void)backInput
{
    [classTableView removeGestureRecognizer:backTgr];
    [UIView animateWithDuration:0.2 animations:^{
        [inputTabBar.inputTextView resignFirstResponder];
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, inputSize.height+10);
    }];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [egoheaderView egoRefreshScrollViewDidEndDragging:classTableView];
    [footerView egoRefreshScrollViewDidEndDragging:classTableView];
}


-(void)addNotice
{
    AddNotificationViewController *addnotification = [[AddNotificationViewController alloc] init];
    addnotification.fromClass = NO;
    if (addOpen)
    {
        addOpen = NO;
        [self closeAdd];
    }
    [self.navigationController pushViewController:addnotification animated:YES];
}
-(void)addDongtai
{
    AddDongTaiViewController *addDongtaiViewController = [[AddDongTaiViewController alloc] init];
    addDongtaiViewController.fromCLass = NO;
    if (addOpen)
    {
        addOpen = NO;
        [self closeAdd];
    }
    [self.navigationController pushViewController:addDongtaiViewController animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [noticeArray count] + ([groupDiaries count]>0?([groupDiaries count]+1):0);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == [noticeArray count])
    {
        return 30;
    }
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = UIColorFromRGB(0xf1f0ec);
    
    UILabel *headerLabel = [[UILabel alloc] init];
    headerLabel.font = [UIFont systemFontOfSize:16];
    headerLabel.backgroundColor = UIColorFromRGB(0xf1f0ec);
    headerLabel.textColor = TITLE_COLOR;
    if (section < [noticeArray count])
    {
        NSDictionary *noticeDict = [noticeArray objectAtIndex:section];
        headerLabel.text = [NSString stringWithFormat:@"    %@未读通知",[noticeDict objectForKey:@"name"]];
        headerLabel.frame = CGRectMake(0, 5, SCREEN_WIDTH, 30);
    }
    else if (section == [noticeArray count])
    {
        headerLabel.backgroundColor = RGB(64, 196, 110, 1);
        headerLabel.text = @"    班级空间";
        headerLabel.font = [UIFont boldSystemFontOfSize:15];
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, 30);
    }
    else
    {
        UIView *dotView = [[UIView alloc] initWithFrame:CGRectMake(28, 12.5, 15, 15)];
        dotView.layer.cornerRadius = 7.5;
        dotView.clipsToBounds = YES;
        dotView.layer.borderColor = [UIColor whiteColor].CGColor;
        dotView.layer.borderWidth = 1.5;
        dotView.backgroundColor = RGB(64, 196, 110, 1);
        [headerView addSubview:dotView];
        int cha = [noticeArray count]>0?([noticeArray count]+1):0;
        NSDictionary *groupDict = [groupDiaries objectAtIndex:section-cha];
//        headerLabel.backgroundColor = RGB(64, 196, 110, 1);
        headerLabel.text = [groupDict objectForKey:@"date"];
//        headerLabel.font = [UIFont boldSystemFontOfSize:15];
//        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.frame = CGRectMake(50, 5, SCREEN_WIDTH, 30);
    }
    [headerView addSubview:headerLabel];
    return headerView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section < [noticeArray count])
    {
        return [[[noticeArray objectAtIndex:section] objectForKey:@"news"] count];
    }
    else if(section > [noticeArray count])
    {
        int cha = [noticeArray count]>0?([noticeArray count]+1):0;
        NSDictionary *groupDict = [groupDiaries objectAtIndex:section-cha];
        NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
        return [tmpArray count];
    }
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [noticeArray count])
    {
        return 105;
    }
    else if(indexPath.section > [noticeArray count])
    {
        CGFloat he=0;
        if (SYSVERSION>=7)
        {
            he = 5;
        }
            //                CGFloat imageWidth = 60;
        CGFloat imageViewHeight = ImageHeight;
        int cha = [noticeArray count]>0?([noticeArray count]+1):0;
        NSDictionary *groupDict = [groupDiaries objectAtIndex:indexPath.section-cha];
        NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        NSString *content = [[dict objectForKey:@"detail"] objectForKey:@"content"];
        NSArray *imgsArray = [[[dict objectForKey:@"detail"] objectForKey:@"img"] count]>0?[[dict objectForKey:@"detail"] objectForKey:@"img"]:nil;
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
        CGFloat tmpcommentHeight = 0;
        if ([[dict objectForKey:@"comments_num"] integerValue] > 0)
        {
            NSArray *array = [[dict objectForKey:@"detail"] objectForKey:@"comments"];
            for (int i=0; i<[array count]; ++i)
            {
                NSDictionary *dict = [array objectAtIndex:i];
                NSString *name = [[dict objectForKey:@"by"] objectForKey:@"name"];
                NSString *content = [dict objectForKey:@"content"];
                NSString *contentString = [NSString stringWithFormat:@"%@:%@",name,content];
                CGSize s = [Tools getSizeWithString:contentString andWidth:SCREEN_WIDTH-6 andFont:[UIFont systemFontOfSize:14]];
                tmpcommentHeight += (s.height > 30 ? (s.height+0):30);
            }
            
        }
        if ([[dict objectForKey:@"likes_num"] integerValue] > 0)
        {
//            int row = [[dict objectForKey:@"likes_num"] integerValue]%4 == 0 ? ([[dict objectForKey:@"likes_num"] integerValue]/4):([[dict objectForKey:@"likes_num"] integerValue]/4+1);
            tmpcommentHeight+=30;
        }
        return 60+imgsHeight+contentHtight+50 + tmpcommentHeight;
    }
    return 0;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [noticeArray count])
    {
        static NSString *notiCell = @"homenotiCell";
        NotificationCell *cell = [tableView dequeueReusableCellWithIdentifier:notiCell];
        if (cell == nil)
        {
            cell = [[NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:notiCell];
        }
        NSDictionary *noticeDict = [noticeArray objectAtIndex:indexPath.section];
        NSArray *tmpArray = [noticeDict objectForKey:@"news"];
        
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        
        NSString *byName = [[dict objectForKey:@"by"] objectForKey:@"name"];
        
        CGFloat he = 0;
        if (SYSVERSION>=7)
        {
            he = 5;
        }
        
        NSString *noticeContent = [dict objectForKey:@"content"];
        CGSize size = [Tools getSizeWithString:noticeContent andWidth:SCREEN_WIDTH-80 andFont:[UIFont systemFontOfSize:16]];
        
        CGFloat height = size.height>60?60:size.height;
        
        [cell.bgImageView setImage:[UIImage imageNamed:@"noticeBg"]];
        cell.bgImageView.layer.cornerRadius = 10;
        cell.bgImageView.clipsToBounds = YES;
        cell.bgImageView.frame = CGRectMake(8, 4, SCREEN_WIDTH-16, 100);
        
        cell.contentLabel.text = noticeContent;
        cell.contentLabel.backgroundColor = [UIColor clearColor];
        cell.contentLabel.font = [UIFont systemFontOfSize:16];
        cell.contentLabel.textColor = RGB(36, 38, 47, 1);
        cell.contentLabel.contentMode = UIViewContentModeTop;
        cell.contentLabel.frame = CGRectMake(20, 15, SCREEN_WIDTH-80, height);
        
        cell.iconImageView.frame = CGRectMake(SCREEN_WIDTH-50, 41.5, 22, 22);
        
        cell.statusLabel.textColor = TITLE_COLOR;
        cell.statusLabel.frame = CGRectMake(SCREEN_WIDTH-150, 82.5, 130, 15);
        
        cell.timeLabel.frame = CGRectMake(20, 80, 240, 20);
        cell.timeLabel.font = [UIFont systemFontOfSize:13];
        cell.timeLabel.text = [NSString stringWithFormat:@"%@发布于%@",byName,[Tools showTime:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]]];
        cell.timeLabel.textColor = TITLE_COLOR;
        
        [cell.iconImageView setImage:[UIImage imageNamed:@"unreadicon"]];
        
        if ([[dict objectForKey:@"c_read"] integerValue] == 0)
        {
            cell.statusLabel.hidden = YES;
        }
        else
        {
            if ([[[dict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
            {
                cell.statusLabel.text =[NSString stringWithFormat:@"%d人已读 %d人未读",[[dict objectForKey:@"read_num"] integerValue],[[dict objectForKey:@"unread_num"] integerValue]];
            }
            else
            {
                cell.statusLabel.text =[NSString stringWithFormat:@"%d人已读 %d人未读",[[dict objectForKey:@"read_num"] integerValue],[[dict objectForKey:@"unread_num"] integerValue]];
            }
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        return cell;
    }
    else if(indexPath.section > [noticeArray count])
    {
        static NSString *topImageView = @"trendcell";
        TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:topImageView];
        if (cell == nil)
        {
            cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topImageView];
        }
        
        NSDictionary *groupDict = [groupDiaries objectAtIndex:indexPath.section-[noticeArray count]-1];
        NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
        
        NSString *name = [[dict objectForKey:@"by"] objectForKey:@"name"];
        
        NSString *nameStr = name;
        
        cell.headerImageView.hidden = NO;
        cell.nameLabel.hidden = NO;
        cell.timeLabel.hidden = NO;
        cell.locationLabel.hidden = NO;
        cell.praiseButton.hidden = NO;
        cell.praiseImageView.hidden = NO;
        cell.commentImageView.hidden = NO;
        cell.commentButton.hidden = NO;
        cell.transmitButton.hidden = NO;
        
        cell.commentsTableView.frame = CGRectMake(0, 0, 0, 0);
        
        cell.nameLabel.frame = CGRectMake(60, 5, [nameStr length]*25>170?170:([nameStr length]*18), 30);
        cell.nameLabel.text = nameStr;
        cell.nameLabel.font = NAMEFONT;
        cell.nameLabel.textColor = NAMECOLOR;
        
        cell.timeLabel.frame = CGRectMake(cell.nameLabel.frame.size.width+cell.nameLabel.frame.origin.x, 5, SCREEN_WIDTH-cell.nameLabel.frame.origin.x-cell.nameLabel.frame.size.width-20, 30);
        cell.timeLabel.textAlignment = NSTextAlignmentRight;
        cell.timeLabel.numberOfLines = 2;
        cell.timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.timeLabel.text = [Tools showTime:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]];
//        cell.headerImageView.layer.cornerRadius = cell.headerImageView.frame.size.width/2;
//        cell.headerImageView.clipsToBounds = YES;
        cell.headerImageView.backgroundColor = [UIColor clearColor];
        [Tools fillImageView:cell.headerImageView withImageFromURL:[[dict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERBG];
        cell.locationLabel.frame = CGRectMake(60, cell.nameLabel.frame.origin.y+cell.nameLabel.frame.size.height, SCREEN_WIDTH-80, 20);
        cell.locationLabel.text = [[dict objectForKey:@"detail"] objectForKey:@"add"];
        
        cell.contentLabel.hidden = YES;
        
        int cha = [noticeArray count]>0?([noticeArray count]+1):0;
        
        for(UIView *v in cell.imagesView.subviews)
        {
            if ([v isKindOfClass:[UIImageView class]])
            {
                [v removeFromSuperview];
            }
        }
        if (![[[dict objectForKey:@"detail"] objectForKey:@"content"] length] <=0)
        {
            CGFloat he = 0;
            if (SYSVERSION >= 7)
            {
                he = 5;
            }
            //有文字
            NSString *content = [[dict objectForKey:@"detail"] objectForKey:@"content"];
            cell.contentLabel.hidden = NO;
            cell.contentLabel.editable = NO;
            cell.contentLabel.textColor = [UIColor blackColor];
            if ([content length] > 40)
            {
                cell.contentLabel.text  = [NSString stringWithFormat:@"%@...",[content substringToIndex:37]];
            }
            else
            {
                cell.contentLabel.text = content;
            }
            cell.contentLabel.frame = CGRectMake(10, 55, SCREEN_WIDTH-20, 45);
        }
        else
        {
            cell.contentLabel.frame = CGRectMake(10, 60, 0, 0);
        }
        CGFloat imageViewHeight = ImageHeight;
        CGFloat imageViewWidth = ImageHeight;
        if ([[[dict objectForKey:@"detail"] objectForKey:@"img"] count] > 0)
        {
            //有图片
            
            NSArray *imgsArray = [[dict objectForKey:@"detail"] objectForKey:@"img"];
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
                imageView.tag = (indexPath.section-cha)*SectionTag+indexPath.row*RowTag+333;
                
                imageView.userInteractionEnabled = YES;
                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                
                // 内容模式
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [Tools fillImageView:imageView withImageFromURL:[imgsArray firstObject] imageWidth:100.0f andDefault:@"3100"];
                //                    [Tools fillImageView:imageView withImageFromURL:[imgsArray firstObject] ];
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
                    imageView.tag = (indexPath.section-cha)*SectionTag+indexPath.row*RowTag+i+333;
                    
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
        cell.transmitButton.tag = (indexPath.section-cha)*SectionTag+indexPath.row;
        [cell.transmitButton addTarget:self action:@selector(transmitDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.transmitImageView.frame = CGRectMake((SCREEN_WIDTH-20)/4-55, cell.transmitButton.frame.size.height+cell.transmitButton.frame.origin.y-22, 13, 13);
        
        
        [cell.praiseButton setTitle:[NSString stringWithFormat:@"赞(%d)",[[dict objectForKey:@"likes_num"] integerValue]] forState:UIControlStateNormal];
        [cell.praiseButton addTarget:self action:@selector(praiseDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.praiseButton.tag = (indexPath.section-cha)*SectionTag+indexPath.row;
        cell.praiseButton.frame = CGRectMake((SCREEN_WIDTH-0)/3, cellHeight+13, (SCREEN_WIDTH-0)/3, 30);
        
        cell.praiseImageView.frame = CGRectMake((SCREEN_WIDTH-20)*2/4-20, cell.praiseButton.frame.size.height+cell.praiseButton.frame.origin.y-19, 13, 13);
        
        [cell.commentButton setTitle:[NSString stringWithFormat:@"评论(%d)",[[dict objectForKey:@"comments_num"] integerValue]] forState:UIControlStateNormal];
        cell.commentButton.frame = CGRectMake((SCREEN_WIDTH-0)/3*2, cellHeight+13, (SCREEN_WIDTH-0)/3, 30);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.commentButton.tag = (indexPath.section-cha)*SectionTag+indexPath.row;
        [cell.commentButton addTarget:self action:@selector(commentDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.commentImageView.frame = CGRectMake((SCREEN_WIDTH-20)*3/4, cell.commentButton.frame.size.height+cell.commentButton.frame.origin.y-20, 13, 13);
        
        cell.backgroundColor = [UIColor clearColor];
        
        if ([[dict objectForKey:@"comments_num"] integerValue] > 0 || [dict objectForKey:@"likes_num"] > 0)
        {
            NSArray *comArray = [[dict objectForKey:@"detail"] objectForKey:@"comments"];
            if ([comArray count] > 0)
            {
                cell.commentsArray = comArray;
            }
            else
            {
                cell.commentsArray = nil;
            }
            NSArray *praiseArray = [[dict objectForKey:@"detail"] objectForKey:@"likes"];
            if ([praiseArray count] > 0)
            {
                cell.praiseArray = praiseArray;
            }
            else
            {
                cell.praiseArray = nil;
            }
            [cell.commentsTableView reloadData];
            cell.commentsTableView.frame = CGRectMake(0, cell.praiseButton.frame.size.height+cell.praiseButton.frame.origin.y, SCREEN_WIDTH, cell.commentsTableView.contentSize.height);
            cell.bgView.frame = CGRectMake(5, 0, SCREEN_WIDTH-10,
                                           cell.commentsTableView.frame.size.height+
                                           cell.commentsTableView.frame.origin.y);
        }
        else
        {
            cell.commentsArray = nil;
            cell.praiseArray = nil;
            [cell.commentsTableView reloadData];
            cell.bgView.frame = CGRectMake(5, 0, SCREEN_WIDTH-10,
                                           cell.praiseButton.frame.size.height+
                                           cell.praiseButton.frame.origin.y);
        }
        cell.bgView.layer.cornerRadius = 5;
        cell.bgView.clipsToBounds = YES;
        cell.bgView.backgroundColor = [UIColor whiteColor];
        return cell;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [noticeArray count])
    {
        NSDictionary *dict = [[[noticeArray objectAtIndex:indexPath.section] objectForKey:@"news"] objectAtIndex:indexPath.row];
        DDLOG(@"home notice dict %@",dict);
        NotificationDetailViewController *notificationDetailViewController = [[NotificationDetailViewController alloc] init];
        notificationDetailViewController.noticeID = [dict objectForKey:@"_id"];
        notificationDetailViewController.noticeContent = [dict objectForKey:@"content"];
        notificationDetailViewController.c_read = [dict objectForKey:@"c_read"];
//        notificationDetailViewController.readnotificationDetaildel = self;
        notificationDetailViewController.isnew = NO;
        notificationDetailViewController.byID = [[dict objectForKey:@"by"] objectForKey:@"_id"];
        [self.navigationController pushViewController:notificationDetailViewController animated:YES];
    }
    else
    {
        
    }
}

- (void)tapImage:(UITapGestureRecognizer *)tap
{
    NSDictionary *groupDict = [groupDiaries objectAtIndex:(tap.view.tag-333)/SectionTag];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [array objectAtIndex:(tap.view.tag-333)%SectionTag/RowTag];
    NSArray *imgs = [[dict objectForKey:@"detail"] objectForKey:@"img"];
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


-(void)praiseDiary:(UIButton *)button
{
    NSDictionary *groupDict = [groupDiaries objectAtIndex:button.tag/SectionTag];
    NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [tmpArray objectAtIndex:button.tag%SectionTag];
    DDLOG(@"home diary %@",[[dict objectForKey:@"detail"] objectForKey:@"content"]);
    if ([Tools NetworkReachable])
    {
//        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
//                                                                      @"token":[Tools client_token],
//                                                                      @"p_id":[dict objectForKey:@"_id"],
//                                                                      @"c_id":classID,
//                                                                      } API:LIKE_DIARY];
//        [request setCompletionBlock:^{
//            NSString *responseString = [request responseString];
//            NSDictionary *responseDict = [Tools JSonFromString:responseString];
//            DDLOG(@"commit diary responsedict %@",responseDict);
//            if ([[responseDict objectForKey:@"code"] intValue]== 1)
//            {
//                [Tools showTips:@"赞成功" toView:classZoneTableView];
//                page = 0;
//                monthStr = @"";
//                NSString *title = [[button titleForState:UIControlStateNormal] substringFromIndex:2];
//                [button setTitle:[NSString stringWithFormat:@"赞(%d)",[title integerValue]+1] forState:UIControlStateNormal];
//            }
//            else
//            {
//                [Tools dealRequestError:responseDict fromViewController:self];
//            }
//        }];
//        
//        [request setFailedBlock:^{
//            NSError *error = [request error];
//            DDLOG(@"error %@",error);
//        }];
//        [request startAsynchronous];
    }
    
}

-(void)commentDiary:(UIButton *)button
{
    NSDictionary *groupDict = [groupDiaries objectAtIndex:button.tag/SectionTag];
    NSArray *tmpArray = [groupDict objectForKey:@"diaries"];
    NSDictionary *dict = [tmpArray objectAtIndex:button.tag%SectionTag];
    DDLOG(@"home diary %@",[[dict objectForKey:@"detail"] objectForKey:@"content"]);
    [inputTabBar.inputTextView becomeFirstResponder];
//    DongTaiDetailViewController *dongtaiDetailViewController = [[DongTaiDetailViewController alloc] init];
//    dongtaiDetailViewController.dongtaiId = [dict objectForKey:@"_id"];
//    dongtaiDetailViewController.addComDel = self;
//    [[XDTabViewController sharedTabViewController].navigationController pushViewController:dongtaiDetailViewController animated:YES];
}

-(void)showKeyBoard:(CGFloat)keyBoardHeight
{
    [classTableView addGestureRecognizer:backTgr];
    [UIView animateWithDuration:0.2 animations:^{
        tmpheight = keyBoardHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-keyBoardHeight, SCREEN_WIDTH, inputSize.height+10+ FaceViewHeight);
    }];
}

-(void)changeInputType:(NSString *)changeType
{
    if ([changeType isEqualToString:@"face"])
    {
        faceViewHeight = FaceViewHeight;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-faceViewHeight, SCREEN_WIDTH, inputSize.height+10 + faceViewHeight);
    }
    else if([changeType isEqualToString:@"key"])
    {
        faceViewHeight = inputSize.height;
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10-tmpheight, SCREEN_WIDTH, inputSize.height+10 + faceViewHeight);
    }
}

-(void)changeInputViewSize:(CGSize)size
{
    inputSize = size;
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-size.height-10-tmpheight, SCREEN_WIDTH, size.height+10+faceViewHeight);
    }];
}


-(void)groupByTime:(NSArray *)array
{
    NSString *timeStr;
    int index = 0;
    [groupDiaries removeAllObjects];
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
                [groupDiaries addObject:groupDict];
            }
        }
    }
//    if ([tmpArray count]>0)
//    {
//        noneDongTaiLabel.hidden = YES;
//    }
//    else
//    {
//        noneDongTaiLabel.hidden = NO;
//    }
    [classTableView reloadData];
    if (footerView)
    {
        [footerView removeFromSuperview];
        footerView = [[FooterView alloc] initWithScrollView:classTableView];
        footerView.delegate = self;
    }
    else
    {
        footerView = [[FooterView alloc] initWithScrollView:classTableView];
        footerView.delegate = self;
    }
}

-(BOOL)haveThisTime:(NSString *)timeStr
{
    for (int i=0; i<[groupDiaries count]; i++)
    {
        NSDictionary *dict = [groupDiaries objectAtIndex:i];
        if ([[dict objectForKey:@"date"] isEqualToString:timeStr])
        {
            return YES;
        }
    }
    return NO;
}

-(void)addButtonClick
{
    if (addOpen)
    {
        //close
        [self closeAdd];
        self.navigationController.sideMenuController.panGestureEnabled = YES;
        self.navigationController.sideMenuController.tapGestureEnabled = YES;
    }
    else
    {
        //open
        [self openAdd];
        self.navigationController.sideMenuController.panGestureEnabled = NO;
        self.navigationController.sideMenuController.tapGestureEnabled = NO;
    }
    addOpen = !addOpen;
}

-(void)openAdd
{
    [UIView animateWithDuration:0.2 animations:^{
        addView.alpha = 1;
        addNoticeButton.alpha = 1;
        addDiaryButton.alpha = 1;
        classTableView.userInteractionEnabled = NO;
    }];
    
}

-(void)closeAdd
{
    [UIView animateWithDuration:0.2 animations:^{
        addNoticeButton.alpha = 0;
        addDiaryButton.alpha = 0;
        addView.alpha = 0;
        self.navigationController.sideMenuController.panGestureEnabled = YES;
        self.navigationController.sideMenuController.tapGestureEnabled = YES;
        classTableView.userInteractionEnabled = YES;
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *t in touches)
    {
        if(!CGRectContainsPoint(addView.frame, [t locationInView:addView]))
        {
            if (addOpen)
            {
                addOpen = NO;
                [self closeAdd];
            }
        }
    }
}


-(void)moreOpen
{
    if (![[self.navigationController sideMenuController] isMenuVisible])
    {
        [[self.navigationController sideMenuController] showMenuAnimated:YES];
    }
    else
    {
        [[self.navigationController sideMenuController] hideMenuAnimated:YES];
    }
}

-(void)transmitDiary:(UIButton *)button
{
    NSDictionary *groupDict = [groupDiaries objectAtIndex:button.tag/SectionTag];
    NSArray *array = [groupDict objectForKey:@"diaries"];
    waitTransmitDict = [[array objectAtIndex:button.tag%SectionTag] objectForKey:@"detail"];
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_async(queue, ^{
//        [[MMProgressHUD sharedHUD] setOverlayMode:MMProgressHUDWindowOverlayModeGradient];
//        [MMProgressHUD showWithTitle:@"Title" status:@"Custom Animated Image" images:nil];
//        sleep(1);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [MMProgressHUD dismissWithSuccess:@"success!"];
//        });
//
//    });

@end