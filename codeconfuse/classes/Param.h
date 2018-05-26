//
//  Param.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/5/2.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Param : NSObject
+(instancetype) shareInstance;
@property(nonatomic,strong) NSString *dir;
@property(nonatomic,strong) NSArray *sourceDirArr;
@property(nonatomic,strong) NSString *outputFile;
@property(nonatomic,strong) NSString *garbageCodeDir;
@property(nonatomic,strong) NSArray *excludeNameArr;

@property(nonatomic,assign) BOOL isConfuseCpp;
@property(nonatomic,assign) BOOL isInsertGarbageForCppFile;

@property(nonatomic,assign) BOOL isConfuseObjc;
@property(nonatomic,assign) BOOL isInsertGarbageForObjectFile;
@property(nonatomic,assign) BOOL isExcludeVar;

@property(nonatomic,assign) NSInteger garbageFilePercent;
@property(nonatomic,assign) NSInteger garbageCodePercent;

- (NSString *)dictionaryFile;

- (NSString *)keywordFile;
@end
