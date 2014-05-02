//
//  InviteViewController.m
//  School
//
//  Created by TeekerZW on 14-1-20.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "InviteViewController.h"
#import "Header.h"
#import "FriendsCell.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "WeiboSDK.h"
#import "WeiboApi.h"
#import "WXApi.h"

#define tableViewTagBase   77777777

#define ContactTableViewTag  tableViewTagBase
#define TencentTableViewTag     (tableViewTagBase+1)
#define WeiXinTag             (tableViewTagBase+2)

#define TIPSLABEL_TAG 10086

#define BUFFER_SIZE 1024 * 100

@class AppDelegate;

@interface InviteViewController ()<UITableViewDataSource,
UITableViewDelegate,
MFMessageComposeViewControllerDelegate,
UIAlertViewDelegate>
{
    UIImageView *selectView;
    UIScrollView *bgScrollView;
    
    
    //腾讯微博
    NSMutableArray *tencentFriendsArray;
    UITableView *tencentTableView;
    NSMutableArray *tencentInviteArray;
    UIButton *inviteTencentButton;
    
    //手机联系人
    NSMutableArray *contactArray;
    UITableView *contactTableView;
    NSMutableArray *contactInviteArray;
    NSMutableArray *groupContactArray;
    
    
    UIView *phoneBgView;
    NSString *_userName;

    NSMutableArray *alreadyUsers;
    
    NSInteger pageNum;
    NSInteger pageSize;
    
    NSString *weiboToken;
    
    UIButton *inviteButton;
    
    OperatDB *db;
}
@end

@implementation InviteViewController
@synthesize fromClass,className,schoolName,classID;
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
    
    self.titleLabel.text = @"邀请";
    
    pageNum = 0;
    pageSize = 100;
    weiboToken = @"";
    
    db = [[OperatDB alloc] init];
    
    //手机联系人
    contactArray = [[NSMutableArray alloc]initWithCapacity:0];
    contactInviteArray  = [[NSMutableArray alloc] initWithCapacity:0];
    alreadyUsers = [[NSMutableArray alloc] initWithCapacity:0];
    groupContactArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    
    inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"邀请" forState:UIControlStateNormal];
    [inviteButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [inviteButton addTarget:self action:@selector(inviteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:inviteButton];
    
    UIScrollView *buttonScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, UI_NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, 70)];
    buttonScrollView.backgroundColor = [UIColor clearColor];
    buttonScrollView.showsHorizontalScrollIndicator = NO;
    [self.bgView addSubview:buttonScrollView];
    
    selectView = [[UIImageView alloc] init];
    [selectView setImage:[UIImage imageNamed:@"selectBg"]];
    selectView.backgroundColor = [UIColor clearColor];
    selectView.frame = CGRectMake(15, 0, 85, 70);
    [buttonScrollView addSubview:selectView];
    
    NSArray *iconArray = @[@"phone",@"QQicon",@"weixin"];
    
    for (int i=0; i<[iconArray count]; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(35+103*i, 12.5, 45, 45);
        button.backgroundColor = [UIColor clearColor];
        button.tag = tableViewTagBase+i;
//        button.layer.borderColor = LIGHT_BLUE_COLOR.CGColor;
//        button.layer.borderWidth = 0.3;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setBackgroundImage:[UIImage imageNamed:[iconArray objectAtIndex:i]] forState:UIControlStateNormal];
        [buttonScrollView addSubview:button];
    }
    buttonScrollView.contentSize = CGSizeMake(35+103*[iconArray count], 70);
    
    bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, buttonScrollView.frame.size.height+buttonScrollView.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT - buttonScrollView.frame.origin.y-buttonScrollView.frame.size.height)];
    bgScrollView.tag = 5000;
    bgScrollView.backgroundColor = [UIColor whiteColor];
    bgScrollView.delegate = self;
    bgScrollView.pagingEnabled = YES;
    bgScrollView.showsHorizontalScrollIndicator = NO;
    bgScrollView.scrollEnabled = NO;
    bgScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*3, bgScrollView.frame.size.height);
    [self.bgView addSubview:bgScrollView];
    
    contactTableView = [[UITableView alloc]initWithFrame:CGRectMake((ContactTableViewTag%tableViewTagBase)*SCREEN_WIDTH, 0, bgScrollView.frame.size.width, bgScrollView.frame.size.height) style:UITableViewStylePlain];
    contactTableView.delegate = self;
    contactTableView.dataSource = self;
    contactTableView.tag = ContactTableViewTag;
    if (SYSVERSION>=7)
    {
        contactTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    
    contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [bgScrollView addSubview:contactTableView];
    
    
    inviteTencentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteTencentButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)] forState:UIControlStateNormal];
    inviteTencentButton.frame = CGRectMake(CENTER_POINT.x-80+SCREEN_WIDTH*(TencentTableViewTag%tableViewTagBase), bgScrollView.frame.size.height/2-35, 160, 35);
    [inviteTencentButton setTitle:@"邀请QQ好友" forState:UIControlStateNormal];
    [inviteTencentButton addTarget:self action:@selector(shareToQQFriendClickHandler:) forControlEvents:UIControlEventTouchUpInside];
    [bgScrollView addSubview:inviteTencentButton];
    
    UIButton *inviteWeiXinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteWeiXinButton setBackgroundImage:[Tools getImageFromImage:[UIImage imageNamed:@"btn_bg"] andInsets:UIEdgeInsetsMake(1, 1, 1, 1)] forState:UIControlStateNormal];
    inviteWeiXinButton.frame = CGRectMake(CENTER_POINT.x-80+SCREEN_WIDTH*(WeiXinTag%tableViewTagBase), bgScrollView.frame.size.height/2-35, 160, 35);
    [inviteWeiXinButton setTitle:@"邀请微信好友" forState:UIControlStateNormal];
    [inviteWeiXinButton addTarget:self action:@selector(inviteWeiXin) forControlEvents:UIControlEventTouchUpInside];
    [bgScrollView addSubview:inviteWeiXinButton];
    
    [self getLocalContacts];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.tag == 1001)
    {
        if (scrollView.contentOffset.y>scrollView.contentSize.height-scrollView.frame.size.height+30)
        {
//            pageNum++;
//            DDLOG(@"pagenum == %d",pageNum);
//            [self getSinaFriends:sinaAuthOptions andPageNumber:pageNum];
        }
    }
}

-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView.tag == ContactTableViewTag)
    {
        if ([contactArray count] > 10)
        {
            NSMutableArray *sectionArray = [[NSMutableArray alloc] initWithCapacity:0];
            NSArray *letters = [NSArray arrayWithObjects:@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",@"U",@"V",@"W",@"X",@"Y",@"Z", nil];
            [sectionArray addObject:@"*"];
            for (int i=0; i<[letters count]; ++i)
            {
                NSString *letter = [letters objectAtIndex:i];
                for (int j=0; j<[groupContactArray count]; ++j)
                {
                    NSString *first = [[groupContactArray objectAtIndex:j] objectForKey:@"key"];
                    if ([letter isEqualToString:first])
                    {
                        [sectionArray addObject:letter];
                    }
                }
            }
            return sectionArray;
        }
    }
    return nil;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == ContactTableViewTag)
    {
        return [groupContactArray count]+1;
    }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView.tag == ContactTableViewTag)
    {
        if ([groupContactArray count] > 0 || [alreadyUsers count] > 0)
        {
            contactTableView.hidden = NO;
            if (section == 0)
            {
                return [alreadyUsers count];
            }
            else
            {
                NSDictionary *groupDict = [groupContactArray objectAtIndex:section-1];
                NSArray *array = [groupDict objectForKey:@"array"];
                return [array count];
            }
        }
    }
    else if(tableView.tag == TencentTableViewTag)
    {
        if ([tencentFriendsArray count] > 0)
        {
            tencentTableView.hidden = NO;
            return [tencentFriendsArray count];
        }
        
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag == ContactTableViewTag)
    {
        if(section == 0)
        {
            if ([alreadyUsers count]>0)
            {
                return 30;
            }
            return 0;
        }
        return 30;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
     if (tableView.tag == ContactTableViewTag)
    {
        if (section == 0)
        {
            if ([alreadyUsers count] > 0)
            {
                
                UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, 27)];
                headerLabel.text = @"    注册联系人";
                headerLabel.backgroundColor = RGB(234, 234, 234, 1);
                headerLabel.font = [UIFont systemFontOfSize:14];
                headerLabel.textColor = TITLE_COLOR;
                return headerLabel;
            }
        }
        else if(section >0)
        {
            NSDictionary *groupDict = [groupContactArray objectAtIndex:section-1];
            UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-15, 27)];
            headerLabel.text = [NSString stringWithFormat:@"   %@",[groupDict objectForKey:@"key"]];
            headerLabel.backgroundColor = RGB(234, 234, 234, 1);
            headerLabel.font = [UIFont systemFontOfSize:14];
            headerLabel.textColor = TITLE_COLOR;
            return headerLabel;
        }
    }
    return nil;
}

-(BOOL)haveThisFriend:(NSString *)fid
{
    NSArray *array = [db findSetWithDictionary:@{@"uid":[Tools user_id]} andTableName:FRIENDSTABLE];
    for (int i=0; i<[array count]; ++i)
    {
        NSDictionary *friendDict = [array objectAtIndex:i];
        if ([fid isEqualToString:[friendDict objectForKey:@"fid"]])
        {
            if ([[friendDict objectForKey:@"checked"]integerValue] == 1)
            {
                return YES;
            }
            return NO;
        }
    }
    return NO;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == ContactTableViewTag)
    {
        if (indexPath.section == 0)
        {
            static NSString *cellName = @"alreadyContactcell";
            FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil)
            {
                cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            cell.nameLabel.frame = CGRectMake(10, 10, SCREEN_WIDTH - 80, 30);
            cell.nameLabel.font = [UIFont systemFontOfSize:16];
            
            NSDictionary *dict = [alreadyUsers objectAtIndex:indexPath.row];
            cell.nameLabel.text = [dict objectForKey:@"r_name"];
            cell.inviteButton.hidden = NO;
            cell.inviteButton.frame = CGRectMake(SCREEN_WIDTH-80, 10, 40, 30);
            [cell.inviteButton setImage:[UIImage imageNamed:@"set_add"] forState:UIControlStateNormal];
            
            cell.inviteButton.enabled = YES;
            
            cell.inviteButton.tag = ContactTableViewTag+3333+indexPath.row;
            
            if (fromClass)
            {
                [cell.inviteButton addTarget:self action:@selector(inviteFriend:) forControlEvents:UIControlEventTouchUpInside];
            }
            else
            {
                [cell.inviteButton addTarget:self action:@selector(addFriendWithID:) forControlEvents:UIControlEventTouchUpInside];
            }
            
            UIImageView *bgImageBG = [[UIImageView alloc] init];
            bgImageBG.image = [UIImage imageNamed:@"line3"];
            bgImageBG.backgroundColor = [UIColor clearColor];
            cell.backgroundView = bgImageBG;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;

        }
        else if(indexPath.section >0)
        {
            static NSString *cellName = @"contactcell";
            FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
            if (cell == nil)
            {
                cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
            }
            
            NSDictionary *groupDict = [groupContactArray objectAtIndex:indexPath.section-1];
            NSArray *tmpArray = [groupDict objectForKey:@"array"];
            
            cell.nameLabel.frame = CGRectMake(10, 10, SCREEN_WIDTH - 80, 30);
            cell.nameLabel.font = [UIFont systemFontOfSize:16];
            
            NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
            cell.nameLabel.text = [dict objectForKey:@"name"];
            cell.inviteButton.frame = CGRectMake(SCREEN_WIDTH-80, 10, 40, 30);
            cell.inviteButton.backgroundColor = [UIColor clearColor];
            [cell.inviteButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
            cell.inviteButton.tag = indexPath.row+(ContactTableViewTag%tableViewTagBase)*tableViewTagBase+(indexPath.section-1)*10000;
            NSArray *array = [self getPhoneArrayFromContactDict:dict];
            for (int i=0; i<[array count]; ++i)
            {
                if ([self haveThisPhone:[array objectAtIndex:i]])
                {
                    [cell.inviteButton setImage:[UIImage imageNamed:@"selectBtn"] forState:UIControlStateNormal];
                    
                }
                else
                {
                    [cell.inviteButton setImage:[UIImage imageNamed:@"unselectBtn"] forState:UIControlStateNormal];
                    
                }
            }
            [cell.inviteButton addTarget:self action:@selector(inviteButtonCLick:) forControlEvents:UIControlEventTouchUpInside];
            UIImageView *bgImageBG = [[UIImageView alloc] init];
            bgImageBG.image = [UIImage imageNamed:@"line3"];
            bgImageBG.backgroundColor = [UIColor clearColor];
            cell.backgroundView = bgImageBG;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == ContactTableViewTag)
    {
        if (indexPath.section > 0)
        {
            NSDictionary *groupDict = [groupContactArray objectAtIndex:indexPath.section-1];
            NSArray *tmpArray = [groupDict objectForKey:@"array"];
            NSDictionary *dict = [tmpArray objectAtIndex:indexPath.row];
            NSArray *homePhoneArray = [self getPhoneArrayFromContactDict:dict];
            for (int i=0; i<[homePhoneArray count]; ++i)
            {
                if ([self haveThisPhone:[homePhoneArray objectAtIndex:i]])
                {
                    [contactInviteArray removeObject:[homePhoneArray objectAtIndex:i]];
                }
                else
                {
                    [contactInviteArray addObject:[homePhoneArray objectAtIndex:i]];
                }
            }
            [contactTableView reloadData];
        }
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    inviteButton.hidden = NO;
    if (scrollView.tag == 5000)
    {
        [UIView animateWithDuration:0.2 animations:^{
            selectView.frame = CGRectMake(scrollView.contentOffset.x/SCREEN_WIDTH*103+35-20, 0, 84, 70);
            
            for (int i=1000; i<1000+3; i++)
            {
                
            }
            
           if(scrollView.contentOffset.x/SCREEN_WIDTH == ContactTableViewTag%tableViewTagBase)
            {
                 inviteButton.hidden = NO;
                 [self getLocalContacts];
            }
            else if(scrollView.contentOffset.x/SCREEN_WIDTH == WeiXinTag%tableViewTagBase)
            {
                inviteButton.hidden = YES;
            }
            
        }];
    }
}


-(void)inviteButtonCLick:(UIButton *)button
{
   if(button.tag/tableViewTagBase == (ContactTableViewTag%tableViewTagBase))
    {
        NSDictionary *groupDict = [groupContactArray objectAtIndex:(button.tag -(ContactTableViewTag%tableViewTagBase)*tableViewTagBase)/10000];
        NSArray *tmpArray = [groupDict objectForKey:@"array"];
        NSDictionary *dict = [tmpArray objectAtIndex:(button.tag -(ContactTableViewTag%tableViewTagBase)*tableViewTagBase)%10000];
        NSArray *homePhoneArray = [self getPhoneArrayFromContactDict:dict];
        for (int i=0; i<[homePhoneArray count]; ++i)
        {
            if ([self haveThisPhone:[homePhoneArray objectAtIndex:i]])
            {
                [contactInviteArray removeObject:[homePhoneArray objectAtIndex:i]];
            }
            else
            {
                [contactInviteArray addObject:[homePhoneArray objectAtIndex:i]];
            }
        }
        [contactTableView reloadData];
    }
}

-(NSArray *)getPhoneArrayFromContactDict:(NSDictionary *)dict
{
    NSMutableString *phonesStr = [[NSMutableString alloc] initWithCapacity:0];
    [phonesStr insertString:[dict objectForKey:@"home_phone"] atIndex:[phonesStr length]];
    
    NSArray *charArray = @[@"(",@")",@"-",@" "];
    
    for (int i=0; i<[charArray count]; ++i)
    {
        NSRange range1 = [phonesStr rangeOfString:[charArray objectAtIndex:i]];
        while (range1.location != NSNotFound)
        {
            [phonesStr deleteCharactersInRange:range1];
            range1 = [phonesStr rangeOfString:[charArray objectAtIndex:i]];
        }
        
    }
    NSArray *homePhoneArray = [phonesStr componentsSeparatedByString:@","];
    return homePhoneArray;
}

-(BOOL)haveThisPhone:(NSString *)phoneStr
{
    if ([contactInviteArray containsObject:phoneStr])
        return YES;
    else
        return NO;
}



-(void)buttonClick:(UIButton *)button
{
    [UIView animateWithDuration:0.2 animations:^{
        selectView.frame = CGRectMake(35+103*(button.tag%tableViewTagBase)-20, 0, 85, 70);
    }];
    
    [contactInviteArray removeAllObjects];
    if(button.tag == ContactTableViewTag)
    {
        inviteButton.hidden = NO;
        if (!([contactArray count] > 0 || [alreadyUsers count] >0))
        {
            [self getLocalContacts];
        }
    }
    if(button.tag == WeiXinTag)
    {
        inviteButton.hidden = YES;
    }
    [UIView animateWithDuration:0.2 animations:^{
        bgScrollView.contentOffset = CGPointMake((button.tag%tableViewTagBase)*SCREEN_WIDTH, 0);
    }];
}

-(void)getLocalContacts
{
    
    //获取通讯录权限
    ABAddressBookRef tmpAddressBook = NULL;
    // ABAddressBookCreateWithOptions is iOS 6 and up.
    if (&ABAddressBookCreateWithOptions)
    {
        CFErrorRef error = nil;
        tmpAddressBook = ABAddressBookCreateWithOptions(NULL, &error);
        
        if (error)
        {
            NSLog(@"%@", error);
        }
    }
    if (tmpAddressBook == NULL)
    {
        tmpAddressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"允许访问通讯录" message:@"请到 手机设置->隐私->通讯录中，允许班家访问你的通讯录" delegate:nil cancelButtonTitle:@"好的，明白了" otherButtonTitles: nil];
        [al show];
        return ;
    }
    if (tmpAddressBook)
    {
        // ABAddressBookRequestAccessWithCompletion is iOS 6 and up. 适配IOS6以上版本
        if (&ABAddressBookRequestAccessWithCompletion)
        {
            ABAddressBookRequestAccessWithCompletion(tmpAddressBook,
                                                     ^(bool granted, CFErrorRef error)
            {
                                                         if (granted)
                                                         {
                                                             // constructInThread: will CFRelease ab.
                                                             [NSThread detachNewThreadSelector:@selector(constructInThread:)
                                                                                      toTarget:self
                                                                                    withObject:CFBridgingRelease(tmpAddressBook)];
                                                         }
                                                         else
                                                         {
                                                             //                                                             CFRelease(ab);
                                                             // Ignore the error
                                                         }
                                                        });
        }
        else
        {
            // constructInThread: will CFRelease ab.
            [NSThread detachNewThreadSelector:@selector(constructInThread:)
                                     toTarget:self
                                   withObject:CFBridgingRelease(tmpAddressBook)];
        }
    }
}
-(void)constructInThread:(ABAddressBookRef) ab
{
    [contactArray removeAllObjects];
    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(ab);
    for(int i = 0; i < CFArrayGetCount(results); i++)
    {
        ABRecordRef person = CFArrayGetValueAtIndex(results, i);
        NSString *firstName = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSString *lastname = (NSString*)CFBridgingRelease(ABRecordCopyValue(person, kABPersonLastNameProperty));
        //读取电话多值
        NSString* phoneString1 = @"";
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //获取該Label下的电话值
            NSString * personPhone = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(phone, k));
            phoneString1 = [phoneString1 stringByAppendingFormat:@",%@",personPhone];
            personPhone = nil;
        }
        CFRelease(phone);
        
        NSString *phoneString = [phoneString1 length]>0?[phoneString1 substringFromIndex:1]:@"";
        //构造字典
        NSDictionary* dic = @{@"name":[NSString stringWithFormat:@"%@%@",lastname?lastname:@"", firstName?firstName:@"" ],
                              @"home_phone": phoneString?phoneString:[NSNull null],
                              };
        [contactArray addObject:dic];
    }
    [self checkContacts:contactArray];
    CFRelease(results);
}

-(NSString *)getPhonesString:(NSString *)phonesString
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *phoneArray = [phonesString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\","]];
    for(NSString *phoneStr in phoneArray)
    {
        NSMutableString *num = [[NSMutableString alloc] initWithString:phoneStr];
        [num replaceOccurrencesOfString:@" " withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [num length])];
        [num replaceOccurrencesOfString:@"-" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [num length])];
        if ([num rangeOfString:@"("].length > 0)
        {
            [num deleteCharactersInRange:[num rangeOfString:@"("]];
        }
        if ([num rangeOfString:@")"].length > 0)
        {
            [num deleteCharactersInRange:[num rangeOfString:@")"]];
        }
        // && ![num isEqualToString:[[Tools myNumber] substringFromIndex:3]]
        if ([Tools isPhoneNumber:num])
        {
            [tmpArray addObject:num];
        }
    }
    return [NSString stringWithFormat:@"%@",tmpArray];
}

-(void)checkContacts:(NSArray *)array
{
    
    if ([array count] == 0)
    {
        [Tools showTips:@"没有任何联系人信息" toView:contactTableView];
        return ;
    }
    if ([Tools NetworkReachable])
    {
        NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
        for (int i=0; i<[array count]; ++i)
        {
            NSString *home_phone = [[array objectAtIndex:i] objectForKey:@"home_phone"];
            NSArray *phoneArray = [home_phone componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\","]];
            for(NSString *phoneStr in phoneArray)
            {
                NSMutableString *num = [[NSMutableString alloc] initWithString:phoneStr];
                [num replaceOccurrencesOfString:@" " withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [num length])];
                [num replaceOccurrencesOfString:@"-" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [num length])];
                if ([num rangeOfString:@"("].length > 0)
                {
                    [num deleteCharactersInRange:[num rangeOfString:@"("]];
                }
                if ([num rangeOfString:@")"].length > 0)
                {
                    [num deleteCharactersInRange:[num rangeOfString:@")"]];
                }
                if ([Tools isPhoneNumber:num])
                {
                    [tmpArray addObject:num];
                }
            }
        }
        NSMutableString *tmpStr = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@",tmpArray]];
        [tmpStr replaceOccurrencesOfString:@"\"" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpStr length])];
        [tmpStr replaceOccurrencesOfString:@"{" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpStr length])];
        [tmpStr replaceOccurrencesOfString:@"}" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpStr length])];
        [tmpStr replaceOccurrencesOfString:@" " withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpStr length])];
        [tmpStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [tmpStr length])];
        DDLOG(@"tmpstr length=%d",[tmpStr length]);
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"contacts":[tmpStr substringWithRange:NSMakeRange(1, [tmpStr length]-2)]
                                                                      } API:CHECKCONTACTS];
        [request setCompletionBlock:^{
            [Tools hideProgress:contactTableView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"checkcontact responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                
                [alreadyUsers removeAllObjects];
                if ([[responseDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
                {
                    NSArray *tmpArray = [[responseDict objectForKey:@"data"] allValues];
                    
                    for (int i=0; i<[tmpArray count]; i++)
                    {
                        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                        NSDictionary *tmpDict = [tmpArray objectAtIndex:i];
                        [dict setObject:[tmpDict objectForKey:@"_id"] forKey:@"_id"];
                        [dict setObject:[tmpDict objectForKey:@"phone"] forKey:@"phone"];
                        [dict setObject:[self getNameWithPhone:[tmpDict objectForKey:@"phone"]] forKey:@"r_name"];
                        if (![[tmpDict objectForKey:@"phone"] isEqualToString:[Tools phone_num]])
                        {
                             [alreadyUsers addObject:dict];
                        }
                    }
                    
                    NSMutableArray *alreadyInClassUsers = [[NSMutableArray alloc] initWithCapacity:0];
                    NSMutableArray *alreadyFriends = [[NSMutableArray alloc] initWithCapacity:0];
                    
                    if (fromClass)
                    {
                        for (int i=0; i<[alreadyUsers count]; ++i)
                        {
                            NSDictionary *dict = [alreadyUsers objectAtIndex:i];
                            NSString *alreadyUserID = [dict objectForKey:@"_id"];
                            if ([[db findSetWithDictionary:@{@"uid":alreadyUserID,@"classid":classID} andTableName:CLASSMEMBERTABLE] count] > 0)
                            {
                                [alreadyInClassUsers addObject:dict];
                            }
                            
                            NSString *phone = [self getPhonesString:[dict objectForKey:@"phone"]];
                            
                            for (int j=0; j<[contactArray count]; ++j)
                            {
                                NSDictionary *dict2 = [contactArray objectAtIndex:j];
                                NSString *phonesString = [self getPhonesString:[dict2 objectForKey:@"home_phone"]];
                                if ([phonesString rangeOfString:phone].length > 0)
                                {
                                    [contactArray removeObject:dict2];
                                }
                            }
                        }
                    }
                    else
                    {
                        for (int i=0; i<[alreadyUsers count]; ++i)
                        {
                            NSDictionary *dict = [alreadyUsers objectAtIndex:i];
                            NSString *alreadyUserID = [dict objectForKey:@"_id"];
                            if ([[db findSetWithDictionary:@{@"fid":alreadyUserID} andTableName:FRIENDSTABLE] count] > 0)
                            {
                                [alreadyFriends addObject:dict];
                            }
                            
                            NSString *phone = [self getPhonesString:[dict objectForKey:@"phone"]];
                            
                            for (int j=0; j<[contactArray count]; ++j)
                            {
                                NSDictionary *dict2 = [contactArray objectAtIndex:j];
                                NSString *phonesString = [self getPhonesString:[dict2 objectForKey:@"home_phone"]];
                                if ([phonesString rangeOfString:phone].length > 0)
                                {
                                    [contactArray removeObject:dict2];
                                }
                            }
                        }

                    }
                    if (fromClass)
                    {
                        for (int i=0; i<[alreadyInClassUsers count]; i++)
                        {
                            [alreadyUsers removeObject:[alreadyInClassUsers objectAtIndex:i]];
                        }
                    }
                    else
                    {
                        for (int i=0; i<[alreadyFriends count]; i++)
                        {
                            [alreadyUsers removeObject:[alreadyFriends objectAtIndex:i]];
                        }
                    }
                }
                
                NSArray *tmpArray = [Tools getSpellSortArrayFromChineseArray:contactArray andKey:@"name"];
                [groupContactArray addObjectsFromArray:tmpArray];
                [contactTableView reloadData];
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:self];
            }
        }];
        
        [request setFailedBlock:^{
            NSError *error = [request error];
            DDLOG(@"error %@",error);
            [Tools hideProgress:contactTableView];
        }];
        [Tools showProgress:contactTableView];
        [request startAsynchronous];
    }
}

-(NSString *)getNameWithPhone:(NSString *)phoneStr
{
    for (int i=0; i<[contactArray count]; i++)
    {
        NSString *tmpPhoneStr = [[contactArray objectAtIndex:i] objectForKey:@"home_phone"];
        if ([[self getPhonesString:tmpPhoneStr] rangeOfString:phoneStr].length > 0)
        {
            return  [[contactArray objectAtIndex:i] objectForKey:@"name"];
        }
    }
    return @"";
}

#pragma mark - inviteQQFriends
/**
 *	@brief	分享给QQ好友
 *
 *	@param 	sender 	事件对象
 */
- (void)shareToQQFriendClickHandler:(UIButton *)sender
{
    //创建分享内容
//    NSString *imagePath = [[NSBundle mainBundle] pathForResource:IMAGE_NAME ofType:IMAGE_EXT];
    id<ISSContent> publishContent = [ShareSDK content:ShareContent
                                       defaultContent:@""
                                                image:nil
                                                title:@"班家"
                                                  url:@"http://www.banjiaedu.com"
                                          description:nil
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


#pragma mark - inviteWeiXin
- (void)inviteWeiXin
{
    // 发送内容给微信
    Byte* pBuffer = (Byte *)malloc(BUFFER_SIZE);
    memset(pBuffer, 0, BUFFER_SIZE);
    NSData* data = [NSData dataWithBytes:pBuffer length:BUFFER_SIZE];
    free(pBuffer);
    
    id<ISSContent> content = [ShareSDK content:NSLocalizedString(@"今天你班家了吗？", @"图标边上的")
                                defaultContent:nil
                                         image:[ShareSDK jpegImageWithImage:[UIImage imageNamed:@""] quality:1]
                                         title:NSLocalizedString(@"班家", @"这是App消息")
                                           url:@"http://www.banjiaedu.com"
                                   description:@"班家是一款为方便老师，家长，学生之间有效沟通的平台，在这里你可以找到或创建属于你们的班级大家庭，快来一起加入吧！"
                                     mediaType:SSPublishContentMediaTypeApp];
    [content addWeixinSessionUnitWithType:INHERIT_VALUE
                                  content:ShareContent
                                    title:INHERIT_VALUE
                                      url:INHERIT_VALUE
                                    image:INHERIT_VALUE
                             musicFileUrl:nil
                                  extInfo:@""
                                 fileData:data
                             emoticonData:nil];
    
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
    
    [ShareSDK shareContent:content
                      type:ShareTypeWeixiSession
               authOptions:authOptions
             statusBarTips:YES
                    result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                        
                        if (state == SSPublishContentStateSuccess)
                        {
                            NSLog(@"success");
                        }
                        else if (state == SSPublishContentStateFail)
                        {
                            if ([error errorCode] == -22003)
                            {
                                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"TEXT_TIPS", @"提示")
                                                                                    message:[error errorDescription]
                                                                                   delegate:nil
                                                                          cancelButtonTitle:NSLocalizedString(@"TEXT_KNOW", @"知道了")
                                                                          otherButtonTitles:nil];
                                [alertView show];
                            }
                        }
                    }];
}

//-(void) onCancelText
//{
//    [self.parentController dismissModalViewControllerAnimated:YES];
//}

#pragma  mark - showmsg
-(void)showMessageView
{
    if( [MFMessageComposeViewController canSendText] ){
        
        MFMessageComposeViewController * controller = [[MFMessageComposeViewController alloc]init]; //autorelease];
        
        controller.recipients = contactInviteArray;
        
        NSString *msgBody;
        if (fromClass)
        {
            msgBody = [NSString stringWithFormat:@"我在%@-%@，快来加入吧！",schoolName,className];
        }
        else
        {
            msgBody = @"测试，快来班家吧！";
        }
        controller.body = msgBody;
        controller.messageComposeDelegate = self;
        
        [self presentViewController:controller animated:YES completion:nil];
        
        [[[[controller viewControllers] lastObject] navigationItem] setTitle:@"测试短信"];//修改短信界面标题
    }else{
        [self alertWithTitle:@"提示信息" msg:@"设备没有短信功能"];
    }
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    [controller dismissViewControllerAnimated:NO completion:nil];
    
    switch ( result ) {
            
        case MessageComposeResultCancelled:
            
            [self alertWithTitle:@"提示信息" msg:@"发送取消"];
            break;
        case MessageComposeResultFailed:// send failed
            [self alertWithTitle:@"提示信息" msg:@"发送失败"];
            break;
        case MessageComposeResultSent:
            [self alertWithTitle:@"提示信息" msg:@"发送成功"];
            break;
        default:
            break;
    }
}

- (void) alertWithTitle:(NSString *)title msg:(NSString *)msg {
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"确定", nil];
    
    [alert show];
    
}

#pragma mark - inviteClick
-(void)inviteClick
{
    if (bgScrollView.contentOffset.x/SCREEN_WIDTH == ContactTableViewTag%tableViewTagBase)
    {
        [self showMessageView];
    }
}

#pragma mark - addFriend
-(void)inviteFriend:(UIButton *)button
{
    NSDictionary *dict = [alreadyUsers objectAtIndex:button.tag-ContactTableViewTag-3333];
    NSString *sendMsg = [NSString stringWithFormat:@"%@$!#我是%@,我在[%@—%@],你也一起加入吧！",classID,[Tools user_name],schoolName,className];
    [self sendMsgWithString:sendMsg andUserID:[dict objectForKey:@"_id"] andUserInfo:dict];
}

#pragma mark - sendmsg
-(void)sendMsgWithString:(NSString *)msgContent andUserID:(NSString *)uid andUserInfo:(NSDictionary *)userInfo
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
                                                                      @"t_id":uid,
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
                [chatDict setObject:uid forKey:@"tid"];
                [chatDict setObject:@"1" forKey:@"readed"];
                if ([[db findSetWithKey:@"mid" andValue:messageID andTableName:@"chatMsg"] count] <= 0)
                {
                    [db insertRecord:chatDict andTableName:@"chatMsg"];
                }
                
                [Tools showAlertView:[NSString stringWithFormat:@"您已经成功邀请%@",[userInfo objectForKey:@"r_name"]] delegateViewController:nil];
                [alreadyUsers removeObject:userInfo];
                [contactTableView reloadData];
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

-(void)addFriendWithID:(UIButton *)button
{
    NSDictionary *dict = [alreadyUsers objectAtIndex:button.tag-ContactTableViewTag-3333];
    [self addFriendWith:[dict objectForKey:@"_id"] andUserInfo:dict];
}
-(void)addFriendWith:(NSString *)uid andUserInfo:(NSDictionary *)userInfo
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"f_id":uid
                                                                      } API:MB_APPLY_FRIEND];
        [request setCompletionBlock:^{
            [Tools hideProgress:self.bgView];
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"memberByClass responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                [Tools showAlertView:@"请求已申请，请等待对方答复！" delegateViewController:self];
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


@end