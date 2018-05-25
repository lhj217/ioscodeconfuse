//
//  IntLogic.m
//  codeconfuse
//
//  Created by Martin on 2018/5/15.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "TypeLogic.h"

@implementation TypeLogic

-(id)initWithCodeGenerator:(CodeGenerator *)cg
{
    self = [super init];
    if (self) {
        mCg = cg;
    }
    return self;
}

- (NSString *)ifFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c {
    return @"";
}
- (NSString *)forFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c{
    return @"";
}

- (NSString *)whileFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c {
    return @"";
}

- (NSString *)switchFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c {
    return @"";
}

@end
