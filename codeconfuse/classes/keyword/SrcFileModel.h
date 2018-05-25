//
//  SrcFileModel.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,FILE_TYPE) {
    FILE_TYPE_M = 1,
    FILE_TYPE_MM =2,
    FILE_TYPE_C =3,
    FILE_TYPE_CPP=4,
    FILE_TYPE_H=5,
    FILE_TYPE_CS=6
};

@interface SrcFileModel : NSObject

@property (nonatomic,assign) NSInteger fileType;
@property (nonatomic,strong) NSString *fileName;
@property (nonatomic,strong) NSString *filePath;
@property (nonatomic,strong) NSString *headerFileName;
@property (nonatomic,strong) NSString *headerFilePath;
@property (nonatomic,strong) NSString *cFileName;
@property (nonatomic,strong) NSString *cFilePath;
@property (nonatomic,strong) NSString *cppFileName;
@property (nonatomic,strong) NSString *cppFilePath;
@property (nonatomic,strong) NSString *mFileName;
@property (nonatomic,strong) NSString *mFilePath;
@property (nonatomic,strong) NSString *mmFileName;
@property (nonatomic,strong) NSString *mmFilePath;
@property (nonatomic) BOOL isParsed;  //是否已进行过语法分析 true-是 false-否
@property (nonatomic) BOOL isInsertGarbageCode;  //是否已进行过插入垃圾代码 true-是 false-否


@end
