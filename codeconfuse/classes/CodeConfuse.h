//
//  CodeConfuse.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SrcFileModel.h"
@interface CodeConfuse : NSObject {
    BOOL isConfuseObjc;
    BOOL isConfuseCpp;
    BOOL isCppInjectGarbageCode;
    BOOL isObjcInjectGarbageCode;
    NSMutableArray *fileList;
    NSMutableArray *excludeFileDir;
    NSMutableArray *excludeFileList;
}
-(void)readFileList:(NSString *)basePath;
-(void)process;

-(BOOL)isIdentifyProperty:(NSString *)identifyStr;
-(BOOL)isIdentifyClass:(NSString *)identifyStr;

@end
