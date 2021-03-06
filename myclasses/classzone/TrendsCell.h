//
//  TrendsCell.h
//  School
//
//  Created by TeekerZW on 14-2-22.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyButton.h"
#import "PersonDetailViewController.h"
#import "CommentCell.h"

#define ColumnPerRow  8
#define PraiseW   31
#define PraiseH   31

@protocol NameButtonDel;

@interface TrendsCell : UITableViewCell<UITableViewDataSource,UITableViewDelegate,CommentDelegate>
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *imagesView;
@property (nonatomic, strong) MyButton *transmitButton;
@property (nonatomic, strong) MyButton *praiseButton;
@property (nonatomic, strong) MyButton *commentButton;
@property (nonatomic, strong) MyTextField *nameTextField;
@property (nonatomic, strong) UITableView *commentsTableView;
@property (nonatomic, strong) NSArray *commentsArray;
@property (nonatomic, strong) NSArray *praiseArray;
@property (nonatomic, assign) BOOL showAllComments;
@property (nonatomic, assign) id<NameButtonDel> nameButtonDel;
@property (nonatomic, strong) NSDictionary *diaryDetailDict;
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UIView *verticalLineView;

@property (nonatomic, strong) UIView *geduan1;
@property (nonatomic, strong) UIView *geduan2;

@property (nonatomic, strong) NSIndexPath *diaryIndexPath;


@property (nonatomic, assign) BOOL openPraise;

-(void)setContent;

@end

@protocol NameButtonDel <NSObject>

@optional

-(void)nameButtonClick:(NSDictionary *)dict andIndexPath:(NSIndexPath *)indexPath;

-(void)showPersonDetail:(NSDictionary *)dict;

-(void)cellCommentDiary:(NSDictionary *)dict andIndexPath:(NSIndexPath *)indexPath andCommentDict:(NSDictionary *)commentDict;

-(void)deleteCommentWithDiary:(NSDictionary *)diaryDetailDict
               andCommentDict:(NSDictionary *)commentDict
              andCommentIndex:(NSInteger)commentIndex
                 andIndexPath:(NSIndexPath *)indexPath;
@end
