//
//  KeywordAnalyse.h
//  codeconfuse
//
//  Created by Martin on 2018/5/15.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeywordAnalyse : NSObject
-(instancetype)initWithFileList:(NSMutableArray *)fileList;
-(void)analyse;
-(void)analyseExcludeFile;
@end
