//
//  Downloader.m
//  SoundDemo
//
//  Created by TeekerZW on 8/19/14.
//  Copyright (c) 2014 ZW. All rights reserved.
//

#import "Downloader.h"
#import "MCSoundBoard.h"
#import "VoiceConverter.h"

@implementation Downloader

@synthesize downloaderDel;

static Downloader *downloader = nil;

+(Downloader *)defaultDownloader
{
    if(downloader == nil)
    {
        downloader = [[Downloader alloc] init];
    }
    return downloader;
}

- (void)downloadWithUrl:(NSString *)fileUrl
{
    NSURLSessionConfiguration *configration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configration];
    
    NSURL *url = [NSURL URLWithString:fileUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:nil destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
//        NSURL *documentsDirectoryUrl = [NSURL URLWithString:[DirectyTools soundDir]];
        NSURL *documentsDirectoryUrl = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *savePath = [documentsDirectoryUrl URLByAppendingPathComponent:[response suggestedFilename]];
        return savePath;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
       
        NSString *tmpUrlStr = [filePath absoluteString];
        NSString *fileUrlStr = [tmpUrlStr substringFromIndex:[tmpUrlStr rangeOfString:@"//"].location+2];
        
        NSString *fileExtention = [fileUrlStr pathExtension];
        NSRange range = [fileUrlStr rangeOfString:fileExtention];
        NSString *pathStr = [fileUrlStr substringToIndex:range.location-1];
        NSString *fileSavePath = [NSString stringWithFormat:@"%@.wav",pathStr];
        [VoiceConverter amrToWav:fileUrlStr wavSavePath:fileSavePath];

        if ([self.downloaderDel respondsToSelector:@selector(downloadDone:)])
        {
            [self.downloaderDel downloadDone:fileSavePath];
        }
        
    }];
    
    
    [downloadTask resume];
}
@end
