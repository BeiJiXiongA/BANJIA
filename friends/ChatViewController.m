//
//  ChatViewController.m
//  School
//
//  Created by TeekerZW on 14-3-4.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "ChatViewController.h"
#import "Header.h"
#import "MessageCell.h"
#import "Base64.h"
#import "AppDelegate.h"
#import "OperatDB.h"
#import "InputTableBar.h"
#import "ClassZoneViewController.h"


#define DIRECT  @"direct"
#define TYPE    @"msgType"
#define TEXTMEG  @"text"
#define IMAGEMSG  @"image"

#define Image_H 180


@interface ChatViewController ()<UITableViewDataSource,
UITableViewDelegate,
UITextFieldDelegate,
UIActionSheetDelegate,
ChatDelegate,
ReturnFunctionDelegate>
{
    NSMutableArray *messageArray;
    UITableView *messageTableView;
    
    UIImagePickerController *imagePickerController;
    UIButton*editButton;
    BOOL edittingTableView;
    
    InputTableBar *inputTabBar;
    
    OperatDB *db;
    
    UIImage *fromImage;
    UIImage *toImage;
    
    NSInteger currentSec;
}
@end

@implementation ChatViewController
@synthesize name,toID,imageUrl,chatVcDel;
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
    self.titleLabel.text = name;
        
    db = [[OperatDB alloc] init];
    if ([imageUrl isEqualToString:@"null"])
    {
        imageUrl = nil;
    }
    
    currentSec = 0;
    
    fromImage = [Tools getImageFromImage:[UIImage imageNamed:@"f"] andInsets:UIEdgeInsetsMake(35, 40, 17, 40)];
    toImage = [Tools getImageFromImage:[UIImage imageNamed:@"t"] andInsets:UIEdgeInsetsMake(35, 40, 17, 40)];
    
    edittingTableView = NO;
    editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame = CGRectMake(SCREEN_WIDTH - 60, 4, 50, 36);
    [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    editButton.backgroundColor = [UIColor clearColor];
    [editButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
    [editButton addTarget:self action:@selector(editTableView) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:editButton];
    
    messageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    
    messageTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-UI_NAVIGATION_BAR_HEIGHT-40) style:UITableViewStylePlain];
    messageTableView.delegate = self;
    messageTableView.dataSource = self;
    messageTableView.backgroundColor = [UIColor clearColor];
    messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.bgView addSubview:messageTableView];
    
    inputTabBar = [[InputTableBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40)];
    inputTabBar.backgroundColor = [UIColor whiteColor];
    inputTabBar.returnFunDel = self;
    [self.bgView addSubview:inputTabBar];
    if ([Tools NetworkReachable])
    {
        [self getChatLog];
    }
    else
    {
        [self dealNewChatMsg:nil];
    }
    [self dealNewChatMsg:nil];
    [self.backButton addTarget:self action:@selector(myBackButtonClick) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = self;
    
    [MobClick beginLogPageView:@"PageOne"];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"PageOne"];
    
    inputTabBar.returnFunDel = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:inputTabBar];
    
    ((AppDelegate *)[[UIApplication sharedApplication] delegate]).chatDelegate = nil;
}


-(void)myBackButtonClick
{
    [self uploadLastViewTime];
    [self unShowSelfViewController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - getchatlog
-(void)getChatLog
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"t_id":toID,
                                                                      } API:GETCHATLOG];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"chat=log=responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                    NSArray *array = [[NSArray alloc] initWithArray:[responseDict objectForKey:@"data"]];
                    for (int i=0; i<[array count]; ++i)
                    {
                        NSMutableDictionary *chatDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                        NSDictionary *dict = [array objectAtIndex:i];
                        [chatDict setObject:[dict objectForKey:@"_id"] forKey:@"mid"];
                        [chatDict setObject:[Tools user_id] forKey:@"userid"];
                        [chatDict setObject:[dict objectForKey:@"by"] forKey:@"fid"];
                        [chatDict setObject:[dict objectForKey:@"msg"] forKey:@"content"];
                        [chatDict setObject:[NSString stringWithFormat:@"%f",[[dict objectForKey:@"t"] floatValue]] forKey:@"time"];
                        [chatDict setObject:imageUrl?imageUrl:@"" forKey:@"ficon"];
                        [chatDict setObject:@"1" forKey:@"readed"];
                        [chatDict setObject:TEXTMEG forKey:@"msgType"];
                        if ([[dict objectForKey:@"by"] isEqualToString:[Tools user_id]])
                        {
                            [chatDict setObject:toID forKey:@"tid"];
                            [chatDict setObject:[Tools user_name] forKey:@"fname"];
                            [chatDict setObject:@"t" forKey:@"direct"];
                        }
                        else if([[dict objectForKey:@"by"] isEqualToString:toID])
                        {
                            [chatDict setObject:[Tools user_id] forKey:@"tid"];
                            [chatDict setObject:name forKey:@"fname"];
                            [chatDict setObject:@"f" forKey:@"direct"];
                        }
                        if ([[db findSetWithKey:@"mid" andValue:[dict objectForKey:@"_id"] andTableName:@"chatMsg"] count] <= 0)
                        {
                            [db insertRecord:chatDict andTableName:@"chatMsg"];
                        }
                        [self dealNewChatMsg:nil];
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

#pragma mark - lastViewTime
-(void)uploadLastViewTime
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"t_id":toID
                                                                      } API:LASTVIEWTIME];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"friendsList responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                
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

}

#pragma mark - returnfunctionDelegate
-(void)myReturnFunction
{
    NSString *sendStr = [inputTabBar analyString:inputTabBar.inputTextView.text];
    
    
    if (inputTabBar.inputTextView.text.length == 0)
    {
        [Tools showAlertView:@"消息不能为空！" delegateViewController:nil];
        return ;
    }
    if ([inputTabBar.inputTextView.text length]>0)
    {
        [self sendMsgWithString:[inputTabBar analyString:inputTabBar.inputTextView.text]];
    }
    DDLOG(@"sendStr===%@",sendStr);
    
//    [UIView animateWithDuration:0.2 animations:^{
//        self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y);
//    }];
}

-(void)showKeyBoard:(CGFloat)keyBoardHeight
{
//    [UIView animateWithDuration:0.2 animations:^{
//        self.bgView.center = CGPointMake(CENTER_POINT.x, CENTER_POINT.y);
//    }];
}

#pragma mark - chatDelegate
-(void)dealNewChatMsg:(NSDictionary *)dict
{
    [messageArray removeAllObjects];
    [messageArray addObjectsFromArray:[db findChatLogWithUid:[Tools user_id] andOtherId:toID andTableName:@"chatMsg"]];
    for (int i=0; i<[messageArray count]; ++i)
    {
        NSDictionary *tmpDict = [messageArray objectAtIndex:i];
        [db updeteKey:@"readed" toValue:@"1" withParaDict:@{@"fid":[tmpDict objectForKey:@"fid"],@"userid":[Tools user_id]} andTableName:@"chatMsg"];
    }
    
    [messageTableView reloadData];
    if (messageTableView.contentSize.height>messageTableView.frame.size.height)
    {
        messageTableView.contentOffset = CGPointMake(0, messageTableView.contentSize.height-messageTableView.frame.size.height);
    }
    if ([self.chatVcDel respondsToSelector:@selector(updateChatList:)])
    {
        [self.chatVcDel updateChatList:YES];
    }
}

#pragma mark - takepicture

-(void)takePicture:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册获取", nil];
    [actionSheet showInView:self.bgView];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else
        {
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"" message:@"相机不可用！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [al show];
        }
        [self presentViewController:imagePickerController animated:YES completion:^{
            
        }];
    }
    else if(buttonIndex == 1)
    {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentModalViewController:imagePickerController animated:YES];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [imagePickerController dismissViewControllerAnimated:YES completion:^{
        UIImage *originaImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        CGSize size = [self sizeWithImage:originaImage];
        UIImage *image = [Tools thumbnailWithImageWithoutScale:originaImage size:CGSizeMake(size.width*3, size.height*3)];
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSString *imageStr = [NSString stringWithFormat:@"imag%@",[Base64 stringByEncodingData:imageData]];
        
    }];
    
}

#pragma mark - sizeabout
-(CGSize)sizeWithImage:(UIImage *)image
{
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    //    DDLOG(@" imageWidth %.0f imageHeight %.0f",imageWidth,imageHeight);
    
    if (imageWidth >= SCREEN_WIDTH && imageHeight >=Image_H)
    {
        if (imageHeight >= imageWidth)
        {
            height = Image_H;
            width = height*imageWidth/imageHeight;
        }
        else if(imageWidth >= imageHeight)
        {
            width = SCREEN_WIDTH-80;
            height = imageHeight*width/imageWidth;
        }
    }
    else if(imageHeight >= Image_H)
    {
        height = Image_H;
        width = height*imageWidth/imageHeight;
    }
    else if(imageWidth >= SCREEN_WIDTH)
    {
        width = SCREEN_WIDTH-80;
        height = imageHeight*width/imageWidth;
    }
    else
    {
        width = imageWidth;
        height = imageHeight;
    }
    CGSize size = CGSizeMake(width, height);
    return size;
}
-(CGSize)sizeWithText:(NSString *)string
{
    CGSize labsize = [string sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(self.view.frame.size.width-150, 9999) lineBreakMode:NSLineBreakByWordWrapping];
    return labsize;
}


#pragma mark - tableview

-(void)editTableView
{
    if (edittingTableView)
    {
        messageTableView.editing = NO;
        [editButton setTitle:@"编辑" forState:UIControlStateNormal];
    }
    else
    {
        messageTableView.editing = YES;
        [editButton setTitle:@"完成" forState:UIControlStateNormal];
    }
    edittingTableView = !edittingTableView;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [messageArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0;
    CGSize size = [self sizeWithText:[[messageArray objectAtIndex:indexPath.row] objectForKey:@"content"]];
    rowHeight = size.height+50;
    NSDictionary *dict = [messageArray objectAtIndex:indexPath.row];
    if ([[dict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
    {
        NSString *msgContent = [dict objectForKey:@"content"];
        NSRange range = [msgContent rangeOfString:@"$!#"];
        msgContent = [msgContent substringFromIndex:range.location+range.length];
        size = [self sizeWithText:msgContent];
        rowHeight = size.height+50;
    }
    return rowHeight+20;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *messageCell = @"messageCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCell];
    if (cell == nil)
    {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:messageCell];
    }
    
    NSDictionary *dict = [messageArray objectAtIndex:indexPath.row];
    CGFloat messageBgY = 30;
    CGFloat messageTfY = 5;
    CGSize size = [self  sizeWithText:[[dict objectForKey:@"content"] emojizedString]];
    cell.chatBg.hidden = NO;
    cell.messageTf.hidden = NO;
    cell.button.hidden = YES;
    cell.joinlable.hidden = YES;
    cell.messageTf.font = [UIFont systemFontOfSize:16];
    if ([[dict objectForKey:DIRECT] isEqualToString:@"f"])
    {
        if ([[dict objectForKey:TYPE] isEqualToString:TEXTMEG])
        {
            if (currentSec == 0)
            {
                currentSec = [[dict objectForKey:@"time"] integerValue];
            }
            
            cell.timeLabel.frame = CGRectMake(SCREEN_WIDTH/2-50, 5, 100, 20);
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            cell.timeLabel.text = timeStr;
            
            cell.chatBg.frame = CGRectMake(55, messageBgY, size.width+20, size.height+20);
            [cell.chatBg setImage:fromImage];
            
            cell.messageTf.frame = CGRectMake(10, messageTfY, size.width+12, size.height+10);
            cell.messageTf.text = [[dict objectForKey:@"content"] emojizedString];
            cell.messageTf.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if ([[dict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
            {
                
                NSString *msgContent = [dict objectForKey:@"content"];
                NSRange range = [msgContent rangeOfString:@"$!#"];
                cell.messageTf.text = [msgContent substringFromIndex:range.location+range.length];
                
                size = [self sizeWithText:[[msgContent substringFromIndex:range.location+range.length] emojizedString]];
                cell.chatBg.frame = CGRectMake(55, messageBgY, size.width+20, size.height+20);
                cell.messageTf.frame = CGRectMake(10, messageTfY, size.width+12, size.height+10);

                cell.button.frame = cell.chatBg.frame;
                [cell.button addTarget:self action:@selector(joinClass:) forControlEvents:UIControlEventTouchUpInside];
                cell.backgroundColor = [UIColor clearColor];
                cell.button.tag = 5555+indexPath.row;
                cell.button.hidden = NO;
                cell.chatBg.frame = CGRectMake(55, messageBgY, size.width+20, size.height+20+30);
             
                cell.joinlable.frame = CGRectMake(15, cell.chatBg.frame.size.height-35, size.width, 30);
                cell.joinlable.text = @"点击申请加入班级";
                cell.joinlable.hidden = NO;
            }
            else
            {
                cell.button.hidden = YES;
            }
            
            cell.headerImageView.frame = CGRectMake(5, messageBgY, 40, 40);
            if (imageUrl)
            {
                [Tools fillImageView:cell.headerImageView withImageFromURL:imageUrl andDefault:HEADERDEFAULT];
            }
            else
            {
                [cell.headerImageView setImage:[UIImage imageNamed:HEADERDEFAULT]];
            }
        }
    }
    else if([[dict objectForKey:DIRECT] isEqualToString:@"t"])
    {
        if ([[dict objectForKey:TYPE] isEqualToString:TEXTMEG])
        {
            cell.timeLabel.frame = CGRectMake(SCREEN_WIDTH/2-50, 5, 100, 20);
            NSString *timeStr = [Tools showTime:[dict objectForKey:@"time"]];
            cell.timeLabel.text = timeStr;
            
            cell.chatBg.frame = CGRectMake(self.view.frame.size.width - 10-size.width-30-45, messageBgY, size.width+20, size.height+35);
            [cell.chatBg setImage:toImage];
            
            cell.messageTf.frame = CGRectMake(5, messageTfY, size.width+12, size.height+25);
            cell.messageTf.text = [[dict objectForKey:@"content"] emojizedString];
            cell.messageTf.backgroundColor = [UIColor clearColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.button.hidden = YES;
            
            if ([[dict objectForKey:@"content"] rangeOfString:@"$!#"].length >0)
            {
                NSString *msgContent = [dict objectForKey:@"content"];
                NSRange range = [msgContent rangeOfString:@"$!#"];
                cell.messageTf.text = [msgContent substringFromIndex:range.location+range.length];
                size = [self sizeWithText:[[msgContent substringFromIndex:range.location+range.length] emojizedString]];
                cell.chatBg.frame = CGRectMake(self.view.frame.size.width - 10-size.width-30-45, messageBgY, size.width+20, size.height+35);
                cell.messageTf.frame = CGRectMake(10, messageTfY, size.width+12, size.height+30);
            }
            cell.headerImageView.frame = CGRectMake(SCREEN_WIDTH - 60, messageBgY, 40, 40);
            [Tools fillImageView:cell.headerImageView withImageFromURL:[Tools header_image] andDefault:HEADERDEFAULT];
        }
    }
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

-(void)joinClass:(UIButton *)button
{
    NSString *msgContent = [[messageArray objectAtIndex:button.tag-5555] objectForKey:@"content"];
    NSRange range1 = [msgContent rangeOfString:@"$!#"];
    NSRange range2 = [msgContent rangeOfString:@"["];
    NSRange range3 = [msgContent rangeOfString:@"—"];
    NSRange range4 = [msgContent rangeOfString:@"]"];
    NSRange range5 = [msgContent rangeOfString:@"("];
    NSString *classID = [msgContent substringToIndex:range1.location];
    
    NSString *schoolName;
    if (range2.length >0 && range5.length > 0)
    {
        schoolName = [msgContent substringWithRange:NSMakeRange(range2.location+1,range5.location-range2.location-1)];
    }
    
    NSString *className;
    if (range3.length>0 && range4.length>0)
    {
        className = [msgContent substringWithRange:NSMakeRange(range3.location+1, range4.location-range3.location-1)];
    }
    
    ClassZoneViewController *classZone = [[ClassZoneViewController alloc] init];
    classZone.fromClasses = YES;
    classZone.classID = classID;
    classZone.schoolName = schoolName;
    classZone.className = className;
    [classZone showSelfViewController:self];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
    NSDictionary *dict = [messageArray objectAtIndex:indexPath.row];
    [db deleteRecordWithDict:dict andTableName:@"chatMsg"];
    [self dealNewChatMsg:nil];
}

#pragma mark - sendMsg
-(void)sendMsgWithString:(NSString *)msgContent
{
    if ([Tools NetworkReachable])
    {
        NSDate *date = [NSDate date];
        NSTimeInterval timeinterval = [date timeIntervalSince1970];
        NSString *str = [NSString stringWithFormat:@"%@%.0f",[Tools user_id],timeinterval];
        NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
        NSString *messageID = [data base64Encoding];
        
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"t_id":toID,
                                                                      @"m_id":messageID,
                                                                      @"content":msgContent
                                                                      } API:CREATE_CHAT_MSG];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"chat responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                NSMutableDictionary *chatDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                [chatDict setObject:messageID forKey:@"mid"];
                [chatDict setObject:msgContent forKey:@"content"];
                [chatDict setObject:[Tools user_id] forKey:@"userid"];
                [chatDict setObject:[Tools user_id] forKey:@"fid"];
                [chatDict setObject:[Tools user_name] forKey:@"fname"];
                [chatDict setObject:@"null" forKey:@"ficon"];
                [chatDict setObject:[NSString stringWithFormat:@"%d",[[responseDict objectForKey:@"data"] integerValue]] forKey:@"time"];
                [chatDict setObject:@"t" forKey:@"direct"];
                [chatDict setObject:@"text" forKey:@"msgType"];
                [chatDict setObject:toID forKey:@"tid"];
                [chatDict setObject:@"1" forKey:@"readed"];
                if ([[db findSetWithKey:@"mid" andValue:messageID andTableName:@"chatMsg"] count] <= 0)
                {
                    [db insertRecord:chatDict andTableName:@"chatMsg"];
                }
                if ([self.chatVcDel respondsToSelector:@selector(updateChatList:)])
                {
                    [self.chatVcDel updateChatList:YES];
                }
                [self dealNewChatMsg:nil];
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

}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [inputTabBar backKeyBoard];
}
@end
