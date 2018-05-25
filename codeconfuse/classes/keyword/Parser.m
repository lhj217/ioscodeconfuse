//
//  Parser.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/26.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "Parser.h"
#import "DataBase.h"
#import "StringUtil.h"
#import "Param.h"

@implementation Parser
- (instancetype)init
{
    self = [super init];
    if (self) {
        if (![[Param shareInstance] isExcludeVar]) {
            [self setVars:[NSMutableArray new]];
        }
        [self setProperties:[NSMutableArray new]];
        [self setFunctions:[NSMutableArray new]];
        [self setExtends:[NSMutableArray new]];
        [self setIncludes:[NSMutableArray new]];
        [self setClasses:[NSMutableArray new]];

    }
    return self;
}

- (int)judge:(NSString *)s{
    return -1;
}
-(NSString *)R:(NSString *)str{
    return nil;
}
-(bool)is_str_contain_space:(NSString *)str{
    return  [str containsString:@" "];
}

- (NSString *)D:(NSString *)str ch:(char)c
{
    NSString *tmp = [NSString stringWithFormat:@"%c",c];
    return [self D:str str:tmp];
}

//除去str中的所有s字符串
-(NSString *)D:(NSString *)str str:(NSString *)s{
    return [str stringByReplacingOccurrencesOfString:s withString:@""];
}


//要求是用制表符进行首行推进，而不是用四个空格。
//根据制表符来分解一个string为一个vector容器
-(NSMutableArray *)divideByTab:(NSString *)str
{
    return  [[str componentsSeparatedByString:@"\t"] mutableCopy];
}

- (void)ignorespacetab:(NSString *)str pos:(NSUInteger *)fI {

    while(*fI<[str length] && ([str characterAtIndex:*fI] == ' ' || [str characterAtIndex:*fI] == '\t'))
    {
        ++(*fI);
    }
}

//忽略字母和数字
-(void)ignorealnum:(NSString *)str pos:(NSUInteger *)fI {
    while(*fI<[str length] && isalnum([str characterAtIndex:*fI]))
    {
        ++(*fI);
    }
}




//以下是判断作用域的位置，并返回合适的 { 和 } 位置来将变量名和函数名分割出来。
-(void)actionscope_ignore:(NSString *)str pos:(NSUInteger *)fI
{
    int lBlock_num = 1;
    while(lBlock_num)
    {
        ++(*fI);
        
        if(*fI >= [str length])
        {
            break;
        }
        if([str characterAtIndex:*fI] == '{')
        {
            ++lBlock_num;
        }
        else if([str characterAtIndex:*fI] == '}')
        {
            --lBlock_num;
        }

    }
}

-(NSMutableArray *)actionscope:(NSString *)str pos:(NSUInteger *)fI
{
    NSMutableArray *index = [NSMutableArray new];
    [index addObject:[NSNumber numberWithUnsignedInteger:*fI-1]];

    int lBlock_num = 1;
    while(lBlock_num)
    {
        if(*fI >= [str length])
        {
            break;
        }
        if([str characterAtIndex:*fI] == '{')
        {
            [index addObject:[NSNumber numberWithUnsignedInteger:*fI]];//获取'{'的下标
            [self actionscope_ignore:str pos:fI];
            [index addObject:[NSNumber numberWithUnsignedInteger:*fI]];//获得匹配上面的'{'的'}'的下标
        }
        else if([str characterAtIndex:*fI] == '}')
        {
            lBlock_num = 0;
            [index addObject:[NSNumber numberWithUnsignedInteger:*fI]];
            continue;
        }
        ++(*fI);
    }
    return index;
}
-(bool)handleCppIdentify:(ClassModel *)classModel {
    NSString *identifyStr = classModel.identifyName;
    if (identifyStr==nil) {
        return NO;
    }
    identifyStr = [identifyStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    identifyStr = [identifyStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *lowercase_idt_str = [identifyStr lowercaseString];
    //过滤宏定义，复制，还有带分号的语句
    if([lowercase_idt_str containsString:@"#define"] ||
       [lowercase_idt_str containsString:@"="] ||
       [lowercase_idt_str containsString:@";"] ||
       [lowercase_idt_str containsString:@"),"] ||
       [lowercase_idt_str containsString:@"export "] ||
       [lowercase_idt_str containsString:@"extern "])
    {
        return false;
    }

    identifyStr = [identifyStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSUInteger class_colonIndex = [identifyStr rangeOfString:@"::"].location;

    if (class_colonIndex != NSNotFound)// Cpp Function
    {
        NSUInteger first_brackets_index = [identifyStr rangeOfString:@"(" options:NSBackwardsSearch].location;
        if (first_brackets_index != NSNotFound&&first_brackets_index>class_colonIndex)
        {

            identifyStr = [identifyStr substringWithRange:NSMakeRange(class_colonIndex+2, first_brackets_index-class_colonIndex-2)];
        }
        identifyStr = [StringUtil deleteSpecialChar:identifyStr];

        if ([StringUtil is_allow_identify_name_c_cpp:identifyStr])
        {
            NSString *method_str = [identifyStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([StringUtil is_allow_identify_name:classModel.className])
            {
                classModel.identifyName = method_str;

                return true;
            }
        }
    }
    else
    {
        NSUInteger first_brackets_index = [identifyStr rangeOfString:@"("].location;

        if (first_brackets_index != NSNotFound)
        {
            identifyStr = [identifyStr substringToIndex:first_brackets_index];
        }

        NSUInteger last_space_index = [identifyStr rangeOfString:@" " options:NSBackwardsSearch].location;

        if (last_space_index != NSNotFound)
        {
            identifyStr = [identifyStr substringWithRange:NSMakeRange(last_space_index+1, [identifyStr length]-last_space_index-1)];
        }

        identifyStr = [StringUtil deleteSpecialChar:identifyStr];
        if ([StringUtil is_allow_identify_name_c_cpp:identifyStr])
        {
            NSString *method_str = [identifyStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([StringUtil is_allow_identify_name:classModel.className])
            {
                classModel.identifyName = method_str;

                return true;
            }
        }
    }

    return false;
}
- (void)display:(SrcFileModel *)fileModel {

}

- (NSString *)findClassName:(NSString *)name pos:(NSUInteger *)pos{
    return nil;

}
- (NSMutableArray *)findExtendsName:(NSString *)str pos:(NSUInteger *)pos{
    return nil;
}
-(int)findGlobalClassDeclares:(NSString *)str{

    return 0;
}
- (int)findGlobalVarsAndFunctions:(NSString *)str{
    return 0;
}
- (int)findSubStrAtPos:(NSString *)str findStr:(NSString *)findStr pos:(NSUInteger *)pos {
    return 0;
}
@end
