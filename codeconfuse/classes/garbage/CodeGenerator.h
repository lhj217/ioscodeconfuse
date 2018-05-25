//
//  CodeGenerator.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/10.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypeInfo.h"
#import "AttributesInfo.h"
#import "VariableInfo.h"
#import "BoolTypeLogic.h"
#import "IntTypeLogic.h"
#import "FloatTypeLogic.h"
#import "DoubleTypeLogic.h"
#import "StringTypeLogic.h"
#import "GarbageInfo.h"

@class TypeLogic;
@interface CodeGenerator : NSObject {
    NSMutableDictionary *base_type_and_default;
    NSMutableArray *base_type_list;
    NSMutableArray *defaultType;
    NSInteger classCount;
}
@property (nonatomic, assign) NSInteger origFileCount;
-(void)start;
-(NSString *)getVariableName;
-(NSString *)getClassName;
-(TypeInfo *)getRandomType;
-(TypeInfo *)getRandomType:(BOOL)isAttribute;
-(void)addSpaceAndLine:(NSMutableString *)retn str:(NSString *) str tabCount:(NSInteger*)t;
-(AttributesInfo *)attributeGenerate:(NSString *)p name:(NSString *)name type:(NSString *)type pi:(PropertyInfo *)pi;

-(VariableInfo *)getRandomVariable:(NSArray *)a;

-(NSString *)variableStr:(VariableInfo *)vi isSet:(BOOL)isSet;
-(NSString *)boolFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c;
-(NSString *)intFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c;
-(NSString *)floatFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c;
-(NSString *)doubleFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c;
-(NSString *)stringFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c;

-(GarbageInfo *)generateGarbagePiece;
@end
