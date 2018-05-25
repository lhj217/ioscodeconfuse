//
//  MethodInfo.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/11.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MethodInfo : NSObject
@property(nonatomic,strong) NSString *p;
@property(nonatomic,strong) NSString *type;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSArray *params;
@property(nonatomic,strong) NSString *retn;
@property(nonatomic,strong) NSArray *content;

@end
