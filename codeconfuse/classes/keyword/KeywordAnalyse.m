//
//  KeywordAnalyse.m
//  codeconfuse
//
//  Created by Martin on 2018/5/15.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "KeywordAnalyse.h"
#import "SrcFileModel.h"
#import "CppParser.h"
#import "OCParser.h"
#import "Param.h"

@implementation KeywordAnalyse {
    NSMutableArray *fileList;
    BOOL mIsConfuseObjc;
    BOOL mIsConfuseCpp;
}

- (instancetype)initWithFileList:(NSMutableArray *)fdileList {
    self = [super init];
    if (self) {
        fileList =fdileList;
        mIsConfuseObjc = [[Param shareInstance] isConfuseObjc];
        mIsConfuseCpp = [[Param shareInstance] isConfuseCpp];
        
    }
    return self;
}

-(void)analyse{
    for(int i=0; i<[fileList count]; i++) {
        if(i%10==0){
            printf("*");
            fflush(stdout);
        }
        
        SrcFileModel *file = [fileList objectAtIndex:i];
        //过滤掉已经解析过的文件，还有Pods文件
        if (file.isParsed) {
            continue;
        }
        //warning 有的C++头文件是.hpp的
        if([file.fileName hasSuffix:@".h"]){
            file.headerFilePath = file.filePath;
            [self findCppFileWithFileModel:file];
            [self findMMFileWithFileModel:file];
            [self findMFileWithFileModel:file];
            
            if (mIsConfuseCpp && file.cppFilePath.length > 0) {
                CppParser *cppParser = [[CppParser alloc] init];
                [cppParser parseFile:file];
            }
            
            if(mIsConfuseObjc && [file.mmFilePath length] > 0) {
                OCParser *ocParser=[[OCParser alloc] init];
                [ocParser parseFile:file];
                
                CppParser *cppParser = [[CppParser alloc] init];
                [cppParser parseFile:file];
            }
            
            if(mIsConfuseObjc && [file.mFilePath length] > 0) {
                OCParser *ocParser=[[OCParser alloc] init];
                [ocParser parseFile:file];
            }
        }
        else if(mIsConfuseCpp && ([file.fileName hasSuffix:@".cpp"] || [file.fileName hasSuffix:@".cxx"] || [file.fileName hasSuffix:@".cc"])) {
            [self findHeaderFileWithFileModel:file];
            file.cppFileName = file.fileName;
            file.cppFilePath = file.filePath;
            CppParser *cppParser = [[CppParser alloc] init];
            [cppParser parseFile:file];
        }
        else if(mIsConfuseCpp && [file.fileName hasSuffix:@".c"]) {
            [self findHeaderFileWithFileModel:file];
            file.cFileName = file.fileName;
            file.cFilePath = file.filePath;
            CppParser *cppParser = [[CppParser alloc] init];
            [cppParser parseFile:file];
        }
        else if(mIsConfuseObjc && [file.fileName hasSuffix:@".m"]) {
            file.mFileName = file.fileName;
            file.mFilePath = file.filePath;
            OCParser *ocParser=[[OCParser alloc] init];
            [ocParser parseFile:file];
            
        } else if(mIsConfuseObjc && [file.fileName hasSuffix:@".mm"])
        {
            [self findHeaderFileWithFileModel:file];
            file.mmFileName = file.fileName;
            file.mmFilePath = file.filePath;
            
            OCParser *ocParser=[[OCParser alloc] init];
            [ocParser parseFile:file];
            CppParser *cppParser = [[CppParser alloc] init];
            [cppParser parseFile:file];
        }
        
    }
    printf("\n");
    fflush(stdout);
    
}

-(void)analyseExcludeFile {
    for(int i=0; i<[fileList count]; i++) {
        if(i%10==0){
            printf("*");
            fflush(stdout);
        }
        SrcFileModel *file = [fileList objectAtIndex:i];
        NSLog(@"%@",[file filePath]);
        //过滤掉已经解析过的文件，还有Pods文件
        if (file.isParsed) {
            continue;
        }
        //warning 有的C++头文件是.hpp的
        if([file.fileName hasSuffix:@".h"]){
            file.headerFilePath = file.filePath;
            if (mIsConfuseCpp) {
                CppParser *cppParser = [[CppParser alloc] init];
                [cppParser parseFile:file];
            }

            if(mIsConfuseObjc) {
                OCParser *ocParser=[[OCParser alloc] init];
                [ocParser parseFile:file];
            }
        }

    }
    printf("\n");
    fflush(stdout);

}


-(BOOL)findMFileWithFileModel:(SrcFileModel *)fileModel {
    NSString *ocFileName = [[[fileModel fileName] stringByDeletingPathExtension] stringByAppendingString:@".m"];
    
    for(int i=0; i<[fileList count]; i++)
    {
        SrcFileModel *file = [fileList objectAtIndex:i];
        
        if([file.filePath hasSuffix:[NSString stringWithFormat:@"/%@",ocFileName]])
        {
            fileModel.mFilePath =[file filePath];
            fileModel.mFileName = [file fileName];
            
            file.isParsed = true;
            return true;
        }
    }
    return NO;
}
-(BOOL)findMMFileWithFileModel:(SrcFileModel *)fileModel{
    NSString *ocFileName = [[[fileModel fileName] stringByDeletingPathExtension] stringByAppendingString:@".mm"];
    for(int i=0; i<[fileList count]; i++) {
        SrcFileModel *file = [fileList objectAtIndex:i];
        if([[file filePath] hasSuffix:[NSString stringWithFormat:@"/%@",ocFileName]]){
            fileModel.mmFilePath =[file filePath];
            fileModel.mmFileName = [file fileName];
            
            file.isParsed = true;
            return true;
        }
    }
    return NO;
}
-(BOOL)findCppFileWithFileModel:(SrcFileModel *)fileModel{
    NSString *cppFileName = [[[fileModel fileName] stringByDeletingPathExtension] stringByAppendingString:@".cpp"];
    NSString *ccFileName = [[[fileModel fileName] stringByDeletingPathExtension] stringByAppendingString:@".cc"];
    NSString *cxxFileName = [[[fileModel fileName] stringByDeletingPathExtension] stringByAppendingString:@".cxx"];
    for(int i=0; i<[fileList count]; i++)  {
        SrcFileModel *file = [fileList objectAtIndex:i];
        if([file.filePath hasSuffix:[NSString stringWithFormat:@"/%@",cppFileName]]||[file.filePath hasSuffix:[NSString stringWithFormat:@"/%@",ccFileName]]||[file.filePath hasSuffix:[NSString stringWithFormat:@"/%@",cxxFileName]]) {
            fileModel.cppFilePath =[file filePath];
            fileModel.cppFileName = [file fileName];
            file.isParsed = true;
            return true;
        }
    }
    return NO;
}
-(BOOL)findHeaderFileWithFileModel:(SrcFileModel *)fileModel{
    NSString *ocFileName = [[[fileModel fileName] stringByDeletingPathExtension] stringByAppendingString:@".h"];
    
    for(int i=0; i<[fileList count]; i++) {
        SrcFileModel *file = [fileList objectAtIndex:i];
        if([file.filePath hasSuffix:[NSString stringWithFormat:@"/%@",ocFileName]]) {
            fileModel.headerFilePath =[file filePath];
            fileModel.headerFileName = [file fileName];
            file.isParsed = true;
            return true;
        }
    }
    return NO;
}
@end
