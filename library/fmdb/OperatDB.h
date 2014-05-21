//
//  OperatDB.h
//  HtmlDemo
//
//  Created by TeekerZW on 14-1-16.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "DBManager.h"
#import "School.h"
#define CHATTABLE  @"chatMsg"
#define NOTICETABLE  @"notice"
#define FRIENDSTABLE     @"friends"
#define CLASSMEMBERTABLE   @"classmembertable"
#define USERICONTABLE    @"usericontalble"
#define CITYTABLE         @"citytable"

@interface OperatDB : NSObject
{
    FMDatabase *_db;
}
-(BOOL)insertRecord:(NSDictionary *)dict
       andTableName:(NSString *)tableName;

-(NSMutableArray *)findStudentsFromParentsWithClassID:(NSString *)classid;

-(NSMutableArray *)findSetWithKey:(NSString *)key
                         andValue:(NSString *)value
                     andTableName:(NSString *)tableName;

-(NSMutableArray *)findSetWithDictionary:(NSDictionary *)dict
                            andTableName:(NSString *)tableName;

-(NSMutableArray *)findSetWithDictionary:(NSDictionary *)dict
                             orderByName:(NSString *)orderKey
                            andTableName:(NSString *)tableName;

-(NSMutableArray *)fuzzyfindSetWithDictionary:(NSDictionary *)dict
                                 andTableName:(NSString *)tableName
                           andFuzzyDictionary:(NSDictionary *)fuzzyDict;

-(NSMutableArray *)findSetWithDictionary:(NSDictionary *)dict
                         andDistinctName:(NSString *)distinctName
                             otherColuns:(NSArray *)colums
                            andTableName:(NSString *)tableName;

-(BOOL)updeteKey:(NSString *)key toValue:(NSString *)value
    withParaDict:(NSDictionary *)dict
    andTableName:(NSString *)tableName;

-(BOOL)deleteRecordWithDict:(NSDictionary *)dict
               andTableName:(NSString *)tableName;
-(NSMutableArray *)findChatLogWithUid:(NSString *)uid andOtherId:(NSString *)otherid
                         andTableName:(NSString *)tableName;
-(NSMutableArray *)findChatUseridWithTableName:(NSString *)tableName;
@end
