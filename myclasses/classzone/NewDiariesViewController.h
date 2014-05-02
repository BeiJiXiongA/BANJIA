//
//  NewDiariesViewController.h
//  School
//
//  Created by TeekerZW on 3/20/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"
@protocol NewDongtaiDelegate;
@interface NewDiariesViewController : XDContentViewController
@property (nonatomic, strong) NSString *classID;
@property (nonatomic, assign) id<NewDongtaiDelegate> classZoneDelegate;
@end

@protocol NewDongtaiDelegate <NSObject>

-(void)haveAddDonfTai:(BOOL)add;

@end