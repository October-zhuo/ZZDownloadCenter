//
//  AppDelegate.m
//  ZZDownloadCenterDemo
//
//  Created by zhuo on 2017/7/5.
//  Copyright © 2017年 zhuo. All rights reserved.
//

#import "AppDelegate.h"
#import "ListViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "ZZDownloadSessionHelper.h"
#import "ZZDownloadSession.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    _window = [[UIWindow alloc] initWithFrame: [UIScreen mainScreen].bounds];
    ListViewController *rootViewController = [[ListViewController alloc] init];
    _window.rootViewController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
    [_window makeKeyAndVisible];
    
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge|UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if(error){
            NSLog(@"%@",error);
        }else{
            NSLog(@"okokok");
        }
    }];
    
    return YES;
}


- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    NSURLSession *session = [ZZDownloadSession backgroundSession];
    NSLog(@"%@",session);
    [[ZZDownloadSessionHelper sharedHelper] cacheCompletionHandler:completionHandler withID:identifier];
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
