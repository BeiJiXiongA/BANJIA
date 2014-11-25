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
@synthesize nameButton,commentContentLabel,commentDict,praiseView,openPraiseButton,headerImageView,timeLabel,lineImageView,nameLable,commentIndex;
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
        
//        UILongPressGestureRecognizer *longTgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(msgLongTgr:)];
//        commentContentLabel.userInteractionEnabled = YES;
//        [commentContentLabel addGestureRecognizer:longTgr];
        
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


#pragma mark - 复制文本

-(void)msgLongTgr:(UILongPressGestureRecognizer *)longTgr
{
    DDLOG(@"%d---%d",longTgr.state,[self becomeFirstResponder]);
    if (longTgr.state != UIGestureRecognizerStateBegan ||
        ![self becomeFirstResponder])
        return;
    CGRect viewRect = longTgr.view.frame;
    CGFloat menuX = 0;
    menuX = viewRect.origin.x+viewRect.size.width/2-52;
    
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *menuItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copytext)];
    UIMenuItem *menuItem1 = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteComment)];
    menu.menuItems = [NSArray arrayWithObjects:menuItem, menuItem1, nil];
    [menu setTargetRect:CGRectMake(menuX, viewRect.origin.y+10, 100, 50) inView:self];
    [menu setMenuVisible:YES animated:YES];
}

-(void)deleteComment
{
    DDLOG(@"delete comment! %@",commentDict);
    if ([self.commentDel respondsToSelector:@selector(deleteCommentWithDict:andCommentIndex:)])
    {
        [self.commentDel deleteCommentWithDict:commentDict andCommentIndex:commentIndex];
    }
    
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copytext)) || (action == @selector(deleteComment));
}

-(void)copytext
{
    UIPasteboard *generalPasteBoard = [UIPasteboard generalPasteboard];
    [generalPasteBoard setString:commentContentLabel.text];
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
