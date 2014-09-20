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
    
    UITapGestureRecognizer *chatImageTap;
    
    NSTimer *timer;
    
    BOOL isPlaying;
    
    int currentSec;
}
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic, strong) UILabel *messageContentLabel;
@property (nonatomic, strong) UIImageView *chatBg;
@property (nonatomic, strong) UIButton *soundButton;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) NSString *fromImgIcon;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIImageView *msgImageView;

@property (nonatomic, strong) UILabel *joinlable;

@property (nonatomic, strong) NSDictionary *msgDict;

@property (nonatomic, assign) BOOL isGroup;

@property (nonatomic, assign) id<MessageDelegate> msgDelegate;

-(void)setCellWithDict:(NSDictionary *)dict;
@end

@protocol MessageDelegate <NSObject>

-(void)toPersonDetail:(NSDictionary *)personDict;
-(void)joinClassWithMsgContent:(NSString *)msgContent;
-(void)soundTap:(NSString *)msgContent andImageView:(UIImageView *)soundImageView;
-(void)stopPlay:(NSString *)soundPath;
@end
