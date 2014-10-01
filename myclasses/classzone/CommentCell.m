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
@synthesize nameButton,commentContentLabel,commentDict,praiseView,openPraiseButton,headerImageView,timeLabel,lineImageView,nameLable;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        nameButton.titleLabel.font = [UIFont systemFontOfSize:14];
        nameButton.backgroundColor = RGB(252, 252, 252, 1);;
        [nameButton setTitleColor:DongTaiCommentName forState:UIControlStateNormal];
        [self.contentView addSubview:nameButton];
        
        nameLable = [[UILabel alloc] init];
        nameLable.textColor = DongTaiCommentName;
        nameLable.font = [UIFont systemFontOfSize:14];
        nameLable.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:nameLable];
        
        commentContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        commentContentLabel.backgroundColor = [UIColor clearColor];
        commentContentLabel.font = [UIFont systemFontOfSize:14];
        commentContentLabel.numberOfLines = 100;
        commentContentLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self.contentView addSubview:commentContentLabel];
        commentContentLabel.textColor = COMMENTCOLOR;
        
        praiseView  = [[UIView alloc] init];
        praiseView.backgroundColor = RGB(252, 252, 252, 0);
        [self.contentView addSubview:praiseView];
        
        openPraiseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        openPraiseButton.hidden = YES;
        [self.contentView addSubview:openPraiseButton];
        
        headerImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:headerImageView];
        
        timeLabel = [[UILabel alloc] init];
        [self.contentView addSubview:timeLabel];
        
        lineImageView = [[UIImageView alloc] init];
        [lineImageView setImage:[UIImage imageNamed:@""]];
        lineImageView.backgroundColor = CommentLineColor;
        [self.contentView addSubview:lineImageView];
        
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
