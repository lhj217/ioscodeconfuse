//
//  OcParser.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "OCParser.h"
#import "DDFileReader.h"
#import "DataBase.h"
#import "StringUtil.h"

@implementation OCParser

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setDelegates:[NSMutableArray new]];
        [self setImports:[NSMutableArray new]];

    }
    return self;
}


- (int)parseFile:(SrcFileModel *)srcFile
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:[srcFile filePath]])
    {
        return -1;
    }

    if([srcFile.fileName hasSuffix:@".h"] )
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
        //注释里面出现include和import的话会出事囧

        while([self find:headerContent findStr:@"#include" pos:&headerPos]){}//连续读取代码中的include名
        headerPos = 0;
        while([self find:headerContent findStr:@"#import" pos:&headerPos]){}//连续读取代码中的import名
        headerPos = 0;
        while([self find:headerContent findStr:@"@interface" pos:&headerPos]){}//连续读取代码中的类
        headerPos = 0;
        while([self find:headerContent findStr:@"@implementation" pos:&headerPos]){}//连续读取代码中的类



        if([[NSFileManager defaultManager] fileExistsAtPath:[srcFile mFilePath]])
        {
            reader = [[DDFileReader alloc] initWithFilePath:[srcFile mFilePath]];//文件输入流，p是代码路径
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
            NSString *mContent=[self R:mTmp]; //删除全部注释，跟D(temp)不一样的是 D(temp)以\t判断，这个以\r判断
            //注释里面出现include和import的话会出事囧

            while([self find:mContent findStr:@"#include" pos:&mPos]){}//连续读取代码中的include名
            mPos = 0;
            while([self find:mContent findStr:@"#import" pos:&mPos]){}//连续读取代码中的import名
            mPos = 0;
            while([self find:mContent findStr:@"@interface" pos:&mPos]){}//连续读取代码中的类
            mPos = 0;
            while([self find:mContent findStr:@"@implementation" pos:&mPos]){}//连续读取代码中的类
            [self display:srcFile];
            [reader close];
        }
        else
        {
            [self display:srcFile];
        }
    }
    else if([srcFile.fileName hasSuffix:@".m"] || [srcFile.fileName hasSuffix:@".mm"])
    {

        DDFileReader *reader = [[DDFileReader alloc] initWithFilePath:[srcFile filePath]];//文件输入流，p是代码路径
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
        //注释里面出现include和import的话会出事囧
        while([self find:mContent findStr:@"#include" pos:&mPos]){}//连续读取代码中的include名
        mPos = 0;
        while([self find:mContent findStr:@"#import" pos:&mPos]){}//连续读取代码中的import名
        mPos = 0;
        while([self find:mContent findStr:@"@interface" pos:&mPos]){}//连续读取代码中的类
        mPos = 0;
        while([self find:mContent findStr:@"@implementation" pos:&mPos]){}//连续读取代码中的类



        if([[NSFileManager defaultManager] fileExistsAtPath:[srcFile headerFilePath]])
        {

            reader = [[DDFileReader alloc] initWithFilePath:[srcFile headerFilePath]];//文件输入流，p是代码路径
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
            //注释里面出现include和import的话会出事囧

            while([self find:headerContent findStr:@"#include" pos:&headerPos]){}//连续读取代码中的include名
            headerPos = 0;
            while([self find:headerContent findStr:@"#import" pos:&headerPos]){}//连续读取代码中的import名
            headerPos = 0;
            while([self find:headerContent findStr:@"@interface" pos:&headerPos]){}//连续读取代码中的类
            headerPos = 0;
            while([self find:headerContent findStr:@"@implementation" pos:&headerPos]){}//连续读取代码中的类
            [self display:srcFile];

        }
        else
        {
            [self display:srcFile];
        }
    }
    else
    {
        //其他文件格式
    }

    return 0;
}
-(int)judge:(NSString *)s
{
    if([s isEqualToString:@"#include"])
    {
        return OC_INCLUDE;
    }
    else if([s isEqualToString:@"#import"])
    {
        return OC_IMPORT;
    }
    else if([s isEqualToString:@"@interface"])
    {
        return OC_CLASS;
    }
    else if([s isEqualToString:@"@implementation"])
    {
        return OC_IMPLEMENTS;
    }
    else if([s isEqualToString:@"vaiabler"])
    {
        return OC_VARIABLE;
    }
    else if([s isEqualToString:@"function"])
    {
        return OC_IMPORT;
    }
    return OC_UNDEINED;
}

- (NSString *)R:(NSString *)str
{

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
-(bool)is_property_name_exist:(NSString *)functionName propertyList:(NSMutableArray *)propertyList{

    for (NSString *str in propertyList) {
        if ([functionName length]>0 && [functionName isEqualToString:str]) {
            return YES;
        }
    }
    return NO;
}
- (void)display:(SrcFileModel *)fileModel{
    DataBase *database = [DataBase shareInstance];

    NSUInteger pos = 0;
//    for (NSString *include in [self oc_include]) {
//        // include
//
//    }
//
//    for (NSString *imp in [self oc_include])
//    {
//        //import
//    }
    for (OCParser *i in [self classes]) {
        NSString *oc_class_name = [i classname];
        ClassModel *model = [[ClassModel alloc] init];
        model.fileName = fileModel.fileName;
        model.className = oc_class_name;
        model.identifyName = oc_class_name;
        //model.identifyOriginName = oc_class_name;
        model.filePath = fileModel.filePath;
        model.isObjectiveC = true;
        [database insertRecord:model];
        //类名
        if([[i extends] count] != 0)
        {
            //继承
        }
        if([[i delegates] count]!=0)
        {
//            for (NSString *delegate in [i delegates]) {
//                //代理
//            }
        }
        for (NSString *tmp in [i vars]) {
            pos = 0;
            NSString *b = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self ignorespacetab:b pos:&pos];

            if(pos != [b length])
            {
                NSString *varName = [b substringWithRange:NSMakeRange(pos, [b length] - pos)];
                //不混淆xib绑定的属性和方法
                if ([varName containsString:@"IBOutlet"] || [varName containsString:@"IBAction"])
                {
                    continue;
                }

                ClassModel *model = [[ClassModel alloc] init];
                model.fileName = fileModel.fileName;
                model.className = oc_class_name;
                model.identifyName = varName;
               // model.identifyOriginName = varName;
                model.filePath = fileModel.filePath;
                model.isObjectiveC = true;

                if ([self handleObjectiveCIdentify:model])
                {
                    //                    qDebug() << "找到OC变量： " << varName.c_str() << endl;
                    [database insertRecord:model];
                }
            }
        }
        for (NSString *tmp in [i properties]) {
            pos = 0;
            NSString *b = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self ignorespacetab:b pos:&pos];

            if(pos < [b length])
            {
                NSString *propertyName = [b substringWithRange:NSMakeRange(pos, [b length] - pos)];
                //不混淆xib绑定的属性和方法
                if ([propertyName containsString:@"IBOutlet"] || [propertyName containsString:@"IBAction"])
                {
                    continue;
                }

                ClassModel *model = [[ClassModel alloc] init];
                model.fileName = fileModel.fileName;
                model.className = oc_class_name;
                model.identifyName = propertyName;
                model.identifyOriginName = propertyName;
                model.filePath = fileModel.filePath;
                model.isObjectiveC = true;

                if ([self handleObjectiveCIdentify:model])
                {
                    //                    qDebug() << "找到OC属性： " << propertyName.c_str() << endl;
                    [database insertRecord:model];
                }

            }
        }
        for (NSString *tmp in [i functions]) {

            pos = 0;
            NSString *b = [tmp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            [self ignorespacetab:b pos:&pos];

            if(pos != [b length])
            {
                NSString *functionName = [b substringWithRange:NSMakeRange(pos, [b length] - pos)];
                //不混淆xib绑定的属性和方法
                if ([functionName containsString:@"IBOutlet"] || [functionName containsString:@"IBAction"])
                {
                    continue;
                }

                if(![self is_property_name_exist:functionName propertyList:[i properties]])
                {
                    ClassModel *model = [[ClassModel alloc] init];

                    model.fileName = fileModel.fileName;
                    model.className = oc_class_name;
                    model.identifyName = functionName;
                   // model.identifyOriginName = functionName;
                    model.filePath = fileModel.filePath;
                    model.isObjectiveC = true;

                    if ([self handleObjectiveCIdentify:model])
                    {
                        //                        qDebug() << "找到OC方法： " << functionName.c_str() << endl;
                        [database insertRecord:model];
                    }
                }
            }
        }
    }
}

/**
 fI , nI - fI 取得是fI 到 nI-1下标的子串
 */
- (int)find:(NSString *)str findStr:(NSString *)findStr pos:(NSUInteger *)pos{
    int type = [self judge:findStr];
    NSUInteger fI=0,nI=0;//firstIndex,nextIndex
    NSString *temp =@"";
    switch(type)
    {
        case OC_INCLUDE:
        case OC_IMPORT:
        {
            fI = [str rangeOfString:findStr options:NSCaseInsensitiveSearch range:NSMakeRange(*pos, [str length] - *pos)].location;
            //先找到include或import的位置
            if(fI != NSNotFound)
            {
                //判断include和import是否在@interface里面的注释里
                NSUInteger cI =[str rangeOfString:@"@interface " options:NSCaseInsensitiveSearch range:NSMakeRange(*pos, [str length] - *pos)].location;
                if(cI != NSNotFound && cI<fI)
                {
                    return OC_NOTFOUND;
                }
                fI+=type;//跳过include 或import 两个字符串(含一个空格)

                [self ignorespacetab:str pos:&fI];//然后忽略剩余的空格或制表符，如果有
                nI = [str rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(fI, [str length]-fI)].location;//找到分号
                temp = [str substringWithRange:NSMakeRange(fI, nI -fI)];//include名



                //除去多余的制表符和空格
                temp = [self D:temp ch:'\t'];
                temp = [self D:temp ch:' '];

                if(type == OC_INCLUDE){
                    [[self includes] addObject:temp];
                }
                else if(type == OC_IMPORT){
                    [[self imports] addObject:temp];
                }
                //pos位置为分号右边一位。
                *pos = nI + 1;
                return OC_HAVEFOUND;
            }
            else{
                return OC_NOTFOUND;
            }
        }
            break;
        case OC_CLASS:
        {
            while (YES) {


            fI = [str rangeOfString:findStr options:NSCaseInsensitiveSearch range:NSMakeRange(*pos, [str length] - *pos)].location;
            //先找到include或import的位置
            if(fI != NSNotFound)
            {
                fI += strlen("@interface")+1;
                OCParser *theclass = [[OCParser alloc] init];
                NSUInteger lBlock =[str rangeOfString:@"@end" options:NSCaseInsensitiveSearch range:NSMakeRange(fI, [str length] - fI)].location;
                if(lBlock != NSNotFound)
                {
                    ++lBlock;
                    NSString *classline =[str substringWithRange:NSMakeRange(fI, lBlock-fI) ];//获得类信息的第一行

                    NSUInteger begin = 0;

                    NSString *cn = [self findClassName:classline pos:&begin];//classname
                    NSString *en = [self findExtendsName1:classline pos:&begin];
                    NSMutableArray *dn = [self findDelegatesName:classline pos:&begin];
                    begin = 0;
                    NSMutableDictionary *map = [self findPropertiesAndFunctionDeclaresName:str pos:&begin];

                    theclass.classname = cn;
                    [theclass.extends addObject:en];
                    theclass.delegates = dn;
                    theclass.properties = [map valueForKey:@"properties"];
                    theclass.functions = [map valueForKey:@"functions"];
                    [[self classes] addObject:theclass];
                    *pos = fI + 1;//下一个搜索位置从fI开始，因为可能会出现类里面嵌套类的情况
                    return OC_HAVEFOUND;
                }
            }
            else
            {
                return OC_NOTFOUND;

            }
            }
        }
            break;
        case OC_IMPLEMENTS:
        {
            fI = [str rangeOfString:findStr options:NSCaseInsensitiveSearch range:NSMakeRange(*pos, [str length] - *pos)].location;
            //找到"@implementation"
            if(fI != NSNotFound)
            {
                fI += strlen("@implementation")+1;
                OCParser *theclass =[[ OCParser alloc] init];//C类
                NSUInteger lBlock =[str rangeOfString:@"\n" options:NSCaseInsensitiveSearch range:NSMakeRange(fI, [str length] - fI)].location;
                if(lBlock != NSNotFound)
                {
                    ++lBlock;
                    NSString *classline =[str substringWithRange:NSMakeRange(fI, lBlock-fI) ];//获得类信息的第一行
                    NSUInteger begin = 0;
                    NSString *cn = [self findClassName:classline pos:&begin];//classname
                    NSMutableArray *dn = [self findDelegatesName:classline pos:&begin];
                    begin = 0;
                    NSMutableDictionary *map = [self findPropertiesAndFunctionDeclaresName:str pos:&begin];

                    theclass.classname = cn;
                    theclass.delegates = dn;
                    theclass.properties = [map valueForKey:@"properties"];
                    theclass.functions = [map valueForKey:@"functions"];
                    
                    NSUInteger cur_index = lBlock;//current_index
                    NSMutableArray *vi = [self actionscope:str pos:&cur_index];//获取函数和数组变量初始化等 { 和 } 的位置
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
                    for (NSString *b in vs) {
                        sem_index = [b rangeOfString:@";" options:NSBackwardsSearch].location;

                        if( sem_index != NSNotFound)
                        {
                            NSString *cur_var =[b substringWithRange:NSMakeRange(0, sem_index)];
                            cur_var = [cur_var stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            if ([cur_var containsString:@"="]) {
                                cur_var = [cur_var substringToIndex:[cur_var rangeOfString:@"="].location];
                                cur_var  = [cur_var stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                if ([cur_var  containsString:@" "]) {
                                    NSUInteger spaceIndex = [cur_var rangeOfString:@" " options:NSBackwardsSearch].location;
                                    if (spaceIndex!=NSNotFound) {
                                        cur_var = [cur_var substringFromIndex:spaceIndex];
                                        cur_var  = [cur_var stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                                        if ([cur_var length]>0) {
                                            [theclass.vars addObject:cur_var];
                                        }
                                    }
                                }
                            } else
                            if ([cur_var length] > 2)
                            {
                                [theclass.vars addObject:cur_var];
                            }
                        }
                        else
                        {
                            NSString *cur_function_str =[b stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                            cur_function_str = [self D:cur_function_str ch:'#'];
                            if ([cur_function_str length] > 2 && ![cur_function_str containsString:@"@" ])
                            {
                                [theclass.functions addObject:cur_function_str];
                            }
                        }
                    }

                    [[theclass vars]  sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
                        return [obj1 compare:obj2];
                    }];

                    NSMutableDictionary *dic = [NSMutableDictionary new];
                    for (int i= (int)[[theclass vars] count]-1; i>=0; i--) {
                        NSString *tmp = [[theclass vars] objectAtIndex:i];
                        NSString *key = [tmp stringByReplacingOccurrencesOfString:@"@" withString:@""];
                        if ([dic valueForKey:key]==nil) {
                            [dic setObject:key forKey:key];
                        } else {
                            [[theclass vars] removeObjectAtIndex:i];
                        }
                    }


                    [[theclass functions] sortUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
                        return [obj1 compare:obj2];
                    }];

                    dic = [NSMutableDictionary new];
                    for (int i= (int)[[theclass functions] count]-1; i>=0; i--) {
                        NSString *tmp = [[theclass functions] objectAtIndex:i];
                        NSString *key = [tmp stringByReplacingOccurrencesOfString:@"@" withString:@""];
                        if ([dic valueForKey:key]==nil) {
                            [dic setObject:key forKey:key];
                        } else {
                            [[theclass functions] removeObjectAtIndex:i];
                        }
                    }


                    [[self classes] addObject:theclass];
                    *pos = fI + 1;//下一个搜索位置从fI开始，因为可能会出现类里面嵌套类的情况
                    return OC_HAVEFOUND;
                }
            }
            else
            {
                return OC_NOTFOUND;
            }
        }
            break;
        case OC_VARIABLE:
            break;
        case OC_FUNCTION:
            break;
        case OC_UNDEINED:
            break;
    };
    return OC_NOTFOUND;
}

- (NSString *)findClassName:(NSString *)classline pos:(NSUInteger *)begin
{
    [self ignorespacetab:classline pos:begin];
    NSUInteger CNS = *begin;//classname_start
    [self ignorealnum:classline pos:begin];
    NSUInteger CNE = *begin;//classname_end
    if (CNS!=NSNotFound && CNE!=NSNotFound && CNE>CNS) {
        return [classline substringWithRange:NSMakeRange(CNS, CNE-CNS)];
    }
    return nil;

}
-(NSString *)findExtendsName1:(NSString *)str pos:(NSUInteger *)pos{

    NSUInteger es =[str rangeOfString:@":" options:NSCaseInsensitiveSearch range:NSMakeRange(*pos, [str length] - *pos)].location;//extends_start
    if( es != NSNotFound )
    {
        es += 1;
        [self ignorespacetab:str pos:&es];
        NSUInteger ens = es;//extendsname_start
        [self ignorealnum:str pos:&es];

        NSUInteger ene = es;//extendsname_end;
        if (ens!=NSNotFound && ene!=NSNotFound && ene>ens) {
            return [str substringWithRange:NSMakeRange(ens, ene-ens)];
        }
    }
    return @"";
}
- (NSMutableArray *)findDelegatesName:(NSString *)str pos:(NSUInteger *)pos{
    NSMutableArray *delegates = [NSMutableArray new];
    NSUInteger ds = [str rangeOfString:@"<" options:NSCaseInsensitiveSearch range:NSMakeRange(*pos, [str length] - *pos)].location;//delegates_start
    NSUInteger de =  [str rangeOfString:@">" options:NSCaseInsensitiveSearch range:NSMakeRange(*pos, [str length] - *pos)].location;//delegates_end
    if( ds != NSNotFound)
    {
        ds += 1;
        [self ignorespacetab:str pos:&ds];
        NSUInteger ins = ds;//delegates_start
        NSUInteger ine = de;//delegates_end

        if (ins!=NSNotFound && ine != NSNotFound && ine > ins) {
            [delegates addObject:[str substringWithRange:NSMakeRange(ins, ine - ins)]];
        }
    }
    return delegates;
}

- (NSMutableDictionary *)findPropertiesAndFunctionDeclaresName:(NSString *)str pos:(NSUInteger *)pos{
    NSMutableDictionary *propertiesAndFunctionDeclaresMap = [NSMutableDictionary new];
    NSMutableArray *properties = [NSMutableArray new];
    NSMutableArray *functionDeclares=[NSMutableArray new];


    NSString *pattern = @"@property\\s*(.+?)*\\s*(;|\n)";        //匹配规则
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];

    //测试字符串
    NSArray *results = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    for (NSTextCheckingResult *match in results) {

        NSRange matchRange = [match range];
        NSString *propertyName=[str substringWithRange:matchRange];
        propertyName = [propertyName stringByReplacingOccurrencesOfString:@";" withString:@""];
        [properties addObject:propertyName];
    }


    pattern = @"-\\s*\\(.+?\\)*\\s*(.+?)\\{";        //匹配规则
    regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];

    //测试字符串
    results = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    for (NSTextCheckingResult *match in results) {

        NSRange matchRange = [match range];
        NSString *functionName=[str substringWithRange:matchRange];
        functionName  = [functionName stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        functionName  = [functionName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        functionName  = [functionName stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        [functionDeclares addObject:functionName];
    }
    pattern = @"\\+\\s*\\(.+?\\)*\\s*(.+?)\\{";        //匹配规则
    regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];

    //测试字符串
    results = [regex matchesInString:str options:0 range:NSMakeRange(0, str.length)];
    for (NSTextCheckingResult *match in results) {

        NSRange matchRange = [match range];
        NSString *functionName=[str substringWithRange:matchRange];
        functionName  = [functionName stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        functionName  = [functionName stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        functionName  = [functionName stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        [functionDeclares addObject:functionName];
    }
    [propertiesAndFunctionDeclaresMap setObject:properties forKey:@"properties"];
    [propertiesAndFunctionDeclaresMap setObject:functionDeclares forKey:@"functions"];
    return propertiesAndFunctionDeclaresMap;
}



-
(bool)handleObjectiveCIdentify:(ClassModel *)classModel{


    NSString *identifyStr = classModel.identifyName;

    identifyStr = [identifyStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    identifyStr = [identifyStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    [classModel setIdentifyName:identifyStr];
    NSUInteger NS1 = [identifyStr rangeOfString:@"NS_AVAILABLE_IOS"].location;
    if (NS1 != NSNotFound)
    {
        identifyStr = [identifyStr substringToIndex:NS1];
    }

    NSUInteger ATTR = [identifyStr rangeOfString:@"__attribute__"].location;
    if (ATTR != NSNotFound)
    {
        identifyStr = [identifyStr substringToIndex:ATTR];
    }

    NSUInteger UI1 = [identifyStr rangeOfString:@"UI_APPEARANCE_SELECTOR"].location;
    if (UI1 != NSNotFound)
    {
        identifyStr = [identifyStr substringToIndex:UI1];
    }

    identifyStr =  [identifyStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    NSUInteger operator_index = [identifyStr rangeOfString:@" operator"].location;
    NSUInteger operator_index2 = [identifyStr rangeOfString:@"::operator"].location;
    NSUInteger method_index = [identifyStr rangeOfString:@"+"].location;
    NSUInteger method_index2 = [identifyStr rangeOfString:@"-"].location;

    NSUInteger property_index = [identifyStr rangeOfString:@"@property"].location;
    if ( (method_index != NSNotFound || method_index2 != NSNotFound) &&
        (operator_index==NSNotFound && operator_index2==NSNotFound) )//Objective C Method
    {
        if ([identifyStr hasPrefix:@"set"])
        {
            return false;
        }

        NSUInteger first_colon_index = [identifyStr rangeOfString:@":"].location;
        if (first_colon_index != NSNotFound)
        {
            identifyStr = [identifyStr substringToIndex:first_colon_index];
        }

        NSUInteger first_brackets_index = [identifyStr rangeOfString:@")" options:NSBackwardsSearch].location;
        if (first_brackets_index != NSNotFound)
        {
            identifyStr = [identifyStr substringWithRange:NSMakeRange(first_brackets_index+1, [identifyStr length]-first_brackets_index-1)];
        }

    
        identifyStr=[StringUtil deleteSpecialChar:identifyStr];
        if ([StringUtil is_allow_identify_name:identifyStr])
        {

            NSString *method_str = [identifyStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([StringUtil is_allow_identify_name:classModel.className])
            {
                classModel.identifyName = method_str;
                classModel.isMethodName = true;

                return true;
            }
        }
    }
    else if(property_index != NSNotFound)//Objective C Property
    {
        NSUInteger block_index = [identifyStr rangeOfString:@"^"].location;
        if (block_index != NSNotFound)
        {
            identifyStr = [identifyStr substringWithRange:NSMakeRange(block_index+1, [identifyStr length]-block_index-1)];
            NSUInteger first_brackets_index = [identifyStr rangeOfString:@")"].location;
            if (first_brackets_index != NSNotFound)
            {
                identifyStr = [identifyStr substringToIndex:first_brackets_index];
            }
            return false;
        }

        NSUInteger last_space_index = [identifyStr rangeOfString:@" " options:NSBackwardsSearch].location;
        if (last_space_index != NSNotFound)
        {
            identifyStr = [identifyStr substringWithRange:NSMakeRange(last_space_index, [identifyStr length]-last_space_index)];
        }

        identifyStr = [StringUtil deleteSpecialChar:identifyStr];
        if ([StringUtil is_allow_identify_name:identifyStr])
        {
            NSString *property_str =[identifyStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if ([StringUtil is_allow_identify_name:classModel.className])
            {
                classModel.identifyName = property_str;
                classModel.isPropertyName = true;
                return true;
            }
        }
    }
    else
    {
        NSUInteger first_brackets_index = [identifyStr rangeOfString:@"("].location;
        if (first_brackets_index != NSNotFound)
        {
            identifyStr = [identifyStr substringToIndex:first_brackets_index];
        }

        NSUInteger last_space_index = [identifyStr rangeOfString:@" " options:NSBackwardsSearch].location;
        if (last_space_index != NSNotFound)
        {
            identifyStr = [identifyStr substringWithRange:NSMakeRange(last_space_index, [identifyStr length]-last_space_index)];
        }

        [StringUtil deleteSpecialChar:identifyStr];
        if ([StringUtil is_allow_identify_name:identifyStr])
        {
            //            qDebug() << "发现其他1:" << classModel.identifyName.c_str() << identifyStr.c_str();
        }
    }

    return false;
}
@end




