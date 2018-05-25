//
//  BoolTypeLogic.m
//  codeconfuse
//
//  Created by Martin on 2018/5/15.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "BoolTypeLogic.h"
#import "VariableInfo.h"
#import "CodeGenerator.h"

@implementation BoolTypeLogic

- (NSString *)ifFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c {
    
    NSArray *nameArr = [NSArray arrayWithObjects:a,b,c, nil];
    
    NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:b,c, nil],a.name,[NSArray arrayWithObjects:a,c, nil],b.name,[NSArray arrayWithObjects:a,b, nil],c.name, nil];
        NSArray *opArr = [NSArray arrayWithObjects:@"||",@"&&", nil];
    
     int index = arc4random()%[nameArr count];
    
    VariableInfo *var1 = [nameArr objectAtIndex:index];
    
    NSArray *otherVarArr = [nameDic valueForKey:var1.name];
    NSString *op1 = [opArr objectAtIndex:(arc4random()%[opArr count])];
    
    VariableInfo *var2 =nil;
    VariableInfo *var3=nil;
    
     if (arc4random()%2) {
         var2 = [otherVarArr objectAtIndex:0];
         var3 = [otherVarArr objectAtIndex:1];
     } else {
         var2 = [otherVarArr objectAtIndex:1];
         var3 = [otherVarArr objectAtIndex:0];
     }
      NSString *op2 = [opArr objectAtIndex:(arc4random()%[opArr count])];
    
    NSMutableString *str = [NSMutableString new];
    
    [str appendString:@"if("];
     if ([op1 isEqualToString:op2]) {
         
         [str appendFormat:@"%@ %@ %@ %@ %@",[mCg variableStr:var1 isSet:NO],op1,[mCg variableStr:var2 isSet:NO],op2,[mCg variableStr:var3 isSet:NO]];
     } else {
     if (arc4random()%2==0) {
          [str appendFormat:@"(%@ %@ %@) %@ %@",[mCg variableStr:var1 isSet:NO],op1,[mCg variableStr:var2 isSet:NO],op2,[mCg variableStr:var3 isSet:NO]];
    
     
     } else {
         [str appendFormat:@"%@ %@ (%@ %@ %@)",[mCg variableStr:var1 isSet:NO],op1,[mCg variableStr:var2 isSet:NO],op2,[mCg variableStr:var3 isSet:NO]];
     }
     }
    
    NSArray *equalArr = [NSArray arrayWithObjects:@"=",@"= !", nil];
    
    NSString *e1 = [equalArr objectAtIndex:(arc4random()%[equalArr count])];
    
    [str appendString:@")"];
    [str appendString:@"{\n"];
    
     
     index = arc4random()%[nameArr count];
    
    var1 = [nameArr objectAtIndex:index];
    
    otherVarArr = [nameDic valueForKey:var1.name];
    op1 = [opArr objectAtIndex:(arc4random()%[opArr count])];
    
    
    if (arc4random()%2) {
        var2 = [otherVarArr objectAtIndex:0];
        var3 = [otherVarArr objectAtIndex:1];
    } else {
        var2 = [otherVarArr objectAtIndex:1];
        var3 = [otherVarArr objectAtIndex:0];
    }
    
    [str appendFormat:@" %@ %@ (%@ %@ %@);",[mCg variableStr:var1 isSet:NO],e1,[mCg variableStr:var2 isSet:NO],op1,[mCg variableStr:var3 isSet:NO]];
    [str appendString:@"}"];
    return str;
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
