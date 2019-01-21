//
//  FilterModel.h
//  Filter
//
//  Created by Yue on 2018/12/13.
//  Copyright © 2018 Yue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FilterModel : NSObject

+ (NSString *)judgeTypeWithMessage:(NSString *)message;

+ (BOOL)needFilter:(NSString *)message;

@end
