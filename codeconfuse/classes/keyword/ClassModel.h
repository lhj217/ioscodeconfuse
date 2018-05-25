//
//  ClassModel.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClassModel : NSObject
@property (nonatomic,strong) NSString *fileName; //不带后缀名的文件名
@property (nonatomic,strong) NSString *filePath; //文件路径
@property (nonatomic,strong) NSString *className;   //类名词
@property (nonatomic,strong) NSString *identifyName;
@property (nonatomic,strong) NSString *identifyOriginName;

@property (nonatomic) BOOL isObjectiveC;
@property (nonatomic) BOOL isPropertyName;
@property (nonatomic) BOOL isMethodName;

@end
