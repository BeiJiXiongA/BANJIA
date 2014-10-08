//
//  AppDelegate.m
//  BANJIA
//
//  Created by TeekerZW on 4/4/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "AppDelegate.h"
#import "Header.h"
#import "WelcomeViewController.h"
//#import "FillInfoViewController.h"
#import "FillInfo2ViewController.h"

#import "MyClassesViewController.h"
#import "HomeViewController.h"
#import "MessageViewController.h"
#import "MCSoundBoard.h"
#import "KKNavigationController.h"

#import "MobClick.h"
#import "ChineseToPinyin.h"
#import "NSString+Emojize.h"

#import "ApplyInfoViewController.h"


#import <ShareSDK/ShareSDK.h>
#import <RennSDK/RennSDK.h>
#import <TencentOpenAPI/QQApi.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboApi.h"
#import "MobClick.h"
#import "WXApi.h"

//Õı»
#define NewVersionTag  1000
#define NEWVERSION  2222

#import "FiistLaunchViewController.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for cupstomization after application launch.
    
    [[NSUserDefaults standardUserDefaults] setObject:@"1.2.3" forKey:@"currentVersion"];
    [[NSUserDefaults standardUserDefaults] setObject:SCHEMERELEASE forKey:SCHEMETYPE];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //显示置顶要闻
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"showad"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewClass) name:UPDATECLASSNUMBER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewChat) name:UPDATECHATSNUMBER object:nil];
    
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    _db = [[OperatDB alloc] init];
    [[StatusBarTips shareTipsWindow] hideTips];
    
    NSDate *localDate = [NSDate date];
    NSTimeInterval localTimeInterVal = [localDate timeIntervalSince1970];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"YYYY年MM月dd日"];
    NSDate *datetimeDate = [NSDate dateWithTimeIntervalSince1970:localTimeInterVal];
    NSString *resultStr = [dateFormatter stringFromDate:datetimeDate];
    NSString *lastUpdateDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastupdate"];
    
    if (!lastUpdateDate || (lastUpdateDate && ![lastUpdateDate isEqualToString:resultStr]))
    {
        [self updateNewVersionWithDate:resultStr];
    }
    
    NSString *soundDir = [NSString stringWithFormat:@"%@/soundCache",[DirectyTools documents]];
    BOOL isDir;
    if (![[NSFileManager defaultManager] fileExistsAtPath:soundDir isDirectory:&isDir])
    {
        if ([[NSFileManager defaultManager] createDirectoryAtPath:soundDir withIntermediateDirectories:YES attributes:nil error:nil])
        {
            DDLOG(@"create sound cache success");
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@"notchat" forKey:@"viewtype"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    [self initialize];
    
    [self updateDatabase];
    
    [APService setAlias:[APService registrationID] callbackSelector:nil object:nil];
    
    if ([[_db findSetWithDictionary:@{} andTableName:CITYTABLE] count] <= 0)
    {
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"citys" ofType:@"plist"];
        NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *array = [dict allValues];
            for (int i=0; i<[array count]; i++)
            {
                NSDictionary *dict = [array objectAtIndex:i];
                NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc] initWithCapacity:0];
                [tmpDict setObject:[dict objectForKey:@"_id"] forKey:@"cityid"];
                [tmpDict setObject:[dict objectForKey:@"name"] forKey:@"cityname"];
                [tmpDict setObject:[dict objectForKey:@"level"] forKey:@"citylevel"];
                [tmpDict setObject:[dict objectForKey:@"p_id"] forKey:@"pid"];
                [tmpDict setObject:[dict objectForKey:@"fname"] forKey:@"fname"];
                [tmpDict setObject:[ChineseToPinyin jianPinFromChiniseString:[dict objectForKey:@"name"]] forKey:@"jianpin"];
                [tmpDict setObject:[ChineseToPinyin pinyinFromChiniseString:[dict objectForKey:@"name"]] forKey:@"quanpin"];
                if ([_db insertRecord:tmpDict  andTableName:CITYTABLE])
                {
                    DDLOG(@"insert city success!");
                }
            }
        });
    }
    
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"myqUGnjMNzdgscv8HVTTgWkn"  generalDelegate:nil];
    if (!ret)
    {
        DDLOG(@"manager start failed!");
    }
    
    [MobClick startWithAppkey:@"53c5f0ec56240be9ed07306e" reportPolicy:SEND_INTERVAL channelId:@"123"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"first"])
    {
        FiistLaunchViewController *firstLaunch = [[FiistLaunchViewController alloc] init];
        KKNavigationController *firstNav = [[KKNavigationController alloc] initWithRootViewController:firstLaunch];
        self.window.rootViewController = firstNav;
    }
    else if ([[Tools user_id] length] > 0)
    {
        if ([[Tools user_name] length] <= 0 || [[Tools user_name] isEqualToString:ANONYMITY])
        {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
            FillInfo2ViewController *fillInfoVC = [[FillInfo2ViewController alloc] init];
            fillInfoVC.fromRoot = YES;
            KKNavigationController *fillNav = [[KKNavigationController alloc] initWithRootViewController:fillInfoVC];
            self.window.rootViewController = fillNav;
        }
        else
        {
            [self getNewChat];
            [self getNewClass];
            [self getNewVersion];
            sideMenuViewController = [[SideMenuViewController alloc] init];
            HomeViewController *homeViewController = [[HomeViewController alloc] init];
            KKNavigationController *homeNav = [[KKNavigationController alloc] initWithRootViewController:homeViewController];
            [sideMenuViewController.buttonTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:homeNav menuController:sideMenuViewController];
            self.window.rootViewController = sideMenu;
        }
    }
    else
    {
        WelcomeViewController *welcomeViewCOntroller = [[WelcomeViewController alloc]init];
        KKNavigationController *welNav = [[KKNavigationController alloc] initWithRootViewController:welcomeViewCOntroller];
        self.window.rootViewController = welNav;
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    }
    
    [ShareSDK registerApp:@"182899e1ea92"];
    [self shareAppKeysForEvery];

    
     //Required
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
     //Required
    [APService setupWithOption:launchOptions];
    

    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

#pragma mark - 版本更新
#pragma mark - updateNewVersion
-(void)updateNewVersionWithDate:(NSString *)updateDate
{
    if ([Tools NetworkReachable])
    {
        NSString *appleID = @"862315597";
        NSString *urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appleID];
        __weak ASIHTTPRequest *request = [Tools getRequestWithDict:@{} andHostUrl:urlStr];
        
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"newViewsion== responsedict %@",responseDict);
            int resultCount = [[responseDict objectForKey:@"resultCount"] intValue];
            if (resultCount >= 1)
            {
                
                [[NSUserDefaults standardUserDefaults] setObject:updateDate forKey:@"lastupdate"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSMutableArray *results = [responseDict objectForKey:@"results"];
                NSDictionary *releaseInfo = [results objectAtIndex:0];
                
                NSString *latestVersion = [releaseInfo objectForKey:@"version"];
                newVersionUrl = [releaseInfo objectForKey:@"trackViewUrl"];
                NSString *trackName = [releaseInfo objectForKey:@"trackName"];
                
                
                NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
                NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
                
                if ([currentVersion compare:latestVersion] < 0) {
                    
                    UIAlertView *alert;
                    alert = [[UIAlertView alloc] initWithTitle:trackName
                                                       message:@"有新版本哦，快去更新吧，加了好多功能的！"
                                                      delegate: self
                                             cancelButtonTitle:@"取消"
                                             otherButtonTitles: @"升级", nil];
                    alert.tag = NEWVERSION;
                    [alert show];
                }
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


-(void)initialize
{
    NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:@"laallalalal", @"UserAgent", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)updateDatabase
{
    NSArray *array = [_db findSetWithDictionary:@{} andTableName:CLASSMEMBERTABLE];
    NSDictionary *dict = [array firstObject];
    if (![[dict allKeys] containsObject:@"admin"])
    {
        [_db alterTableAdd:@"admin" charLength:8 defaultValue:@"0" andTableName:CLASSMEMBERTABLE];
    }
    
    NSArray *array2 = [_db findSetWithDictionary:@{} andTableName:CLASSMEMBERTABLE];
    NSDictionary *dict2 = [array2 firstObject];
    if (![[dict2 allKeys] containsObject:@"jianpin"])
    {
        [_db alterTableAdd:@"jianpin" charLength:8 defaultValue:@"" andTableName:CLASSMEMBERTABLE];
        [_db alterTableAdd:@"quanpin" charLength:8 defaultValue:@"" andTableName:CLASSMEMBERTABLE];
    }
    
    NSArray *array3 = [_db findSetWithDictionary:@{} andTableName:CHATTABLE];
    NSDictionary *dict3 = [array3 firstObject];
    if (![[dict3 allKeys] containsObject:@"by"])
    {
        [_db alterTableAdd:@"by" charLength:8 defaultValue:@"" andTableName:CHATTABLE];
    }
    
    NSArray *array4 = [_db findSetWithDictionary:@{} andTableName:USERICONTABLE];
    NSDictionary *dict4 = [array4 firstObject];
    if (![[dict4 allKeys] containsObject:@"by"])
    {
        [_db alterTableAdd:@"username" charLength:8 defaultValue:@"" andTableName:USERICONTABLE];
    }
    
    NSArray *array5 = [_db findSetWithDictionary:@{} andTableName:FRIENDSTABLE];
    NSDictionary *dict5 = [array5 firstObject];
    if (![[dict5 allKeys] containsObject:@"cgroup"])
    {
        [_db alterTableAdd:@"cgroup" charLength:8 defaultValue:@"" andTableName:FRIENDSTABLE];
    }
    
    NSArray *array6 = [_db findSetWithDictionary:@{} andTableName:CLASSMEMBERTABLE];
    NSDictionary *dict6 = [array6 firstObject];
    if (![[dict6 allKeys] containsObject:@"sn"])
    {
        [_db alterTableAdd:@"sn" charLength:20 defaultValue:@"" andTableName:CLASSMEMBERTABLE];
    }
    
    NSArray *array7 = [_db findSetWithDictionary:@{} andTableName:CLASSMEMBERTABLE];
    NSDictionary *dict7 = [array7 firstObject];
    if (![[dict7 allKeys] containsObject:@"sex"])
    {
        [_db alterTableAdd:@"sex" charLength:6 defaultValue:@"" andTableName:CLASSMEMBERTABLE];
    }
    NSArray *array8 = [_db findSetWithDictionary:@{} andTableName:CLASSMEMBERTABLE];
    NSDictionary *dict8 = [array8 firstObject];
    if (![[dict8 allKeys] containsObject:@"cb_id"])
    {
        [_db alterTableAdd:@"cb_id" charLength:6 defaultValue:@"" andTableName:CLASSMEMBERTABLE];
    }
    
    NSArray *array9 = [_db findSetWithDictionary:@{} andTableName:CHATTABLE];
    NSDictionary *dict9 = [array9 firstObject];
    if (![[dict9 allKeys] containsObject:@"byname"])
    {
        [_db alterTableAdd:@"byname" charLength:8 defaultValue:@"" andTableName:CHATTABLE];
    }
    
    NSArray *array10 = [_db findSetWithDictionary:@{} andTableName:CLASSMEMBERTABLE];
    NSDictionary *dict10 = [array10 firstObject];
    if (![[dict10 allKeys] containsObject:@"re_sn"])
    {
        [_db alterTableAdd:@"re_sn" charLength:8 defaultValue:@"" andTableName:CLASSMEMBERTABLE];
    }
    NSArray *array11 = [_db findSetWithDictionary:@{} andTableName:CLASSMEMBERTABLE];
    NSDictionary *dict11 = [array11 firstObject];
    if (![[dict11 allKeys] containsObject:@"def"])
    {
        [_db alterTableAdd:@"def" charLength:8 defaultValue:@"" andTableName:CLASSMEMBERTABLE];
    }
    
    NSArray *array12 = [_db findSetWithDictionary:@{} andTableName:CHATTABLE];
    NSDictionary *dict12 = [array12 firstObject];
    if (![[dict12 allKeys] containsObject:@"def"])
    {
        [_db alterTableAdd:@"l" charLength:4 defaultValue:@"" andTableName:CHATTABLE];
    }
    
    NSArray *array13 = [_db findSetWithDictionary:@{} andTableName:USERICONTABLE];
    NSDictionary *dict13 = [array13 firstObject];
    if (![[dict13 allKeys] containsObject:@"unum"])
    {
        [_db alterTableAdd:@"unum" charLength:4 defaultValue:@"" andTableName:USERICONTABLE];
    }
    
    NSArray *array14 = [_db findSetWithDictionary:@{} andTableName:FRIENDSTABLE];
    NSDictionary *dict14 = [array14 firstObject];
    if (![[dict14 allKeys] containsObject:@"fnum"])
    {
        [_db alterTableAdd:@"fnum" charLength:4 defaultValue:@"" andTableName:FRIENDSTABLE];
    }
}

-(void)getNewVersion
{
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"type":@"iOS",
                                                                      @"build":[[NSUserDefaults standardUserDefaults] objectForKey:@"currentVersion"]
                                                                      } API:MB_NEWVERSION];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"newversion responsedict %@",responseString);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if ([[responseDict objectForKey:@"data"] isKindOfClass:[NSDictionary class]])
                {
                    if ([[responseDict objectForKey:@"data"] objectForKey:@"iOS_url"])
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:[[responseDict objectForKey:@"data"] objectForKey:@"iOS_url"] forKey:@"iOS_url"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
//                        UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"新版本提示" message:@"有新版本哦，快去更新吧，加了好多功能的！" delegate:self cancelButtonTitle:@"一会在更新" otherButtonTitles:@"用最新的", nil];
//                        al.tag = NewVersionTag;
//                        [al show];

                    }
                    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                    NSDictionary *template = [[responseDict objectForKey:@"data"] objectForKey:@"template"];
                    NSString *item1 = [template objectForKey:@"tem1"];
                    
                    if (![[ud objectForKey:InviteClassMemberKey] isEqualToString:item1])
                    {
                        [ud setObject:item1 forKey:ShareContentKey];
                        [ud synchronize];
                    }
                    
                    NSString *item2 = [template objectForKey:@"tem2"];
                    if (![[ud objectForKey:InviteClassMemberKey] isEqualToString:item2])
                    {
                        [ud setObject:item2 forKey:InviteClassMemberKey];
                        [ud synchronize];
                    }
                    
                    NSString *item3 = [template objectForKey:@"tem3"];
                    if (![[ud objectForKey:InviteParentKey] isEqualToString:item3])
                    {
                        [ud setObject:item3 forKey:InviteParentKey];
                        [ud synchronize];
                    }
                }
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
        }];
        [request startAsynchronous];
    }

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == NewVersionTag)
    {
        if (buttonIndex == 1)
        {
            NSString *url = [[NSUserDefaults standardUserDefaults] objectForKey:@"iOS_url"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
    else if(alertView.tag == NEWVERSION)
    {
        if (buttonIndex == 1)
        {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",newVersionUrl]]];
        }
    }
}

-(void)getNewClass
{
    if ([[Tools user_id] length] > 0)
    {
        if ([Tools NetworkReachable])
        {
            __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                          @"token":[Tools client_token]
                                                                          } API:MB_NEWCLASS];
            [request setCompletionBlock:^{
                NSString *responseString = [request responseString];
                NSDictionary *responseDict = [Tools JSonFromString:responseString];
                DDLOG(@"newclass responsedict %@",responseDict);
                if ([[responseDict objectForKey:@"code"] intValue]== 1)
                {
                    if ([[responseDict objectForKey:@"data"] objectForKey:@"count"]||
                        [[responseDict objectForKey:@"data"] objectForKey:@"ucfriendsnum"])
                    {
                        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",[[[responseDict objectForKey:@"data"]objectForKey:@"count"] integerValue]] forKey:NewClassNum];
                        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",[[[responseDict objectForKey:@"data"] objectForKey:@"ucfriendsnum"] intValue]] forKey:UCFRIENDSUM];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        if ([[[responseDict objectForKey:@"data"] objectForKey:@"count"] integerValue] > 0||
                            [[[responseDict objectForKey:@"data"] objectForKey:@"ucfriendsnum"] integerValue] > 0)
                        {
                            if ([self.msgDelegate respondsToSelector:@selector(dealNewMsg:)])
                            {
                                [self.msgDelegate dealNewMsg:nil];
                            }
                        }
                    }
                }
                else
                {
                    [Tools dealRequestError:responseDict fromViewController:nil];
                }
            }];
            
            [request setFailedBlock:^{
            }];
            [request startAsynchronous];
        }

    }
}

-(void)getNewChat
{
    if ([[Tools user_id] length] > 0)
    {
        if ([Tools NetworkReachable])
        {
            __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                          @"token":[Tools client_token]
                                                                          } API:MB_NEWCHAT];
            [request setCompletionBlock:^{
                NSString *responseString = [request responseString];
                NSDictionary *responseDict = [Tools JSonFromString:responseString];
                DDLOG(@"newchat responsedict %@",responseDict);
                if ([[responseDict objectForKey:@"code"] intValue] == 1)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%d",[[responseDict objectForKey:@"data"] integerValue]] forKey:NewChatMsgNum];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    if([[responseDict objectForKey:@"data"] integerValue] > 0)
                    {
//                        if ([self.chatDelegate respondsToSelector:@selector(dealNewChatMsg:)])
//                        {
//                            [self.chatDelegate dealNewChatMsg:nil];
//                        }
                    }
                    
                    [[NSUserDefaults standardUserDefaults] setObject:ENTER_FORGROUD forKey:BECOMEACTIVE];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                }
                else
                {
                    [Tools dealRequestError:responseDict fromViewController:nil];
                }
            }];
            
            [request setFailedBlock:^{
            }];
            [request startAsynchronous];
        }

    }
}

- (void)shareAppKeysForEvery{
    // 新浪微博1
    [ShareSDK connectSinaWeiboWithAppKey:@"2793768944"
                               appSecret:@"65318523f0490d86a589fcff8279ac87"
                             redirectUri:@"http://open.weibo.com/apps/2793768944/privilege/oauth"];
    //腾讯微博2
    //tencent101057587
    [ShareSDK connectTencentWeiboWithAppKey:@"801497378"
                                  appSecret:@"37cc575e8a4b86d54f8af0a7ba709b4e"
                                redirectUri:@"http://api.banjiaedu.com"
                                   wbApiCls:[WeiboApi class]];
    
    [ShareSDK connectRenRenWithAppId:@"266632"
                              appKey:@"de954cb45bd54168a06ca0a7ffc825ca"
                           appSecret:@"7e5b80a8b1e544e19606a864c2c9c805"
                   renrenClientClass:[RennClient class]];
    
    [ShareSDK connectQZoneWithAppKey:@"101057587"
                           appSecret:@"42265b5d4afd87a65a269f18f845f9da"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    //QQ应用
    [ShareSDK connectQQWithQZoneAppKey:@"101057587"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    
    //微信5
        [ShareSDK connectWeChatWithAppId:@"wx480bf9924a52975f" wechatCls:[WXApi class]];
    //    [ShareSDK connectWeChatWithAppId:@"wx387c10c2e338aa3c" wechatCls:[WXApi class]];
}


-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
//    [[NSUserDefaults standardUserDefaults] setObject:@"accept" forKey:@"receive"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    DDLOG(@"device token %@",deviceToken);
    [APService registerDeviceToken:deviceToken];
   
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"receive"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"receive"])
//    {
//        [Tools showAlertView:@"你还不能收到推送的消息，不能及时收到班级通知，也不能正常聊天，您可以到系统设置里打开限制！" delegateViewController:nil];
//    }
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url wxDelegate:self];
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [ShareSDK handleOpenURL:url sourceApplication:sourceApplication annotation:annotation wxDelegate:self];
}


-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [self handlePushNotification:userInfo];
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self handlePushNotification:userInfo];
}

-(void)handlePushNotification:(NSDictionary *)userInfo
{
    [APService handleRemoteNotification:userInfo];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    DDLOG(@"push info %@",userInfo);
    
    if ([Tools user_id])
    {
        [self getNewChat];
        [self getNewClass];
        if ([[userInfo objectForKey:@"type"] isEqualToString:@"chat"])
        {
            NSMutableDictionary *chatDict = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSString *alertContent = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            NSString *chatContent;
            NSString *fname;
            if ([alertContent rangeOfString:@":"].length > 0)
            {
                chatContent = [alertContent substringFromIndex:[alertContent rangeOfString:@":"].location+1];
                fname = [alertContent substringToIndex:[alertContent rangeOfString:@":"].location];
                NSRange range1 = [fname rangeOfString:@"["];
                NSRange range2 = [fname rangeOfString:@"]"];
                if (range1.length > 0 && range2.length > 0)
                {
                    fname = [fname substringWithRange:NSMakeRange(range1.location+1, range2.location-1-range1.location)];
                }
            }
            else
            {
                chatContent = alertContent;
                fname = @"";
            }
            
            [chatDict setObject:[userInfo objectForKey:@"m"] forKey:@"mid"];
            
            [chatDict setObject:chatContent forKey:@"content"];
            
            if ([userInfo objectForKey:@"g_id"] &&
                ![[userInfo objectForKey:@"g_id"] isEqual:[NSNull null]] &&
                [[userInfo objectForKey:@"g_id"] length] > 0)
            {
                [chatDict setObject:[userInfo objectForKey:@"g_id"] forKey:@"fid"];
                [chatDict setObject:[userInfo objectForKey:@"u"] forKey:@"by"];
            }
            else
            {
                NSString *unum = [userInfo  objectForKey:@"u"];
                [chatDict setObject:unum forKey:@"fid"];
            }
            
            NSString *timeStr = [[userInfo objectForKey:@"m"] substringToIndex:8];
            
            [chatDict setObject:[CommonFunc from16To10:timeStr] forKey:@"time"];
            [chatDict setObject:@"f" forKey:@"direct"];
            [chatDict setObject:@"text" forKey:@"msgType"];
            [chatDict setObject:[Tools banjia_num] forKey:@"tid"];
            [chatDict setObject:@"0" forKey:@"readed"];
            [chatDict setObject:fname forKey:@"byname"];
            [chatDict setObject:[NSString stringWithFormat:@"%d",[[userInfo objectForKey:@"l"] intValue]] forKey:@"l"];
            NSString *ficon = @"";
            [chatDict setObject:ficon forKey:@"ficon"];
            //            [chatDict setObject:fname forKey:@"fname"];
            [chatDict setObject:[Tools user_id] forKey:@"userid"];
            
            if ([[NSUserDefaults standardUserDefaults] objectForKey:NewChatAlert])
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:NewChatAlert] integerValue] == 1)
                {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
            }
            
            if ([[_db findSetWithDictionary:@{@"userid":[Tools user_id],@"mid":[userInfo objectForKey:@"m"]} andTableName:CHATTABLE] count]==0)
            {
                
                if ([_db insertRecord:chatDict andTableName:CHATTABLE])
                {
                    
                    if ([self.chatDelegate respondsToSelector:@selector(dealNewChatMsg:)])
                    {
                        [self.chatDelegate dealNewChatMsg:chatDict];
                    }
                    if (!([[NSUserDefaults standardUserDefaults] objectForKey:@"viewtype"] &&
                          [[[NSUserDefaults standardUserDefaults] objectForKey:@"viewtype"] isEqualToString:@"chat"]))
                    {
                        if ([[[NSUserDefaults standardUserDefaults]objectForKey:BECOMEACTIVE] isEqualToString:ENTER_BACKGROUD])
                        {
                            sideMenuViewController = [[SideMenuViewController alloc] init];
                            MessageViewController *msgViewController = [[MessageViewController alloc] init];
                            KKNavigationController *msgNav = [[KKNavigationController alloc] initWithRootViewController:msgViewController];
                            [sideMenuViewController.buttonTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                            JDSideMenu *sideMenu = [[JDSideMenu alloc] initWithContentController:msgNav menuController:sideMenuViewController];
                            self.window.rootViewController = sideMenu;
                            
                            [[NSUserDefaults standardUserDefaults] setObject:ENTER_FORGROUD forKey:BECOMEACTIVE];
                            [[NSUserDefaults standardUserDefaults] synchronize];
                        }
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECHATSNUMBER object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVENEWMSG object:chatDict];
                }
            }
        }
        else if ([[userInfo objectForKey:@"type"] isEqualToString:@"c_apply"])
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
            [dict setObject:@"" forKey:@"role"];
            [dict setObject:@"" forKey:@"img_icon"];
            [dict setObject:@"" forKey:@"phone"];
            [dict setObject:@"" forKey:@"re_name"];
            [dict setObject:@"" forKey:@"re_id"];
            [dict setObject:@"" forKey:@"re_type"];
            [dict setObject:@"" forKey:@"title"];
            [dict setObject:@"" forKey:@"name"];
            [dict setObject:[userInfo objectForKey:@"tag"] forKey:@"classid"];
            [dict setObject:@"" forKey:@"re_type"];
            [dict setObject:@"0" forKey:@"checked"];
            [dict setObject:@"" forKey:@"uid"];
            if ([_db insertRecord:dict andTableName:CLASSMEMBERTABLE])
            {
                if ([self.msgDelegate respondsToSelector:@selector(dealNewMsg:)])
                {
                    [self.msgDelegate dealNewMsg:userInfo];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSMEMBERLIST object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSNUMBER object:nil];
        }
        else if ([[userInfo objectForKey:@"type"] isEqualToString:@"notice"])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVENEWNOTICE object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSNUMBER object:nil];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:NewNoticeMotion])
            {
                if ([[[NSUserDefaults standardUserDefaults]objectForKey:NewNoticeMotion] integerValue] == 1)
                {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
            }
            if([[NSUserDefaults standardUserDefaults] objectForKey:NewNoticeAlert])
            {
                if ([[[NSUserDefaults standardUserDefaults] objectForKey:NewNoticeAlert] integerValue] == 1)
                {
                    NSString *path = [[NSBundle mainBundle] pathForResource:@"msg"
                                                                     ofType:@"wav"];
                    SystemSoundID soundID;
                    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path]
                                                     , &soundID);
                    AudioServicesPlaySystemSound (soundID);
                }
            }
        }
        else if([[userInfo objectForKey:@"type"] isEqualToString:@"f_apply"])
        {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
            NSString *alertString = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
            NSRange range = [alertString rangeOfString:@":"];
            NSString *name;
            if (range.length > 0)
            {
                name = [alertString substringToIndex:range.location-1];
            }
            else
            {
                name = @"";
            }
            
            [dict setObject:[Tools user_id] forKey:@"uid"];
            [dict setObject:name forKey:@"fname"];
            [dict setObject:@"" forKey:@"ficon"];
            [dict setObject:@"" forKey:@"fid"];
            [dict setObject:@"" forKey:@"phone"];
            [dict setObject:@"0" forKey:@"checked"];
            [dict setObject:[Tools user_id] forKey:@"uid"];
            if ([_db insertRecord:dict andTableName:FRIENDSTABLE])
            {
                if ([self.msgDelegate respondsToSelector:@selector(dealNewMsg:)])
                {
                    [self.msgDelegate dealNewMsg:userInfo];
                }
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:UPDATECLASSNUMBER object:nil];
            UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"提示" message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
            [al show];
        }
        else if ([[userInfo objectForKey:@"type"] isEqualToString:@"c_allow"])
        {
            if ([self.msgDelegate respondsToSelector:@selector(dealNewMsg:)])
            {
                [self.msgDelegate dealNewMsg:userInfo];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:CHANGECLASSINFO object:nil];
        }
        else if([[userInfo objectForKey:@"type"] isEqualToString:@"logout"])
        {
            if ([[Tools user_id] length] > 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"logout" object:userInfo];
            }
            [Tools showAlertView:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"] delegateViewController:nil];
        }
    }
}

#pragma mark - tapstip
-(void)tapTipsWithData:(NSDictionary *)dataDict
{
    [sideMenuViewController statusTipTapWithDataDict:dataDict];
}

-(void)getClassInfo:(NSDictionary  *)classDict
{
    if ([Tools NetworkReachable])
    {
        NSString *classID = [classDict objectForKey:@"tag"];
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"c_id":classID
                                                                      } API:CLASSINFO];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"classInfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue]== 1)
            {
                if(![[responseDict objectForKey:@"data"] isEqual:[NSNull null]])
                {                    
                    NSString *alertString = [[classDict objectForKey:@"aps"] objectForKey:@"alert"];
                    NSRange range = [alertString rangeOfString:@":"];
                    
                    NSString *name;
                    NSString *content;
                    
                    if (range.length > 0)
                    {
                        name = [alertString substringToIndex:range.location-1];
                        content = [alertString substringFromIndex:range.location+1];
                    }
                    else
                    {
                        name = @"";
                        content = @"";
                    }
                    
                    
                    NSString *message = [NSString stringWithFormat:@"%@:%@",[[responseDict objectForKey:@"data"] objectForKey:@"name"],content];
                    UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"新公告" message:message delegate:self cancelButtonTitle:@"知道了" otherButtonTitles: nil];
                    [al show];
                    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:0];
                    [dict setObject:content forKey:@"content"];
                    [dict setObject:name forKey:@"fname"];
                    [dict setObject:[classDict objectForKey:@"tag"] forKey:@"tag"];
                    [dict setObject:[classDict objectForKey:@"time"] forKey:@"time"];
                    [dict setObject:[classDict objectForKey:@"type"] forKey:@"type"];
                    [dict setObject:@"0" forKey:@"readed"];
                    [dict setObject:[Tools user_id] forKey:@"uid"];
                    if ([_db insertRecord:dict andTableName:@"notice"])
                    {
                        if ([self.msgDelegate respondsToSelector:@selector(dealNewMsg:)])
                        {
                            [self.msgDelegate dealNewMsg:classDict];
                        }
                    }
                    
                }
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



-(BOOL)silenced {
#if TARGET_IPHONE_SIMULATOR
    // return NO in simulator. Code causes crashes for some reason.
    return NO;
#endif
    
    CFStringRef state;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &state);
    if(CFStringGetLength(state) > 0)
        return NO;
    else
        return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    DDLOG_CURRENT_METHOD;
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DDLOG_CURRENT_METHOD;
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] setObject:ENTER_BACKGROUD forKey:BECOMEACTIVE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[StatusBarTips shareTipsWindow] hideTips];
    if ([[Tools user_id] length] > 0 && [[Tools client_token] length] > 0)
    {
        [self getNewChat];
        [self getNewClass];
//        [[NSUserDefaults standardUserDefaults] setObject:ENTER_FORGROUD forKey:BECOMEACTIVE];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [self getNewChat];
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
    
    DDLOG_CURRENT_METHOD;
    [[NSUserDefaults standardUserDefaults] setObject:ENTER_BACKGROUD forKey:BECOMEACTIVE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BANJIA" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"BANJIA.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
