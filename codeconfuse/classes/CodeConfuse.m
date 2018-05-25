//
//  CodeConfuse.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "CodeConfuse.h"
#import "GarbageCodeTool.h"
#import "CppParser.h"
#import "OCParser.h"
#import "DataBase.h"
#import "DDFileReader.h"
#import "Param.h"
#import "StringUtil.h"
#import "KeywordAnalyse.h"
#import "CodeGenerator.h"
#import "CppCodeGenerator.h"
#import "ObjcCodeGenerator.h"

@implementation CodeConfuse {
    NSArray *allowFileExtention;
    NSInteger cppFileCount;
    NSInteger objcFileCount;

}

- (instancetype)init
{
    self = [super init];
    if (self) {
        isConfuseObjc = [[Param shareInstance] isConfuseObjc] ;
        isConfuseCpp = [[Param shareInstance] isConfuseCpp] ;
        isCppInjectGarbageCode = [[Param shareInstance] isInsertGarbageForCppFile] ;
        isObjcInjectGarbageCode =[[Param shareInstance] isInsertGarbageForObjectFile] ;
        fileList = [[NSMutableArray alloc] init];
        excludeFileDir = [[NSMutableArray alloc] init];
        excludeFileList = [[NSMutableArray alloc] init];
        allowFileExtention = [NSArray arrayWithObjects:@".m",@".mm",@".cpp",@".h",@".c",@".cxx",@".cc",nil];

    }
    return self;
}


-(void)process {
    NSArray *sourceDirArr = [[Param shareInstance] sourceDirArr];
    NSLog(@"start to read file");
    for (NSString *filePath in sourceDirArr) {
        NSLog(@"code source path=%@",filePath);
        [self readFileList:filePath];
        printf("\n");
        fflush(stdout);
    }

    NSLog(@"end to read file, count=[%ld]",[fileList count]);

//
//    NSLog(@"start to read exclude file");
//    for (NSString *filePath in excludeFileDir) {
//        NSLog(@"code source path=%@",filePath);
//        [self readExcludeFileList:filePath];
//    }
//    printf("\n");
//    fflush(stdout);
//    NSLog(@"end to read exlcude file");
//
//    NSLog(@"start to analyse excluded keyword");
//    KeywordAnalyse *ka=[[KeywordAnalyse alloc] initWithFileList:excludeFileList];
//    [ka analyseExcludeFile];
//    NSLog(@"end to analyse excluded keyword");
//
//    NSArray *excludeKeyword = [[DataBase shareInstance] queryAll];
//    if ([excludeKeyword count]>0) {
//        [[[DataBase shareInstance] excludeKeywordArr] addObjectsFromArray:excludeKeyword];
//    }
//    [[DataBase shareInstance] reset];
    
    if (isConfuseCpp || isConfuseObjc) {
        NSLog(@"start to analyse keyword code");
        KeywordAnalyse *ka=[[KeywordAnalyse alloc] initWithFileList:fileList];
        [ka analyse];
        NSLog(@"end to analyse keyword code");
    }
    
    if (isCppInjectGarbageCode || isObjcInjectGarbageCode) {
        if (isCppInjectGarbageCode) {
            CodeGenerator *cg = [[CppCodeGenerator alloc] init];
            [cg setOrigFileCount:cppFileCount];
            [cg start];

        }
        
        
        if (isObjcInjectGarbageCode) {
            CodeGenerator *cg = [[ObjcCodeGenerator alloc] init];
            [cg setOrigFileCount:objcFileCount];
            [cg start];
        }
        
        
        NSLog(@"start to inject garbage code");
        [[GarbageCodeTool shareInstance] insertGarbageCodeForList:fileList];
       
        NSLog(@"end to inject garbage code");
    }


    NSLog(@"start to generate define file [%@]",[[Param shareInstance] outputFile] );
    [self showResult];
     NSLog(@"end to generate define file" );
}

-(void)readFileList:(NSString *)basePath{
    BOOL isDir = NO;

    NSString *dirName = [basePath lastPathComponent];
    NSArray *excludeNameArr = [[Param shareInstance] excludeNameArr];
    for (NSString *excludeName in excludeNameArr) {
        if ([dirName isEqualToString:excludeName]) {
            [excludeFileDir addObject:basePath];
            return ;
        }
    }
    if([[NSFileManager defaultManager] fileExistsAtPath:basePath isDirectory:&isDir]){
        if (isDir) {
            NSArray *fileArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:nil];
            for (NSString *obj in fileArr) {
                if(![obj hasPrefix:@"."] &&![obj hasSuffix:@".framework"]){
                    [self readFileList:[basePath stringByAppendingPathComponent:obj]];
                }
            };
        } else {
            NSString *filePath = basePath;
            NSString *fileName = [basePath lastPathComponent];
            if([self isAllowFile:fileName]){
                if([fileList count]%20==0){
                    printf("*");
                    fflush(stdout);
                }
                SrcFileModel *fileModel= [[SrcFileModel alloc] init];
                fileModel.fileName = fileName;
                fileModel.filePath = filePath;
                fileModel.isParsed = NO;
                if ([self isImplementFileExist:filePath]) {
                    [fileList addObject:fileModel];
                    [self checkDefine:filePath];
                } else {
                    [excludeFileList addObject:fileModel];
                }

            }
        }
    }
}


-(void)readExcludeFileList:(NSString *)basePath{
    BOOL isDir = NO;

    if([[NSFileManager defaultManager] fileExistsAtPath:basePath isDirectory:&isDir]){
        if (isDir) {
            NSArray *fileArr = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:nil];
            for (NSString *obj in fileArr) {
                if(![obj hasPrefix:@"."] &&![obj hasSuffix:@".framework"] ){
                    [self readFileList:[basePath stringByAppendingPathComponent:obj]];
                }
            };
        } else {
            if ([basePath hasSuffix:@".h"]) {
                NSString *filePath = basePath;
                NSString *fileName = [basePath lastPathComponent];
                if([self isAllowFile:fileName]){
                    if([fileList count]%20==0){
                        printf("*");
                        fflush(stdout);
                    }
                    SrcFileModel *fileModel= [[SrcFileModel alloc] init];
                    fileModel.fileName = fileName;
                    fileModel.filePath = filePath;
                    fileModel.isParsed = NO;
                    [excludeFileList addObject:fileModel];
                    [self checkDefine:filePath];
                }
            }
        }
    }
}

-(BOOL)isImplementFileExist:(NSString *)headerFile {
    if ([headerFile hasSuffix:@".h"]) {
        for (NSString *extention in allowFileExtention) {
            if (![extention isEqualToString:@".h"]) {
                NSString *implementFile = [[headerFile stringByDeletingPathExtension] stringByAppendingString:extention];
                if ([[NSFileManager defaultManager] fileExistsAtPath:implementFile]) {
                    if ([extention isEqualToString:@".m"] || [extention isEqualToString:@".mm"]) {
                        objcFileCount ++;
                    } else {
                        cppFileCount ++;
                    }
                    return YES;
                }

            }
        }
        return NO;
    } else {
        return YES;
    }
}

- (void)checkDefine:(NSString *)filePath{
    DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:filePath];
    NSString *str = [reader readTrimmedLine];
    while (str) {


        NSRange range = [str rangeOfString:@"#\\s*define" options:NSRegularExpressionSearch];
        if(range.location!=NSNotFound){
            str = [str stringByReplacingCharactersInRange:range withString:@"#define"];
        }
        if([str containsString:@"#define"]){
            str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            str =[str stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
            while ([str rangeOfString:@"  "].location!=NSNotFound) {
                str =[str stringByReplacingOccurrencesOfString:@"  " withString:@" "];
            }
            if ([str hasPrefix:@"#define"]) {
                NSArray *contentArr = [str componentsSeparatedByString:@" "];
                if ([contentArr count] >=2) {
                    NSString *name = [contentArr objectAtIndex:1];
                    NSUInteger idx = [name rangeOfString:@"("].location;
                    if (idx!=NSNotFound) {
                        name = [name substringToIndex:idx];

                    }
                    if(![[[DataBase shareInstance] excludeKeywordDic] objectForKey:name]){
                        [[[DataBase shareInstance] excludeKeywordDic] setObject:@"1" forKey:name];
                    }
                    //NSLog(@"define name=%@",name);
                }
            } else {

                // NSLog(@"****************************%@",str);
            }
        } else if([str containsString:@"#ifdef"]){
            str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            str =[str stringByReplacingOccurrencesOfString:@"\t" withString:@" "];
            while ([str rangeOfString:@"  "].location!=NSNotFound) {
                str =[str stringByReplacingOccurrencesOfString:@"  " withString:@" "];
            }
            if ([str hasPrefix:@"#ifdef"]) {
                NSArray *contentArr = [str componentsSeparatedByString:@" "];
                if ([contentArr count] >=2) {
                    NSString *name = [contentArr objectAtIndex:1];
                    NSUInteger idx = [name rangeOfString:@"("].location;
                    if (idx!=NSNotFound) {
                        name = [name substringToIndex:idx];

                    }
                    if(![[[DataBase shareInstance] excludeKeywordDic] objectForKey:name]){
                        [[[DataBase shareInstance] excludeKeywordDic] setObject:@"1" forKey:name];
                    }
                    //NSLog(@"define name=%@",name);
                }
            }
        }

        str = [reader readTrimmedLine];
    }
}

- (void)showResult {
    NSMutableArray *resultVec = [[DataBase shareInstance] queryAllIdentify];

    resultVec=[[resultVec sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }]mutableCopy];

    NSMutableString *resultStr = [NSMutableString new];
    
  //  [resultStr appendString:@"#include <stdlib.h>\n#include <time.h>\n"];
    
    for (int i=0; i<[resultVec count]; i++) {
        NSString *identifyStr = [ resultVec objectAtIndex:i];
        
        if([identifyStr length]>0){

            NSString *word = [[DataBase shareInstance] randomName:1];

            if ([self isIdentifyProperty:identifyStr ])
            {
                [resultStr appendFormat:@"#define %@ %@\n",identifyStr,word ];
                [resultStr appendFormat:@"#define _%@ _%@\n",identifyStr,word ];
                [resultStr appendFormat:@"#define set%@ set%@\n",[StringUtil firstWordToUpperCase:identifyStr],[StringUtil firstWordToUpperCase:word] ];
            }else if ([self isIdentifyClass:identifyStr ])
            {
                [resultStr appendFormat:@"#define %@ %@\n",identifyStr,[StringUtil firstWordToUpperCase:word] ];

            }
            else
            {
                [resultStr appendFormat:@"#define %@ %@\n",identifyStr,word ];

            }
        }
    }
    [resultStr writeToFile:[[Param shareInstance] outputFile] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

-(BOOL)isIdentifyProperty:(NSString *)identifyStr{
    ClassModel *model = [[[DataBase shareInstance] identifyDic] objectForKey:identifyStr];
     if ( model.isPropertyName && ![model.identifyName containsString:@"readonly"] && [[model identifyName] isEqualToString:identifyStr])
        {
            return true;
        }


    return false;

}
-(BOOL)isIdentifyClass:(NSString *)identifyStr {
    ClassModel *model = [[[DataBase shareInstance] identifyDic] objectForKey:identifyStr];
     if ([model.className isEqualToString:identifyStr]) {
            return true;
        }


    return false;


}
-(BOOL)isAllowFile:(NSString *)fileName {
    for (NSString *extention in allowFileExtention) {
        if ([fileName hasSuffix:extention]) {
            return  YES;
        }
    }
    return NO;
}

@end



