//
//  IntLogic.h
//  codeconfuse
//
//  Created by Martin on 2018/5/15.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VariableInfo.h"
#import "TypeInfo.h"
#import "DataBase.h"
@class CodeGenerator;
@interface TypeLogic : NSObject {
    CodeGenerator *mCg;
}
-(id)initWithCodeGenerator:(CodeGenerator *)cg;

- (NSString *)ifFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c;
- (NSString *)forFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c;
- (NSString *)whileFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c;
- (NSString *)switchFunction:(VariableInfo *)a b:(VariableInfo *)b c:(VariableInfo *)c;


@end
