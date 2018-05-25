//
//  GarbageInfo.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/16.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassInfo.h"

@interface GarbageInfo : NSObject

@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSMutableArray *classArr;
-(void)addClass:(ClassInfo *)ci;
@end
