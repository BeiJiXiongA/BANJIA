//
//  DongTaiDetailViewController.h
//  School
//
//  Created by TeekerZW on 14-2-28.
//  Copyright (c) 2014年 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol DongTaiDetailAddCommentDelegate <NSObject>

-(void)addComment:(BOOL)add;

@end

@interface DongTaiDetailViewController : XDContentViewController
@property (nonatomic, strong) NSString *dongtaiId;
@property (nonatomic, strong) NSString *classID;
@property (nonatomic, assign) id<DongTaiDetailAddCommentDelegate> addComDel;
@end
