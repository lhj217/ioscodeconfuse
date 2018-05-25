//
//  DataBase.h
//  codeconfuse
//
//  Created by Martin Liu on 2018/4/25.
//  Copyright © 2018年 Martin Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClassModel.h"
#import "ClassInfo.h"

@interface DataBase : NSObject {

}
+(instancetype) shareInstance;
@property (nonatomic, strong) NSMutableDictionary *identifyDic;
@property (nonatomic, strong) NSMutableDictionary *excludeKeywordDic;
@property (nonatomic, strong) NSMutableArray *dictArr;

-(void)reset;
-(BOOL)insertRecord:(ClassModel *)classModel;      //新增数据
-(NSMutableArray *)queryAllIdentify;          //查询所有信息

-(NSString *)randomWord;
-(NSString *)randomWord:(NSUInteger)wordNum;
- (NSString *)randomName:(NSUInteger)length;
- (void)addClass:(ClassInfo *)ci;
- (NSMutableArray *)classArrByClassType:(NSInteger)classType;
@end
