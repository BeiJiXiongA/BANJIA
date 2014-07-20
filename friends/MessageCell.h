//
//  MessageCell.h
//  XMPP1106
//
//  Created by mac120 on 13-11-6.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MessageDelegate;

@interface MessageCell : UITableViewCell
{
    UITapGestureRecognizer *headerTapTgr;
    UIImage *fromImage;
    UIImage *toImage;
}
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UITextView *messageTf;
@property (nonatomic, strong) UIImageView *chatBg;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIImageView *msgImageView;

@property (nonatomic, strong) UILabel *joinlable;

@property (nonatomic, strong) NSDictionary *msgDict;

@property (nonatomic, assign) id<MessageDelegate> msgDelegate;

-(void)setCellWithDict:(NSDictionary *)dict;
@end

@protocol MessageDelegate <NSObject>

-(void)toPersonDetail:(NSDictionary *)personDict;

@end
