//
//  MethodInfo.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/11.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "MethodInfo.h"

@implementation MethodInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setP:@""];
        [self setName:@"default"];
        //{{"type1", "name1"}, {"type2", "name2"}, ..}
          //  {"type", "value"}

    }
    return self;
}
@end
