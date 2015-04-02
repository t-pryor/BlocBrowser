//
//  AppDelegate.m
//  BlocBrowser
//
//  Created by Tim on 2015-03-27.
//  Copyright (c) 2015 Tim Pryor. All rights reserved.
//

#import "AppDelegate.h"
#import "BLCWebBrowserViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

/* **** Not Running -> Active **** */


-(BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   NSLog(@"IN application: WillFinishLaunchingWithOptions");
  return YES;
  
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSLog(@"IN application: didFinishLaunchingWithOptions");
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  // Override point for customization after application launch.
  self.window.backgroundColor = [UIColor whiteColor];
  self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[BLCWebBrowserViewController alloc] init]];
  NSLog(@"NAV.VIEW  %@", self.window.rootViewController.view);
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  NSLog(@"IN applicationDidBecomeActive");
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Welcome!", @"Welcome title")
                                                  message:NSLocalizedString(@"Get excited to use the best web browser ever!", @"Welcome comment")
                                                 delegate:nil
                                        cancelButtonTitle:NSLocalizedString(@"OK, I'm excited!", @"Welcome button title") otherButtonTitles:nil];
  [alert show];
}


/* **** Active -> Inactive ***** */


// This code finds the navigation controller, looks at its first view controller (which is our
// BLCWebBrowserViewController instance) and sends it the resetWebView message

- (void)applicationWillResignActive:(UIApplication *)application {
  NSLog(@"IN applicationWillResignActive");
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  UINavigationController *navigationVC = (UINavigationController *)self.window.rootViewController;
  BLCWebBrowserViewController *browserVC = [[navigationVC viewControllers] firstObject];
  [browserVC resetWebView];
}

/* **** Inactive -> Background **** */

- (void)applicationDidEnterBackground:(UIApplication *)application {
  NSLog(@"IN applicationDidEnterBackground");
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


/* **** Background -> Suspended -> Active **** */

- (void)applicationWillEnterForeground:(UIApplication *)application {
  NSLog(@"IN applicationWillEnterForeground");
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}


- (void)applicationWillTerminate:(UIApplication *)application {
   NSLog(@"IN applicationWillTerminate");
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
