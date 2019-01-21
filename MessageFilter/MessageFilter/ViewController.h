//
//  ViewController.h
//  MessageFilter
//
//  Created by Yue on 2018/12/13.
//  Copyright © 2018 Yue. All rights reserved.
//

#import <UIKit/UIKit.h>

#define StatusBarFrame [UIApplication sharedApplication].statusBarFrame
#define StatusBarHeight (StatusBarFrame.origin.y + StatusBarFrame.size.height)
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController : UIViewController


@end

