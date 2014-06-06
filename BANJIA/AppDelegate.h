//
//  AppDelegate.h
//  BANJIA
//
//  Created by TeekerZW on 4/4/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OperatDB.h"
#import "BMapKit.h"
#import "APService.h"



@protocol ChatDelegate;
@protocol MsgDelegate;

@interface AppDelegate : UIResponder <UIApplicationDelegate,UIAlertViewDelegate>
{
    NSString *updateUrl;
    BMKMapManager* _mapManager;
}
@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, assign) id<ChatDelegate> chatDelegate;
@property (nonatomic, assign) id<MsgDelegate> msgDelegate;
@property (strong ,nonatomic) OperatDB *db;


- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end

@protocol ChatDelegate <NSObject>

-(void)dealNewChatMsg:(NSDictionary *)dict;

@end
@protocol MsgDelegate <NSObject>

-(void)dealNewMsg:(NSDictionary *)dict;

@end