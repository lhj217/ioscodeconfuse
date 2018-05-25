//
//  DDFileReader.m
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import "DDFileReader.h"
#import "DataBase.h"

//
//  DDFileReader.m
//  PBX2OPML
//
//  Created by michael isbell on 11/6/11.
//  Copyright (c) 2011 BlueSwitch. All rights reserved.
//

//DDFileReader.m

#import "DDFileReader.h"

@interface NSData (DDAdditions)

- (NSRange) rangeOfData_dd:(NSData *)dataToFind;

@end

@implementation NSData (DDAdditions)

- (NSData *)UTF8Data
{
    //保存结果
    NSMutableData *resData = [[NSMutableData alloc] initWithCapacity:self.length];

    //无效编码替代符号(常见 � □ ?)
    NSData *replacement = [@"�" dataUsingEncoding:NSUTF8StringEncoding];

    uint64_t index = 0;
    const uint8_t *bytes = self.bytes;

    while (index < self.length)
    {
        uint8_t len = 0;
        uint8_t header = bytes[index];

        //单字节
        if ((header&0x80) == 0)
        {
            len = 1;
        }
        //2字节(并且不能为C0,C1)
        else if ((header&0xE0) == 0xC0)
        {
            if (header != 0xC0 && header != 0xC1)
            {
                len = 2;
            }
        }
        //3字节
        else if((header&0xF0) == 0xE0)
        {
            len = 3;
        }
        //4字节(并且不能为F5,F6,F7)
        else if ((header&0xF8) == 0xF0)
        {
            if (header != 0xF5 && header != 0xF6 && header != 0xF7)
            {
                len = 4;
            }
        }

        //无法识别
        if (len == 0)
        {
            [resData appendData:replacement];
            index++;
            continue;
        }

        //检测有效的数据长度(后面还有多少个10xxxxxx这样的字节)
        uint8_t validLen = 1;
        while (validLen < len && index+validLen < self.length)
        {
            if ((bytes[index+validLen] & 0xC0) != 0x80)
                break;
            validLen++;
        }

        //有效字节等于编码要求的字节数表示合法,否则不合法
        if (validLen == len)
        {
            [resData appendBytes:bytes+index length:len];
        }else
        {
            [resData appendData:replacement];
        }

        //移动下标
        index += validLen;
    }

    return resData;
}

- (NSRange) rangeOfData_dd:(NSData *)dataToFind {

    const void * bytes = [self bytes];
    NSUInteger length = [self length];

    const void * searchBytes = [dataToFind bytes];
    NSUInteger searchLength = [dataToFind length];
    NSUInteger searchIndex = 0;

    NSRange foundRange = {NSNotFound, searchLength};
    for (NSUInteger index = 0; index < length; index++) {
        if (((char *)bytes)[index] == ((char *)searchBytes)[searchIndex]) {
            //the current character matches
            if (foundRange.location == NSNotFound) {
                foundRange.location = index;
            }
            searchIndex++;
            if (searchIndex >= searchLength) { return foundRange; }
        } else {
            searchIndex = 0;
            foundRange.location = NSNotFound;
        }
    }
    return foundRange;
}

@end

@implementation DDFileReader
@synthesize lineDelimiter, chunkSize;

- (id) initWithFilePath:(NSString *)aPath {
    if (self = [super init]) {
        fileHandle = [NSFileHandle fileHandleForReadingAtPath:aPath];
        if (fileHandle == nil) {
            return nil;
        }

        lineDelimiter = @"\n";
        currentOffset = 0ULL; // ???
        chunkSize = 10;
        [fileHandle seekToEndOfFile];
        totalFileLength = [fileHandle offsetInFile];
        //we don't need to seek back, since readLine will do that.
    }
    return self;
}

- (void) dealloc {
    [fileHandle closeFile];
    currentOffset = 0ULL;

}
- (void)close {
    [fileHandle closeFile];
    currentOffset = 0ULL;
}

- (NSString *) readLine {
    if (currentOffset >= totalFileLength) { return nil; }

    NSData * newLineData = [lineDelimiter dataUsingEncoding:NSUTF8StringEncoding];
    [fileHandle seekToFileOffset:currentOffset];
    NSMutableData * currentData = [[NSMutableData alloc] init];
    BOOL shouldReadMore = YES;

    @autoreleasepool {

        while (shouldReadMore) {
            if (currentOffset >= totalFileLength) { break; }
            NSData * chunk = [fileHandle readDataOfLength:chunkSize];
            NSRange newLineRange = [chunk rangeOfData_dd:newLineData];
            if (newLineRange.location != NSNotFound) {

                //include the length so we can include the delimiter in the string
                chunk = [chunk subdataWithRange:NSMakeRange(0, newLineRange.location+[newLineData length])];
                shouldReadMore = NO;
            }
            [currentData appendData:chunk];
            currentOffset += [chunk length];
        }
    }

    currentData = [[currentData UTF8Data] mutableCopy];

    NSString * line = [[NSString alloc] initWithData:currentData encoding:NSUTF8StringEncoding];
    line = [line stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    line = [line stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return line;
}
- (NSString *) readTrimmedLine {
    return [[self readLine] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#if NS_BLOCKS_AVAILABLE
- (void) enumerateLinesUsingBlock:(void(^)(NSString*, BOOL*))block {
    NSString * line = nil;
    BOOL stop = NO;
    while (stop == NO && (line = [self readLine])) {
        block(line, &stop);
    }
}
#endif

@end
