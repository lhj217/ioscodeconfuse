//
//  CppParser.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SrcFileModel.h"
#import "ClassModel.h"
#import "Parser.h"

#define INCLUDE                 10
#define CLASS                   20
#define TEMPLATE_CLASS          30
#define VARIABLE                40
#define FUNCTION                50
#define UNDEINED                -1
#define NOTFOUND                0
#define HAVEFOUND               1

@interface CppParser : Parser
-(int)findFunctionAndVarsOfClass:(NSString *)str s:(NSString *)s pos:(NSUInteger *)pos parser:(CppParser *) theclass;
@end
