//
//  DongTaiDetailViewController.m
//  School
//
//  Created by TeekerZW on 14-2-28.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "DongTaiDetailViewController.h"
#import "Header.h"
#import "TrendsCell.h"

#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "NSString+Emojize.h"
#import "InputTableBar.h"

@interface DongTaiDetailViewController ()<UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
ReturnFunctionDelegate>
{
    UITableView *diaryDetailTableView;
    NSDictionary *diaryDetailDict;
    
    UIView *commitView;
    UITextField *commitTextField;
    NSMutableArray *commentsArray;
    
    NSMutableString *commentStr;
    
    InputTableBar *inputTabBar;
}
@end

@implementation DongTaiDetailViewController
@synthesize dongtaiId,classID;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    DDLOG_CURRENT_METHOD;
    [self.sideMenuController setPanGestureEnabled:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.titleLabel.text = @"动态详情";
    
    commentStr = [[NSMutableString alloc] initWithCapacity:0];
    
    commentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIView *tableViewBg = [[UIView alloc] initWithFrame:self.bgView.frame];
    [tableViewBg setBackgroundColor:UIColorFromRGB(0xf1f0ec)];
    
    diaryDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-40) style:UITableViewStyleGrouped];
    diaryDetailTableView.dataSource = self;
    diaryDetailTableView.delegate = self;
    diaryDetailTableView.tag = 10000;
    diaryDetailTableView.backgroundView = tableViewBg;
    diaryDetailTableView.backgroundColor = [UIColor clearColor];
    [self.bgView addSubview:diaryDetailTableView];
    
    inputTabBar = [[InputTableBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40)];
    inputTabBar.backgroundColor = [UIColor grayColor];
    inputTabBar.returnFunDel = self;
    [self.bgView addSubview:inputTabBar];
    
    diaryDetailTableView.hidden = YES;
    
    UIButton *faceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    faceButton.frame = CGRectMake(SCREEN_WIDTH-70, 5, 50, 30);
    [faceButton setImage:[UIImage imageNamed:@"icon_comment"] forState:UIControlStateNormal];
    faceButton.backgroundColor = [UIColor clearColor];
    [commitView addSubview:faceButton];

    [self getDiaryDetail];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)myReturnFunction
{
    DDLOG(@"=====%@",inputTabBar.sendString);
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"])
    {
        if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentComment] integerValue] == 0)
        {
            [Tools showAlertView:@"本班日志不允许家长发表评论" delegateViewController:nil];
        }
    }
    [self commentdiary];
}

#pragma mark - tableview

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (section == 0)
    {
        return 0;
    }
//    else
//        return 40;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        CGFloat imageViewHeight = 0;
        NSString *content = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"content"];
        NSArray *imgsArray = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"img"];
        if ([imgsArray count]>0)
        {
            imageViewHeight = 134;
        }
        CGFloat contentHtight = [self getSizeWithString:content andWidth:SCREEN_WIDTH-50 andFont:nil].height;
        return 60+imageViewHeight+contentHtight+50;
    }
    else if(indexPath.section == 1)
    {
        
        NSDictionary *dict = [commentsArray objectAtIndex:indexPath.row];
        NSString *contentStr = [dict objectForKey:@"content"];
        CGSize size = [self getSizeWithString:contentStr andWidth:SCREEN_WIDTH-50 andFont:nil];
        return size.height+50;
    }
    return 0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 1;
    }
    else if(section == 1)
    {
        return [commentsArray count];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        static NSString *topImageView = @"trendcell";
        TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:topImageView];
        if (cell == nil)
        {
            cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topImageView];
        }
        cell.nameLabel.text = [[diaryDetailDict objectForKey:@"by"] objectForKey:@"name"];
        cell.timeLabel.frame = CGRectMake(cell.nameLabel.frame.size.width+cell.nameLabel.frame.origin.x+10, 5, SCREEN_WIDTH-cell.nameLabel.frame.origin.x-cell.nameLabel.frame.size.width-40, 30);
        cell.timeLabel.textAlignment = NSTextAlignmentRight;
        cell.timeLabel.text = [Tools showTime:[NSString stringWithFormat:@"%d",[[[diaryDetailDict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]];
        cell.locationLabel.frame = CGRectMake(60, cell.nameLabel.frame.origin.y+cell.nameLabel.frame.size.height, SCREEN_WIDTH-80, 20);
        cell.locationLabel.text = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"add"];
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;
        [Tools fillImageView:cell.headerImageView withImageFromURL:[[diaryDetailDict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:@"header_pic.jpg"];
        cell.contentLabel.hidden = YES;
        cell.imagesScrollView.hidden = YES;
        cell.imagesView.hidden  = YES;
        for(UIView *v in cell.imagesScrollView.subviews)
        {
            [v removeFromSuperview];
        }
        if (!([[[diaryDetailDict objectForKey:@"detail"] objectForKey:@"content"] length] <= 0))
        {
            //有文字
            cell.contentLabel.hidden = NO;
            NSString *content = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"content"];
            CGSize contentSize = [self getSizeWithString:content andWidth:SCREEN_WIDTH-30 andFont:nil];
            cell.contentLabel.text = [[[diaryDetailDict objectForKey:@"detail"] objectForKey:@"content"] emojizedString];
            cell.contentLabel.textColor = TITLE_COLOR;
            
            cell.contentLabel.frame = CGRectMake(15, 60, SCREEN_WIDTH-50, contentSize.height);
            
        }
        else
        {
            cell.contentLabel.frame = CGRectMake(10, 60, 0, 0);
        }
        
        CGFloat imageViewHeight = 134;
        CGFloat imageViewWidth = 134;
        if ([[[diaryDetailDict objectForKey:@"detail"] objectForKey:@"img"] count] > 0)
        {
            //有图片
            cell.imagesScrollView.hidden = NO;
            
            NSArray *imgsArray = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"img"];
            cell.imagesScrollView.frame = CGRectMake(5, cell.contentLabel.frame.size.height+cell.contentLabel.frame.origin.y+3, SCREEN_WIDTH-50, imageViewHeight);
            cell.imagesScrollView.contentSize = CGSizeMake((imageViewWidth+5)*[imgsArray count], imageViewHeight);
            UIImage *placeholder = [UIImage imageNamed:@""];
            for (int i=0; i<[imgsArray count]; ++i)
            {
                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.frame = CGRectMake(i*(imageViewWidth+5), 0, imageViewWidth, imageViewHeight);
                imageView.userInteractionEnabled = YES;
                imageView.tag = (indexPath.row)*1000+i+1000;;
                
                imageView.userInteractionEnabled = YES;
                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
                
                [imageView setImageURLStr:[NSString stringWithFormat:@"%@%@",IMAGEURL,[imgsArray objectAtIndex:i]] placeholder:placeholder];
                
                // 内容模式
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [Tools fillImageView:imageView withImageFromURL:[imgsArray objectAtIndex:i] andDefault:@"0.jpg"];
                [cell.imagesScrollView addSubview:imageView];
            }
        }
        else
        {
            cell.imagesScrollView.frame = CGRectMake(5, cell.contentLabel.frame.size.height+cell.contentLabel.frame.origin.y, SCREEN_WIDTH-10, 0);
        }
        [cell.praiseButton setTitle:[NSString stringWithFormat:@"赞(%d)",[[diaryDetailDict objectForKey:@"likes_num"] integerValue]] forState:UIControlStateNormal];
        cell.praiseButton.frame = CGRectMake(SCREEN_WIDTH - 140, cell.imagesScrollView.frame.size.height+cell.imagesScrollView.frame.origin.y+10, 40, 30);
        [cell.praiseButton addTarget:self action:@selector(praiseDiary) forControlEvents:UIControlEventTouchUpInside];
        [cell.commentButton setTitle:[NSString stringWithFormat:@"评论(%d)",[[diaryDetailDict objectForKey:@"comments_num"] integerValue]] forState:UIControlStateNormal];
        cell.commentButton.frame = CGRectMake(SCREEN_WIDTH - 80, cell.imagesScrollView.frame.size.height+cell.imagesScrollView.frame.origin.y+10, 40, 30);
        [cell.commentButton addTarget:self action:@selector(startCommit) forControlEvents:UIControlEventTouchUpInside];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.bgView.frame = CGRectMake(5, 5, SCREEN_WIDTH-10, cell.headerImageView.frame.size.height+cell.contentLabel.frame.size.height+cell.imagesScrollView.frame.size.height+cell.praiseButton.frame.size.height);
        cell.bgView.backgroundColor = [UIColor clearColor];
        cell.bgView.layer.borderWidth = 0;
        UIImageView *cellImage = [[UIImageView alloc] initWithFrame:cell.bgView.frame];
        [cellImage setImage:[Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)]];
        cell.backgroundView = cellImage;
        return cell;

    }
    else if(indexPath.section == 1)
    {
        static NSString *commitCell = @"commentCell";
        TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:commitCell];
        if (cell == nil)
        {
            cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commitCell];
        }
        NSDictionary *dict = [commentsArray objectAtIndex:indexPath.row];
        cell.headerImageView.frame = CGRectMake(5, 5, 30, 30);
        cell.headerImageView.layer.cornerRadius = 5;
        cell.headerImageView.clipsToBounds = YES;
        [Tools fillImageView:cell.headerImageView withImageFromURL:[[dict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:@"0.jpg"];
        cell.nameLabel.text = [[dict objectForKey:@"by"] objectForKey:@"name"];
        cell.timeLabel.frame = CGRectMake(cell.nameLabel.frame.size.width+cell.nameLabel.frame.origin.x+10, 5, SCREEN_WIDTH-cell.nameLabel.frame.origin.x-cell.nameLabel.frame.size.width-40, 30);
        cell.timeLabel.textAlignment = NSTextAlignmentRight;
        cell.timeLabel.text = [Tools showTime:[[dict objectForKey:@"created"] objectForKey:@"sec"]];
        NSString *contentStr = [dict objectForKey:@"content"];
        CGSize size = [self getSizeWithString:contentStr andWidth:SCREEN_WIDTH-50 andFont:nil];
        cell.contentLabel.numberOfLines = 0;
        cell.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.contentLabel.frame = CGRectMake(40, 35, SCREEN_WIDTH-90, size.height);
        cell.contentLabel.text = [[dict objectForKey:@"content"] emojizedString];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.bgView.frame = CGRectMake(5, 5, SCREEN_WIDTH-10, cell.headerImageView.frame.size.height+cell.contentLabel.frame.size.height);
        cell.bgView.backgroundColor = [UIColor clearColor];
        cell.bgView.layer.borderWidth = 0;
        UIImageView *cellImage = [[UIImageView alloc] initWithFrame:cell.bgView.frame];
        [cellImage setImage:[Tools getImageFromImage:[UIImage imageNamed:@"input"] andInsets:UIEdgeInsetsMake(20, 2, 20, 2)]];
        cell.backgroundView = cellImage;
        return cell;
    }
    return nil;
}
- (void)tapImage:(UITapGestureRecognizer *)tap
{
    NSArray *imgs = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"img"];
    int count = [imgs count];
    
    // 1.封装图片数据
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        // 替换为中等尺寸图片
        NSString *url = [[NSString stringWithFormat:@"%@%@",IMAGEURL,imgs[i]] stringByReplacingOccurrencesOfString:@"thumbnail" withString:@"bmiddle"];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:url]; // 图片路径
        photo.srcImageView = (UIImageView *)[self.bgView viewWithTag:tap.view.tag]; // 来源于哪个UIImageView
        [photos addObject:photo];
    }
    
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag%1000; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [inputTabBar backKeyBoard];
}

-(CGSize)getSizeWithString:(NSString *)content andWidth:(CGFloat)width andFont:(UIFont *)font
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
    [label setNumberOfLines:0];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    CGSize size = CGSizeMake(width, 2000);
    if (font == nil)
    {
        font = [UIFont systemFontOfSize:14];
    }
    CGSize labelSize = [content sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    
    DDLOG(@"labelSize==%@",NSStringFromCGSize(labelSize));
    [label setFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
    return labelSize;
}

#pragma mark - aboutComment

-(void)startCommit
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"])
    {
        if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentComment] integerValue] == 0)
        {
            [Tools showAlertView:@"本班日志不允许家长发表评论" delegateViewController:nil];
            return ;
        }
    }
    [commitTextField becomeFirstResponder];
}

-(void)commentdiary
{
    if ([[inputTabBar analyString:inputTabBar.inputTextView.text] length] <= 0)
    {
        [Tools showAlertView:@"请输入评论内容！" delegateViewController:nil];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":dongtaiId,
                                                                      @"c_id":classID,
                                                                      @"content":[inputTabBar analyString:inputTabBar.inputTextView.text]
                                                                        } API:COMMENT_DIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"评论成功" toView:diaryDetailTableView];
                [self getDiaryDetail];
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
    else
    {
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

-(void)praiseDiary
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":dongtaiId,
                                                                      @"c_id":classID,
                                                                      } API:LIKE_DIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"commit diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"赞成功" toView:diaryDetailTableView];
                [self getDiaryDetail];
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

#pragma mark - getNetdata
-(void)getDiaryDetail
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":dongtaiId
                                                                      } API:GETDIARY_DETAIL];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"diary detail responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                diaryDetailTableView.hidden = NO;
                diaryDetailDict = [[NSDictionary alloc] initWithDictionary:[responseDict objectForKey:@"data"]];
                
                [commentsArray removeAllObjects];
                [commentsArray addObjectsFromArray:[[[responseDict objectForKey:@"data"] objectForKey:@"detail"] objectForKey:@"comments"]];
                [diaryDetailTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
            diaryDetailTableView.hidden = YES;
        }];
        [request startAsynchronous];
    }
    else
    {
        diaryDetailTableView.hidden = YES;
        [Tools showAlertView:NOT_NETWORK delegateViewController:nil];
    }
}

@end
