//
//  CodeGenerator.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/10.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "CSCodeGenerator.h"
#import "TypeInfo.h"
#import "ClassInfo.h"
#import "PropertyInfo.h"
#import "AttributesInfo.h"
#import "MethodInfo.h"
#import "ParamInfo.h"
#import "Param.h"

@implementation CSCodeGenerator {
    NSString *charlist;
    NSString *header_charlist;
    NSMutableDictionary *base_type_and_default;
    NSMutableArray *base_type_list;
    NSMutableArray *existName;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        charlist = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890_";
        header_charlist = @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_";
        base_type_and_default = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"false",@"bool",@"0",@"int",@"0.0f",@"float",@"0.0",@"double",@"null",@"string", nil];
        base_type_list=[NSMutableArray arrayWithObjects:@"bool",@"int",@"float",@"double",@"string", nil];
        existName = [NSMutableArray new];
    }
    return self;
}
- (NSString *)getChar:(NSString *)str  length:(NSUInteger)length{
    NSMutableString *buffer = [NSMutableString new];
    for (int i=0; i<length; i++) {
        uint32_t index=  arc4random()%[str length];
        char ch=[str characterAtIndex:index];
        [buffer appendFormat:@"%c",ch];
    }
    return buffer;
}
- (NSString *)getRandomChar{
    uint32_t length=  4+arc4random()%20;
    return [self getChar:charlist length:length];
}

- (NSString *)getRandomHChar{
    uint32_t length=  4+arc4random()%20;
    return [self getChar:header_charlist length:length];
}
- (NSString *)getRandomName:(NSInteger )length{
    NSString *header = [self getRandomHChar];
    NSString *body = [self getRandomChar];
    return [header stringByAppendingString:body];
}





/*[[
    - 类生成函数
    - 参数
    mc: 函数数量
    pc: 变量数量
    ac: 属性数量
    ]]*/


-(NSString *)boolFunction:(NSString *)a b:(NSString *)b c:(NSString *)c{
    int r = arc4random() %5+1;

    if (r == 1) {
        return [NSString stringWithFormat:@"%@ = %@ && %@;",a,b,c];
    } else if(r == 2){
        return [NSString stringWithFormat:@" if(%@){\n\t%@ =! %@;\n}",a,b,c];
    } else if(r==3){
          return [NSString stringWithFormat:@" if(%@ && %@ ){\n\t%@ =! %@;\n}",a,c,b,b];
    } else if(r==4){
        return [NSString stringWithFormat:@" if(%@ || %@ ){\n\t%@ =! %@;\n}",a,b,b,b];
    } else if(r==5){
        return [NSString stringWithFormat:@"%@ = %@ || %@;",a,b,c];
    } else {
        return [NSString stringWithFormat:@"%@ = %@ && %@;",a,b,c];
    }
}

-(NSString *)intFunction:(NSString *)a b:(NSString *)b c:(NSString *)c{
    int r = arc4random() %7+1;

    if (r == 1) {
        return [NSString stringWithFormat:@"%@ = %@ + %@;",a,b,c];
    } else if(r == 2){
        return [NSString stringWithFormat:@"%@ = %@ - %@;",a,b,c];
    } else if(r==3){
        return [NSString stringWithFormat:@"%@ = %@ * %@;",a,b,c];
    } else if(r==4){
       return [NSString stringWithFormat:@"%@ = %@ / %@;",a,b,c];
    } else if(r==5){
        return [NSString stringWithFormat:@"%@ = math.random(1, 100000);\n%@ = math.random(1, 100000);\n%@ = math.random(1, 100000);\n",a,b,c];
    } else if(r==6){
        return [NSString stringWithFormat:@"for(int i=0;i<%@;++i){\n\t%@+=1;\n\t%@+=%@",a,b,c,b];
    }
    else {
        return [NSString stringWithFormat:@"%@ = %@;\n%@=%@;",b,a,c,a];
    }
}


-(NSString *)floatFunction:(NSString *)a b:(NSString *)b c:(NSString *)c{
    int r = arc4random() %6+1;

    if (r == 1) {
        return [NSString stringWithFormat:@"%@ = %@ + %@;",a,b,c];
    } else if(r == 2){
        return [NSString stringWithFormat:@"%@ = %@ - %@;",a,b,c];
    } else if(r==3){
        return [NSString stringWithFormat:@"%@ = %@ * %@;",a,b,c];
    } else if(r==4){
        return [NSString stringWithFormat:@"%@ = %@ / %@;",a,b,c];
    } else if(r==5){
        return [NSString stringWithFormat:@"%@ = math.random(1, 100000).0f;\n%@ = math.random(1, 100000).0f;\n%@ = math.random(1, 100000).0f;\n",a,b,c];
    }else {
        return [NSString stringWithFormat:@"%@ = %@;\n%@=%@;",b,a,c,a];
    }
}

-(NSString *)doubleFunction:(NSString *)a b:(NSString *)b c:(NSString *)c{
    int r = arc4random() %6+1;

    if (r == 1) {
        return [NSString stringWithFormat:@"%@ = %@ + %@;",a,b,c];
    } else if(r == 2){
        return [NSString stringWithFormat:@"%@ = %@ - %@;",a,b,c];
    } else if(r==3){
        return [NSString stringWithFormat:@"%@ = %@ * %@;",a,b,c];
    } else if(r==4){
        return [NSString stringWithFormat:@"%@ = %@ / %@;",a,b,c];
    } else if(r==5){
        return [NSString stringWithFormat:@"%@ = math.random(1, 100000).0;\n%@ = math.random(1, 100000).0;\n%@ = math.random(1, 100000).0;\n",a,b,c];
    }else {
        return [NSString stringWithFormat:@"%@ = %@;\n%@=%@;",b,a,c,a];
    }
}

-(NSString *)stringFunction:(NSString *)a b:(NSString *)b c:(NSString *)c{
    int r = arc4random() %3+1;

    if (r == 1) {
        return [NSString stringWithFormat:@"%@ = %@ + %@;",a,b,c];
    } else if(r == 2){
        return [NSString stringWithFormat:@"%@ =  string.Format(%@,%@);",a,b,c];
    } else {
        return [NSString stringWithFormat:@"%@ = %@;\n%@=%@;",b,a,c,a];
    }
}

-(TypeInfo *)getRandomType{
    NSString *type = [base_type_list objectAtIndex:arc4random()%[base_type_list count]];
    NSString *value = [base_type_and_default valueForKey:type];
    TypeInfo *ti = [TypeInfo new];
    [ti setType:type];
    [ti setDefaultValue:value];
    return ti;
}

-(NSString *)getRandomPublic {
    int r = arc4random()%3+1;
    if (r==1) {
        return @"public";
    } else if(r==2){
        return @"private";
    } else {
        return @"";
    }
}

-(PropertyInfo *)PropertyGenerate:(NSString *)p name:(NSString *)name type:(NSString *)type defaultValue:(NSString *)defaultValue {
    PropertyInfo *pi = [PropertyInfo new];
    [pi setP:p];
    [pi setName:name];
    [pi setType:type];
    [pi setDefaultValue:defaultValue];
    return pi;
}

-(AttributesInfo *)AttributeGenerate:(NSString *)p name:(NSString *)name type:(NSString *)type pi:(PropertyInfo *)pi {
    AttributesInfo *ai = [AttributesInfo new];
    [ai setP:p];
    [ai setName:name];
    [ai setType:type];
    [ai setPi:pi];
    return ai;
}

-(VariableInfo *)getRandomP:(NSArray *)a{
    return [a objectAtIndex:arc4random()%[a count]];
}

-(NSMutableArray *)MethodContentGenerate:(ClassInfo *)ci {
    NSMutableArray *content = [NSMutableArray new];
    for (int i=0; i<10; i++) {
        TypeInfo *ti= [self getRandomType];
        NSArray *map = [[ci typeDic] valueForKey:[ti type]];
        if ([map count]>0) {
            if ([[ti type] isEqualToString:@"bool"]) {
                NSString *str =[self boolFunction:[self getRandomP:map] b:[self getRandomP:map] c:[self getRandomP:map]];
                [content addObject:str];
            } else if ([[ti type] isEqualToString:@"int"]) {
                NSString *str =[self intFunction:[self getRandomP:map] b:[self getRandomP:map] c:[self getRandomP:map]];
                [content addObject:str];
            } else if ([[ti type] isEqualToString:@"float"]) {
                NSString *str= [self floatFunction:[self getRandomP:map] b:[self getRandomP:map] c:[self getRandomP:map]];
                [content addObject:str];
            } else if ([[ti type] isEqualToString:@"double"]) {
                NSString *str =[self doubleFunction:[self getRandomP:map] b:[self getRandomP:map] c:[self getRandomP:map]];
                [content addObject:str];
            } else if ([[ti type] isEqualToString:@"string"]) {
                NSString *str= [self stringFunction:[self getRandomP:map] b:[self getRandomP:map] c:[self getRandomP:map]];
                [content addObject:str];
            }
        }
    }
    return content;

}

-(MethodInfo *)MethodGenerate:(ClassInfo *)ci p:(NSString *)p name:(NSString *)name retn:(NSString *)retn{
    MethodInfo *mi = [MethodInfo new];
    [mi setP:p];
    [mi setName:name];
    [mi setRetn:retn];
    NSArray *content =[self MethodContentGenerate:ci];
    [mi setContent:content];
    return mi;
}

-(NSString *)GetNextClassName:(NSInteger)minLength maxLength:(NSInteger)maxLength {
    int length = arc4random()%(maxLength-minLength);
    NSString *name =  [self getRandomName:length];
    while ([existName containsObject:name]) {
        name = [self getRandomName:length];
    }
    [existName addObject:name];
    return name;
}

/**--[[
    - 类生成函数
    - 参数
    mc: 函数数量
    pc: 变量数量
    ac: 属性数量
    ]]
 */

-(ClassInfo *) ClassGenerater:(NSInteger)mc propertyCount:(NSInteger)pc attributeCount:(NSInteger)ac{
    ClassInfo *ci = [ClassInfo new];
    [ci setP:[self getRandomPublic]];
    NSString *name = [self GetNextClassName:10 maxLength:40];
    [ci setName:name];
    //[ci setImplement:@"MonoBehaviour"];
    NSMutableArray *properties = [NSMutableArray new];
    [ci setProperties:properties];

    for (int i =0; i<pc; i++) {
        TypeInfo *ti = [self getRandomType];
        PropertyInfo *pi = [self PropertyGenerate:[self getRandomPublic] name:[self GetNextClassName:10 maxLength:40] type:[ti type] defaultValue:[ti defaultValue]];
        [properties addObject:pi];
    }


    NSMutableArray *attributes = [NSMutableArray new];
    [ci setAttributes:attributes];
    for (int i=0;i<ac; i++) {
        TypeInfo *ti = [self getRandomType];
        PropertyInfo *pi = nil;
        if (arc4random()%10<3) {
            pi = [properties objectAtIndex:arc4random()%[properties count]];
        }
        AttributesInfo *ai = [self AttributeGenerate:@"public" name:[self GetNextClassName:10 maxLength:40] type:[ti type] pi:pi];
        [attributes addObject:ai];
    }

    NSMutableDictionary *typeDic = [NSMutableDictionary new];
    [ci setTypeDic:typeDic];
    for (int i=0; i<[base_type_list count]; i++) {
        [typeDic setObject:[NSMutableArray new] forKey:[base_type_list objectAtIndex:i]];
    }

    for (PropertyInfo *pi in properties) {
        NSMutableArray *typeArr = [typeDic objectForKey:[pi type]];
        [typeArr addObject:[pi name]];
    }

    for (AttributesInfo *ai in properties) {
        NSMutableArray *typeArr = [typeDic objectForKey:[ai type]];
        [typeArr addObject:[ai name]];
    }


    NSMutableArray *methods = [NSMutableArray new];
    [ci setMethods:methods];
    for (int i=0;i<mc; i++) {
        PropertyInfo *pi = nil;
        if (arc4random()%10<3) {
            pi = [properties objectAtIndex:arc4random()%[properties count]];
        }
        MethodInfo *mi = [self MethodGenerate:ci p:@"public" name:[self GetNextClassName:10 maxLength:40] retn:nil];
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
    NSString *str = [NSString stringWithFormat:@"%@ %@ %@=%@;",pi.p,pi.type,pi.name,pi.defaultValue];
    [self addSpaceAndLine:retn str:str tabCount:t];
}
-(void)addAttribute:(NSMutableString *)retn ai:(AttributesInfo *)ai tabCount:(NSInteger*)t {
    NSString *str = [NSString stringWithFormat:@"%@ %@ %@;",ai.p,ai.type,ai.name];
    [self addSpaceAndLine:retn str:str tabCount:t];
    [self addSpaceAndLine:retn str:@"{" tabCount:t];
    *t=*t+1;
    if (ai.pi!=nil) {
        [self addSpaceAndLine:retn str:[NSString stringWithFormat:@"get { return %@; }",ai.pi.name] tabCount:t];
        [self addSpaceAndLine:retn str:[NSString stringWithFormat:@"set { %@ = value; }]",ai.pi.name] tabCount:t];
    } else {
        [self addSpaceAndLine:retn str:[NSString stringWithFormat:@"get;"] tabCount:t];
        [self addSpaceAndLine:retn str:[NSString stringWithFormat:@"set;"] tabCount:t];

    }
    *t=*t-1;
    [self addSpaceAndLine:retn str:@"}" tabCount:t];
}

-(void)addMethod:(NSMutableString *)retn mi:(MethodInfo *)mi tabCount:(NSInteger*)t {
    NSString *returnType = @"void";
    if (mi.retn) {
        returnType = mi.retn;
    }
    NSString *p = @"()";
    if (mi.params) {
        p = @"";
        for (int i=0; i<[mi.params count]; i++) {
            ParamInfo *param = [mi.params objectAtIndex:i];
            if ([p length]>0) {
                p = [p stringByAppendingFormat:@", %@ %@",[param type],[param name]];
            } else {
                p = [p stringByAppendingFormat:@"%@ %@",[param type],[param name]];
            }
        }
        p = [NSString stringWithFormat:@"(%@)",p];
    }
    [self addSpaceAndLine:retn str:[NSString stringWithFormat:@"%@ %@ %@%@",mi.p,returnType,mi.name,p] tabCount:t];
    [self addSpaceAndLine:retn str:@"{" tabCount:t];
    *t=*t+1;
    for (int i=0; i<[mi.content count]; i++) {
        NSString *content = [[mi content] objectAtIndex:i];
         [self addSpaceAndLine:retn str:content tabCount:t];
    }

    *t=*t-1;
    [self addSpaceAndLine:retn str:@"}" tabCount:t];
}

- (NSString *)GetClassSource:(ClassInfo *)ci {
    NSMutableString *r = [NSMutableString new];
    NSInteger t = 0;
    NSString *str = [NSString stringWithFormat:@"%@ class %@ %@",ci.p,ci.name,ci.implement==nil?@"":[NSString stringWithFormat:@" : %@",[ci implement]]];
    [self addSpaceAndLine:r str:str tabCount:&t];
    [self addSpaceAndLine:r str:@"{" tabCount:&t];

    t = t+1;
    if ([ci properties]!=nil) {
        for (PropertyInfo *pi in [ci properties]) {
            [self addProeprty:r pi:pi tabCount:&t];
        }
    }

    if ([ci attributes]!=nil) {
        for (AttributesInfo *ai in [ci attributes]) {
            [self addAttribute:r ai:ai tabCount:&t];
        }
    }

    if ([ci methods]!=nil) {
        for (MethodInfo *mi in [ci methods]) {
            [self addMethod:r mi:mi tabCount:&t];
        }
    }
    t = t-1;
    [self addSpaceAndLine:r str:@"}" tabCount:&t];
    return r;
}

-(void)start{
    NSInteger class_count = 1;
    NSInteger method_count = 30;
    NSInteger property_count = 30;
    NSInteger attribute_count = 30;

    NSLog(@"start to generate c# garbage file,count=[%ld]",class_count);
    for (int i=0; i<class_count; i++) {
        if(i%(class_count/10)==0){
            printf("*");
            fflush(stdout);
        }
         method_count = 5+ arc4random()%10;
         property_count = 5+ arc4random()%10;
         attribute_count = 10+ arc4random()%10;

         ClassInfo *ci = [self ClassGenerater:method_count propertyCount:property_count attributeCount:attribute_count];
        [ci setClassType:CLASS_TYPE_CS];
        [[DataBase shareInstance] addClass:ci];
        
        NSString *classContent = [self GetClassSource:ci];
        [classContent writeToFile:[[[Param shareInstance] garbageCodeDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.cs",[ci name]]] atomically:YES encoding:NSUTF8StringEncoding error:nil];

    }
    NSLog(@"end to generate c# garbage file");
}

@end
