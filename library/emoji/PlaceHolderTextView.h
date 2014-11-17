//
//  PlaceHolderTextView.h
//  BANJIA
//
//  Created by TeekerZW on 14/11/14.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceHolderTextView : UITextView<UITextViewDelegate>

@property (nonatomic, strong) UITextView *textView;

-(id)initWithFrame:(CGRect)frame placeHolder:(NSString *)placeholder;

@end
