#import <UIKit/UIKit.h>

@interface ChineseToPinyin : NSObject {
    
}

+ (NSString *) pinyinFromChiniseString:(NSString *)string;
+ (NSString *) jianPinFromChiniseString:(NSString *)string;
+ (char) sortSectionTitle:(NSString *)string; 

@end