//
//  InputTableBar.h
//  FaceDemo
//
//  Created by TeekerZW on 3/26/14.
//
//

#import <UIKit/UIKit.h>

#import "NSString+Emojize.h"
#import "Header.h"
@protocol ReturnFunctionDelegate;

@interface InputTableBar : UIView<UIScrollViewDelegate,UITextViewDelegate>
{
    UIButton *inputButton;
    UIButton *addButton;
    CGFloat inputLength;
    
    UIScrollView *faceView;
    NSMutableArray *fileNameArray;
    UIPageControl *pageControl;
    NSDictionary *faceDict;
    
    UIView *moreView;
    
    CGFloat keyBoardHeight;
    
    CGSize inputTextViewSize;
    
    NSArray *faceArray;
    
    CGFloat inputWidth;
}
@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong) UIView *inputBgView;
@property (nonatomic, assign) BOOL face;
@property (nonatomic, assign) BOOL more;
@property (nonatomic, assign) BOOL sound;
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, assign) BOOL notOnlyFace;
@property (nonatomic, strong) UIButton *soundButton;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *recordButton;
@property (nonatomic, assign) id<ReturnFunctionDelegate> returnFunDel;
@property (nonatomic, strong) NSMutableString *sendString;

-(NSMutableString *)analyString:(NSString *)inputString;

-(void)backKeyBoard;

-(void)setLayout;
//-(void)layOutWithKeyBoardHeight:(CGFloat)keyBoardHeight;
@end

@protocol ReturnFunctionDelegate <NSObject>

-(void)myReturnFunction;
-(void)showKeyBoard:(CGFloat)keyBoardHeight;
-(void)changeInputType:(NSString *)changeType;

-(void)changeInputViewSize:(CGSize)size;

-(void)selectPic:(int)selectPicTag;

@end
