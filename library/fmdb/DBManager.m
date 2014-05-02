//
//  DBManager.m
//  HtmlDemo
//
//  Created by TeekerZW on 14-1-16.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "DBManager.h"
#import "FMDatabase.h"

#define kDefaultDBName @"database.sqlite"

@implementation DBManager

static DBManager *_sharedDBManager;
+(DBManager *)defaultDBManager
{
    @synchronized (self)
    {
        if (_sharedDBManager == nil)
        {
            _sharedDBManager = [[DBManager alloc] init];
        }
    }
    return _sharedDBManager;
}

-(id)init
{
    self = [super init];
    if (self)
    {
        int state = [self initializeDBWithName:kDefaultDBName];
        if (state == -1)
        {
            NSLog(@"db init failed!");
        }
        else
        {
            NSLog(@"db init success!");
        }
    }
    return self;
    
}

- (int) initializeDBWithName : (NSString *) name {
    if (!name) {
		return -1;  // 返回数据库创建失败
	}
    // 沙盒Docu目录
    NSString * docp = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
	_name = [docp stringByAppendingString:[NSString stringWithFormat:@"/%@",name]];
	NSFileManager * fileManager = [NSFileManager defaultManager];
    BOOL exist = [fileManager fileExistsAtPath:_name];
    [self connect];
    if (!exist) {
        return 0;
    } else {
        return 1;          // 返回 数据库已经存在
        
	}
    
}

- (void) connect {
	if (!_dataBase) {
		_dataBase = [[FMDatabase alloc] initWithPath:_name];
	}
	if (![_dataBase open]) {
		NSLog(@"can not open db!");
	}
}

- (void) close {
	[_dataBase close];
    _sharedDBManager = nil;
}
@end
