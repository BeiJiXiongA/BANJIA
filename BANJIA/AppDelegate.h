//
//  AppDelegate.h
//  BANJIA
//
//  Created by TeekerZW on 4/4/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OperatDB.h"
#import "APService.h"
#import "StatusBarTips.h"
#import "SideMenuViewController.h"
#import "WXApi.h"

@protocol ChatDelegate;
@protocol MsgDelegate;
@protocol WeiChatDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate,TipsDelegate,WXApiDelegate>
{
    NSString *updateUrl;
    SideMenuViewController *sideMenuViewController;
    
    NSString *newVersionUrl;
}
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, assign) id<ChatDelegate> chatDelegate;
@property (nonatomic, assign) id<MsgDelegate> msgDelegate;
@property (nonatomic, assign) id<WeiChatDelegate> weiChatDel;
@property (strong ,nonatomic) OperatDB *db;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

@protocol ChatDelegate <NSObject>
@optional
-(void)dealNewChatMsg:(NSDictionary *)dict;
-(void)uploadLastViewTime;

@end
@protocol MsgDelegate <NSObject>
@optional
-(void)dealNewMsg:(NSDictionary *)dict;
@end

@protocol WeiChatDelegate <NSObject>

-(void)loginWithWeiChatId:(NSString *)userid
            andHeaderIcon:(NSString *)headerUrl
              andUserName:(NSString *)userName
                   andSex:(NSString *)sex;
@end