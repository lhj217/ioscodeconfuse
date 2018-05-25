//
//  CodeGenerator.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/10.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "ObjcCodeGenerator.h"
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

@implementation ObjcCodeGenerator 

- (instancetype)init
{
    self = [super init];
    if (self) {
        base_type_and_default = [NSMutableDictionary dictionaryWithObjectsAndKeys:OBJC_TYPE_BOOL_VALUE,OBJC_TYPE_BOOL,OBJC_TYPE_INT_VALUE,OBJC_TYPE_INT,OBJC_TYPE_FLOAT_VALUE,OBJC_TYPE_FLOAT,OBJC_TYPE_DOUBLE_VALUE,OBJC_TYPE_DOUBLE,OBJC_TYPE_ID_VALUE,OBJC_TYPE_ID, nil];
        base_type_list=[NSMutableArray arrayWithObjects:OBJC_TYPE_BOOL,OBJC_TYPE_INT,OBJC_TYPE_FLOAT,OBJC_TYPE_DOUBLE,OBJC_TYPE_ID, nil];
        defaultType = [NSMutableArray new];
    }
    return self;
}


/*[[
    - 类生成函数
    - 参数
    mc: 函数数量
    pc: 变量数量
    ac: 属性数量
    ]]*/


-(NSString *)boolFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c{
   return [super boolFunction:a b:b c:c];
}

-(NSString *)variableStr:(VariableInfo *)vi isSet:(BOOL)isSet {
    if ([vi varType] == VAR_TYPE_ATTR) {
        return [vi name];
    } else if([vi varType]==VAR_TYPE_PROP){
        return [NSString stringWithFormat:@"self.%@",[vi name]];
       
    }
     return [vi name];
}

-(NSString *)intFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c{
    return [super intFunction:a b:b c:c];
}


-(NSString *)floatFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c{
    return [super floatFunction:a b:b c:c];
    
}

-(NSString *)doubleFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c{
    return [super doubleFunction:a b:b c:c];
}

-(NSString *)stringFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c{
    int r = arc4random() %2+1;

    if (r == 1) {
        NSString *format = @"[NSString stringWithFormat:@\"%@%@\"";
        return [NSString stringWithFormat:@"%@ = %@,%@,%@];",[self variableStr:a isSet:YES],format,[self variableStr:b isSet:NO],[self variableStr:c isSet:NO]];
    } else {
        return [NSString stringWithFormat:@"%@ = %@;\n%@=%@;",[self variableStr:b isSet:YES],[self variableStr:a isSet:NO],[self variableStr:c isSet:YES],[self variableStr:a isSet:NO]];
    }
}

-(NSString *)getRandomVariableublic {
    int r = arc4random() %5+1;
    if (r==1) {
        return @"-";
    }
    return @"-";
}

-(PropertyInfo *)propertyGenerate:(NSString *)p name:(NSString *)name type:(NSString *)type defaultValue:(NSString *)defaultValue {
    PropertyInfo *pi = [PropertyInfo new];
    [pi setP:p];
    [pi setName:name];
    [pi setType:type];
    [pi setDefaultValue:defaultValue];
    return pi;
}


-(NSMutableArray *)methodContentGenerate:(ClassInfo *)ci mi:(MethodInfo *)mi {
    NSMutableArray *content = [NSMutableArray new];
    int methodBodyLine = 2+arc4random()%5;
    for (int i=0; i<methodBodyLine; i++) {
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
        
        
        VariableInfo *a = [self getRandomVariable:map];
        [map removeObject:a];
        VariableInfo *b = [self getRandomVariable:map];
        [map removeObject:b];
        VariableInfo *c = [self getRandomVariable:map];


        [map removeObject:c];
        if ([map count]>0) {
            if ([[ti type] isEqualToString:@"bool"]) {
                NSString *str =[self boolFunction:a b:b c:c];
                [content addObject:str];
            } else if ([[ti type] isEqualToString:@"int"]) {
                NSString *str =[self intFunction:a b:b c:c];
                [content addObject:str];
            } else if ([[ti type] isEqualToString:@"float"]) {
                NSString *str= [self floatFunction:a b:b c:c];
                [content addObject:str];
            } else if ([[ti type] isEqualToString:@"double"]) {
                NSString *str =[self doubleFunction:a b:b c:c];
                [content addObject:str];
            } else if ([[ti type] isEqualToString:@"id"]) {
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
    //[ci setImplement:@"MonoBehaviour"];
    NSMutableArray *properties = [NSMutableArray new];
    [ci setProperties:properties];

    for (int i =0; i<pc; i++) {
        TypeInfo *ti = [self getRandomType];
        NSString *propName =[self getVariableName];
        PropertyInfo *pi = [self propertyGenerate:[self getRandomVariableublic] name:propName type:[ti type] defaultValue:[ti defaultValue]];
        [properties addObject:pi];
    }


    NSMutableArray *attributes = [NSMutableArray new];
    [ci setAttributes:attributes];
    if(ac<[base_type_list count]*3){
        ac =[base_type_list count]*3;
    }
    for (int i=0;i<ac; i++) {
        TypeInfo *ti = [self getRandomType:YES];
        PropertyInfo *pi = nil;
        if (arc4random()%10<3) {
            pi = [properties objectAtIndex:arc4random()%[properties count]];
        }
        NSString *attrName = [self getVariableName];
        AttributesInfo *ai = [self attributeGenerate:@"" name:attrName type:[ti type] pi:pi];
        [attributes addObject:ai];
    }

    NSMutableDictionary *typeDic = [NSMutableDictionary new];
    [ci setTypeDic:typeDic];
    for (int i=0; i<[base_type_list count]; i++) {
        [typeDic setObject:[NSMutableArray new] forKey:[base_type_list objectAtIndex:i]];
    }

    for (PropertyInfo *pi in properties) {
        NSMutableArray *typeArr = [typeDic objectForKey:[pi type]];
        VariableInfo *vi = [VariableInfo new];
        [vi setVarType:VAR_TYPE_PROP];
        [vi setName:[pi name]];
        [vi setType:[pi type]];
        [typeArr addObject:vi];
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

-(void)addSpaceAndLine:(NSMutableString *)retn str:(NSString *) str tabCount:(NSInteger*)t{
    for (int i=0; i<*t; i++) {
        [retn appendString:@"    "];
    }
    [retn appendString:str];
    [retn appendString:@"\n"];
}


-(void)addProeprty:(NSMutableString *)retn pi:(PropertyInfo *)pi tabCount:(NSInteger *)t{
    NSString *retainType=@"assign";
    if([[pi type] isEqualToString:OBJC_TYPE_ID]) {
        retainType = @"strong";
    }
    NSString *str = [NSString stringWithFormat:@"@property(nonatomic,%@) %@ %@;",retainType,pi.type,pi.name];
    [self addSpaceAndLine:retn str:str tabCount:t];
}
-(void)addAttribute:(NSMutableString *)retn ai:(AttributesInfo *)ai tabCount:(NSInteger*)t {
    NSString *str = [NSString stringWithFormat:@"%@ %@;",ai.type,ai.name];
    [self addSpaceAndLine:retn str:str tabCount:t];

}

-(void)addMethod:(NSMutableString *)retn mi:(MethodInfo *)mi tabCount:(NSInteger*)t {
    NSString *returnType = @"void";
    if (mi.retn) {
        returnType = mi.type;
    }
    NSString *p = @"";
    if (mi.params) {
       for (int i=0; i<[mi.params count]; i++) {
            ParamInfo *param = [mi.params objectAtIndex:i];
            if ([p length]>0) {
                p = [p stringByAppendingFormat:@" %@:(%@)%@",[param name],[param type],[param name]];
            } else {
                p = [p stringByAppendingFormat:@":(%@) %@",[param type],[param name]];
            }
        }
    }
    [self addSpaceAndLine:retn str:[NSString stringWithFormat:@"%@(%@)%@%@",mi.p,returnType,mi.name,p] tabCount:t];
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
    NSString *returnType = @"void";
    if (mi.retn) {
        returnType = mi.type;
    }
    NSString *p = @"";
    if (mi.params) {
        for (int i=0; i<[mi.params count]; i++) {
            ParamInfo *param = [mi.params objectAtIndex:i];
            if ([p length]>0) {
                p = [p stringByAppendingFormat:@" %@:(%@)%@",[param name],[param type],[param name]];
            } else {
                p = [p stringByAppendingFormat:@":(%@)%@",[param type],[param name]];
            }
        }
    }
    [self addSpaceAndLine:retn str:[NSString stringWithFormat:@"%@(%@)%@%@;",mi.p,returnType,mi.name,p] tabCount:t];
}

- (NSString *)getClassSource:(ClassInfo *)ci {
    NSMutableString *r = [NSMutableString new];
    NSInteger t = 0;
    [r appendFormat:@"#import \"%@.h\"\n",[ci name]];
    NSString *str = [NSString stringWithFormat:@"@implementation %@ %@",ci.name,ci.implement==nil?@"":[NSString stringWithFormat:@" : %@",[ci implement]]];
    [self addSpaceAndLine:r str:str tabCount:&t];

    if ([ci methods]!=nil) {
        for (MethodInfo *mi in [ci methods]) {
            [self addMethod:r mi:mi tabCount:&t];
        }
    }
    [r appendFormat:@"\n%@",@"@end"];
    return r;
}

- (NSString *)getHeaderClassSource:(ClassInfo *)ci {
    NSMutableString *r = [NSMutableString new];
    NSInteger t = 0;
    [r appendString:@"#import <Foundation/Foundation.h>\n"];
    if ([ci implement]) {
        [r appendFormat:@"#import %@.h\n",[ci implement]];
    }
    NSString *str = [NSString stringWithFormat:@"@interface %@ : %@",ci.name,ci.implement==nil?@"NSObject":[NSString stringWithFormat:@"%@",[ci implement]]];
    [self addSpaceAndLine:r str:str tabCount:&t];


    if ([ci attributes]!=nil) {
        [self addSpaceAndLine:r str:@"{" tabCount:&t];
        t = t+1;
        for (AttributesInfo *ai in [ci attributes]) {
            [self addAttribute:r ai:ai tabCount:&t];
        }
        t = t-1;
        [self addSpaceAndLine:r str:@"}" tabCount:&t];

    }

    [r appendString:@"\n"];

    if ([ci properties]!=nil) {
        for (PropertyInfo *pi in [ci properties]) {
            [self addProeprty:r pi:pi tabCount:&t];
        }
    }

    [r appendString:@"\n"];

    if ([ci methods]!=nil) {
        for (MethodInfo *mi in [ci methods]) {
            [self addHeaderMethod:r mi:mi tabCount:&t];
        }
    }

    [self addSpaceAndLine:r str:@"@end" tabCount:&t];
    return r;
}


-(void)start{
    NSInteger class_count = (int)([self origFileCount]*[[Param shareInstance] garbageFilePercent]/100);
    NSInteger method_count = 30;
    NSInteger property_count = 30;
    NSInteger attribute_count = 30;

    NSLog(@"start to generate objc garbage file,count=[%ld]",class_count);
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
        [ci setClassType:CLASS_TYPE_OBJC];
        [[DataBase shareInstance] addClass:ci];
        
        NSString *headerContent = [self getHeaderClassSource:ci];
        NSString *hFilePath =[[[Param shareInstance] garbageCodeDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.h",[ci name]]];
        [headerContent writeToFile:hFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
         NSString *classContent = [self getClassSource:ci];
        NSString *mFilePath =[[[Param shareInstance] garbageCodeDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m",[ci name]]];
        [classContent writeToFile:mFilePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        
    }
    printf("\n");
    fflush(stdout);
    
     NSLog(@"end to generate objc garbage file");
}

@end
