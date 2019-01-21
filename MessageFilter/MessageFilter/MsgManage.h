//
//  MsgManage.h
//  MessageFilter
//
//  Created by Yue on 2018/12/14.
//  Copyright © 2018 Yue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MsgManage : NSObject

+ (NSString *)filePath;

+ (NSArray *)messageList;

+ (void)addMessage:(NSString *)message isFilted:(BOOL)isFilted;

+ (void)deleteMessage:(NSString *)message;

+ (void)importMessageWithJsonFilePath:(NSString *)jsonPath;

@end

