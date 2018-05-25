//
//  ClassInfo.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/10.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define CLASS_TYPE_CPP      1
#define CLASS_TYPE_OBJC     2
#define CLASS_TYPE_CS       3
#define CLASS_TYPE_C        4
@interface ClassInfo : NSObject

@property (nonatomic,strong) NSString *p;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *implement;
@property (nonatomic,strong) NSMutableArray *properties;
@property (nonatomic,strong) NSMutableArray *attributes;
@property (nonatomic,strong) NSMutableArray *methods;
@property (nonatomic,strong) NSMutableDictionary *typeDic;
@property (nonatomic,assign) NSInteger classType;

@end
