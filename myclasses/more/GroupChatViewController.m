//
//  GroupChatViewController.m
//  BANJIA
//
//  Created by TeekerZW on 7/21/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "GroupChatViewController.h"
#import "SelectChatMemberViewController.h"
#import "MemberCell.h"
#import "ChatViewController.h"

#import "EGORefreshTableHeaderView.h"
#import "NSString+Emojize.h"

@interface GroupChatViewController ()<UITableViewDataSource,EGORefreshTableHeaderDelegate,UITableViewDelegate>
{
    NSString *role;
    NSString *classID;
    
    NSMutableArray *groupChatArray;
    UITableView *groupChatTableView;
    
    EGORefreshTableHeaderView *pullRefreshView;
    BOOL _reloading;
    
    OperatDB *db;
}
@end

@implementation GroupChatViewController

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealNewChatMsg) name:RECEIVENEWMSG object:nil];
    [groupChatTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.titleLabel.text = @"群聊";
    
    groupChatArray = [[NSMutableArray alloc] initWithCapacity:0];
    db = [[OperatDB alloc] init];
    
    role = [[NSUserDefaults standardUserDefaults] objectForKey:@"role"];
    classID = [[NSUserDefaults standardUserDefaults] objectForKey:@"classid"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroupChatList) name:UPDATEGROUPCHATLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGroupChatList) name:RECEIVENEWMSG object:nil];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(SCREEN_WIDTH - 60, self.backButton.frame.origin.y, 50, NAV_RIGHT_BUTTON_HEIGHT);
    [addButton addTarget:self action:@selector(addClick) forControlEvents:UIControlEventTouchUpInside];
    [addButton setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    [self.navigationBarView addSubview:addButton];
    
    groupChatTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    groupChatTableView.delegate = self;
    groupChatTableView.dataSource = self;
    groupChatTableView.backgroundColor = self.bgView.backgroundColor;
    groupChatTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:groupChatTableView];
    
    _reloading = NO;
    pullRefreshView = [[EGORefreshTableHeaderView alloc] initWithScrollView:groupChatTableView orientation:EGOPullOrientationDown];
    pullRefreshView.delegate = self;
    
    [self getGroupChatList];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UPDATEGROUPCHATLIST object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RECEIVENEWMSG object:nil];
}

-(void)addClick
{
    SelectChatMemberViewController *selectMemberViewController = [[SelectChatMemberViewController alloc] init];
    [self.navigationController pushViewController:selectMemberViewController animated:YES];
}

-(void)dealNewChatMsg
{
    [groupChatTableView reloadData];
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

-(NSDictionary *)findLastMsgWithUser:(NSString *)fid
{
    NSMutableArray *array = [db findChatLogWithUid:[Tools user_id] andOtherId:fid andTableName:CHATTABLE];
    return [array lastObject];
}

-(int)findCountOfUserId:(NSString *)fid
{
    NSMutableArray *array = [db findSetWithDictionary:@{@"userid":[Tools user_id],@"fid":fid,@"readed":@"0"} andTableName:CHATTABLE];
    return [array count];
}


#pragma mark - egodelegate
-(void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    [self getGroupChatList];
    //    [self dealNewChatMsg:nil];
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
    [pullRefreshView egoRefreshScrollViewDidScroll:groupChatTableView];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [pullRefreshView egoRefreshScrollViewDidEndDragging:groupChatTableView];
}



#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [groupChatArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *chatCell = @"chatcell";
    MemberCell *cell = [tableView dequeueReusableCellWithIdentifier:chatCell];
    if (cell == nil)
    {
        cell = [[MemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:chatCell];
    }
    NSDictionary *dict = [groupChatArray objectAtIndex:indexPath.row];
    cell.headerImageView.frame = CGRectMake(10, 7, 46, 46);
    
    cell.headerImageView.layer.cornerRadius = 5;
    cell.headerImageView.clipsToBounds = YES;
    [cell.headerImageView setImage:[UIImage imageNamed:@"headpic.jpg"]];
    
    cell.memNameLabel.frame = CGRectMake(70, 7, 220, 20);
    
    NSString *fname = [dict objectForKey:@"name"];
    NSRange range = [fname rangeOfString:@"("];
    NSRange range1 = [fname rangeOfString:@"人"];
    if ([fname length] > 13 && range.length > 0 && range1.length > 0)
    {
        cell.memNameLabel.text = [NSString stringWithFormat:@"%@...%@",[fname substringToIndex:8],[fname substringFromIndex:range.location]];
    }
    else
    {
        cell.memNameLabel.text = [dict objectForKey:@"name"];
    }

    cell.memNameLabel.font = [UIFont systemFontOfSize:16];
    cell.unreadedMsgLabel.hidden = YES;
    
    NSDictionary *msgDict = [self findLastMsgWithUser:[dict objectForKey:@"_id"]];
    if (msgDict)
    {
        cell.remarkLabel.frame = CGRectMake(cell.memNameLabel.frame.origin.x, cell.memNameLabel.frame.origin.y+cell.memNameLabel.frame.size.height+5, 220, 18);
        cell.remarkLabel.font = [UIFont systemFontOfSize:14];
        cell.remarkLabel.hidden = NO;
        NSDictionary *userIconDict = [ImageTools iconDictWithUserID:[msgDict objectForKey:@"by"]];
        NSString *byName;
        if (userIconDict)
        {
            byName = [userIconDict objectForKey:@"username"];
        }
        NSString *msgContent = [[msgDict objectForKey:@"content"] emojizedString];
        if ([[msgContent pathExtension] isEqualToString:@"png"] || [[msgContent pathExtension] isEqualToString:@"jpg"])
        {
            cell.remarkLabel.text = [NSString stringWithFormat:@"%@:%@",byName,@"图片"];
        }
        else
        {
            cell.remarkLabel.text = [[NSString stringWithFormat:@"%@:%@",byName,[msgDict objectForKey:@"content"]] emojizedString];
        }
        cell.remarkLabel.textAlignment = NSTextAlignmentLeft;
        cell.remarkLabel.textColor = COMMENTCOLOR;
    }
    DDLOG(@"unread count %d",[self findCountOfUserId:[dict objectForKey:@"_id"]]);
    
    [cell.contentView bringSubviewToFront:cell.unreadedMsgLabel];
    cell.unreadedMsgLabel.backgroundColor = [UIColor redColor];
    int unReadCount = [self findCountOfUserId:[dict objectForKey:@"_id"]];
    if (unReadCount > 0)
    {
        cell.unreadedMsgLabel.hidden = NO;
        cell.unreadedMsgLabel.text = [NSString stringWithFormat:@"%d",unReadCount];
    }
    else
    {
        cell.unreadedMsgLabel.hidden = YES;
    }
    
    CGFloat cellHeight = [tableView rectForRowAtIndexPath:indexPath].size.height;
    UIImageView *lineImageView = [[UIImageView alloc] init];
    lineImageView.frame = CGRectMake(0, cellHeight-0.5, cell.frame.size.width, 0.5);
    lineImageView.backgroundColor = LineBackGroudColor;
    [cell.contentView addSubview:lineImageView];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    UIImageView *markView = [[UIImageView alloc] init];
    markView.hidden = NO;
    markView.frame = CGRectMake(SCREEN_WIDTH-20, 24, 8, 12);
    [markView setImage:[UIImage imageNamed:@"discovery_arrow"]];
    [cell.contentView addSubview:markView];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [groupChatArray objectAtIndex:indexPath.row];
    ChatViewController  *chat = [[ChatViewController alloc] init];
    chat.isGroup = YES;
    chat.name = [dict objectForKey:@"name"];
    chat.toID = [dict objectForKey:@"_id"];
    chat.imageUrl = @"";
    [self.navigationController pushViewController:chat animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)getGroupChatList
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID
                                                                      } API:GROUPCHATLIST];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"get group list responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [groupChatArray removeAllObjects];
                [groupChatArray addObjectsFromArray:[responseDict objectForKey:@"data"]];
                [groupChatTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
            _reloading = NO;
            [pullRefreshView egoRefreshScrollViewDataSourceDidFinishedLoading:groupChatTableView];
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
            
        }];
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
