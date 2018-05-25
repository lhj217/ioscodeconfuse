//
//  Parser.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/26.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SrcFileModel.h"
#import "ClassModel.h"

@interface Parser : NSObject

@property (nonatomic, strong) NSString *classname;
@property (nonatomic, strong) NSMutableArray *vars;//类的变量
@property (nonatomic, strong) NSMutableArray *properties;//类的属性
@property (nonatomic, strong) NSMutableArray *functions;//类的函数
@property (nonatomic, strong) NSMutableArray *extends;//类的extends
@property (nonatomic, strong) NSMutableArray *includes;//include集合
@property (nonatomic, strong) NSMutableArray *classes;//类的结合


-(int)judge:(NSString *)s;//判断字符串名字返回不同的值
-(NSString *)D:(NSString *)str ch:(char) c;//在字符串str中循环删除字符c
-(NSString *)D:(NSString *)str str:(NSString *)s;//删除所有指定的字符串
-(NSString *)R:(NSString *)str;//以\r为判断删除注释
-(NSMutableArray *)divideByTab:(NSString *)str;//以制表符为分隔符分解字符串成vector
-(void) ignorespacetab:(NSString *)str pos:(NSUInteger *)fI;//fI停在非空格和制表符处
-(void) ignorealnum:(NSString *)str pos:(NSUInteger *)fI;//fI停在非数字和字母处
-(void) display:(SrcFileModel *)fileModel;//用文件输出流输出
-(int) findSubStrAtPos:(NSString *)str findStr:(NSString *)findStr pos:(NSUInteger *)pos;//在pos处，str找s
-(NSString *)findClassName:(NSString *)name pos:(NSUInteger *)pos;//在一个字符串上找类名
-(NSMutableArray *)findExtendsName:(NSString *)str pos:(NSUInteger* )pos;//在一个字符串上找扩展名

-(int) findGlobalClassDeclares:(NSString *)str;//寻找全局类声明，和友元类;

-(int) findGlobalVarsAndFunctions:(NSString *)str;//寻找全局变量和全局函数
-(void) actionscope_ignore:(NSString *)str pos:(NSUInteger *)fI;//忽略一个大的作用域中的所有作用域
-(NSMutableArray *)actionscope:(NSString *)str pos:(NSUInteger *)fI;//获取最大的作用域的位置
-(bool) is_str_contain_space:(NSString *)str;//是否包含空格

-(bool)handleCppIdentify:(ClassModel *)classModel;

-(int)parseFile:(SrcFileModel *)srcFile;
@end
