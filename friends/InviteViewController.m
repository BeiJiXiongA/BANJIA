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
@class AppDelegate;

@interface InviteViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIImageView *selectView;
    UIScrollView *bgScrollView;
    
    UITableView *sinaFriendsTableView;
    NSMutableArray *sinaFriendsArray;
    UIButton *bindSinaButton;
    UIButton *bindQQButton;
    UIButton *outSinaButton;
    BOOL isBindSina;
    
    NSMutableArray *contactArray;
    UITableView *contactTableView;
    
    UIView *phoneBgView;
    
    NSArray *buttonNamesArray;
    
    NSMutableArray *inviteArray;
    
    NSString *_userName;
}
@end

@implementation InviteViewController

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
    
    self.titleLabel.text = @"好友";
    
    contactArray = [[NSMutableArray alloc]initWithCapacity:0];
    inviteArray  = [[NSMutableArray alloc] initWithCapacity:0];
    
    UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inviteButton setTitle:@"邀请" forState:UIControlStateNormal];
    [inviteButton setBackgroundImage:[UIImage imageNamed:NAVBTNBG] forState:UIControlStateNormal];
    inviteButton.frame = CGRectMake(SCREEN_WIDTH - 60, 5, 50, UI_NAVIGATION_BAR_HEIGHT - 10);
    [inviteButton addTarget:self action:@selector(inviteClick) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBarView addSubview:inviteButton];
    
    sinaFriendsArray = [[NSMutableArray alloc] initWithCapacity:0];
    self.friendsArr = [[NSMutableArray alloc] initWithCapacity:0];
    
    buttonNamesArray = [NSArray arrayWithObjects:@"新浪",@"通讯录",@"QQ", nil];
    selectView = [[UIImageView alloc] init];
    [selectView setImage:[UIImage imageNamed:@"selectBg"]];
    selectView.backgroundColor = [UIColor clearColor];
    selectView.frame = CGRectMake(15, UI_NAVIGATION_BAR_HEIGHT, 85, 70);
    [self.bgView addSubview:selectView];
    
    for (int i=0; i<[buttonNamesArray count]; i++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(35+103*i, UI_NAVIGATION_BAR_HEIGHT+12.5, 45, 45);
        button.backgroundColor = [UIColor clearColor];
        button.tag = 1000+i;
//        button.layer.borderColor = LIGHT_BLUE_COLOR.CGColor;
//        button.layer.borderWidth = 0.3;
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0)
        {
            [button setBackgroundImage:[UIImage imageNamed:@"weixin"] forState:UIControlStateNormal];
        }
        else if(i==1)
        {
            [button setBackgroundImage:[UIImage imageNamed:@"sinaicon"] forState:UIControlStateNormal];
        }
        else if(i==2)
        {
            [button setBackgroundImage:[UIImage imageNamed:@"phone"] forState:UIControlStateNormal];
        }
        [self.bgView addSubview:button];
    }
    
    bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, selectView.frame.size.height+selectView.frame.origin.y, SCREEN_WIDTH, SCREEN_HEIGHT - selectView.frame.origin.y-selectView.frame.size.height)];
    bgScrollView.tag = 5000;
    bgScrollView.backgroundColor = [UIColor whiteColor];
    bgScrollView.delegate = self;
    bgScrollView.pagingEnabled = YES;
    bgScrollView.showsHorizontalScrollIndicator = NO;
    bgScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*3, bgScrollView.frame.size.height);
    [self.bgView addSubview:bgScrollView];
    
    sinaFriendsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, bgScrollView.frame.size.width, bgScrollView.frame.size.height-40) style:UITableViewStylePlain];
    sinaFriendsTableView.delegate = self;
    sinaFriendsTableView.dataSource = self;
    sinaFriendsTableView.tag = 1000+1;
    sinaFriendsTableView.hidden = YES;
    sinaFriendsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [bgScrollView addSubview:sinaFriendsTableView];
    
    contactTableView = [[UITableView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*2, 0, bgScrollView.frame.size.width, bgScrollView.frame.size.height) style:UITableViewStylePlain];
    contactTableView.delegate = self;
    contactTableView.dataSource = self;
    contactTableView.tag = 1000+3;
    contactTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [bgScrollView addSubview:contactTableView];
    
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

#pragma mark - inviteClick
-(void)inviteClick
{
    DDLOG(@"%@",inviteArray);
}

#pragma mark - tableview
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == 1000+1)
    {
        if ([sinaFriendsArray count] > 0)
        {
            sinaFriendsTableView.hidden = NO;
            return [sinaFriendsArray count];
        }
        sinaFriendsTableView.hidden = YES;
    }
    else if(tableView.tag == 1000+3)
    {
        return [contactArray count];
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1000+1)
    {
        return 60;
    }
    else if(tableView.tag == 1000+3)
    {
        return 60;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1000+1)
    {
        static NSString *cellName = @"friendscell";
        FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil)
        {
            cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.headerImageView.frame = CGRectMake(5, 5, 50, 50);
        cell.nameLabel.frame = CGRectMake(60, 10, SCREEN_WIDTH - 80, 30);
        cell.nameLabel.font = [UIFont systemFontOfSize:14];
        cell.locationLabel.frame = CGRectMake(70, 40, 80, 15);
        cell.locationLabel.font = [UIFont systemFontOfSize:12];
        
        NSDictionary *dict = [sinaFriendsArray objectAtIndex:indexPath.row];
        [Tools fillImageView:cell.headerImageView withImageFromURL:[dict objectForKey:@"avatar_large"]];
        cell.nameLabel.text = [dict objectForKey:@"name"];
        cell.locationLabel.text = [dict objectForKey:@"location"];
        cell.inviteButton.frame = CGRectMake(SCREEN_WIDTH-80, 15, 50, 30);
        cell.inviteButton.tag = indexPath.row+1000;
        [cell.inviteButton setTitle:@"邀请" forState:UIControlStateNormal];
        cell.inviteButton.backgroundColor = [UIColor clearColor];
        [cell.inviteButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        [cell.inviteButton addTarget:self action:@selector(inviteButtonCLick:) forControlEvents:UIControlEventTouchUpInside];
        UIImageView *bgImageBG = [[UIImageView alloc] init];
        bgImageBG.image = [UIImage imageNamed:@"cell_bg"];
        cell.backgroundView = bgImageBG;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (tableView.tag == 1000+3)
    {
        static NSString *cellName = @"contactcell";
        FriendsCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
        if (cell == nil)
        {
            cell = [[FriendsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        }
        cell.nameLabel.frame = CGRectMake(10, 10, SCREEN_WIDTH - 80, 30);
        cell.nameLabel.font = [UIFont systemFontOfSize:16];
        
        NSDictionary *dict = [contactArray objectAtIndex:indexPath.row];
        NSString *lastName = [dict objectForKey:@"last_name"];
        NSString *firstName = [dict objectForKey:@"first_name"];
        cell.nameLabel.text = [NSString stringWithFormat:@"%@%@",[lastName isEqual:[NSNull null]]?@"":lastName,[firstName isEqual:[NSNull null]]?@"":firstName];
        cell.inviteButton.frame = CGRectMake(SCREEN_WIDTH-50, 10, 40, 40);
        cell.inviteButton.backgroundColor = [UIColor clearColor];
        [cell.inviteButton setTitleColor:TITLE_COLOR forState:UIControlStateNormal];
        cell.inviteButton.tag = indexPath.row+2000;
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
        bgImageBG.image = [UIImage imageNamed:@"line2"];
        cell.backgroundView = bgImageBG;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.tag == 5000)
    {
        [UIView animateWithDuration:0.2 animations:^{
            selectView.frame = CGRectMake(scrollView.contentOffset.x/SCREEN_WIDTH*103+35-20, UI_NAVIGATION_BAR_HEIGHT, 84, 70);
            
            for (int i=1000; i<1000+[buttonNamesArray count]; i++)
            {
                
            }
            
            if (scrollView.contentOffset.x/SCREEN_WIDTH == 0)
            {
                
            }
            else if(scrollView.contentOffset.x/SCREEN_WIDTH == 1)
            {
               
            }
            else if(scrollView.contentOffset.x/SCREEN_WIDTH == 2)
            {
                 [self getLocalContacts];
            }
            
        }];
    }
}


-(void)inviteButtonCLick:(UIButton *)button
{
    if (button.tag/1000 == 1)
    {
       
        
    }
    else if(button.tag/1000 == 2)
    {
        NSDictionary *dict = [contactArray objectAtIndex:button.tag - 2000];
        DDLOG(@"%@",dict);
        NSArray *homePhoneArray = [self getPhoneArrayFromContactDict:dict];
        for (int i=0; i<[homePhoneArray count]; ++i)
        {
            if ([self haveThisPhone:[homePhoneArray objectAtIndex:i]])
            {
                [inviteArray removeObject:[homePhoneArray objectAtIndex:i]];
            }
            else
            {
                [inviteArray addObject:[homePhoneArray objectAtIndex:i]];
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
    if ([inviteArray containsObject:phoneStr])
        return YES;
    else
        return NO;
}

-(void)buttonClick:(UIButton *)button
{
    [UIView animateWithDuration:0.2 animations:^{
        
        selectView.frame = CGRectMake(35+103*(button.tag-1000)-20, UI_NAVIGATION_BAR_HEIGHT, 85, 70);
        
    }];
    
    [inviteArray removeAllObjects];
    
    if (button.tag == 1000)
    {
        
    }
    else if(button.tag == 1001)
    {
        
    }
    else if(button.tag == 1002)
    {
        [self getLocalContacts];
    }
    [UIView animateWithDuration:0.2 animations:^{
        bgScrollView.contentOffset = CGPointMake((button.tag%1000)*SCREEN_WIDTH, 0);
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
        NSDictionary* dic = @{@"first_name": firstName?firstName:[NSNull null],
                              @"last_name": lastname?lastname:[NSNull null],
                              @"home_phone": phoneString?phoneString:[NSNull null],
                              };
        DDLOG(@"contact dict %@",dic);
        [contactArray addObject:dic];
    }
    [contactTableView reloadData];
    CFRelease(results);
}

@end
