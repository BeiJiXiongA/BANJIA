//
//  CommentCell.m
//  BANJIA
//
//  Created by TeekerZW on 6/17/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "CommentCell.h"
#import "PopView.h"

@implementation CommentCell
@synthesize nameButton,commentContentLabel;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        nameButton.titleLabel.font = [UIFont systemFontOfSize:14];
        nameButton.backgroundColor = RGB(252, 252, 252, 1);;
        [nameButton setTitleColor:RGB(64, 196, 110, 1) forState:UIControlStateNormal];
        [self.contentView addSubview:nameButton];
        
        commentContentLabel = [[UILabel alloc] init];
        commentContentLabel.backgroundColor = RGB(252, 252, 252, 1);
        commentContentLabel.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:commentContentLabel];
        
        self.backgroundColor = RGB(252, 252, 252, 1);
        self.contentView.backgroundColor = RGB(252, 252, 252, 1);
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
