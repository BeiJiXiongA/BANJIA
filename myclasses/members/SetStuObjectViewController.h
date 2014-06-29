//
//  SetStuObjectViewController.h
//  School
//
//  Created by TeekerZW on 3/18/14.
//  Copyright (c) 2014 TeekerZW. All rights reserved.
//

#import "XDContentViewController.h"

@protocol SetStudentObject <NSObject>

-(void)setStuObj:(NSString *)title;

@end

@interface SetStuObjectViewController : XDContentViewController
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *userid;
@property (nonatomic, strong) NSString *classID;
@property (nonatomic, strong) id<SetStudentObject> setStudel;
@property (nonatomic, strong) NSString *title;
@end
