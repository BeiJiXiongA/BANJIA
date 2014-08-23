//
//  Downloader.h
//  SoundDemo
//
//  Created by TeekerZW on 8/19/14.
//  Copyright (c) 2014 ZW. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloaderDelegate;

@interface Downloader : NSObject<ASIHTTPRequestDelegate>

+(Downloader *)defaultDownloader;

@property (nonatomic, strong) id<DownloaderDelegate>  downloaderDel;

-(void)afDownloadWithUrl:(NSString *)fileUrl;
-(void)adiDownloadWithUrl:(NSString *)fileUrl;
@end


@protocol DownloaderDelegate <NSObject>

-(void)downloadDone:(NSString *)filePath;

@end