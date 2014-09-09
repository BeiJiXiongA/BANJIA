//
//  NewDiariesViewController.m
//  School
//
//  Created by TeekerZW on 3/20/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "NewDiariesViewController.h"
#import "TrendsCell.h"
#import "Header.h"


#import "UIImageView+WebCache.h"

#define GIARYTAG  100000

@interface NewDiariesViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *newDiariesTableView;
    NSMutableArray *tmpArray;
}
@end

@implementation NewDiariesViewController
@synthesize classID;
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
    
    self.titleLabel.text = @"待审核日志";
    
    
    DDLOG(@"frame=%@",NSStringFromCGRect(self.bgView.frame));
    self.navigationBarView.backgroundColor = [UIColor redColor];
    
    tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    newDiariesTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    newDiariesTableView.delegate = self;
    newDiariesTableView.dataSource = self;
    [self.bgView addSubview:newDiariesTableView];
    
    [self getNewDiaries];
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

-(void)getNewDiaries
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID
                                                                      } API:GETNEWDIARIES];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"newdiaries responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [tmpArray addObjectsFromArray:[responseDict objectForKey:@"data"]];
                [newDiariesTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
}

-(void)allow:(UIButton *)button
{
    NSDictionary *dict = [tmpArray objectAtIndex:button.tag/GIARYTAG];
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"p_id":[dict objectForKey:@"_id"]
                                                                      } API:ALLOW_DIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"allow responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [tmpArray removeObjectAtIndex:button.tag/GIARYTAG];
                [Tools showAlertView:@"已经同意本条日志" delegateViewController:nil];
                if ([self.classZoneDelegate respondsToSelector:@selector(haveAddDonfTai:)])
                {
                    [self.classZoneDelegate haveAddDonfTai:YES];
                }
                if ([tmpArray count] == 0)
                {
                    [self unShowSelfViewController];
                }
                [newDiariesTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
}
-(void)ignore:(UIButton *)button
{
    NSDictionary *dict = [tmpArray objectAtIndex:button.tag/GIARYTAG];
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID,
                                                                      @"p_id":[dict objectForKey:@"_id"]
                                                                      } API:IGNORE_DIARY];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"ignore responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [tmpArray removeObjectAtIndex:button.tag/GIARYTAG];
                [Tools showAlertView:@"已经忽略本条日志" delegateViewController:nil];
                if ([self.classZoneDelegate respondsToSelector:@selector(haveAddDonfTai:)])
                {
                    [self.classZoneDelegate haveAddDonfTai:YES];
                }
                if ([tmpArray count] == 0)
                {
                    [self unShowSelfViewController];
                }
                [newDiariesTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
        }];
        [request startAsynchronous];
    }
}
#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tmpArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat imageViewHeight = 134;
    NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
    NSString *content = [dict objectForKey:@"content"];
    NSArray *imgsArray = [[dict objectForKey:@"img"] count]>0?[dict objectForKey:@"img"]:nil;
    CGFloat imgsHeight = [imgsArray count]>0?(imageViewHeight+10):10;
    CGFloat contentHtight = [content length]>0?35:0;
    return 60+imgsHeight+contentHtight+50;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *topImageView = @"trendcell";
    TrendsCell *cell = [tableView dequeueReusableCellWithIdentifier:topImageView];
    if (cell == nil)
    {
        cell = [[TrendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:topImageView];
    }
    NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
    NSString *name = [[dict objectForKey:@"by"] objectForKey:@"name"];
    cell.nameLabel.frame = CGRectMake(60, 5, [name length]*25, 30);
    cell.nameLabel.text = name;
    cell.timeLabel.frame = CGRectMake(cell.nameLabel.frame.size.width+cell.nameLabel.frame.origin.x+10, 5, SCREEN_WIDTH-cell.nameLabel.frame.origin.x-cell.nameLabel.frame.size.width-20, 30);
    cell.timeLabel.textAlignment = NSTextAlignmentRight;
    cell.timeLabel.text = [Tools showTime:[NSString stringWithFormat:@"%d",[[[dict objectForKey:@"created"] objectForKey:@"sec"] integerValue]]];
    cell.headerImageView.layer.cornerRadius = cell.headerImageView.frame.size.width/2;
    cell.headerImageView.clipsToBounds = YES;
    [Tools fillImageView:cell.headerImageView withImageFromURL:@"" andDefault:HEADERDEFAULT];
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
        //有文字
        cell.contentLabel.hidden = NO;
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
        
        cell.imagesView.tag = 10000*indexPath.row;
        UIImage *placeholder = [UIImage imageNamed:@"0.jpg"];
        for (int i=0; i<[imgsArray count]; ++i)
        {
            UIImageView *imageView = [[UIImageView alloc] init];
            imageView.frame = CGRectMake(i*(imageViewWidth+5), 0, imageViewWidth, imageViewHeight);
            imageView.userInteractionEnabled = YES;
            imageView.tag = (indexPath.row)*1000+i+1000;
            
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)]];
            
            
            [imageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",IMAGEURL,[imgsArray objectAtIndex:i]]] placeholderImage:placeholder];
            
            // 内容模式
            imageView.clipsToBounds = YES;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            [Tools fillImageView:imageView withImageFromURL:[imgsArray objectAtIndex:i] andDefault:@"0.jpg"];
        }
    }
    else
    {
    }
    [cell.transmitButton setTitle:@"转发" forState:UIControlStateNormal];
    [cell.praiseButton setTitle:@"同意" forState:UIControlStateNormal];
    [cell.praiseButton addTarget:self action:@selector(allow:) forControlEvents:UIControlEventTouchUpInside];
    cell.praiseButton.tag = indexPath.row*GIARYTAG;
    [cell.commentButton setTitle:@"忽略" forState:UIControlStateNormal];
    cell.commentButton.tag = indexPath.row*GIARYTAG;
    [cell.commentButton addTarget:self action:@selector(ignore:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.bgView.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tapImage:(UITapGestureRecognizer *)tap
{
    
}
@end
