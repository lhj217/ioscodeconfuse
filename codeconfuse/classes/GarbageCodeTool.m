//
//  GarbageCodeTool.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "GarbageCodeTool.h"
#import "DDFileReader.h"
#import "Param.h"
#import "CppGarbageCodeGenerator.h"
#import "ObjcGarbageCodeGenerator.h"
#import "CSGarbageCodeGenerator.h"
#import "CodeGenerator.h"

@implementation GarbageCodeTool {
    NSMutableArray *mExcludeArr;
    BOOL isCppInjectGarbageCode;
    BOOL isObjcInjectGarbageCode;
}
static GarbageCodeTool* _instance = nil;

+(instancetype) shareInstance
{
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        _instance = [[self alloc] init];
    });

    return _instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        mExcludeArr = [[NSMutableArray arrayWithObjects:@"switch",@"@implementation",@"@interface",@"typedef",@"//",@"extern",@"struct",@"union",@"static", nil] copy];
        isCppInjectGarbageCode = [[Param shareInstance] isInsertGarbageForCppFile] ;
        isObjcInjectGarbageCode =[[Param shareInstance] isInsertGarbageForObjectFile] ;


    }
    return self;
}

-(BOOL)isAllow:(NSString *)str {
    for (NSString *excludeStr in mExcludeArr) {
        if ([str hasPrefix:excludeStr]) {
            return NO;
        }
    }
    if ([str containsString:@"="]) {
        return NO;
    }
    return YES;
}

-(void)insertGarbageCode:(SrcFileModel *)file
{
    DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:[file filePath]];

    NSString *line = [reader readLine];
    NSString *preLine = nil;
    int count =0;
    NSMutableString *garbageContent = [NSMutableString new];
    NSMutableArray *classArr = [NSMutableArray new];
    int lineCount = 0;
    while(line!=nil)
    {
        lineCount++;
        NSString *lineTmp = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([lineTmp hasSuffix:@"{"] && ![lineTmp hasPrefix:@"//"] && [self isAllow:lineTmp]&&[self isAllow:preLine]) {
            int r = arc4random()%100;

            if (r<[[Param shareInstance] garbageCodePercent]) {
                CodeGenerator *gc = [self garbageCodeGeneratorBy:file];
                GarbageInfo *gi = [gc generateGarbagePiece];
                NSString *content = [gi content];
                if ([[gi classArr] count]>0) {
                    [classArr addObjectsFromArray:[gi classArr]];
                }
                if (content) {
                    [garbageContent appendFormat:@"%@\n%@\n",line,content];
                    count++;
                }else {
                    [garbageContent appendFormat:@"%@\n",line];
                }
            } else {
                [garbageContent appendFormat:@"%@\n",line];
            }

        }
        else
        {
            [garbageContent appendFormat:@"%@\n",line];
        }
        if ([lineTmp length]>0) {
            preLine = lineTmp;
        }
        line = [reader readLine];

    }

    [reader close];


    if (count>0) {


        NSMutableString *classStr = [NSMutableString new];
        for(int i=0; i<[classArr count]; i++) {
            ClassInfo *ci = [classArr objectAtIndex:i];
            if ([file fileType] == FILE_TYPE_CPP) {
                [classStr appendFormat:@"#include \"%@.h\"\n",[ci name]];\
            } else  if ([file fileType] == FILE_TYPE_M||[file fileType]==FILE_TYPE_MM) {
                [classStr appendFormat:@"#import \"%@.h\"\n",[ci name]];\
            }
        }
        NSError *error;
        NSString *content = [classStr stringByAppendingString:garbageContent];
        [content writeToFile:[file filePath] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSLog(@"write file [%@] error,%@",[file filePath],error);
        }
    }

}

- (CodeGenerator *)garbageCodeGeneratorBy:(SrcFileModel *)file {
    CodeGenerator *gc = nil;
    if ([file fileType] == FILE_TYPE_CPP ||[file fileType] == FILE_TYPE_C ) {
        gc = [CppGarbageCodeGenerator new];
    } else  if ([file fileType] == FILE_TYPE_MM || [file fileType] == FILE_TYPE_M) {
        gc = [ObjcGarbageCodeGenerator new];
    }else if([file fileType] == FILE_TYPE_CS) {
        gc = [CSGarbageCodeGenerator new];
    }
    return gc;
}

-(void)insertGarbageCodeForList:(NSMutableArray *)fileList {
    for(int i=0; i<[fileList count]; i++)
    {
        if(i%10==0){
            printf("*");
            fflush(stdout);
        }
        SrcFileModel *file = [fileList objectAtIndex:i];
        //过滤掉已经插入过垃圾代码的cpp文件，还有Pods文件
        if (file.isInsertGarbageCode || [[file filePath] containsString:@"Pods/"])
        {
            continue;
        }

        if (isCppInjectGarbageCode) {
            if([file.fileName hasSuffix:@".cpp"] || [file.fileName hasSuffix:@".cxx"] || [file.fileName hasSuffix:@".cc"])
            {
                file.cppFileName = file.fileName;
                file.cppFilePath = file.filePath;
                file.fileType=FILE_TYPE_CPP;

                [[GarbageCodeTool shareInstance] insertGarbageCode:file];
            }
            else if([file.fileName hasSuffix:@".c"])
            {
                file.fileType=FILE_TYPE_C;
                file.cFileName = file.fileName;
                file.cFilePath = file.filePath;

                [[GarbageCodeTool shareInstance] insertGarbageCode:file];
            }
        }
        if (isObjcInjectGarbageCode) {
            if([file.fileName hasSuffix:@".m"])
            {
                file.cppFileName = file.fileName;
                file.cppFilePath = file.filePath;
                file.fileType=FILE_TYPE_M;

                [[GarbageCodeTool shareInstance] insertGarbageCode:file];
            } else if([file.fileName hasSuffix:@".mm"])
            {
                file.cppFileName = file.fileName;
                file.cppFilePath = file.filePath;
                file.fileType=FILE_TYPE_MM;

                [[GarbageCodeTool shareInstance] insertGarbageCode:file];
            }
        }
        file.isInsertGarbageCode = YES;

    }
    printf("\n");
    fflush(stdout);
}

@end



