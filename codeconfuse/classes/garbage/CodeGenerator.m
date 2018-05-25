//
//  CodeGenerator.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/10.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "CodeGenerator.h"
#import "TypeInfo.h"
#import "ClassInfo.h"
#import "PropertyInfo.h"
#import "AttributesInfo.h"
#import "MethodInfo.h"
#import "ParamInfo.h"
#import "Param.h"
#import "GarbageInfo.h"
#import "StringUtil.h"

@implementation CodeGenerator

- (void)start{
    
}

- (NSString *)generateGarbagePiece {
    return @"";
}


-(NSString *)getName:(NSInteger)minLength maxLength:(NSInteger)maxLength {
    int length = arc4random()%(maxLength-minLength);
    NSString *name = [[DataBase shareInstance] randomName:length];
    return name;
}

-(NSString *)getVariableName {
    int wordCount = 1+arc4random()%2;
    NSString *name = [[DataBase shareInstance] randomWord:wordCount];
    name = [StringUtil firstWordToLowerCase:name];
    return name;
}

- (NSString *)getClassName {
    int wordCount = 2+arc4random()%2;
    NSString *name = [[DataBase shareInstance] randomWord:wordCount];
    name = [StringUtil firstWordToUpperCase:name];
    return name;
}


-(TypeInfo *)getRandomType{
    return [self getRandomType:NO];
}

-(TypeInfo *)getRandomType:(BOOL)isAttribute{
    if (isAttribute && [defaultType count]>0) {
        int index = arc4random()%[defaultType count];
        NSString *type = [defaultType objectAtIndex:index];
        [defaultType removeObjectAtIndex:index];
        NSString *value = [base_type_and_default valueForKey:type];
        TypeInfo *ti = [TypeInfo new];
        [ti setType:type];
        [ti setDefaultValue:value];
        return ti;
    } else {
        
        NSString *type = [base_type_list objectAtIndex:arc4random()%[base_type_list count]];
        NSString *value = [base_type_and_default valueForKey:type];
        TypeInfo *ti = [TypeInfo new];
        [ti setType:type];
        [ti setDefaultValue:value];
        return ti;
    }
    
}

-(AttributesInfo *)attributeGenerate:(NSString *)p name:(NSString *)name type:(NSString *)type pi:(PropertyInfo *)pi {
    AttributesInfo *ai = [AttributesInfo new];
    [ai setP:p];
    [ai setName:name];
    [ai setType:type];
    [ai setPi:pi];
    return ai;
}

-(VariableInfo *)getRandomVariable:(NSArray *)a{
    return [a objectAtIndex:arc4random()%[a count]];
}

-(void)addSpaceAndLine:(NSMutableString *)retn str:(NSString *) str tabCount:(NSInteger*)t{
    for (int i=0; i<*t; i++) {
        [retn appendString:@"    "];
    }
    [retn appendString:str];
    [retn appendString:@"\n"];
}


-(NSString *)boolFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c{
    TypeLogic *tl = [[BoolTypeLogic alloc] initWithCodeGenerator:self];
    
    int r = arc4random() %3+1;
    
    if (r == 1) {
        return [NSString stringWithFormat:@"%@ = %@ && %@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r == 2){
        NSString *str = [tl ifFunction:a b:b c:c];
        return str;
    } else if(r==3){
        return [NSString stringWithFormat:@"%@ = %@ || %@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else {
        return [NSString stringWithFormat:@"%@ = %@ && %@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    }
}

-(NSString *)variableStr:(VariableInfo *)vi isSet:(BOOL)isSet {
    return [vi name];
}

-(NSString *)intFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c{
    TypeLogic *tl = [[IntTypeLogic  alloc] initWithCodeGenerator:self];
    int r = arc4random() %10+1;
    
    if (r == 1) {
        return [NSString stringWithFormat:@"%@ = %@ + %@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r == 2){
        return [NSString stringWithFormat:@"%@ = %@ - %@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r==3){
        return [NSString stringWithFormat:@"%@ = %@ * %@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r==4){
        return [NSString stringWithFormat:@"if(%@==0)%@=1;\n%@ = %@ / %@;",[self variableStr:c isSet:NO],[self variableStr:c isSet:NO],[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r==5){
        return [NSString stringWithFormat:@"%@ = %@;\n\t%@ = %@;\n\t%@ = %@;\n",[self variableStr:a isSet:YES],@"1+(arc4random() % 1000)",[self variableStr:b isSet:YES],@"1+(arc4random() % 10000)",[self variableStr:c isSet:YES],@"1+(arc4random() % 100000)"];
    } else if(r==6){
        NSString *str = [tl ifFunction:a b:b c:c];
        return str;
    }
    else if(r==7){
        NSString *str = [tl forFunction:a b:b c:c];
        return str;
    } else if(r==8){
        NSString *str = [tl whileFunction:a b:b c:c];
        return str;
    }else if(r==9){
        NSString *str = [tl switchFunction:a b:b c:c];
        return str;
        
    }
    else {
        return [NSString stringWithFormat:@"%@ = %@;\n%@=%@;",[self variableStr:b isSet:YES],[self variableStr:a isSet:NO],[self variableStr:c isSet:YES],[self variableStr:a isSet:NO]];
    }
}


-(NSString *)floatFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c{
    TypeLogic *tl = [[FloatTypeLogic   alloc] initWithCodeGenerator:self];
    int r = arc4random() %10+1;
    
    if (r == 1) {
        return [NSString stringWithFormat:@"%@ = %@ + %@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r == 2){
        return [NSString stringWithFormat:@"%@ = %@ - %@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r==3){
        return [NSString stringWithFormat:@"%@ = %@ * %@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r==4){
        return [NSString stringWithFormat:@"if(%@==0)%@=1;\n%@ = %@ / %@;",[self variableStr:c isSet:NO],[self variableStr:c isSet:NO],[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r==5){
        return [NSString stringWithFormat:@"%@ = %@;\n\t%@ = %@;\n\t%@ = %@;\n",[self variableStr:a isSet:YES],@"1+(arc4random() % 100000)*1.0f",[self variableStr:b isSet:YES],@"1+(arc4random() % 100000)*1.0f",[self variableStr:c isSet:YES],@"1+(arc4random() % 100000)*1.0f"];
    } else if(r==6){
        NSString *str = [tl ifFunction:a b:b c:c];
        return str;
    } else if(r==7){
        NSString *str = [tl forFunction:a b:b c:c];
        return str;
    } else if(r==8){
        NSString *str = [tl whileFunction:a b:b c:c];
        return str;
    } else if(r==9){
        NSString *str = [tl switchFunction:a b:b c:c];
        return str;
    }else {
        return [NSString stringWithFormat:@"%@ = %@;\n%@=%@;",[self variableStr:b isSet:YES],[self variableStr:a isSet:NO],[self variableStr:c isSet:YES],[self variableStr:a isSet:NO]];
    }
}

-(NSString *)doubleFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c{
    TypeLogic *tl = [[FloatTypeLogic   alloc] initWithCodeGenerator:self];
    int r = arc4random() %10+1;
    
    if (r == 1) {
        return [NSString stringWithFormat:@"%@ = %@ + %@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r == 2){
        return [NSString stringWithFormat:@"%@ = %@ - %@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r==3){
        return [NSString stringWithFormat:@"%@ = %@ * %@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r==4){
        return [NSString stringWithFormat:@"if(%@==0)%@=1;\n%@ = %@ / %@;",[self variableStr:c isSet:NO],[self variableStr:c isSet:NO],[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r==5){
        return [NSString stringWithFormat:@"%@ = %@;\n\t%@ = %@;\n\t%@ = %@;\n",[self variableStr:a isSet:YES],@"1+(arc4random() % 100000)*1.0",[self variableStr:b isSet:YES],@"1+(arc4random() % 100000)*1.0",[self variableStr:c isSet:YES],@"1+(arc4random() % 100000)*1.0"];
    } else if(r==6){
        NSString *str = [tl ifFunction:a b:b c:c];
        return str;
    } else if(r==7){
        NSString *str = [tl forFunction:a b:b c:c];
        return str;
    } else if(r==8){
        NSString *str = [tl whileFunction:a b:b c:c];
        return str;
    } else if(r==9){
        NSString *str = [tl switchFunction:a b:b c:c];
        return str;
    }else {
        return [NSString stringWithFormat:@"%@ = %@;\n%@=%@;",[self variableStr:b isSet:YES],[self variableStr:a isSet:NO],[self variableStr:c isSet:YES],[self variableStr:a isSet:NO]];
    }
}

-(NSString *)stringFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c{
    TypeLogic *tl = [[StringTypeLogic   alloc] initWithCodeGenerator:self];
    int r = arc4random() %3+1;
    
    if (r == 1) {
        
        return [NSString stringWithFormat:@"%@ = %@+%@;",[self variableStr:a isSet:YES],[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else if(r==2) {
        return [NSString stringWithFormat:@"%@ = %@;\n%@=%@;",[self variableStr:b isSet:YES],[self variableStr:a isSet:NO],[self variableStr:c isSet:YES],[self variableStr:a isSet:NO]];
    } else {
        NSString *str = [tl ifFunction:a b:b c:c];
        return str;
    }
}

@end
