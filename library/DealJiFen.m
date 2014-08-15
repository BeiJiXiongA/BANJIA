//
//  DealJiFen.m
//  BANJIA
//
//  Created by TeekerZW on 8/15/14.
//  Copyright (c) 2014 TEEKER. All rights reserved.
//

#import "DealJiFen.h"

@implementation DealJiFen
+(void)dealJiFenWithPhones:(NSArray *)phoneArray
{
    NSMutableString *phonesStr = [[NSMutableString alloc] initWithCapacity:0];
    for (NSString *phone in phoneArray)
    {
        if([phone rangeOfString:@"+86"].length> 0)
        {
            [phonesStr insertString:[NSString stringWithFormat:@"%@,",[phone substringFromIndex:[phone rangeOfString:@"+86"].location+3]] atIndex:[phonesStr length]];
        }
        else
        {
            [phonesStr insertString:[NSString stringWithFormat:@"%@,",phone] atIndex:[phonesStr length]];
        }
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"phone":[phonesStr substringToIndex:[phonesStr length]-1]
                                                                      } API:MB_INVITE];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getuserinfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue] == 1)
            {
                
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            DDLOG(@"error %@",[request error]);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
        }];
        [request startAsynchronous];
    }
}

+(void)dealJiFenWithID:(NSString *)p_id
{
    if (!p_id)
    {
        return ;
    }
    if ([Tools NetworkReachable])
    {
        __weak ASIHTTPRequest *request = [Tools postRequestWithDict:@{@"u_id":[Tools user_id],
                                                                      @"token":[Tools client_token],
                                                                      @"p_id":p_id
                                                                      } API:MB_TRANSMIT];
        [request setCompletionBlock:^{
            NSString *responseString = [request responseString];
            NSDictionary *responseDict = [Tools JSonFromString:responseString];
            DDLOG(@"getuserinfo responsedict %@",responseDict);
            if ([[responseDict objectForKey:@"code"] intValue] == 1)
            {
                
            }
            else
            {
                [Tools dealRequestError:responseDict fromViewController:nil];
            }
        }];
        
        [request setFailedBlock:^{
            DDLOG(@"error %@",[request error]);
            [Tools showAlertView:@"连接错误" delegateViewController:nil];
        }];
        [request startAsynchronous];
    }
}

@end
