//
//  DBManager.h
//  HtmlDemo
//
//  Created by TeekerZW on 14-1-16.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabaseAdditions.h"

@class FMDatabase;

@interface DBManager : NSObject
{
    NSString *_name;
}
@property (nonatomic, readonly) FMDatabase *dataBase;

+(DBManager *) defaultDBManager;

- (void) close;

@end
