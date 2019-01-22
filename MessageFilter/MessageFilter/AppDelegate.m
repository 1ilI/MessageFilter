//
//  AppDelegate.m
//  MessageFilter
//
//  Created by Yue on 2018/12/13.
//  Copyright © 2018 Yue. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "MsgManage.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [[ViewController alloc] init];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSString *filePath = [[url absoluteString] stringByRemovingPercentEncoding];
    if (filePath.length) {
        NSString *fileName = [filePath lastPathComponent];
        NSString *extensionStr = [filePath pathExtension];
        if ([extensionStr isEqualToString:@"json"]) {
            NSString *message = [NSString stringWithFormat:@"是否将%@文件导入至本地语料库？", fileName];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"导入语料库" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [MsgManage importMessageWithJsonFilePath:filePath];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ImportNotificationName" object:nil];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }]];
            
            UIViewController *showVC = self.window.rootViewController.presentedViewController ? : self.window.rootViewController;
            [showVC presentViewController:alert animated:YES completion:nil];
            return YES;
        }
    }
    
    return NO;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
