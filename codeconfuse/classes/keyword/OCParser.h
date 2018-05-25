//
//  OcParser.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SrcFileModel.h"
#import "ClassModel.h"
#import "Parser.h"
#define OC_INCLUDE     8
#define OC_IMPORT      7
#define OC_CLASS       3
#define OC_IMPLEMENTS  2
#define OC_VARIABLE    4
#define OC_FUNCTION    5
#define OC_UNDEINED    -1
#define OC_NOTFOUND    0
#define OC_HAVEFOUND   1
@interface OCParser : Parser
@property (nonatomic, strong) NSMutableArray *delegates;//类的delegates
@property (nonatomic, strong) NSMutableArray *imports;//import集合

//如果已经存在属性名称，则忽略同名的函数名称
-(bool)is_property_name_exist:(NSString *)functionName propertyList:(NSMutableArray*) propertyList;

-(bool) handleObjectiveCIdentify:(ClassModel *)model;
-(int)find:(NSString *)str findStr:(NSString *)s pos:(NSUInteger *)pos;
-(NSString *)findExtendsName1:(NSString *)str pos:(NSUInteger *)pos;//在一个字符串上找扩展名
-(NSMutableArray *) findDelegatesName:(NSString *)str pos:(NSUInteger *)pos;//代理
-(NSMutableDictionary *)findPropertiesAndFunctionDeclaresName:(NSString *)str pos:(NSUInteger *)pos;//属性和方法


@end
