//
//  CodeGenerator.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/10.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "CppGarbageCodeGenerator.h"
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

@implementation CppGarbageCodeGenerator

- (VariableInfo *)localVar:(TypeInfo *)ti{
    VariableInfo *var = [VariableInfo new];
    [var setName:[[DataBase shareInstance] randomName:10]];
    [var setType:[ti type]];
    [var setVarType:VAR_TYPE_LOCAL];
    if ([[ti type] isEqualToString:CPP_TYPE_INT]) {
        NSString *value = [NSString stringWithFormat:@"%d",1+arc4random()%100000];
        [var setValue:value];
    } else  if ([[ti type] isEqualToString:CPP_TYPE_FLOAT]) {
        NSString *value = [NSString stringWithFormat:@"%d.0f",1+arc4random()%100000];
        [var setValue:value];
    } else if ([[ti type] isEqualToString:CPP_TYPE_DOUBLE]) {
        NSString *value = [NSString stringWithFormat:@"%d.0",1+arc4random()%100000];
        [var setValue:value];
    } else if ([[ti type] isEqualToString:CPP_TYPE_BOOL]) {
        NSString *value =nil;
        if (arc4random()%2==0) {
            value=@"false";
        } else {
            value = @"true";
        }

        [var setValue:value];
    } else if ([[ti type] isEqualToString:CPP_TYPE_STRING]) {
        NSString *value = [[DataBase shareInstance] randomName:2];
        [var setValue:value];
    }
    return var;
}


-(GarbageInfo *)generateGarbagePiece{
    NSMutableString *retn  = [NSMutableString new];
    GarbageInfo *gi = [GarbageInfo new];
    [gi setContent:retn];
    if (arc4random()%3>0) {
        int count = 1+ arc4random()%3;
        for (int i=0; i<count; i++) {
            NSMutableArray *classArr = [[DataBase shareInstance] classArrByClassType:CLASS_TYPE_CPP];
            if ([classArr count]>0) {
                int index =arc4random()%[classArr count];
                ClassInfo *ci = [classArr objectAtIndex:index];
                [gi addClass:ci];
                [classArr removeObjectAtIndex:index];
                NSString *className = [[DataBase shareInstance] randomName:2];
                [retn appendFormat:@"%@ *%@ = new %@();\n",[ci name],className,[ci name]];
                NSArray *methods = [ci methods];
                if ([methods count]>0) {
                    MethodInfo *mi = [methods objectAtIndex:(arc4random()%[methods count])];
                    NSArray *params = [mi params];
                    NSMutableString *paramStr = [NSMutableString new];
                    if ([params count]>0) {
                        for (int j=0;j<[params count]; j++) {
                            ParamInfo *pi = [params objectAtIndex:j];
                            NSString *type = [pi type];
                            NSString *value = [base_type_and_default valueForKey:type];
                            TypeInfo *ti = [TypeInfo new];
                            [ti setType:type];
                            [ti setDefaultValue:value];
                            VariableInfo *a = [self localVar:ti];
                            if ([[ti type] isEqualToString:CPP_TYPE_BOOL]) {
                                [retn appendFormat:@"bool %@=%@;\n",[a name],[a value]];

                            } else if ([[ti type] isEqualToString:CPP_TYPE_INT]) {
                                [retn appendFormat:@"int %@=%@;\n",[a name],[a value]];

                            } else if ([[ti type] isEqualToString:CPP_TYPE_FLOAT]) {
                                [retn appendFormat:@"float %@=%@;\n",[a name],[a value]];

                            } else if ([[ti type] isEqualToString:CPP_TYPE_DOUBLE]) {
                                [retn appendFormat:@"double %@=%@;\n",[a name],[a value]];

                            } else if ([[ti type] isEqualToString:CPP_TYPE_STRING]) {
                                [retn appendFormat:@"std::string %@=\"%@\";\n",[a name],[a value]];

                            }
                            if ([paramStr length]>0) {
                                [paramStr appendFormat:@",%@",[a name]];
                            } else {
                                [paramStr appendFormat:@"%@",[a name]];
                            }
                        }

                    }
                    [retn appendFormat:@"%@->%@(%@);\n",className,[mi name],paramStr];
                }
            }
        }
    } else {
        int count = 1+ arc4random()%3;
        for (int i=0; i<count; i++) {
            TypeInfo *ti= [self getRandomType];


            VariableInfo *a = [self localVar:ti];
            VariableInfo *b = [self localVar:ti];
            VariableInfo *c = [self localVar:ti];


            if ([[ti type] isEqualToString:CPP_TYPE_BOOL]) {
                [retn appendFormat:@"bool %@=%@;\n",[a name],[a value]];
                [retn appendFormat:@"bool %@=%@;\n",[b name],[b value]];
                [retn appendFormat:@"bool %@=%@;\n",[c name],[c value]];
                NSString *str =[self boolFunction:a b:b c:c];
                [retn appendFormat:@"%@\n",str];
            } else if ([[ti type] isEqualToString:CPP_TYPE_INT]) {
                [retn appendFormat:@"int %@=%@;\n",[a name],[a value]];
                [retn appendFormat:@"int %@=%@;\n",[b name],[b value]];
                [retn appendFormat:@"int %@=%@;\n",[c name],[c value]];
                NSString *str =[self intFunction:a b:b c:c];
                [retn appendFormat:@"%@\n",str];
            } else if ([[ti type] isEqualToString:CPP_TYPE_FLOAT]) {
                [retn appendFormat:@"float %@=%@;\n",[a name],[a value]];
                [retn appendFormat:@"float %@=%@;\n",[b name],[b value]];
                [retn appendFormat:@"float %@=%@;\n",[c name],[c value]];
                NSString *str= [self floatFunction:a b:b c:c];
                [retn appendFormat:@"%@\n",str];
            } else if ([[ti type] isEqualToString:CPP_TYPE_DOUBLE]) {
                [retn appendFormat:@"double %@=%@;\n",[a name],[a value]];
                [retn appendFormat:@"double %@=%@;\n",[b name],[b value]];
                [retn appendFormat:@"double %@=%@;\n",[c name],[c value]];
                NSString *str =[self doubleFunction:a b:b c:c];
                [retn appendFormat:@"%@\n",str];
            } else if ([[ti type] isEqualToString:CPP_TYPE_STRING]) {
                [retn appendFormat:@"std::string %@=\"%@\";\n",[a name],[a value]];
                [retn appendFormat:@"std::string %@=\"%@\";\n",[b name],[b value]];
                [retn appendFormat:@"std::string %@=\"%@\";\n",[c name],[c value]];
                NSString *str= [self stringFunction:a b:b c:c];
                [retn appendFormat:@"%@\n",str];
            }

        }

    }
    return gi;

}
@end




