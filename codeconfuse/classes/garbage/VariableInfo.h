//
//  VariableInfo.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/11.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#define VAR_TYPE_ATTR   1
#define VAR_TYPE_PROP   2
#define VAR_TYPE_LOCAL  3
@interface VariableInfo : NSObject
@property (nonatomic, assign) NSInteger varType;
@property (nonatomic, assign) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;
@end
