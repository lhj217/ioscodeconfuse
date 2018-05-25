//
//  StringUtil.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringUtil : NSObject
+(bool) is_allow_identify_name:(NSString *)str;
+(bool) is_allow_identify_name_c_cpp:(NSString *)str;
+(NSString *)deleteSpecialChar:(NSString *)str;
+(NSString *)firstWordToUpperCase:(NSString *)str;
+(NSString *)firstWordToLowerCase:(NSString *)str;
@end
