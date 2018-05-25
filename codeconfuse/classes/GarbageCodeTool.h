//
//  GarbageCodeTool.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SrcFileModel.h"

@interface GarbageCodeTool : NSObject
+(instancetype) shareInstance;
-(void)insertGarbageCode:(SrcFileModel *)file;
-(void)insertGarbageCodeForList:(NSMutableArray *)fileList;
@end
