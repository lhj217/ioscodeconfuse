//
//  CppParser.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "CppParser.h"
#import "DDFileReader.h"
#import "DataBase.h"
#import "StringUtil.h"

@implementation CppParser

-(int)parseFile:(SrcFileModel *)srcFile {
    if([srcFile.fileName hasSuffix:@".h"] && srcFile.mFileName.length == 0) {
        DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:[srcFile filePath]];//文件输入流，p是代码路径
        NSMutableString *headerTmp = [NSMutableString new];
        NSUInteger headerPos = 0;
        NSString *headerLineTmp = [reader readLine];
        while(headerLineTmp!=nil)
        {
            headerLineTmp = [headerLineTmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if([headerLineTmp length]>0){
                [headerTmp appendFormat:@"%@\r\n\t",headerLineTmp];
            }
            headerLineTmp = [reader readLine];
        }
        [reader close];

        NSString *headerContent = [self R:headerTmp];//删除全部注释，跟D(temp)不一样的是 D(temp)以\t判断，这个以\r判断
        //注释里面出现include的话会出事囧
        while([self findSubStrAtPos:headerContent findStr:@"#include" pos:&headerPos]){}//连续读取代码中的include名
        while([self findSubStrAtPos:headerContent findStr:@"class " pos:&headerPos]){}//连续读取代码中的类
        while([self findSubStrAtPos:headerContent findStr:@"#template" pos:&headerPos]){}//连续读取代码中的类

        if([[NSFileManager defaultManager] fileExistsAtPath:srcFile.cppFilePath]) {
            srcFile.fileName = srcFile.cppFileName;
            srcFile.filePath = srcFile.cppFilePath;
            reader = [[DDFileReader alloc] initWithFilePath:[srcFile cppFilePath]];//文件输入流，p是代码路径
            NSMutableString *mTmp = [NSMutableString new];
            NSString *mLineTmp= [reader readLine] ;
            NSUInteger mPos = 0;
            while(mLineTmp!=nil)
            {
                mLineTmp = [mLineTmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if([mLineTmp length]>0){
                    [mTmp appendFormat:@"%@\r\n\t",mLineTmp];
                }
                mLineTmp = [reader readLine];
            }
            NSString *mContent=[self R:mTmp];
            //has_class_declare为false的时候，表示虽然是cpp文件，但是cpp文件中不包含class类声明
            //GlobalClassDeclare这个类是默认用于添加形如"class A;"的类声明语句，不是真实类名
            BOOL has_class_declare = false;

            for (CppParser *b in [self classes]) {
                if ([[b classname] hasSuffix:@"GlobalClassDeclare"]) {
                    has_class_declare = true;
                    while([self findFunctionAndVarsOfClass:mContent s:[b classname] pos:&mPos parser:b]){}
                }
            }

            if (!has_class_declare)
            {
                [self findGlobalVarsAndFunctions:mContent];

            }
            [self display:srcFile];
            [reader close];
        }
        else
        {
            [self display:srcFile];

            [reader close];
        }
    }
    else if([srcFile.fileName hasSuffix:@".cpp"] || [srcFile.fileName hasSuffix:@".cxx"] || [srcFile.fileName hasSuffix:@".cc"] || [srcFile.fileName hasSuffix:@".mm"])
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:[srcFile headerFilePath]])
        {
            DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:[srcFile headerFilePath]];//文件输入流，p是代码路径

            NSMutableString *headerTmp = [NSMutableString new];
            NSUInteger headerPos = 0;
            NSString *headerLineTmp = [reader readLine];
            while(headerLineTmp!=nil)
            {
                headerLineTmp = [headerLineTmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if([headerLineTmp length]>0){
                    [headerTmp appendFormat:@"%@\r\n\t",headerLineTmp];
                }
                headerLineTmp = [reader readLine];
            }
            [reader close];

            NSString *headerContent = [self R:headerTmp];//删除全部注释，跟D(temp)不一样的是 D(temp)以\t判断，这个以\r判断
            //注释里面出现include的话会出事囧
            while([self findSubStrAtPos:headerContent findStr:@"#include" pos:&headerPos]){}//连续读取代码中的include名
            headerContent = [self removeInclude:headerContent];
            headerPos = 0;
            while([self findSubStrAtPos:headerContent findStr:@"class " pos:&headerPos]){}//连续读取代码中的类
            headerPos = 0;
            while([self findSubStrAtPos:headerContent findStr:@"#template" pos:&headerPos]){}//连续读取代码中的类

            [reader close];
            reader = [[DDFileReader alloc] initWithFilePath:[srcFile filePath]];//文件输入流，p是代码路径

            NSMutableString *mTmp = [NSMutableString new];
            NSString *mLineTmp= [reader readLine] ;
            NSUInteger mPos = 0;
            while(mLineTmp!=nil)
            {
                mLineTmp = [mLineTmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if([mLineTmp length]>0){
                    [mTmp appendFormat:@"%@\r\n\t",mLineTmp];
                }
                mLineTmp = [reader readLine];
            }
            NSString *mContent=[self R:mTmp];
            //删除全部注释，跟D(temp)不一样的是 D(temp)以\t判断，这个以\r判断

            while([self findSubStrAtPos:mContent findStr:@"#include"pos:&mPos]){}//连续读取代码中的include名

            //has_class_declare为false的时候，表示虽然是cpp文件，但是cpp文件中不包含class类声明
            //GlobalClassDeclare这个类是默认用于添加形如"class A;"的类声明语句，不是真实类名
            BOOL has_class_declare = false;

            for (CppParser *b in [self classes]) {
                if (![[b classname] hasSuffix:@"GlobalClassDeclare"]) {
                    has_class_declare = true;
                    mPos = 0;
                    while([self findFunctionAndVarsOfClass:mContent s:[b classname] pos:&mPos parser:b]){}
                }
            }

            if (!has_class_declare)
            {
                [self findGlobalVarsAndFunctions:mContent];

            }
            [self display:srcFile];
            [reader close];


        }
        else
        {

            DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:[srcFile filePath]];//文件输入流，p是代码路径

            NSMutableString *headerTmp = [NSMutableString new];
            NSUInteger headerPos = 0;
            NSString *headerLineTmp = [reader readLine];
            while(headerLineTmp!=nil)
            {
                headerLineTmp = [headerLineTmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                if([headerLineTmp length]>0){
                    [headerTmp appendFormat:@"%@\r\n\t",headerLineTmp];
                }
                headerLineTmp = [reader readLine];
            }
            [reader close];

            NSString *headerContent = [self R:headerTmp];//删除全部注释，跟D(temp)不一样的是 D(temp)以\t判断，这个以\r判断
            //注释里面出现include的话会出事囧
            while([self findSubStrAtPos:headerContent findStr:@"#include" pos:&headerPos]){}//连续读取代码中的include名
            headerPos = 0;
            while([self findSubStrAtPos:headerContent findStr:@"class " pos:&headerPos]){}//连续读取代码中的类
            headerPos = 0;
            while([self findSubStrAtPos:headerContent findStr:@"#template" pos:&headerPos]){}//连续读取代码中的类
            [self findGlobalVarsAndFunctions:headerContent];
            [self display:srcFile];
            [reader close];

        }
    }
    else if([srcFile.fileName hasSuffix:@".c"])
    {
        DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:[srcFile headerFilePath]];//文件输入流，p是代码路径

        NSMutableString *mTmp = [NSMutableString new];
        NSString *mLineTmp= [reader readLine] ;
        NSUInteger mPos = 0;
        while(mLineTmp!=nil)
        {
            mLineTmp = [mLineTmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if([mLineTmp length]>0){
                [mTmp appendFormat:@"%@\r\n\t",mLineTmp];
            }
            mLineTmp = [reader readLine];
        }
        NSString *mContent=[self R:mTmp];//删除全部注释，跟D(temp)不一样的是 D(temp)以\t判断，这个以\r判断
        //注释里面出现include的话会出事囧
        while([self findSubStrAtPos:mContent findStr:@"#include" pos:&mPos]){}//连续读取代码中的include名
        mPos = 0;
        while([self findSubStrAtPos:mContent findStr:@"class " pos:&mPos]){}//连续读取代码中的类
        mPos = 0;
        while([self findSubStrAtPos:mContent findStr:@"#template" pos:&mPos]){}//连续读取代码中的类
        
        [self findGlobalVarsAndFunctions:mContent];
        [self display:srcFile];
        [reader close];
    }
    else
    {
        //其他文件格式
    }

    return 0;
}
-(int)findFunctionAndVarsOfClass:(NSString *)str s:(NSString *)s pos:(NSUInteger *)pos parser:(CppParser *)theclass {
    NSUInteger fI=0;//firstIndex

    fI =[str rangeOfString:[s stringByAppendingString:@"::"] options:NSCaseInsensitiveSearch range:NSMakeRange(*pos, [str length] - *pos)].location;//找到具体类
    if(fI != NSNotFound)
    {
        NSUInteger lBlock =[str rangeOfString:@"{" options:NSCaseInsensitiveSearch range:NSMakeRange(fI, [str length] - fI)].location  ;// 找{

        fI += [s length];

        NSUInteger cur_index = lBlock;//current_index
        NSMutableArray *vi = [self actionscope:str pos:&cur_index];//获取函数和数组变量初始化等 { 和 } 的位置
        NSString *temp = @"";
        //排除所有作用域内的字符串

        for (int i=0; i<[vi count]-1; i++) {
            NSInteger vit1 = [[vi objectAtIndex:i] integerValue];
            NSInteger vit2 = [[vi objectAtIndex:i+1] integerValue];
            NSUInteger start_index = vit1;
            NSUInteger substr_index = vit2-vit1;

            if (start_index > [str length] || start_index+substr_index > [str length])
            {
                break;
            }
            temp=[temp stringByAppendingString:[str substringWithRange:NSMakeRange(start_index, substr_index)]];
        }
        [self D:temp ch:'#']; //删除 # 号 和 \n 号之间的信息，包括#号，不包括\n号


        NSMutableArray *vs = [self divideByTab:temp];//根据制表符分解字符串
        //根据分号来区分函数和变量
        for (NSString *b in vs) {

            NSString *cur_function_str =[b stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([cur_function_str length] > 2 && [cur_function_str containsString: [s stringByAppendingString:@"::"]] && [cur_function_str containsString:@" "] )
            {
                [theclass.functions addObject:cur_function_str];
            }

        }
        [[theclass functions] sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
            return [obj1 compare:obj2];
        }];

        NSMutableDictionary *dic = [NSMutableDictionary new];
        for (int i= (int)[[theclass functions] count]-1; i>=0; i--) {
            NSString *tmp = [[theclass functions] objectAtIndex:i];
            if ([dic valueForKey:tmp]==nil) {
                [dic setObject:tmp forKey:tmp];
            } else {
                [[theclass functions] removeObjectAtIndex:i];
            }
        }
        *pos = fI + 1;//下一个搜索位置从fI开始，因为可能会出现类里面嵌套类的情况
        return HAVEFOUND;
    }
    else
    {
        return NOTFOUND;
    }
}
- (int)judge:(NSString *)s
{
    if([s isEqualToString:@"#include"])
    {
        return INCLUDE;
    }
    else if([s isEqualToString:@"class "])
    {
        return CLASS;
    }
    else if([s isEqualToString:@"template"])
    {
        return TEMPLATE_CLASS;
    }
    else if([s isEqualToString:@"vaiabler"])
    {
        return VARIABLE;
    }
    else if([s isEqualToString:@"function"])
    {
        return FUNCTION;
    }
    return UNDEINED;
}

- (void)display:(SrcFileModel *)fileModel
{
    DataBase *database =[DataBase shareInstance];
    NSUInteger pos = 0;

    for (CppParser *i in [self classes]) {

        //类名
        NSString *classname = [i classname];
        if([[i extends] count] != 0)
        {

            for (NSString *tmp1 in [i extends]){
                pos = 0;
                NSString  *tmp = [tmp1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                [self ignorespacetab:tmp pos:&pos];
                if(pos != [tmp1 length])
                {
                    //继承
                }
            }
        }
        for (NSString *tmp1 in [i vars]) {

            pos = 0;
            NSString  *tmp = [tmp1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self ignorespacetab:tmp pos:&pos];

            if(pos < [tmp length])
            {
                NSString *varName = [tmp substringWithRange:NSMakeRange(pos, [tmp length]-pos)];
                ClassModel *model = [[ClassModel alloc] init];
                model.fileName = fileModel.fileName;
                model.className = classname;
                model.identifyName = varName;
                //model.identifyOriginName = varName;
               // model.filePath = fileModel.filePath;
                if ([self handleCppIdentify:model])
                {
                    [database insertRecord:model];
                }
            }
        }
        for (NSString *tmp1 in [i functions]) {

            pos = 0;
            NSString *tmp = [tmp1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self ignorespacetab:tmp pos:&pos];

            if(pos < [tmp length])
            {
                NSString *functionName = [tmp substringWithRange:NSMakeRange(pos, [tmp length]-pos)];
                ClassModel *model = [[ClassModel alloc] init];
                model.fileName = fileModel.fileName;
                model.className = classname;
                model.identifyName = functionName;
                //model.identifyOriginName = functionName;
                model.filePath = fileModel.filePath;

                if ([self handleCppIdentify:model])
                {
                    [database insertRecord:model];
                }
            }
        }
    }
}

-(int)findGlobalVarsAndFunctions:(NSString *)str{
    CppParser *tempC= [[CppParser alloc] init] ;
    tempC.classname = @"GlobalVarsAndFunctions";

    NSUInteger lBlock =[str rangeOfString:@"{"].location ;// 找{
    NSUInteger cur_index = lBlock;
    NSMutableArray *vi =[self actionscope:str pos:&cur_index];////获取函数和数组变量初始化等 { 和 } 的位置
    NSString *temp = @"";
    //排除所有作用域内的字符串
    for (int i=0; i<[vi count]-1; i++) {
        NSInteger vit1 = [[vi objectAtIndex:i] integerValue];
        NSInteger vit2 = [[vi objectAtIndex:i+1] integerValue];
        NSUInteger start_index = vit1;
        NSUInteger substr_index = vit2-vit1;

        if (start_index > [str length] || start_index+substr_index > [str length])
        {
            break;
        }
        temp=[temp stringByAppendingString:[str substringWithRange:NSMakeRange(start_index, substr_index)]];
    }

    NSMutableArray *vs = [self divideByTab:temp];//根据制表符分解字符串
    NSUInteger sem_index=NSNotFound;//分号下标
    //根据分号来区分函数和变量
    for (NSString *b in vs) {
        sem_index = [b rangeOfString:@";" options:NSBackwardsSearch].location;

        if( sem_index != NSNotFound)
        {
            NSString *cur_var =[b substringWithRange:NSMakeRange(0, sem_index)];
            cur_var = [cur_var stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([cur_var length] > 2)
            {
                [tempC.vars addObject:cur_var];
            }
        }
        else
        {
            NSString *cur_function_str =[b stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([cur_function_str length] > 2 )
            {
                [tempC.functions addObject:cur_function_str];
            }
        }
    }
    [[self classes ] addObject:tempC];

    if([tempC.vars count] > 0 || [tempC.functions count] > 0)
    {
        return HAVEFOUND;
    }
    else
    {
        return NOTFOUND;
    }
}




/**
 fI , nI - fI 取得是fI 到 nI-1下标的子串
 */
- (int)findSubStrAtPos:(NSString *)str findStr:(NSString *)findStr pos:(NSUInteger *)pos
{
    int type = [self judge:findStr];
    NSUInteger fI=0;//firstIndex,
    switch(type)
    {
        case INCLUDE:
        {
            NSString *pattern = @"#include\\s*(.+?)*\\s*(;|\n)";        //匹配规则
            NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];

            //测试字符串
            NSArray *results = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
            for (NSTextCheckingResult *match in results) {

                NSRange matchRange = [match range];
                NSString *includeStr=[str substringWithRange:matchRange];
                includeStr = [includeStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                includeStr = [includeStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                includeStr = [includeStr stringByReplacingOccurrencesOfString:@"#include " withString:@""];
                [[self includes] addObject:includeStr];
            }
            return NOTFOUND;

        }
            break;
        case CLASS:
        {
            fI = [str rangeOfString:findStr options:NSCaseInsensitiveSearch range:NSMakeRange(*pos, [str length] - *pos)].location;
            if(fI != NSNotFound)
            {
                fI += [@"class " length];

                CppParser *theclass = [[CppParser alloc] init];//C类
                NSUInteger lBlock = [str rangeOfString:@"{" options:NSCaseInsensitiveSearch range:NSMakeRange(fI, [str length] - fI)].location;// 找{
                if(lBlock != NSNotFound)
                {
                    ++lBlock;
                    NSString *classline= [str substringWithRange:NSMakeRange(fI, lBlock-fI)]; //获得类信息的第一行
                    NSUInteger begin = 0;
                    NSString *cn = [self findClassName:classline pos:&begin];//classname
                    NSMutableArray *en = [self findExtendsName:classline pos:&begin];
                    NSString *classname = [cn stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    if ([classname length] <= 0)
                    {
                        return NOTFOUND;
                    }

                    theclass.classname = cn;
                    theclass.extends = en;

                    NSUInteger cur_index = lBlock;//current_index
                    NSMutableArray *vi =[self actionscope:str pos:&cur_index];
                    NSString *temp = @"";
                    //排除所有作用域内的字符串
                    for (int i=0; i<[vi count]-1; i++) {
                        NSInteger vit1 = [[vi objectAtIndex:i] integerValue];
                        NSInteger vit2 = [[vi objectAtIndex:i+1] integerValue];
                        NSUInteger index = vit1;
                        NSUInteger length = vit2-vit1;

                        if (index > [str length] || index+length >= [str length])
                        {
                            break;
                        }
                        temp=[temp stringByAppendingString:[str substringWithRange:NSMakeRange(index, length)]];
                    }

                    NSMutableArray *vs = [self divideByTab:temp];//根据制表符分解字符串
                    NSUInteger sem_index=NSNotFound;//分号下标
                    //根据分号来区分函数和变量
                    for (NSString *tmp in vs) {
                       NSString *b = [tmp stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                        b = [b stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                        sem_index = [b rangeOfString:@";" options:NSBackwardsSearch].location;

                        if( sem_index != NSNotFound)
                        {
                            NSString *cur_var =[b substringWithRange:NSMakeRange(0, sem_index)];
                            cur_var = [cur_var stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if ([cur_var length] > 2)
                            {
                                [theclass.vars addObject:cur_var];
                            }
                        }
                        else
                        {
                            NSString *cur_function_str =[b stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if ([cur_function_str length] > 2  && [b rangeOfString:@"("].location!=NSNotFound)
                            {
                                [theclass.functions addObject:cur_function_str];
                            }
                        }
                    }

                    [[self classes] addObject:theclass];
                    *pos = fI + 1;//下一个搜索位置从fI开始，因为可能会出现类里面嵌套类的情况
                    return HAVEFOUND;
                }
            }
            else
            {
                return NOTFOUND;
            }
        }
        case TEMPLATE_CLASS:
        {
            fI = [str rangeOfString:findStr options:NSCaseInsensitiveSearch range:NSMakeRange(*pos, [str length] - *pos)].location; //找到"template"
            if(fI != NSNotFound)
            {
                fI += strlen("template");
                CppParser *theclass = [[CppParser alloc] init];//C类
                NSUInteger lBlock = [str rangeOfString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(fI, [str length] - fI)].location;// 找template<>的>结束符
                if(lBlock != NSNotFound)
                {
                    ++lBlock;
                    NSString *classline = [str substringWithRange:NSMakeRange(fI,lBlock-fI)];//获得类信息的第一行
                    NSUInteger begin = 0;
                    NSString *cn = [self findClassName:classline pos:&begin];//classname
                    NSMutableArray *en = [self findExtendsName:classline pos:&begin];//extendsname


                    theclass.classname = cn;
                    theclass.extends = en;

                    NSUInteger cur_index = lBlock;//current_index
                    NSMutableArray *vi = [self actionscope:str pos:&cur_index];//获取函数和数组变量初始化等 { 和 } 的位置
                    NSString *temp = @"";
                    //排除所有作用域内的字符串
                    for (int i=0; i<[vi count]-1; i++) {
                        NSInteger vit1 = [[vi objectAtIndex:i] integerValue];
                        NSInteger vit2 = [[vi objectAtIndex:i+1] integerValue];
                        NSUInteger start_index = vit1;
                        NSUInteger substr_index = vit2-vit1;

                        if (start_index > [str length] || start_index+substr_index > [str length])
                        {
                            break;
                        }
                        temp=[temp stringByAppendingString:[str substringWithRange:NSMakeRange(start_index, substr_index)]];
                    }
                    NSMutableArray *vs = [self divideByTab:temp];//根据制表符分解字符串
                    NSUInteger sem_index=NSNotFound;//分号下标
                    //根据分号来区分函数和变量
                    for (NSString *b in vs) {
                        sem_index = [b rangeOfString:@";" options:NSBackwardsSearch].location;

                        if( sem_index != NSNotFound)
                        {
                            NSString *cur_var =[b substringWithRange:NSMakeRange(0, sem_index)];
                            cur_var = [cur_var stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if ([cur_var length] > 2)
                            {
                                [theclass.vars addObject:cur_var];
                            }
                        }
                        else
                        {
                            NSString *cur_function_str =[b stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if ([cur_function_str length] > 2 )
                            {
                                [theclass.functions addObject:cur_function_str];
                            }
                        }
                    }


                    NSUInteger template_class_begin = [cn rangeOfString:@"<"].location;
                    NSUInteger template_class_end =[cn rangeOfString:@">"].location;
                    if (template_class_begin!=NSNotFound || template_class_end!=NSNotFound)
                    {
                        //do nothing
                    }
                    else
                    {
                        [[self classes] addObject:theclass];
                    }
                    *pos = fI + 1;//下一个搜索位置从fI开始，因为可能会出现类里面嵌套类的情况
                    return HAVEFOUND;
                }
            }
            else
            {
                return NOTFOUND;
            }
        }
            break;
        case VARIABLE:
            break;
        case FUNCTION:
            break;
        case UNDEINED:
            break;
    };
    return NOTFOUND;
}



- (NSString *)findClassName:(NSString *)classline pos:(NSUInteger *)pos
{
    NSString *classname = classline;

    classname  = [classname stringByReplacingOccurrencesOfString:@"  " withString:@""];
    classname  = [classname stringByReplacingOccurrencesOfString:@"\r\n\t" withString:@""];

    NSUInteger decorate_start = [classname rangeOfString:@"public"].location;//找修饰符的位置
    NSString *result = classname;
    while (decorate_start != NSNotFound)
    {
        NSUInteger nest_class_index = [result rangeOfString:@"public:class"].location;
        NSUInteger block_index = [result rangeOfString:@"{"].location;
        if (nest_class_index != NSNotFound)//内部类
        {
            NSString *nest_classname = [classname substringWithRange:NSMakeRange(nest_class_index+strlen("public:class"), block_index-nest_class_index-strlen("public:class"))];
            nest_classname = [nest_classname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
            return nest_classname;
        }
        result = [result stringByReplacingCharactersInRange:NSMakeRange(decorate_start, strlen("public"))withString: @""];
        decorate_start = [result rangeOfString:@"public"].location;
    }
    result = classname;
    decorate_start =[result rangeOfString:@"protected"].location;//找修饰符的位置
    while (decorate_start != NSNotFound)
    {
        NSUInteger nest_class_index =[result rangeOfString:@"protected:class"].location;
        NSUInteger block_index = [result rangeOfString:@"{"].location;

        if (nest_class_index != NSNotFound)//内部类
        {
            NSString *nest_classname = [classname substringWithRange:NSMakeRange(nest_class_index+strlen("protected:class"), block_index-nest_class_index-strlen("protected:class"))];
            nest_classname = [nest_classname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ];
            return nest_classname;
        }
        result = [classname stringByReplacingCharactersInRange:NSMakeRange(decorate_start, strlen("protected:class"))withString: @""];
        decorate_start = [result rangeOfString:@"protected:class"].location;
    }

    NSUInteger extends_colon_index =  [result rangeOfString:@":"].location;
    NSUInteger not_extends_colon_index =  [result rangeOfString:@"::"].location;
    NSString  *curr_classline = result;

    if (extends_colon_index != NSNotFound && not_extends_colon_index == NSNotFound)
    {
        curr_classline= [result substringWithRange:NSMakeRange(0, extends_colon_index)];
        curr_classline = [curr_classline stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSUInteger space_index = [curr_classline rangeOfString:@" " options:NSBackwardsSearch ].location;
        NSString *result_classname = curr_classline;
        if (space_index != NSNotFound)
        {
            curr_classline = [curr_classline substringWithRange:NSMakeRange(space_index, curr_classline.length-space_index)];
            result_classname =[curr_classline stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
//        else
//        {
//            result_classname = [curr_classline substringWithRange:NSMakeRange(0, extends_colon_index)];
//            result_classname = [result_classname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//        }

        return result_classname;
    }

    NSUInteger space_index = [curr_classline rangeOfString:@" "].location;
    NSUInteger block_index = [curr_classline rangeOfString:@"{" options:NSBackwardsSearch].location;
    if (space_index != NSNotFound && block_index != NSNotFound)
    {
        NSString  *result_classname = [curr_classline substringWithRange:NSMakeRange(space_index, block_index-space_index)];
        result_classname = [result_classname stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        return result_classname;
    }
    [self ignorespacetab:curr_classline pos:pos];

    NSUInteger CNS = *pos;//classname_start
    [self ignorealnum:curr_classline pos:pos];
    NSUInteger CNE = *pos;//classname_end

    curr_classline = [curr_classline substringWithRange:NSMakeRange(CNS,CNE-CNS)];

    return curr_classline;
}

-(NSMutableArray *)findExtendsName:(NSString *)str pos:(NSUInteger *)pos
{
    NSMutableArray  *extends_name = [NSMutableArray new];

    NSString *curr_str = str;


    NSUInteger extends_start = [curr_str rangeOfString:@":" options:NSCaseInsensitiveSearch range:NSMakeRange(*pos, [curr_str length]-*pos)].location ;//extends_start

    if (extends_start!=NSNotFound) {


    NSUInteger extends_end = [curr_str rangeOfString:@"\r\n\t" options:NSCaseInsensitiveSearch range:NSMakeRange(extends_start, [curr_str length]-extends_start)].location;//extends_end

    if( extends_end != NSNotFound && extends_end>extends_start)
    {
        NSString *result = [curr_str substringWithRange:NSMakeRange(extends_start+1, extends_end-extends_start-1)];
        NSArray *extends = [result componentsSeparatedByString:@","];
        for (NSString *curr_extend_str in extends) {
            NSUInteger public_start = [curr_extend_str rangeOfString:@"public"].location;//找修饰符的位置
            NSUInteger protected_start =[curr_extend_str rangeOfString:@"protected"].location;//找修饰符的位置
            NSUInteger nest_class_index =[curr_extend_str rangeOfString:@"class "].location;
            if (public_start != NSNotFound && nest_class_index == NSNotFound)
            {
                NSString *curr_extend_str1 = [curr_extend_str stringByReplacingOccurrencesOfString:@"public" withString:@""];

                [extends_name addObject: [curr_extend_str1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
            else if (protected_start != NSNotFound && nest_class_index == NSNotFound)
            {
                NSString *curr_extend_str1 = [curr_extend_str stringByReplacingOccurrencesOfString:@"protected" withString:@""];

                [extends_name addObject: [curr_extend_str1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
            }
        }
        return extends_name;
    }

    }
    return extends_name;
}


- (int)findGlobalClassDeclares:(NSString *)str
{
    CppParser *parser = [[CppParser alloc] init];
    parser.classname = @"GlobalClassDeclare";
    NSMutableArray *vs = [self divideByTab:str];//根据制表符分解字符串
    //根据分号来区分函数和变量
    for (int i=0; i< [vs count]; i++) {
        NSString *it_str = [vs objectAtIndex:i];

        NSRange range =[it_str rangeOfString:@";" options:NSBackwardsSearch];
        if( range.location!=NSNotFound)
        {
            NSString *cur_var = [it_str substringToIndex:range.location];
            cur_var = [cur_var stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

            NSRange classRange = [cur_var rangeOfString:@"class "];
            NSRange friendRange = [cur_var rangeOfString:@"friend "];
            if (classRange.location != NSNotFound && friendRange.location!=NSNotFound)
            {
                classRange = friendRange;
            }

            if (cur_var.length > 2 && classRange.location!=NSNotFound)
            {
                NSString *class_declare_str = [cur_var stringByAppendingString:@";"];
                NSRange rangeTmp = [str rangeOfString:class_declare_str];

                [[parser vars] addObject:cur_var];

                if (rangeTmp.location != NSNotFound)
                {
                    str = [str stringByReplacingCharactersInRange:NSMakeRange(rangeTmp.location, range.location-classRange.location+1) withString:@""];
                }
            }
        }
    }

    [[self classes] addObject:parser];

    if([parser.vars count] > 0 || [parser.functions count] > 0)
    {
        return HAVEFOUND;
    }
    else
    {
        return NOTFOUND;
    }
}
- (NSString *)R:(NSString *)str {

    NSUInteger index = 0;
    do
    {
        index = [str rangeOfString:@"://"].location;// 找到 :// 的位置 各种协议中包含的字符串, 防止和//注释混淆
        if(index != NSNotFound){
            NSUInteger index_quote = [str rangeOfString:@"\"|\n" options:NSRegularExpressionSearch range:NSMakeRange(index, [str length] - index)].location;//找到 双引号" 的位置
            if(index_quote != NSNotFound)
            {
                str  = [str stringByReplacingCharactersInRange:NSMakeRange(index,index_quote + 1 - index ) withString:@""];
            }
            else
            {
                break;
            }
        }
        else break;
    }while(1);


    while(1)
    {
        if([str rangeOfString:@"//"].location!=NSNotFound)
        {
            NSUInteger pos = [str rangeOfString:@"//"].location;
            NSUInteger end =[str rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(pos, [str length]-pos)].location;//从pos位置开始寻找
            NSUInteger len = end - pos;
            str = [str stringByReplacingCharactersInRange:NSMakeRange(pos, len) withString:@""];//删除pos位置开始后长度为len的字符串
        }
        else if([str rangeOfString:@"/*"].location!=NSNotFound)
        {
            NSUInteger pos = [str rangeOfString:@"/*"].location;
            NSUInteger end =[str rangeOfString:@"*/" options:NSCaseInsensitiveSearch range:NSMakeRange(pos, [str length]-pos)].location;//从pos位置开始寻找
            NSUInteger len = end - pos+2;
            str = [str stringByReplacingCharactersInRange:NSMakeRange(pos, len) withString:@""];//删除pos位置开始后长度为len的字符串
        }
        else
        {
            break;
        }
    }


    while(1)
    {
        if([str rangeOfString:@"#define"].location!=NSNotFound)
        {
            NSUInteger pos = [str rangeOfString:@"#define"].location;
            NSUInteger end =[str rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(pos, [str length]-pos)].location;//从pos位置开始寻找
            NSUInteger len = end - pos;
            str = [str stringByReplacingCharactersInRange:NSMakeRange(pos, len) withString:@""];//删除pos位置开始后长度为len的字符串
        }else {
            break;
        }
    }
    str = [str stringByReplacingOccurrencesOfString:@"class\t" withString:@"class "];
    str = [str stringByReplacingOccurrencesOfString:@"friend\t" withString:@"friend "];
    str = [str stringByReplacingOccurrencesOfString:@", " withString:@","];
    [self findGlobalClassDeclares:str];
    return str;
}

- (NSString *)removeInclude:(NSString *)str{
    while(1)
    {
        if([str rangeOfString:@"#"].location!=NSNotFound)
        {
            NSUInteger pos = [str rangeOfString:@"#"].location;
            NSUInteger end =[str rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(pos, [str length]-pos)].location;//从pos位置开始寻找
            NSUInteger len = end - pos;
            str = [str stringByReplacingCharactersInRange:NSMakeRange(pos, len) withString:@""];//删除pos位置开始后长度为len的字符串
        }
        else
        {
            break;
        }
    }
    return str;
}



@end


