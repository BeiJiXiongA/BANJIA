//
//  PopView.h
//  MyProject
//
//  Created by TeekerZW on 14-6-6.
//  Copyright (c) 2014年 ZW. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PopOrientationUp = 0,
    PopOrientationDown,
    PopOrientationLeft,
    PopOrientationRight,
}PopOrientation;


@interface PopView : UIView
@property (nonatomic, assign) PopOrientation orientation;
@property (nonatomic, assign) CGPoint point;
@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat hei;
@property (nonatomic, assign) CGFloat wid;
@end
