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

#define ImageViewTag  9999
#define HeaderImageTag  7777
#define CellButtonTag   33333

#define SectionTag  10000
#define RowTag     100

#define ImageHeight  60.0f

#define ImageCountPerRow  4

@interface HomeViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    BOOL addOpen;
    PopView *addView;
    UIButton *addNoticeButton;
    UIButton *addDiaryButton;
    
    DemoVIew *demoView;
    
    
    UITapGestureRecognizer *tapTgr;
    
    UITableView *classTableView;
    
    UIImageView *navImageView;
    
    NSMutableArray *noticeArray;
    NSMutableArray *diariesArray;
    OperatDB *db;
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
    
    db = [[OperatDB alloc]init];
    
    self.backButton.hidden = YES;
    self.returnImageView.hidden = YES;
    self.titleLabel.text = @"首页";
    self.titleLabel.frame = CGRectMake((SCREEN_WIDTH - [self.titleLabel.text length]*19)/2, self.titleLabel.frame.origin.y, [self.titleLabel.text length]*19, 30);
    self.titleLabel.hidden = YES;
    
    addOpen = NO;
    
    noticeArray = [[NSMutableArray alloc] initWithCapacity:0];
    diariesArray = [[NSMutableArray alloc] initWithCapacity:0];
    
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
    
    classTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT+0, SCREEN_WIDTH, SCREEN_HEIGHT-5-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getHomeData
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token]}
                                                                API:HOMEDATA];
        
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"home responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [noticeArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"notices"]];
                [diariesArray addObjectsFromArray:[[responseDict objectForKey:@"data"] objectForKey:@"diaries"]];
                [classTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
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
    return [noticeArray count] + ([diariesArray count] > 0 ? 1 : 0);
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section < [noticeArray count])
    {
        return 30;
    }
    return 40;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, 30)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:16];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = TITLE_COLOR;
    if (section < [noticeArray count])
    {
        NSDictionary *noticeDict = [noticeArray objectAtIndex:section];
        headerLabel.text = [NSString stringWithFormat:@"    %@未读通知",[noticeDict objectForKey:@"name"]];
        return headerLabel;
    }
    else
    {
        headerLabel.backgroundColor = RGB(64, 196, 110, 1);
        headerLabel.text = @"   班级空间";
        headerLabel.font = [UIFont boldSystemFontOfSize:15];
        headerLabel.textColor = [UIColor whiteColor];
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
    DDLOG(@"diaries %@",diariesArray);
    return [diariesArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < [noticeArray count])
    {
        return 105;
    }
    else
    {
        CGFloat he=0;
        if (SYSVERSION>=7)
        {
            he = 5;
        }
            //                CGFloat imageWidth = 60;
        CGFloat imageViewHeight = ImageHeight;
        NSDictionary *dict = [diariesArray objectAtIndex:indexPath.row];
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
        return 60+imgsHeight+contentHtight+50;
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
        
        NSDictionary *dict = [tmpArray objectAtIndex:[tmpArray count]-indexPath.row-1];
        
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
    else
    {
        static NSString *topImageView = @"trendcell";
        TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:topImageView];
        if (cell == nil)
        {
            cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topImageView];
        }
//        NSDictionary *groupDict = [diariesArray objectAtIndex:indexPath.section-1];
//        NSArray *array = [groupDict objectForKey:@"diaries"];
        NSDictionary *dict = [diariesArray objectAtIndex:indexPath.row];
        NSString *name = [[dict objectForKey:@"by"] objectForKey:@"name"];
        
        NSString *nameStr = name;
//        NSArray *classmen = [db findSetWithDictionary:@{@"uid":[[dict objectForKey:@"by"] objectForKey:@"_id"],@"classid":classID} andTableName:CLASSMEMBERTABLE];
//        if ([classmen count]>0)
//        {
//            NSDictionary *memdict = [classmen firstObject];
//            if (![[memdict objectForKey:@"title"] isEqual:[NSNull null]])
//            {
//                if ([[memdict objectForKey:@"title"] length] >0)
//                {
//                    nameStr = [NSString stringWithFormat:@"%@（%@）",name,[memdict objectForKey:@"title"]];
//                }
//                else
//                    nameStr = name;
//            }
//            else
//            {
//                nameStr = name;
//            }
//        }
//        else
//        {
//            nameStr = name;
//        }
        
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
        cell.nameLabel.font = NAMEFONT;
        cell.nameLabel.textColor = NAMECOLOR;
        
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
                imageView.tag = (indexPath.section-1)*SectionTag+indexPath.row*RowTag+333;
                
                imageView.userInteractionEnabled = YES;
//                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                
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
                    imageView.tag = (indexPath.section-1)*SectionTag+indexPath.row*RowTag+i+333;
                    
                    imageView.userInteractionEnabled = YES;
//                    [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                    
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
//        [cell.transmitButton addTarget:self action:@selector(transmitDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.transmitImageView.frame = CGRectMake((SCREEN_WIDTH-20)/4-55, cell.transmitButton.frame.size.height+cell.transmitButton.frame.origin.y-22, 13, 13);
        
        
        [cell.praiseButton setTitle:[NSString stringWithFormat:@"赞(%d)",[[dict objectForKey:@"likes_num"] integerValue]] forState:UIControlStateNormal];
//        [cell.praiseButton addTarget:self action:@selector(praiseDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.praiseButton.tag = indexPath.section*SectionTag+indexPath.row;
        cell.praiseButton.frame = CGRectMake((SCREEN_WIDTH-0)/3, cellHeight+13, (SCREEN_WIDTH-0)/3, 30);
        
        cell.praiseImageView.frame = CGRectMake((SCREEN_WIDTH-20)*2/4-20, cell.praiseButton.frame.size.height+cell.praiseButton.frame.origin.y-19, 13, 13);
        
        [cell.commentButton setTitle:[NSString stringWithFormat:@"评论(%d)",[[dict objectForKey:@"comments_num"] integerValue]] forState:UIControlStateNormal];
        cell.commentButton.frame = CGRectMake((SCREEN_WIDTH-0)/3*2, cellHeight+13, (SCREEN_WIDTH-0)/3, 30);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.commentButton.tag = indexPath.section*SectionTag+indexPath.row;
//        [cell.commentButton addTarget:self action:@selector(commentDiary:) forControlEvents:UIControlEventTouchUpInside];
        cell.commentImageView.frame = CGRectMake((SCREEN_WIDTH-20)*3/4, cell.commentButton.frame.size.height+cell.commentButton.frame.origin.y-20, 13, 13);
        
        cell.bgView.frame = CGRectMake(3, 0, SCREEN_WIDTH-6,
                                       cell.praiseButton.frame.size.height+
                                       cell.praiseButton.frame.origin.y);
        cell.bgView.backgroundColor = [UIColor whiteColor];
        cell.backgroundColor = [UIColor clearColor];
        
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