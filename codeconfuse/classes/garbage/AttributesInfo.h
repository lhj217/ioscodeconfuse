//
//  PropertyInfo.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/11.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyInfo.h"

@interface AttributesInfo : NSObject
@property(nonatomic,strong) NSString *p;
@property(nonatomic,strong) NSString *name;
@property(nonatomic,strong) NSString *type;
@property(nonatomic,strong) NSString *defaultValue;
@property(nonatomic,strong) PropertyInfo *pi;
@end
