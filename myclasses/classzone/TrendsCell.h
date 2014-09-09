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

#define ColumnPerRow  8
#define PraiseW   31
#define PraiseH   31
#define PraiseCellHeight  30

@protocol NameButtonDel;

@interface TrendsCell : UITableViewCell<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UITextView *contentTextField;
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


@property (nonatomic, assign) BOOL openPraise;
@end

@protocol NameButtonDel <NSObject>

-(void)nameButtonClick:(NSDictionary *)dict;
@optional
-(void)showPersonDetail:(NSDictionary *)dict;
-(void)cellCommentDiary:(NSDictionary *)dict;
@end
