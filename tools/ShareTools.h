//
//  ShareTools.h
//  BANJIA
//
//  Created by TeekerZW on 14/10/23.
//  Copyright (c) 2014年 TEEKER. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ShareContentDelegate <NSObject>

-(void)shareSuccess;

@end

@interface ShareTools : NSObject
@property (nonatomic, assign) id<ShareContentDelegate> shareContentDel;

-(void)shareTo:(ShareType)shareType
andShareContent:(NSString *)shareContent
      andImage:(id<ISSCAttachment>)attachment
  andMediaType:(SSPublishContentMediaType)mediaType
   description:(NSString *)description
        andUrl:(NSString *)url;

@end
