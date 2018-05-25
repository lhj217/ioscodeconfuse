//
//  GarbageInfo.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/16.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "GarbageInfo.h"

@implementation GarbageInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setClassArr:[NSMutableArray new]];
    }
    return self;
}
-(void)addClass:(ClassInfo *)ci{
    if (![[self classArr] containsObject:ci]) {
        [[self classArr] addObject:ci];
    }

}
@end
