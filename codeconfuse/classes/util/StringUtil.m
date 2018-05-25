//
//  StringUtil.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "StringUtil.h"

@implementation StringUtil
+(bool)is_allow_identify_name:(NSString *)str {
    if ([str length] == 1)
    {
        return false;
    }

    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([str rangeOfString:@"^[0-9a-zA-Z_]{1,}$" options:NSRegularExpressionSearch].location!=NSNotFound
        &&![str hasPrefix:@"_"] &&
        ![str hasPrefix:@"init"] &&
        ![str hasPrefix:@"dispatch_"] &&
        ![str hasPrefix:@"gl"] &&
        ![str hasPrefix:@"const_"] &&
        ![str hasPrefix:@"objc_"] &&
        ![str hasPrefix:@"CC_"] &&
        ![str hasPrefix:@"CG"] &&
        ![str hasPrefix:@"CM"] &&
        ![str hasPrefix:@"CT"] &&
        ![str hasPrefix:@"CF"] &&
        ![str hasPrefix:@"NS"] &&
        ![str hasPrefix:@"sqlite3_"] &&
        ![str hasPrefix:@"set"] &&
        ![str hasPrefix:@"is"] &&
        ![str hasPrefix:@"NS"] &&
        ![str hasPrefix:@"kCG"] &&
        ![str hasPrefix:@"AV"] &&
        ![str hasPrefix:@"kCF"] &&
        ![str hasPrefix:@"kCT"] &&
        ![str hasPrefix:@"isEqual"] &&
        ![str hasPrefix:@"UI"] &&
        ![str hasPrefix:@"Sec"] &&
        ![str hasPrefix:@"error"] &&
        ![str hasSuffix:@"error"] &&
        ![str hasPrefix:@"unsigned"])
    {
        return true;
    }
    else
    {
        return false;
    }
}

+(bool)is_allow_identify_name_c_cpp:(NSString *)str {
//
//    if (str.length() == 1)
//    {
//        return false;
//    }
//
//    StringUtil stringUtil;
//    regex reg("[_[:alpha:]][_[:alnum:]]*");
//
//    regex upper_underline_reg("[_[:digit:][:upper:]]*");
//
//    string judge_str = stringUtil.trim(str);
//    if (regex_match(str, reg) &&
//        !regex_match(str, upper_underline_reg) &&
//        ![str hasPrefix:@"_"] &&
//        ![str hasPrefix:@"gl"] &&
//        ![str hasPrefix:@"const_"] &&
//        ![str hasPrefix:@"objc_") )
//    {
//        return true;
//    }
//    else
//    {
//        return false;
//    }
    return YES;
}


+(NSString *)deleteSpecialChar:(NSString *)str
{
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    str = [str stringByReplacingOccurrencesOfString:@"{" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"*" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"~" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"&" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"[" withString:@""];
    NSUInteger bracket_left_index =[str rangeOfString:@"["].location;
    if (bracket_left_index!=NSNotFound) {
        str = [str substringToIndex:bracket_left_index];
    }
    return str;
}

+(NSString *)firstWordToLowerCase:(NSString *)str {
    if ([str length]>0) {
        str = [NSString stringWithFormat:@"%@%@",[[str substringToIndex:1] lowercaseString],[str substringFromIndex:1] ];
    }
    return str;
}

+(NSString *)firstWordToUpperCase:(NSString *)str {
    if ([str length]>0) {
        str = [NSString stringWithFormat:@"%@%@",[[str substringToIndex:1] uppercaseString],[str substringFromIndex:1] ];
    }
    return str;
}
@end
