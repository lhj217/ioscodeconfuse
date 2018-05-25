//
//  CodeGenerator.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/10.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "CppCodeGenerator.h"
#import "TypeInfo.h"
#import "ClassInfo.h"
#import "PropertyInfo.h"
#import "AttributesInfo.h"
#import "MethodInfo.h"
#import "ParamInfo.h"
#import "Param.h"
#import "VariableInfo.h"
#import "DataBase.h"
#import "StringUtil.h"

@implementation CppCodeGenerator 
- (instancetype)init
{
    self = [super init];
    if (self) {
        base_type_and_default = [NSMutableDictionary dictionaryWithObjectsAndKeys:CPP_TYPE_BOOL_VALUE,CPP_TYPE_BOOL,CPP_TYPE_INT_VALUE,CPP_TYPE_INT,CPP_TYPE_FLOAT_VALUE,CPP_TYPE_FLOAT,CPP_TYPE_DOUBLE_VALUE,CPP_TYPE_DOUBLE,CPP_TYPE_STRING_VALUE,CPP_TYPE_STRING, nil];
        base_type_list=[NSMutableArray arrayWithObjects:CPP_TYPE_BOOL,CPP_TYPE_INT,CPP_TYPE_FLOAT,CPP_TYPE_DOUBLE,CPP_TYPE_STRING, nil];
        defaultType = [NSMutableArray new];
        
    }
    return self;
}




-(NSString *)getRandomVariableublic {
    int r = arc4random() %5+1;
    if (r==1) {
        return @"-";
    }
    return @"-";
}



-(NSMutableArray *)methodContentGenerate:(ClassInfo *)ci mi:(MethodInfo *)mi {
    NSMutableArray *content = [NSMutableArray new];
    int count = 1+ arc4random()%4;
    for (int i=0; i<count; i++) {
        TypeInfo *ti= [self getRandomType];
        NSMutableArray *map = [[[ci typeDic] valueForKey:[ti type]] mutableCopy];
        if ([[mi params] count]>0) {
            for (ParamInfo *pi in [mi params]) {
                if ([[pi type] isEqualToString:[ti type]]) {
                    VariableInfo *vi = [VariableInfo new];
                    [vi setType:[pi type]];
                    [vi setName:[pi name]];
                    [vi setVarType:VAR_TYPE_ATTR];
                    [map addObject:vi];
                }
            }
            
            
            
        }
        if ([map count]<3) {
            NSLog(@"");
        }
        VariableInfo *a = [self getRandomVariable:map];
        [map removeObject:a];
        VariableInfo *b = [self getRandomVariable:map];
        [map removeObject:b];
        VariableInfo *c = [self getRandomVariable:map];
        
        [map removeObject:c];
        if ([map count]>0) {
            if ([[ti type] isEqualToString:CPP_TYPE_BOOL]) {
                NSString *str =[self boolFunction:a b:b c:c];
                [content addObject:str];
            } else if ([[ti type] isEqualToString:CPP_TYPE_INT]) {
                NSString *str =[self intFunction:a b:b c:c];
                [content addObject:str];
            } else if ([[ti type] isEqualToString:CPP_TYPE_FLOAT]) {
                NSString *str= [self floatFunction:a b:b c:c];
                [content addObject:str];
            } else if ([[ti type] isEqualToString:CPP_TYPE_DOUBLE]) {
                NSString *str =[self doubleFunction:a b:b c:c];
                [content addObject:str];
            } else if ([[ti type] isEqualToString:CPP_TYPE_STRING]) {
                NSString *str= [self stringFunction:a b:b c:c];
                [content addObject:str];
            }
        }
        
    }
    return content;
    
}
-(NSMutableArray *)generateMethodParam {
    int count = arc4random()%5;
    NSMutableArray *params = [NSMutableArray new];
    NSMutableArray *dictArr = [[DataBase shareInstance] dictArr];
    for (int i=0; i<count; i++) {
        ParamInfo *paramInfo = [ParamInfo new];
        TypeInfo *ti = [self getRandomType];
        [paramInfo setType:[ti type]];
        NSString *name = [[dictArr objectAtIndex:(arc4random()%[dictArr count])] lowercaseString];
        [paramInfo setName:name];
        [params addObject:paramInfo];
    }
    return params;
}
-(MethodInfo *)methodGenerate:(ClassInfo *)ci p:(NSString *)p name:(NSString *)name retn:(VariableInfo *)retn{
    MethodInfo *mi = [MethodInfo new];
    [mi setP:p];
    [mi setName:name];
    [mi setType:[retn type]];
    [mi setRetn:[self variableStr:retn isSet:NO]];
    int r = arc4random()%3;
    if (r>0) {
        NSMutableArray *params = [self generateMethodParam];
        [mi setParams:params];
    }
    NSArray *content =[self methodContentGenerate:ci mi:mi];
    [mi setContent:content];
    return mi;
}

/**--[[
 - 类生成函数
 - 参数
 mc: 函数数量
 pc: 变量数量
 ac: 属性数量
 ]]
 */

-(ClassInfo *) classGenerater:(NSInteger)mc propertyCount:(NSInteger)pc attributeCount:(NSInteger)ac{
    ClassInfo *ci = [ClassInfo new];
    [ci setP:[self getRandomVariableublic]];
    
    NSString *name = [self getClassName];
    [ci setName:name];
    
    
    NSMutableArray *attributes = [NSMutableArray new];
    [ci setAttributes:attributes];
    if(ac<[base_type_list count]*3){
        ac =[base_type_list count]*3;
    }
    for (int i=0;i<ac; i++) {
        TypeInfo *ti = [self getRandomType:YES];
        NSString *attrName = [self getVariableName];
        AttributesInfo *ai = [self attributeGenerate:@"" name:attrName type:[ti type] pi:nil];
        [attributes addObject:ai];
    }
    
    NSMutableDictionary *typeDic = [NSMutableDictionary new];
    [ci setTypeDic:typeDic];
    for (int i=0; i<[base_type_list count]; i++) {
        [typeDic setObject:[NSMutableArray new] forKey:[base_type_list objectAtIndex:i]];
    }
    
    
    for (AttributesInfo *ai in attributes) {
        NSMutableArray *typeArr = [typeDic objectForKey:[ai type]];
        VariableInfo *vi = [VariableInfo new];
        [vi setVarType:VAR_TYPE_ATTR];
        [vi setName:[ai name]];
        [vi setType:[ai type]];
        [typeArr addObject:vi];
    }
    
    
    NSMutableArray *methods = [NSMutableArray new];
    [ci setMethods:methods];
    for (int i=0;i<mc; i++) {
        TypeInfo *ti = [self getRandomType];
        
        NSArray *typeArr = [[ci typeDic] valueForKey:[ti type]];
        VariableInfo *vi = nil;
        if (arc4random()%10>2) {
            vi =[typeArr objectAtIndex:arc4random()%[typeArr count]];
        }
        NSString *methodName =[self getVariableName];
        MethodInfo *mi = [self methodGenerate:ci p:[self getRandomVariableublic] name:methodName retn:vi];
        
        [methods addObject:mi];
    }
    
    
    return ci;
}



-(void)addAttribute:(NSMutableString *)retn ai:(AttributesInfo *)ai tabCount:(NSInteger*)t {
    NSString *str = [NSString stringWithFormat:@"%@ %@;",ai.type,ai.name];
    [self addSpaceAndLine:retn str:str tabCount:t];
    
}

-(void)addMethod:(NSMutableString *)retn mi:(MethodInfo *)mi ci:(ClassInfo *)ci tabCount:(NSInteger*)t {
    NSString *returnType = @"void";
    if (mi.retn) {
        returnType = mi.type;
    }
    NSString *p = @"";
    if (mi.params) {
        for (int i=0; i<[mi.params count]; i++) {
            ParamInfo *param = [mi.params objectAtIndex:i];
            if ([p length]>0) {
                p = [p stringByAppendingFormat:@",%@ %@",[param type],[param name]];
            } else {
                p = [p stringByAppendingFormat:@"%@ %@",[param type],[param name]];
            }
        }
    }
    [self addSpaceAndLine:retn str:[NSString stringWithFormat:@"%@ %@::%@(%@)",returnType,ci.name,mi.name,p] tabCount:t];
    [self addSpaceAndLine:retn str:@"{" tabCount:t];
    *t=*t+1;
    
    for (int i=0; i<[mi.content count]; i++) {
        NSString *content = [[mi content] objectAtIndex:i];
        [self addSpaceAndLine:retn str:content tabCount:t];
    }
    if (mi.retn) {
        NSString *str = [NSString stringWithFormat:@"return %@;",[mi retn]];
        [self addSpaceAndLine:retn str:str tabCount:t];
    }
    
    *t=*t-1;
    [self addSpaceAndLine:retn str:@"}" tabCount:t];
}

-(void)addHeaderMethod:(NSMutableString *)retn mi:(MethodInfo *)mi tabCount:(NSInteger*)t {
    *t=*t+1;
    NSString *returnType = @"void";
    if (mi.retn) {
        returnType = mi.type;
    }
    NSString *p = @"";
    if (mi.params) {
        for (int i=0; i<[mi.params count]; i++) {
            ParamInfo *param = [mi.params objectAtIndex:i];
            if ([p length]>0) {
                p = [p stringByAppendingFormat:@", %@ %@",[param type],[param name]];
            } else {
                p = [p stringByAppendingFormat:@"%@ %@",[param type],[param name]];
            }
        }
    }
    [self addSpaceAndLine:retn str:[NSString stringWithFormat:@"%@ %@(%@);",returnType,mi.name,p] tabCount:t];
    *t=*t-1;
}

- (NSString *)getClassSource:(ClassInfo *)ci {
    NSMutableString *r = [NSMutableString new];
    NSInteger t = 0;
    [r appendFormat:@"#include \"%@.h\"\n",[ci name]];
    [r appendFormat:@"%@::%@(){\n}\n",[ci name],[ci name]];
    if ([ci methods]!=nil) {
        for (MethodInfo *mi in [ci methods]) {
            [self addMethod:r mi:mi ci:ci tabCount:&t];
        }
    }
    [r appendFormat:@"\n"];
    return r;
}

- (NSString *)getHeaderClassSource:(ClassInfo *)ci {
    NSMutableString *r = [NSMutableString new];
    NSInteger t = 0;
    [r appendFormat:@"#ifndef __FruitingToys__%@__\n",[ci name]];
    [r appendFormat:@"#define __FruitingToys__%@__\n",[ci name]];

    [r appendString:@"#include <string>\nusing namespace std;\n"];
    
    if ([ci implement]) {
        [r appendFormat:@"#include %@.h\n",[ci implement]];
    }
    NSString *str = [NSString stringWithFormat:@"class %@  %@",ci.name,ci.implement==nil?@"":[NSString stringWithFormat:@"public %@",[ci implement]]];
    [self addSpaceAndLine:r str:str tabCount:&t];
    [self addSpaceAndLine:r str:@"{" tabCount:&t];
    t = t+1;
    if ([ci attributes]!=nil) {
        
        for (AttributesInfo *ai in [ci attributes]) {
            [self addAttribute:r ai:ai tabCount:&t];
        }
    }

    t = t-1;
    [r appendString:@"\n"];
    [self addSpaceAndLine:r str:@"public:" tabCount:&t];
    [self addSpaceAndLine:r str:[NSString stringWithFormat:@"%@();\n",[ci name]] tabCount:&t];
    [r appendString:@"\n"];
    t = t+1;
    
    if ([ci methods]!=nil) {
        for (MethodInfo *mi in [ci methods]) {
            [self addHeaderMethod:r mi:mi tabCount:&t];
        }
    }
    
    t = t-1;
    [self addSpaceAndLine:r str:@"};\n" tabCount:&t];
    [r appendString:@"#endif\n"];
    return r;
}


-(void)start{
    NSInteger class_count = (int)([self origFileCount]*[[Param shareInstance] garbageFilePercent]/100);
    NSInteger method_count = 30;
    NSInteger property_count = 30;
    NSInteger attribute_count = 30;
    NSLog(@"start to generate c++ garbage file,count=[%ld]",class_count);
    for (int i=0; i<class_count; i++) {
        if(i%10==0){
            printf("*");
            fflush(stdout);
        }

        for (int i=0; i<[base_type_list count]; i++) {
            for (int j=0; j<3; j++) {
                [defaultType addObject:[base_type_list objectAtIndex:i]];
            }
        }
        method_count = 5+ arc4random()%10;
        property_count = 5+ arc4random()%10;
        attribute_count = 10+ arc4random()%10;
        
        ClassInfo *ci = [self classGenerater:method_count propertyCount:property_count attributeCount:attribute_count];
        [ci setClassType:CLASS_TYPE_CPP];
        [[DataBase shareInstance] addClass:ci];
        
        NSString *headerContent = [self getHeaderClassSource:ci];
        NSString *hFilePath =[[[Param shareInstance] garbageCodeDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h",[ci name]]];
        
        [headerContent writeToFile:hFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        NSString *classContent = [self getClassSource:ci];
        NSString *mFilePath =[[[Param shareInstance] garbageCodeDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.cpp",[ci name]]];
        [classContent writeToFile:mFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
       
    }
    printf("\n");
    fflush(stdout);
    
    NSLog(@"end to generate c++ garbage file");
}

@end



