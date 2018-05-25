//
//  IntTypeLogic.m
//  codeconfuse
//
//  Created by Martin on 2018/5/15.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "StringTypeLogic.h"
#import "CodeGenerator.h"

@implementation StringTypeLogic
- (NSString *)ifFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c {
    
    NSArray *nameArr = [NSArray arrayWithObjects:a,b,c, nil];
    
    NSDictionary *nameDic = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:b,c, nil],a.name,[NSArray arrayWithObjects:a,c, nil],b.name,[NSArray arrayWithObjects:a,b, nil],c.name, nil];
    NSArray *logicArr = [NSArray arrayWithObjects:@"||",@"&&", nil];
    
    int index = arc4random()%[nameArr count];
    
    VariableInfo *var1 = [nameArr objectAtIndex:index];
    
    NSArray *otherVarArr = [nameDic valueForKey:var1.name];
    NSString *l1 = [logicArr objectAtIndex:(arc4random()%[logicArr count])];
    
    VariableInfo *var2 =nil;
    VariableInfo *var3=nil;
    
    if (arc4random()%2) {
        var2 = [otherVarArr objectAtIndex:0];
        var3 = [otherVarArr objectAtIndex:1];
    } else {
        var2 = [otherVarArr objectAtIndex:1];
        var3 = [otherVarArr objectAtIndex:0];
    }
    NSMutableString *str = [NSMutableString new];
    NSArray *equalArr = [NSArray arrayWithObjects:@"==",@">",@"<", nil];
    NSArray *e1 =[equalArr objectAtIndex:arc4random()%[equalArr count]];
    NSArray *e2 =[equalArr objectAtIndex:arc4random()%[equalArr count]];
    
    [str appendString:@"if("];
    [str appendFormat:@"strcmp(%@.c_str(),%@.c_str())%@ 0%@ strcmp(%@.c_str(),%@.c_str())%@ 0 ",[mCg variableStr:var1 isSet:NO],[mCg variableStr:var2 isSet:NO],e1,l1,[mCg variableStr:var1 isSet:NO],[mCg variableStr:var3 isSet:NO],e2];
    
    [str appendString:@")"];
    [str appendString:@"{\n"];
    
    
    NSArray *assigArr = [NSArray arrayWithObjects:@"=",@"+=", nil];
    
    NSArray *opArr = [NSArray arrayWithObjects:@"+", nil];
    
    int num = 1+arc4random()%[assigArr count];
    
    for (int i=0; i<num; i++) {
        NSString *a1 = [assigArr objectAtIndex:(arc4random()%[assigArr count])];
        NSString *op1 = [opArr objectAtIndex:(arc4random()%[opArr count])];
        
        index = arc4random()%[nameArr count];
        
        var1 = [nameArr objectAtIndex:index];
        
        otherVarArr = [nameDic valueForKey:var1.name];
        
        if (arc4random()%2) {
            var2 = [otherVarArr objectAtIndex:0];
            var3 = [otherVarArr objectAtIndex:1];
        } else {
            var2 = [otherVarArr objectAtIndex:1];
            var3 = [otherVarArr objectAtIndex:0];
        }
        int r = arc4random()%2;
        if (r==1) {
            if(arc4random()%2==0){
                [str appendFormat:@"%@ %@ %@;",[mCg variableStr:var1 isSet:NO],a1,[mCg variableStr:var2 isSet:NO]];
            } else {
                [str appendFormat:@"%@ %@ %@;",[mCg variableStr:var1 isSet:NO],a1,[mCg variableStr:var3 isSet:NO]];
            }
        } else {
            [str appendFormat:@"%@ %@ (%@ %@ %@);",[mCg variableStr:var1 isSet:NO],a1,[mCg variableStr:var2 isSet:NO],op1,[mCg variableStr:var3 isSet:NO]];
        }
    }
    [str appendString:@"}"];
    return str;
}
@end
