//
//  MessageCell.h
//  XMPP1106
//
//  Created by mac120 on 13-11-6.
//  Copyright (c) 2013年 mac120. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageCell : UITableViewCell
@property (nonatomic, strong) UIImageView *headerImageView;
@property (nonatomic,strong) UITextView *messageTf;
@property (nonatomic,strong) UIImageView *chatBg;
@property (nonatomic,strong) UIButton *button;
@property (nonatomic,strong) UILabel *timeLabel;
@end
