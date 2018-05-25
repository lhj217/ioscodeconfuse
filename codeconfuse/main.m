//
//  main.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CodeConfuse.h"
#import "Param.h"
#import "CodeGenerator.h"
#import "ObjcCodeGenerator.h"
#import "CppCodeGenerator.h"
#import "TypeLogic.h"
#import "BoolTypeLogic.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {

        
        NSArray *argArr = [[NSProcessInfo processInfo] arguments];
        Param *param = [Param shareInstance];
        NSString *dir = [[argArr objectAtIndex:0] stringByDeletingLastPathComponent];
        [param setDir:dir];

        NSString *configFile = [dir stringByAppendingPathComponent:@"config.plist"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:configFile]) {
            NSLog(@"Cannot found config file [%@]",configFile);
            exit(0);
        }


        NSDictionary *configDir = [NSDictionary dictionaryWithContentsOfFile:configFile];
        NSLog(@"config content:\n%@\n",configDir);
        BOOL isConfuseCpp = [[configDir valueForKey:@"isConfuseCpp"] boolValue];
        BOOL isConfuseObjc = [[configDir valueForKey:@"isConfuseObjc"] boolValue];
        BOOL isInsertGarbageForCppFile = [[configDir valueForKey:@"isInsertGarbageForCppFile"] boolValue];
        BOOL isInsertGarbageForObjcFile = [[configDir valueForKey:@"isInsertGarbageForObjcFile"] boolValue];
        BOOL isExcludeVar = [[configDir valueForKey:@"isExcludeVar"] boolValue];
        NSInteger garbageFilePercent= [[configDir valueForKey:@"garbageFilePercent"] integerValue];
        NSInteger garbageCodePercent = [[configDir valueForKey:@"garbageCodePercent"] integerValue];
        if (garbageCodePercent==0) {
            garbageCodePercent = 100;
        }
        if(garbageFilePercent==0){
            garbageFilePercent = 100;
        }
        NSArray *sourceDirArr = [configDir valueForKey:@"sourcePath"];
        NSString *outputDir = [configDir valueForKey:@"outputDir"];
        NSArray *excludeNameArr = [configDir valueForKey:@"excludeName"];
        if (outputDir==nil) {
            outputDir = dir;
        }

        if([outputDir isEqualToString:@"."]){
            outputDir = dir;
        } else  if ([outputDir hasPrefix:@"."]) {
            outputDir = [dir stringByAppendingPathComponent:outputDir];
        } else if (![outputDir hasPrefix:@"/"]) {
            outputDir = [dir stringByAppendingPathComponent:outputDir];
        }

        if(![[NSFileManager defaultManager] fileExistsAtPath:outputDir]){
            NSLog(@"output dir is not found [%@]",outputDir);
            exit(0);
        }
        NSString *outputFile= [outputDir stringByAppendingPathComponent:@"output.txt"];
        NSString *garcodeCodeDir = [outputDir stringByAppendingPathComponent:@"garbagecode"];
        if([[NSFileManager defaultManager] fileExistsAtPath:garcodeCodeDir]){
            [[NSFileManager defaultManager] removeItemAtPath:garcodeCodeDir error:nil];
        }
        [[NSFileManager defaultManager] createDirectoryAtPath:garcodeCodeDir withIntermediateDirectories:YES attributes:nil error:nil];
        [param setSourceDirArr:sourceDirArr];
        [param setOutputFile:outputFile];
        [param setGarbageCodeDir:garcodeCodeDir];
        [param setIsConfuseCpp:isConfuseCpp];
        [param setIsConfuseObjc:isConfuseObjc];
        [param setIsInsertGarbageForCppFile:isInsertGarbageForCppFile];
        [param setIsInsertGarbageForObjectFile:isInsertGarbageForObjcFile];
        [param setIsExcludeVar:isExcludeVar];
        [param setExcludeNameArr:excludeNameArr];
        [param setGarbageCodePercent:garbageCodePercent];
        [param setGarbageFilePercent:garbageFilePercent];
        if([sourceDirArr count]==0) {
            NSLog(@"source path error");
            exit(0);
        }
        
        
        CodeConfuse *dialog = [[CodeConfuse alloc] init];
        [dialog process];
       
    }
    return 0;
}
