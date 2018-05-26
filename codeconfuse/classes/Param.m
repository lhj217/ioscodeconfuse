//
//  Param.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/2.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "Param.h"

@implementation Param
static Param* _instance = nil;
+(instancetype) shareInstance
{
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });

    return _instance;
}

- (NSString *)dictionaryFile {
    return [[self dir] stringByAppendingPathComponent:@"DICT.txt"];
}


- (NSString *)keywordFile {
    return [[self dir] stringByAppendingPathComponent:@"reskeys.txt"];
}

@end
