//
//  FilterModel.m
//  Filter
//
//  Created by Yue on 2018/12/13.
//  Copyright © 2018 Yue. All rights reserved.
//

#import "FilterModel.h"
#import "Filter.h"

@implementation FilterModel

static Filter *filter = nil;
+ (Filter *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (filter == nil) {
            filter = [[Filter alloc] init];
        }
    });
    return filter;
}

+ (NSString *)judgeTypeWithMessage:(NSString *)message {
    NSError *error = nil;
    FilterOutput *output = [[self shared] predictionFromText:message error:&error];
    NSString *outputLabel = output.label;
    if (!error && outputLabel.length) {
        return outputLabel;
    }
    else {
        NSLog(@"CoreML输出出错--->%@",error);
        return nil;
    }
}

+ (BOOL)needFilter:(NSString *)message {
    NSString *type = [self judgeTypeWithMessage:message];
    return [type isEqualToString:@"过滤"];
}

@end
