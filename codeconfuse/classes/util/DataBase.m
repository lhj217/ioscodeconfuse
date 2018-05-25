//
//  DataBase.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "DataBase.h"
#import "StringUtil.h"
#import "DDFileReader.h"
#import "Param.h"

@implementation DataBase {
    NSMutableDictionary *existNameDir;
    NSMutableDictionary *classDic;
    NSMutableDictionary *backupClassDic;
}
static DataBase* _instance = nil;

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
        [self reset];
        [self setExcludeKeywordDic:[NSMutableDictionary new]];
        [self setDictArr:[NSMutableArray new]];
        [self loadReservedKeywords];
        [self loadDict];
    }
    return self;
}

-(void)reset {
    [self setIdentifyDic:[NSMutableDictionary new]];
    existNameDir = [NSMutableDictionary new];
    classDic = [NSMutableDictionary new];
    backupClassDic= [NSMutableDictionary new];
}
-(void)loadDict {
    NSString *dictionaryFile = [[Param shareInstance] dictionaryFile];
    DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:dictionaryFile];
    NSString *line = [reader readLine];
    while(line!=nil){
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([line length]>1) {
            [[self dictArr] addObject:line];
        }

        line = [reader readLine];
    }
}

-(void)addClass:(ClassInfo *)ci {
    if (ci) {
        NSString *key = [NSString stringWithFormat:@"%ld",[ci classType]];
        NSMutableArray *classTypeArr = [classDic valueForKey:key];
        NSMutableArray *backupClassTypeArr = [backupClassDic valueForKey:key];
        if (classTypeArr==nil) {
            classTypeArr = [NSMutableArray new];
            [classDic setObject:classTypeArr forKey:key];
            backupClassTypeArr = [NSMutableArray new];
            [backupClassDic setObject:backupClassTypeArr forKey:key];
        }
        [classTypeArr addObject:ci];
        [backupClassTypeArr addObject:ci];
    }
}

- (NSMutableArray *)classArrByClassType:(NSInteger)classType {
    NSString *key = [NSString stringWithFormat:@"%ld",classType];
    NSMutableArray *classTypeArr = [classDic valueForKey:key];
    if (classTypeArr==nil || [classTypeArr count]==0) {
        classTypeArr =[[backupClassDic valueForKey:key] mutableCopy];
    }
    return classTypeArr;
}


- (void)loadReservedKeywords{
    DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:[[Param shareInstance] keywordFile ] ];
    NSString *line = [reader readTrimmedLine];
    while (line!=nil) {
        if ([line length]>0) {
            [[self excludeKeywordDic] setObject:@"1" forKey:line];
        }
        line = [reader readTrimmedLine];
    }
}

- (NSString *)randomName:(NSUInteger)length {
    NSString *name = [self getRandomName:length];
    while ([existNameDir objectForKey:name]) {
        name = [self getRandomName:length];
    }
    [existNameDir setObject:@"1" forKey:name];
    return name;
}
- (NSString *)getRandomName:(NSInteger )length{
    NSMutableArray *dictArr = [[DataBase shareInstance] dictArr];
    int index1 = arc4random()%[dictArr count];
    NSString *str1 = [[dictArr objectAtIndex:index1] lowercaseString];
    
    int index2 = arc4random()%[dictArr count];
    NSString *str2 = [[dictArr objectAtIndex:index2] lowercaseString];
    str2 = [StringUtil firstWordToUpperCase:str2];
    
    int index3 = arc4random()%[dictArr count];
    NSString *str3 = [[dictArr objectAtIndex:index3] lowercaseString];
    str3 = [StringUtil firstWordToUpperCase:str3];
    
    NSString *str = [NSString stringWithFormat:@"%@%@%@",str1,str2,str3];
    while ([str length] < length) {
        int index = arc4random()%[dictArr count];
        NSString *tmp = [[dictArr objectAtIndex:index] lowercaseString];
        tmp = [StringUtil firstWordToUpperCase:tmp];
        str = [str stringByAppendingString:tmp];
    }
    
    return str;
}

- (NSString *)randomWord{
    NSMutableArray *dictArr = [[DataBase shareInstance] dictArr];
    int index = arc4random()%[dictArr count];
    NSString *name = [dictArr objectAtIndex:index];
    while ([existNameDir objectForKey:name]) {
        index = arc4random()%[dictArr count];
        name = [dictArr objectAtIndex:index];
    }
    [existNameDir setObject:@"1" forKey:name];
    return name;
}

- (NSString *)randomWord:(NSUInteger)wordNum{
    if (wordNum<=0) {
        wordNum = 1;
    }
    NSString *name = @"";
    for (int i=0; i<wordNum; i++) {
        NSMutableArray *dictArr = [[DataBase shareInstance] dictArr];
        int index = arc4random()%[dictArr count];
        NSString *tmp = [[dictArr objectAtIndex:index] lowercaseString];
        name = [name stringByAppendingString:[StringUtil firstWordToUpperCase:tmp]];

    }
    while ([existNameDir objectForKey:name]) {
        name = @"";
        for (int i=0; i<wordNum; i++) {
            NSMutableArray *dictArr = [[DataBase shareInstance] dictArr];
            int index = arc4random()%[dictArr count];
            NSString *tmp = [[dictArr objectAtIndex:index] lowercaseString];
            name = [name stringByAppendingString:[StringUtil firstWordToUpperCase:tmp]];

        }
    }
    [existNameDir setObject:@"1" forKey:name];
    return name;
}

-(BOOL)isAllowIdentify:(NSString *) str{
    NSRange range= [str rangeOfString:@"^[a-zA-Z_][a-zA-Z0-9_]{1,}$" options:NSRegularExpressionSearch];
    if (range.location!=NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)insertRecord:(ClassModel *)classModel {

    if ([classModel identifyName]) {

        NSString *className = [[classModel className] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *identifyName = [[classModel identifyName] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (! [self isAllowIdentify:identifyName]) {
            return NO;
        }
        NSString *setProperty=@"888888888888888888";
        NSString *underLineProperty=@"999999999999999999";

        if (classModel.isPropertyName) {
            setProperty = [@"set" stringByAppendingFormat:@"%@%@",[[identifyName substringToIndex:1] uppercaseString],[identifyName substringFromIndex:1] ];
            underLineProperty = [@"_" stringByAppendingString:identifyName];
        }
        if ([[self excludeKeywordDic] objectForKey:identifyName] || [[self excludeKeywordDic] objectForKey:className] || [[self excludeKeywordDic] objectForKey:setProperty] || [[self excludeKeywordDic] objectForKey:underLineProperty]) {
            return NO;
        }
        //[[self m_modelVec] addObject:classModel];
        if (![[self identifyDic] objectForKey:identifyName]) {
            [[self identifyDic] setObject:classModel forKey:identifyName];
        }

        //类名
        if (classModel.isObjectiveC)
        {
            if ([StringUtil is_allow_identify_name:classModel.className])
            {
                if (![[self identifyDic] objectForKey:className]) {
                    [[self identifyDic] setObject:classModel forKey:className];
                }

            }
        }
        else
        {
            if (![[self identifyDic] objectForKey:className]) {
                [[self identifyDic] setObject:classModel forKey:className];
            }
        }
    }

    return YES;
}

- (NSMutableArray *)queryAllIdentify {
    return [[[self identifyDic] allKeys] mutableCopy];
}
@end

