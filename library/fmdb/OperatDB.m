//
//  OperatDB.m
//  HtmlDemo
//
//  Created by TeekerZW on 14-1-16.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "OperatDB.h"

@implementation OperatDB

-(id)init
{
    self = [super init];
    if (self)
    {
        _db = [DBManager defaultDBManager].dataBase;
        [self createTableWithTableName:@"chatMsg"];
        [self createNoticeTabel];
        [self createCityTable];
        [self createFriendsTable];
        [self createClassMemTable];
        [self createImgIconTabel];
        [self createUserInfoTable];
        [self createMyClassTable];
    }
    return self;
}

#pragma mark - operatetable

-(BOOL)alterTableAdd:(NSString *)column
          charLength:(NSInteger)charlength
        defaultValue:(NSString *)defaultValue
        andTableName:(NSString *)tableName
{
    NSString *altertableStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD '%@' VARCHAR(%d) default '%@'",tableName,column,charlength,defaultValue];
    BOOL res = [_db executeUpdate:altertableStr];
    if (res)
    {
        DDLOG(@"add %@ to %@ success",column,tableName);
    }
    return res;
}

-(void)deleteTable:(NSString *)tablename
{
    NSString *dropTableStr = [NSString stringWithFormat:@"DROP TABLE %@",tablename];
    BOOL res = [_db executeUpdate:dropTableStr];
    if (res)
    {
        DDLOG(@"drop %@ success!",tablename);
    }
}

#pragma mark - createtable

-(void)createUserInfoTable
{
    FMResultSet *set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",USERINFO]];
    [set next];
    
    NSInteger count = [set intForColumnIndex:0];
    BOOL existTable = !!count;
    if (existTable)
    {
        NSLog(@"table has exist!");
    }
    else
    {
        //chatMsg
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (\
                         userid VARCHAR(30),username VARCHAR(30),img_icon VARCHAR(30),img_kb VARCHAR(30),phone VARCHAR(20),birth VARCHAR(10),QQ VARCHAR(20),renren VARCHAR(20),sina VARCHAR(20),classes VARCHAR(50))",USERINFO];
        BOOL res = [_db executeUpdate:sql];
        if (!res)
        {
            NSLog(@"table %@ create failed!",USERINFO);
        }
        else
        {
            NSLog(@"table %@ create success!",USERINFO);
        }
    }

}

-(void)createMyClassTable
{
    FMResultSet *set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",MYCLASSTABLE]];
    [set next];
    
    NSInteger count = [set intForColumnIndex:0];
    BOOL existTable = !!count;
    if (existTable)
    {
        NSLog(@"table has exist!");
    }
    else
    {
        //chatMsg
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (\
                         uid VARCHAR(30),classid VARCHAR(30),classname VARCHAR(10),img_icon VARCHAR(30),img_kb VARCHAR(10),s_name VARCHAR(50),s_level VARCHAR(50),s_id VARCHAR(50))",MYCLASSTABLE];
        BOOL res = [_db executeUpdate:sql];
        if (!res)
        {
            NSLog(@"table %@ create failed!",MYCLASSTABLE);
        }
        else
        {
            NSLog(@"table %@ create success!",MYCLASSTABLE);
        }
    }
}


-(void)createCityTable
{
    FMResultSet *set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",CITYTABLE]];
    [set next];
    
    NSInteger count = [set intForColumnIndex:0];
    BOOL existTable = !!count;
    if (existTable)
    {
        NSLog(@"table has exist!");
    }
    else
    {
        //chatMsg
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (\
                         cityid VARCHAR(30),cityname VARCHAR(30),jianpin VARCHAR(10),quanpin VARCHAR(30),citylevel VARCHAR(10),pid VARCHAR(50),fname VARCHAR(50))",CITYTABLE];
        BOOL res = [_db executeUpdate:sql];
        if (!res)
        {
            NSLog(@"table %@ create failed!",CITYTABLE);
        }
        else
        {
            NSLog(@"table %@ create success!",CITYTABLE);
        }
    }
}

#pragma mark - chattable
-(void)createTableWithTableName:(NSString *)TableName
{
    FMResultSet *set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",TableName]];
    [set next];
    
    NSInteger count = [set intForColumnIndex:0];
    BOOL existTable = !!count;
    if (existTable)
    {
        NSLog(@"table has exist!");
    }
    else
    {
        //chatMsg
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (userindex INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,\
                         mid VARCHAR(30) NOT NULL,\
                         userid VARCHAR(30),fid VARCHAR(30),fname VARCHAR(30),ficon VARCHAR(50),tid VARCHAR(30),direct VARCHAR(2),readed VARCHAR(2), content VARCHAR(20),msgType VARCHAR(8),time VARCHAR(15))",TableName];
        BOOL res = [_db executeUpdate:sql];
        if (!res)
        {
            NSLog(@"table %@ create failed!",TableName);
        }
        else
        {
            NSLog(@"table %@ create success!",TableName);
        }
    }
}
#pragma mark - notice
-(void)createNoticeTabel
{
    FMResultSet *set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = 'notice'"]];
    [set next];
    
    NSInteger count = [set intForColumn:0];
    BOOL existTable = !!count;
    if (existTable)
    {
        {
            DDLOG(@"table notice has exist!");
        }
    }
    else
    {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE notice (nid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,uid VARCHAR(30),fname VARCHAR(20),tag VARCHAR(30),content VARCHAR(30),time VARCHAR(20),type VARCHAR(10),readed VARCHAR(6),fid VARCHAR(30))"];
        BOOL res = [_db executeUpdate:sql];
        if (!res)
        {
            DDLOG(@"table notice create failed!");
        }
        else
        {
            DDLOG(@"table notice create success!");
        }
    }
}
#pragma mark - imag_icon
-(void)createImgIconTabel
{
    FMResultSet *set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",USERICONTABLE]];
    [set next];
    
    NSInteger count = [set intForColumn:0];
    BOOL existTable = !!count;
    if (existTable)
    {
        {
            DDLOG(@"table notice has exist!");
        }
    }
    else
    {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (iid INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,uid VARCHAR(30),uicon VARCHAR(30))",USERICONTABLE];
        BOOL res = [_db executeUpdate:sql];
        if (!res)
        {
            DDLOG(@"table usericon create failed!");
        }
        else
        {
            DDLOG(@"table usericon create success!");
        }
    }
}
#pragma mark - friends

-(void)createFriendsTable
{
    FMResultSet *set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",FRIENDSTABLE]];
    [set next];
    
    NSInteger count = [set intForColumn:0];
    BOOL existTable = !!count;
    if (existTable)
    {
        {
            NSLog(@"table has exist!");
        }
    }
    else
    {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (userindex INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,\
                         uid VARCHAR(30),fname VARCHAR(20),ficon VARCHAR(30),fid VARCHAR(30),phone VARCHAR(15),checked VARCHAR(10))",FRIENDSTABLE];
        BOOL res = [_db executeUpdate:sql];
        if (!res)
        {
            NSLog(@"table %@ create failed!",@"friends");
        }
        else
        {
            NSLog(@"table %@ create success!",@"friends");
        }
    }
    
}
#pragma mark - classmembers
-(void)createClassMemTable
{
    FMResultSet *set = [_db executeQuery:[NSString stringWithFormat:@"select count(*) from sqlite_master where type ='table' and name = '%@'",CLASSMEMBERTABLE]];
    [set next];
    
    NSInteger count = [set intForColumn:0];
    BOOL existTable = !!count;
    if (existTable)
    {
        
        [self deleteTable:CLASSMEMBERTABLE];
    }
    else
    {
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE %@ (userindex INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,\
                         classid VARCHAR(30),name VARCHAR(20),jianpin VARCHAR(10),quanpin VARCHAR(10),uid VARCHAR(30),img_icon VARCHAR(30),re_id VARCHAR(30),re_name VARCHAR(30),checked VARCHAR(5),phone VARCHAR(15),role VARCHAR(15),re_type VARCHAR(20),title VARCHAR(20),birth VARCHAR(20),admin VARCHAR(4))",CLASSMEMBERTABLE];
        BOOL res = [_db executeUpdate:sql];
        if (!res)
        {
            NSLog(@"table %@ create failed!",CLASSMEMBERTABLE);
        }
        else
        {
            NSLog(@"table %@ create success!",CLASSMEMBERTABLE);
        }
    }
    
}
-(NSMutableArray *)findStudentsFromParentsWithClassID:(NSString *)classid
{
    NSMutableArray *studentsArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *query = [NSString stringWithFormat:@"select re_name from %@ where classid='%@' and role='parents' group by re_name",CLASSMEMBERTABLE,classid];
    FMResultSet *resultSet = [_db executeQuery:query];
    while ([resultSet next])
    {
        [studentsArray addObject:[resultSet resultDictionary]];
    }
    return studentsArray;
}

#pragma mark - chatlog
-(NSMutableArray *)findChatLogWithUid:(NSString *)uid andOtherId:(NSString *)otherid
                         andTableName:(NSString *)tableName
{
    NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ WHERE (fid='%@' AND tid='%@' and direct='t') OR (fid='%@' AND tid='%@' and direct='f') ORDER BY time",tableName,uid,otherid,otherid,uid];
    NSString *queryStr = [query substringToIndex:[query length]];
    FMResultSet *resultSet = [_db executeQuery:queryStr];
    DDLOG(@"chat log query %@",queryStr);
    while ([resultSet next])
    {
        [msgArray addObject:[resultSet resultDictionary]];
    }
    return msgArray;
}

-(NSMutableArray *)findChatUseridWithTableName:(NSString *)tableName
{
    NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT  * FROM chatMsg where fid IN (SELECT DISTINCT fid FROM chatMsg WHERE userid='%@' AND fid != '%@') AND  userid='%@' GROUP BY fid",[Tools user_id],[Tools user_id],[Tools user_id]];
    NSString *queryStr = [query substringToIndex:[query length]];
    FMResultSet *resultSet = [_db executeQuery:queryStr];
    DDLOG(@"quert dictinct %@",queryStr);
    while ([resultSet next])
    {
        [msgArray addObject:[resultSet resultDictionary]];
    }
    DDLOG(@"chat list=%@",msgArray);
    return msgArray;
    
}

#pragma mark - operate DB

-(BOOL)insertRecord:(NSDictionary *)dict andTableName:(NSString *)tableName
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"INSERT INTO %@",tableName];
    NSMutableString *keys = [NSMutableString stringWithFormat:@" ( "];
    NSMutableString *values = [NSMutableString stringWithFormat:@" ( "];
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:0];
    for (NSString *key in dict)
    {
        [keys appendString:[NSString stringWithFormat:@"%@,",key]];
        [values appendString:@"?,"];
        [arguments addObject:[dict objectForKey:key]];
    }

    [keys appendString:@") "];
    [values appendString:@") "];
    [query appendFormat:@" %@ VALUES %@",
    [keys stringByReplacingOccurrencesOfString:@",)" withString:@")"],
    [values stringByReplacingOccurrencesOfString:@",)" withString:@")"]];
    if ([_db executeUpdate:query withArgumentsInArray:arguments])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(NSMutableArray *)findSetWithKey:(NSString *)key
                         andValue:(NSString *)value
                     andTableName:(NSString *)tableName
{
    NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ WHERE %@ = '%@'",tableName,key,value];
    FMResultSet *resultSet = [_db executeQuery:query];
    while ([resultSet next])
    {
        [msgArray addObject:[resultSet resultDictionary]];
    }
    return msgArray;
}

-(NSMutableArray *)findSetWithDictionary:(NSDictionary *)dict
                            andTableName:(NSString *)tableName
{
    NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ",tableName];
    if([dict count] > 0)
    {
        [query insertString:@" WHERE" atIndex:[query length]];
        for (NSString *key in dict)
        {
            [query appendString:[NSString stringWithFormat:@" %@='%@' and",key,[dict objectForKey:key]]];
        }
        [query deleteCharactersInRange:NSMakeRange([query length]-3, 3)];
    }
    DDLOG(@"find query %@",query);
    FMResultSet *resultSet = [_db executeQuery:query];
    while ([resultSet next])
    {
        [msgArray addObject:[resultSet resultDictionary]];
    }
    return msgArray;
}

-(NSMutableArray *)findSetWithDictionary:(NSDictionary *)dict
                             orderByName:(NSString *)orderKey
                            andTableName:(NSString *)tableName
{
    NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ",tableName];
    if([dict count] > 0)
    {
        [query insertString:@" WHERE" atIndex:[query length]];
        for (NSString *key in dict)
        {
            [query appendString:[NSString stringWithFormat:@" %@='%@' and",key,[dict objectForKey:key]]];
        }
        [query deleteCharactersInRange:NSMakeRange([query length]-3, 3)];
        [query insertString:[NSString stringWithFormat:@" order by %@",orderKey] atIndex:[query length]];
    }
    DDLOG(@"find query %@",query);
    FMResultSet *resultSet = [_db executeQuery:query];
    while ([resultSet next])
    {
        [msgArray addObject:[resultSet resultDictionary]];
    }
    return msgArray;
}


-(NSMutableArray *)fuzzyfindSetWithDictionary:(NSDictionary *)dict
                     andTableName:(NSString *)tableName
                           andFuzzyDictionary:(NSDictionary *)fuzzyDict
{
    NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT * FROM %@ ",tableName];
    if([dict count] > 0)
    {
        [query insertString:@" WHERE" atIndex:[query length]];
        for (NSString *key in dict)
        {
            [query appendString:[NSString stringWithFormat:@" %@='%@' and",key,[dict objectForKey:key]]];
        }
        
        if ([fuzzyDict count] > 0)
        {
            [query insertString:@" (" atIndex:[query length]];
            for(NSString *key in fuzzyDict)
            {
                [query appendString:[NSString stringWithFormat:@" %@ like \'%%%@%%\' or",key,[fuzzyDict objectForKey:key]]];
            }
            [query deleteCharactersInRange:NSMakeRange([query length]-2, 2)];
            [query insertString:@")" atIndex:[query length]];
        }
//        [query appendString:[NSString stringWithFormat:@" (%@ like \'%%%@%%\' or %@ like \'%@%%\' or %@ like \'%%%@\')",fuzzyKey,fuzzyValue,fuzzyKey,fuzzyValue,fuzzyKey,fuzzyValue]];
    }
    DDLOG(@"fuzzy query %@",query);
    FMResultSet *resultSet = [_db executeQuery:query];
    while ([resultSet next])
    {
        [msgArray addObject:[resultSet resultDictionary]];
    }
    return msgArray;
}


-(NSMutableArray *)findSetWithDictionary:(NSDictionary *)dict
                         andDistinctName:(NSString *)distinctName
                              otherColuns:(NSArray *)colums
                            andTableName:(NSString *)tableName
{
    NSMutableArray *msgArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableString *query = [NSMutableString stringWithFormat:@"SELECT DISTINCT %@ ",distinctName];
    for(NSString *colum in colums)
    {
        [query appendString:[NSString stringWithFormat:@",%@ ",colum]];
    }
    [query appendString:[NSString stringWithFormat:@" FROM %@ WHERE ",tableName]];
    
    for (NSString *key in dict)
    {
        [query appendString:[NSString stringWithFormat:@" %@='%@' and",key,[dict objectForKey:key]]];
    }
    NSString *queryStr = [query substringToIndex:[query length]-3];
    FMResultSet *resultSet = [_db executeQuery:queryStr];
    DDLOG(@"===%@",queryStr);
    while ([resultSet next])
    {
        [msgArray addObject:[resultSet resultDictionary]];
    }
    return msgArray;
}

-(BOOL)deleteRecordWithDict:(NSDictionary *)dict andTableName:(NSString *)tableName
{
    NSMutableString *query = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"DELETE FROM %@ WHERE",tableName]];
    for (NSString *key in dict)
    {
        [query insertString:[NSString stringWithFormat:@" %@='%@' and",key,[dict objectForKey:key]] atIndex:[query length]];
    }
    NSString *queryStr = [query substringToIndex:[query length]-3];
    DDLOG(@"queryStr %@",queryStr);
    BOOL success = [_db executeUpdate:queryStr];
    if (success)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(BOOL)updeteKey:(NSString *)key toValue:(NSString *)value
    withParaDict:(NSDictionary *)dict
    andTableName:(NSString *)tableName
{
    NSMutableString *query = [NSMutableString stringWithFormat:@"UPDATE %@ SET %@ = '%@' WHERE",tableName,key,value];
    for (NSString *key in dict)
    {
        [query appendString:[NSString stringWithFormat:@" %@='%@' and",key,[dict objectForKey:key]]];
    }
    NSString *queryStr = [query substringToIndex:[query length]-3];
    BOOL success = [_db executeUpdate:queryStr];
    if (success)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
@end
