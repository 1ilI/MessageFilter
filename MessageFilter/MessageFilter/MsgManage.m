//
//  MsgManage.m
//  MessageFilter
//
//  Created by Yue on 2018/12/14.
//  Copyright © 2018 Yue. All rights reserved.
//

#import "MsgManage.h"

static NSString *filePath = nil;
static NSString *const fileName = @"MessageData.json";
@implementation MsgManage

+ (NSString *)filePath {
    if (filePath == nil) {
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsPath = [path objectAtIndex:0];
        filePath = [documentsPath stringByAppendingPathComponent:fileName];
    }
    return filePath;
}

+ (NSArray *)messageList {
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:[self filePath]];
    NSArray *list = [self jsonDataToObject:jsonData];
    return list.count ? list : @[];
}

+ (void)addMessage:(NSString *)message isFilted:(BOOL)isFilted {
    if (message.length) {
        NSMutableArray *mArr = [NSMutableArray arrayWithArray:[self messageList]];
        //去重
        [[self messageList] enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull msgDic, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *savedMsgText = [msgDic valueForKey:@"text"];
            if ([message isEqualToString:savedMsgText]) {
                [mArr removeObject:msgDic];
            }
        }];
        
        NSDictionary *saveDic = @{
                                  @"text": message,
                                  @"label": isFilted ? @"过滤" : @"正常"
                                  };
        [mArr insertObject:saveDic atIndex:0];
        
        //写成jsonData然后写入文件
        [self messageArrWriteToFile:mArr];
    }
    else {
        NSLog(@"新增Msg失败，message格式有误：%@",message);
    }
}

+ (void)deleteMessage:(NSString *)message {
    NSMutableArray *mArr = [NSMutableArray arrayWithArray:[self messageList]];
    [[self messageList] enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull msgDic, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *savedMsgText = [msgDic valueForKey:@"text"];
        if ([message isEqualToString:savedMsgText]) {
            [mArr removeObject:msgDic];
        }
    }];
    //写成jsonData然后写入文件
    [self messageArrWriteToFile:mArr];
}

+ (void)importMessageWithJsonFilePath:(NSString *)jsonPath {
    NSData *jsonData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:jsonPath]];
    NSArray *importList = [self jsonDataToObject:jsonData];
    NSMutableSet *importSet = [NSMutableSet setWithArray:importList];
    NSMutableSet *savedSet = [NSMutableSet setWithArray:[self messageList]];
    [savedSet unionSet:importSet];
    
    //排个序
    NSArray *resultArr = [[savedSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *obj1, NSDictionary *obj2) {
        NSString *label1 = [obj1 valueForKey:@"label"];
        NSString *label2 = [obj2 valueForKey:@"label"];
        if ([label1 isEqualToString:@"正常"] && [label2 isEqualToString:@"过滤"]) {
            return NSOrderedDescending;
        }
        else if ([label1 isEqualToString:@"过滤"] && [label2 isEqualToString:@"正常"]) {
            return NSOrderedAscending;
        }
        else {
            return NSOrderedSame;
        }
    }];
    
    //写入文件
    [self messageArrWriteToFile:resultArr];
}

//将数组写成json文件
+ (BOOL)messageArrWriteToFile:(NSArray *)messageArr {
    NSData *jsonData = [self objectToJsonData:messageArr];
    if ([jsonData writeToFile:[self filePath] atomically:YES]) {
        return YES;
    }
    else {
        NSLog(@"json写入文件失败");
        return NO;
    }
}

//将对象（数组，字典）转成 jsonData
+ (NSData *)objectToJsonData:(id)obj {
    if (obj == nil) {
        return nil;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    if ([jsonData length] && error == nil) {
        return jsonData;
    }
    else{
        NSLog(@"数组 转 json 失败：%@",error);
        return nil;
    }
}

//将 jsonData 转成 数组
+ (id)jsonDataToObject:(NSData *)jsonData {
    if (jsonData) {
        NSError *error = nil;
        NSArray *list = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&error];
        if ([list count] && error == nil) {
            return list;
        }
        else {
            NSLog(@"json 转 数组 失败：%@", error);
            return nil;
        }
    }
    else {
        return nil;
    }
}

@end
