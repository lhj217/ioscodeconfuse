//
//  PropertyInfo.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/11.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "PropertyInfo.h"

@implementation PropertyInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setP:@""];
        [self setName:@"default"];
        [self setType:@"int"];
        [self setDefaultValue:@"0"];
    }
    return self;
}


@end
