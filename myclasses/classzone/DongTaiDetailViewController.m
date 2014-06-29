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
#import "CommentCell.h"

#import "UIImageView+MJWebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "NSString+Emojize.h"
#import "InputTableBar.h"
#import "ReportViewController.h"

#define additonalH  90

@interface DongTaiDetailViewController ()<UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
ReturnFunctionDelegate,
UIActionSheetDelegate>
{
    UITableView *diaryDetailTableView;
    NSDictionary *diaryDetailDict;
    NSDictionary *waitTransDict;
    
    UIView *commitView;
    UITextField *commitTextField;
    NSMutableArray *commentsArray;
    
    NSMutableString *commentStr;
    
    InputTableBar *inputTabBar;
    
    CGFloat tmpheight;
    
    CGSize inputSize;
    
    CGFloat faceViewHeight;
    
    OperatDB *db;
    NSString *classID;
    
    UIButton *moreButton;
}
@end

@implementation DongTaiDetailViewController
@synthesize dongtaiId,addComDel,fromclass;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self backInput];
    inputTabBar.returnFunDel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:inputTabBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleLabel.text = @"空间详情";
    if (fromclass)
    {
        self.view.backgroundColor = [UIColor blackColor];
    }
    self.stateView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 0);
    
    
    faceViewHeight = 0;
    
    db = [[OperatDB alloc] init];
    
    inputSize = CGSizeMake(250, 30);
    
    self.bgView.frame = CGRectMake(0, YSTART, SCREEN_WIDTH, SCREEN_HEIGHT+200);
    
    moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreButton.frame = CGRectMake(SCREEN_WIDTH-60, 6, 50, 32);
    [moreButton setImage:[UIImage imageNamed:CornerMore] forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:moreButton];
    moreButton.hidden = YES;
    
    commentStr = [[NSMutableString alloc] initWithCapacity:0];
    
    commentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIView *tableViewBg = [[UIView alloc] initWithFrame:self.bgView.frame];
    [tableViewBg setBackgroundColor:UIColorFromRGB(0xf1f0ec)];
    
    diaryDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-40) style:UITableViewStylePlain];
    diaryDetailTableView.dataSource = self;
    diaryDetailTableView.delegate = self;
    diaryDetailTableView.tag = 10000;
    diaryDetailTableView.backgroundView = tableViewBg;
    diaryDetailTableView.backgroundColor = [UIColor clearColor];
    diaryDetailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
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


-(void)unShowSelfViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - moreclick

-(void)moreClick
{
    if (fromclass)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] ==2 || [[[diaryDetailDict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除",@"举报", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
        }
        else
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
        }
        
    }
    else
    {
        if ([[[diaryDetailDict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"删除",@"举报", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
        }
        else
        {
            UIActionSheet *ac = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"举报", nil];
            ac.tag = 3333;
            [ac showInView:self.bgView];
        }
    }
}

#pragma mark - inputTabBarDel

-(void)myReturnFunction
{
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"role"] isEqualToString:@"parents"])
    {
        if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"set"] objectForKey:ParentComment] integerValue] == 0)
        {
            [Tools showAlertView:@"本班日志不允许家长发表评论" delegateViewController:nil];
            return ;
        }
        else
        {
            [self commentdiary];
        }
    }
    else if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"opt"] objectForKey:UserSendComment] == 0)
    {
        [Tools showAlertView:@"您没有评论日志的权限" delegateViewController:nil];
        return ;
    }
    else
    {
        [self commentdiary];
    }
    inputSize = CGSizeMake(250, 30);
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10, SCREEN_WIDTH, inputSize.height+10);
        [self backInput];
    }];
}

-(void)backInput
{
    [UIView animateWithDuration:0.2 animations:^{
        [inputTabBar.inputTextView resignFirstResponder];
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-inputSize.height-10, SCREEN_WIDTH, inputSize.height+10);
    }];
}


-(void)showKeyBoard:(CGFloat)keyBoardHeight
{
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

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self backInput];
    [inputTabBar backKeyBoard];
}

-(void)changeInputViewSize:(CGSize)size
{
    inputSize = size;
    [UIView animateWithDuration:0.2 animations:^{
        inputTabBar.frame = CGRectMake(0, SCREEN_HEIGHT-size.height-10-tmpheight, SCREEN_WIDTH, size.height+10+faceViewHeight);
    }];
}


#pragma mark - tableview

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    else
        return 30;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 1.5, SCREEN_WIDTH-30, 26.5)];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.font = [UIFont systemFontOfSize:17];
    headerLabel.textColor = TITLE_COLOR;
    headerLabel.text = @"    评论";
    return headerLabel;
}
#define ImageCountPerRow 4

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        CGFloat imageViewHeight = 0;
        NSString *content = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"content"];
        NSArray *imgsArray = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"img"];
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
        
        imageViewHeight = row * (60+5);
        CGFloat he= 0;
        if (SYSVERSION>=7)
        {
            he = 10;
        }
        CGFloat contentHtight;
        if ([content length]>0)
        {
            contentHtight = [Tools getSizeWithString:content andWidth:SCREEN_WIDTH-50 andFont:nil].height;
        }
        else
        {
            contentHtight = -15;
        }
        
        CGFloat tmpcommentHeight = 0;
        if ([[diaryDetailDict objectForKey:@"comments_num"] integerValue] > 0)
        {
            NSArray *array = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"comments"];
            for (int i=0; i<[array count]; ++i)
            {
                NSDictionary *dict = [array objectAtIndex:i];
                NSString *name = [[dict objectForKey:@"by"] objectForKey:@"name"];
                NSString *content = [dict objectForKey:@"content"];
                NSString *contentString = [NSString stringWithFormat:@"%@:%@",name,content];
                CGSize s = [Tools getSizeWithString:contentString andWidth:200 andFont:[UIFont systemFontOfSize:14]];
                tmpcommentHeight += (s.height > 25 ? (s.height+13):35);
            }
            
        }
        if ([[diaryDetailDict objectForKey:@"likes_num"] integerValue] > 0)
        {
//            int row = [[diaryDetailDict objectForKey:@"likes_num"] integerValue]%4 == 0 ? ([[diaryDetailDict objectForKey:@"likes_num"] integerValue]/4):([[diaryDetailDict objectForKey:@"likes_num"] integerValue]/4+1);
            int likes_num = [[diaryDetailDict objectForKey:@"likes_num"] integerValue];
            
            int row = likes_num % ColumnPerRow == 0 ? (likes_num/ColumnPerRow):(likes_num/ColumnPerRow+1);
            tmpcommentHeight+=(36+(PraiseW+5)*row);
        }

        
        return 60+imageViewHeight+contentHtight+75+he+tmpcommentHeight+5;
    }
    else if(indexPath.section == 1)
    {
        NSDictionary *dict = [commentsArray objectAtIndex:[commentsArray count] - indexPath.row-1];
        NSString *contentStr = [dict objectForKey:@"content"];
        CGSize size = [Tools getSizeWithString:contentStr andWidth:SCREEN_WIDTH-50 andFont:nil];
        return size.height+68;
    }
    return 0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (diaryDetailDict)
        {
            return 1;
        }
    }
    return 0;
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *topImageView = @"trendcell";
    TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:topImageView];
    if (cell == nil)
    {
        cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topImageView];
    }
    
    cell.showAllComments = YES;
    
    NSString *name = [[diaryDetailDict objectForKey:@"by"] objectForKey:@"name"];
    
    NSString *nameStr;
    NSArray *classmen = [db findSetWithDictionary:@{@"uid":[[diaryDetailDict objectForKey:@"by"] objectForKey:@"_id"],@"classid":classID} andTableName:CLASSMEMBERTABLE];
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
    
    cell.nameLabel.frame = CGRectMake(60, 5, [nameStr length]*25>170?170:([nameStr length]*18), 30);
    cell.nameLabel.text = nameStr;
    cell.nameLabel.font = [UIFont systemFontOfSize:15];
    cell.nameLabel.textColor = NAMECOLOR;
    cell.timeLabel.frame = CGRectMake(cell.nameLabel.frame.size.width+cell.nameLabel.frame.origin.x, 5, SCREEN_WIDTH-cell.nameLabel.frame.origin.x-cell.nameLabel.frame.size.width-20, 30);
    cell.timeLabel.textAlignment = NSTextAlignmentRight;
    cell.timeLabel.numberOfLines = 1;
    cell.timeLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    
    cell.nameLabel.text = nameStr;
    cell.timeLabel.text = [Tools showTime:[NSString stringWithFormat:@"%d",[[[diaryDetailDict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]];
    
    cell.locationLabel.frame = CGRectMake(60, cell.headerImageView.frame.origin.y+cell.headerImageView.frame.size.height-20, SCREEN_WIDTH-80, 20);
    
    cell.locationLabel.text = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"add"];
    cell.locationLabel.numberOfLines = 2;
    cell.locationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.headerImageView.layer.cornerRadius = 0;
    cell.headerImageView.clipsToBounds = YES;
    
    [Tools fillImageView:cell.headerImageView withImageFromURL:[[diaryDetailDict objectForKey:@"by"] objectForKey:@"img_icon"] andDefault:HEADERICON];
    cell.locationLabel.numberOfLines = 1;
    cell.locationLabel.lineBreakMode = NSLineBreakByWordWrapping | NSLineBreakByTruncatingTail;
    
    cell.headerImageView.hidden = NO;
    cell.contentLabel.hidden = YES;
    cell.imagesScrollView.hidden = YES;
    cell.nameLabel.hidden = NO;
    cell.locationLabel.hidden = NO;
    cell.timeLabel.hidden = NO;
    cell.praiseButton.hidden = NO;
    cell.commentButton.hidden = NO;
    
    for(UIView *v in cell.imagesScrollView.subviews)
    {
        [v removeFromSuperview];
    }
    if (!([[[diaryDetailDict objectForKey:@"detail"] objectForKey:@"content"] length] <= 0))
    {
        CGFloat he = 0;
        if (SYSVERSION >= 7)
        {
            he = 10;
        }
        //有文字
        cell.contentLabel.hidden = NO;
        NSString *content = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"content"];
        CGSize contentSize = [Tools getSizeWithString:content andWidth:SCREEN_WIDTH-50 andFont:[UIFont systemFontOfSize:16]];
        cell.contentLabel.text = [[[diaryDetailDict objectForKey:@"detail"] objectForKey:@"content"] emojizedString];
        cell.contentLabel.textColor = [UIColor blackColor];
        cell.contentLabel.frame = CGRectMake(15, 60, SCREEN_WIDTH-30, contentSize.height+8+he);
    }
    else
    {
        cell.contentLabel.frame = CGRectMake(10, 60, 0, 0);
    }
    
    CGFloat imageViewHeight = 67.5f;
    CGFloat imageViewWidth = 67.5f;
    if ([[[diaryDetailDict objectForKey:@"detail"] objectForKey:@"img"] count] > 0)
    {
        //有图片
        cell.imagesScrollView.hidden = NO;
        
        NSArray *imgsArray = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"img"];
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
        cell.imagesView.frame = CGRectMake(12,
                                           cell.contentLabel.frame.size.height +
                                           cell.contentLabel.frame.origin.y+7,
                                           SCREEN_WIDTH-20, (imageViewHeight+5) * row);
        
        for (int i=0; i<[imgsArray count]; ++i)
        {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake((i%(NSInteger)ImageCountPerRow)*(imageViewWidth+5), (imageViewWidth+5)*(i/(NSInteger)ImageCountPerRow), imageViewWidth, imageViewHeight);
            imageView.userInteractionEnabled = YES;
            imageView.tag = (indexPath.row)*1000+i+1000;
            
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
            
            // 内容模式
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [Tools fillImageView:imageView withImageFromURL:[imgsArray objectAtIndex:i] andDefault:@"3100"];
            [cell.imagesView addSubview:imageView];
        }
    }
    else
    {
        cell.imagesView.frame = CGRectMake(5, cell.contentLabel.frame.size.height+cell.contentLabel.frame.origin.y, SCREEN_WIDTH-10, 0);
    }
    
    CGFloat buttonHeight = 37;
    CGFloat iconH = 18;
    CGFloat iconTop = 9;

    cell.transmitButton.hidden = NO;
    [cell.transmitButton setTitle:@"   转发" forState:UIControlStateNormal];
    cell.transmitButton.frame = CGRectMake(0, cell.imagesView.frame.size.height+cell.imagesView.frame.origin.y+16, (SCREEN_WIDTH-10)/3, buttonHeight);
    [cell.transmitButton addTarget:self action:@selector(shareAPP) forControlEvents:UIControlEventTouchUpInside];
    cell.transmitButton.iconImageView.frame = CGRectMake(18, iconTop+1, iconH, iconH);
    cell.transmitButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
    
    cell.praiseButton.frame = CGRectMake((SCREEN_WIDTH-10)/3, cell.imagesView.frame.size.height+cell.imagesView.frame.origin.y+16, (SCREEN_WIDTH-10)/3, buttonHeight);
    if ([[diaryDetailDict objectForKey:@"likes_num"] integerValue] > 0)
    {
        [cell.praiseButton setTitle:[NSString stringWithFormat:@"   %d",[[diaryDetailDict objectForKey:@"likes_num"] integerValue]] forState:UIControlStateNormal];
    }
    else
    {
        [cell.praiseButton setTitle:@"   赞" forState:UIControlStateNormal];
    }
    if ([self havePraisedThisDiary:diaryDetailDict])
    {
        cell.praiseButton.iconImageView.image = [UIImage imageNamed:@"praised"];
        cell.praiseButton.iconImageView.frame = CGRectMake(27, iconTop, iconH, iconH);
    }
    else
    {
        cell.praiseButton.iconImageView.image = [UIImage imageNamed:@"icon_heart"];
        cell.praiseButton.iconImageView.frame = CGRectMake(25, iconTop, iconH, iconH);
    }
    cell.praiseButton.backgroundColor = UIColorFromRGB(0xfcfcfc);
    
    
     cell.commentButton.frame = CGRectMake((SCREEN_WIDTH-10)/3*2, cell.imagesView.frame.size.height+cell.imagesView.frame.origin.y+16, (SCREEN_WIDTH-10)/3, buttonHeight);
    if ([[diaryDetailDict objectForKey:@"comments_num"] integerValue] > 0)
    {
        [cell.commentButton setTitle:[NSString stringWithFormat:@"   %d",[[diaryDetailDict objectForKey:@"comments_num"] integerValue]] forState:UIControlStateNormal];
        cell.commentButton.iconImageView.frame = CGRectMake(25, iconTop, iconH, iconH);
    }
    else
    {
        [cell.commentButton setTitle:@"  评论" forState:UIControlStateNormal];
        cell.commentButton.iconImageView.frame = CGRectMake(18, iconTop, iconH, iconH);
    }
    cell.commentButton.backgroundColor = UIColorFromRGB(0xfcfcfc);

    cell.geduan1.hidden = NO;
    cell.geduan2.hidden = NO;
    cell.geduan1.frame = CGRectMake(cell.transmitButton.frame.size.width+cell.transmitButton.frame.origin.x, cell.transmitButton.frame.origin.y+9.5, 1, 18);
    cell.geduan2.frame = CGRectMake(cell.praiseButton.frame.size.width+cell.praiseButton.frame.origin.x, cell.praiseButton.frame.origin.y+9.5, 1, 18);
    
    [cell.praiseButton addTarget:self action:@selector(praiseDiary) forControlEvents:UIControlEventTouchUpInside];

    [cell.commentButton addTarget:self action:@selector(startCommit) forControlEvents:UIControlEventTouchUpInside];
    
    if ([[diaryDetailDict objectForKey:@"comments_num"] integerValue] > 0 || [diaryDetailDict objectForKey:@"likes_num"] > 0)
    {
        NSArray *comArray = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"comments"];
        if ([comArray count] > 0)
        {
            cell.commentsArray = comArray;
        }
        else
        {
            cell.commentsArray = nil;
        }
        NSArray *praiseArray = [[diaryDetailDict objectForKey:@"detail"] objectForKey:@"likes"];
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
        cell.bgView.frame = CGRectMake(5, 5, SCREEN_WIDTH-10,
                                       cell.commentsTableView.frame.size.height+
                                       cell.commentsTableView.frame.origin.y);
    }
    else
    {
        cell.commentsArray = nil;
        cell.praiseArray = nil;
        [cell.commentsTableView reloadData];
        cell.bgView.frame = CGRectMake(5, 5, SCREEN_WIDTH-10,
                                       cell.praiseButton.frame.size.height+
                                       cell.praiseButton.frame.origin.y);
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.bgView.layer.borderWidth = 1;
    cell.bgView.layer.cornerRadius = 5;
    cell.bgView.clipsToBounds = YES;
    cell.backgroundColor = [UIColor clearColor];
    return cell;
   
}

-(BOOL)havePraisedThisDiary:(NSDictionary *)diaryDict
{
    NSArray *praiseArray = [[diaryDict objectForKey:@"detail"] objectForKey:@"likes"];
    for (int i = 0; i < [praiseArray count]; i++)
    {
        NSDictionary *dict = [praiseArray objectAtIndex:i];
        if ([[[dict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
        {
            return YES;
        }
    }
    return NO;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [inputTabBar backKeyBoard];
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
        photo.url = [NSURL URLWithString:url];
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
    [inputTabBar.inputTextView becomeFirstResponder];
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
                
                if ([self.addComDel respondsToSelector:@selector(addComment:)])
                {
                    [self.addComDel addComment:YES];
                }
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
                
                if ([self.addComDel respondsToSelector:@selector(addComment:)])
                {
                    [self.addComDel addComment:YES];
                }
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

-(void)deleteDiary
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":dongtaiId,
                                                                      @"c_id":classID,
                                                                      } API:DELETEDIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"delete diary responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showTips:@"日志删除成功" toView:diaryDetailTableView];
                if ([self.addComDel respondsToSelector:@selector(addComment:)])
                {
                    [self.addComDel addComment:YES];
                }
                [self.navigationController popViewControllerAnimated:YES];
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
                
                if (fromclass)
                {
                    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] ==2 || [[[diaryDetailDict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
                    {
                        moreButton.hidden = NO;
                    }
                }
                else
                {
                    if ([[[diaryDetailDict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
                    {
                        moreButton.hidden = NO;
                    }

                }
                
                waitTransDict = [diaryDetailDict objectForKey:@"detail"];
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


#pragma mark - shareAPP
-(void)shareAPP
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"转发到" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博",@"QQ空间",@"腾讯微博",@"QQ好友",@"微信朋友圈",@"人人网", nil];
    actionSheet.tag = 4444;
    [actionSheet showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 4444)
    {
        DDLOG(@"waittransdict %@",diaryDetailDict);
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
    else if (actionSheet.tag == 3333)
    {
        if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"admin"] integerValue] ==2 || [[[diaryDetailDict objectForKey:@"by"] objectForKey:@"_id"] isEqualToString:[Tools user_id]])
        {
            if (buttonIndex == 0)
            {
                [self deleteDiary];
            }
            else if(buttonIndex == 1)
            {
                ReportViewController *reportVC = [[ReportViewController alloc] init];
                reportVC.reportUserid = [[diaryDetailDict objectForKey:@"by"] objectForKey:@"_id"];
                reportVC.reportContentID = dongtaiId;
                reportVC.reportType = @"content";
                [self.navigationController pushViewController:reportVC animated:YES];
            }
        }
        else
        {
            if(buttonIndex == 0)
            {
                ReportViewController *reportVC = [[ReportViewController alloc] init];
                reportVC.reportUserid = [[diaryDetailDict objectForKey:@"by"] objectForKey:@"_id"];
                reportVC.reportContentID = dongtaiId;
                reportVC.reportType = @"content";
                [self.navigationController pushViewController:reportVC animated:YES];
            }
        }
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
    if ([waitTransDict objectForKey:@"content"])
    {
        if ([[waitTransDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransDict objectForKey:@"img"])
    {
        if ([[waitTransDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransDict objectForKey:@"img"] firstObject]];
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
    if ([waitTransDict objectForKey:@"content"])
    {
        if ([[waitTransDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    NSString *imagePath;
    if ([waitTransDict objectForKey:@"img"])
    {
        if ([[waitTransDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransDict objectForKey:@"img"] firstObject]];
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
    if ([waitTransDict objectForKey:@"content"])
    {
        if ([[waitTransDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransDict objectForKey:@"img"])
    {
        if ([[waitTransDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransDict objectForKey:@"img"] firstObject]];
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
    if ([waitTransDict objectForKey:@"content"])
    {
        if ([[waitTransDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransDict objectForKey:@"img"])
    {
        if ([[waitTransDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransDict objectForKey:@"img"] firstObject]];
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
    if ([waitTransDict objectForKey:@"content"])
    {
        if ([[waitTransDict objectForKey:@"content"] length] > 0)
        {
            content = [waitTransDict objectForKey:@"content"];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransDict objectForKey:@"img"])
    {
        if ([[waitTransDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransDict objectForKey:@"img"] firstObject]];
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
    if ([waitTransDict objectForKey:@"content"])
    {
        if ([[waitTransDict objectForKey:@"content"] length] > 0)
        {
            content = [NSString stringWithFormat:@"%@%@",[waitTransDict objectForKey:@"content"],ShareUrl];
        }
    }
    
    
    NSString *imagePath;
    if ([waitTransDict objectForKey:@"img"])
    {
        if ([[waitTransDict objectForKey:@"img"] count] > 0)
        {
            imagePath = [NSString stringWithFormat:@"%@%@",IMAGEURL,[[waitTransDict objectForKey:@"img"] firstObject]];
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


@end
