//
//  AppDelegate.m
//  Chatterbox
//
//  Created by Michael Ng on 10/22/12.
//  Copyright (c) 2012 Michael Ng. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "ConversationsViewController.h"
#import <Parse/Parse.h>
#import "DCIntrospect.h"
#import "CBCommons.h"
#import "AuthenticationViewController.h"

#define kAlertTag 89043

@interface AppDelegate () <UIAlertViewDelegate>

@end
@implementation AppDelegate 

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [Parse setApplicationId:@"XAOiCNdtHHHMBpbq38h1pLK1iwp2yc5B3M19jPWm"
                  clientKey:@"hiXkrkEzvXIQK3sZODoRRpMtwsUSXKjssoD9sy4Y"];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    HomeViewController *homeViewController = [HomeViewController new];
    UINavigationController *homeNavController = [[UINavigationController alloc]initWithRootViewController:homeViewController];
    [homeNavController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    homeNavController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Chattegories" image:[UIImage imageNamed:@"category_tab_bar_icon"] tag:589340];

    ConversationsViewController *conversationsViewController = [ConversationsViewController new];
    UINavigationController *conversationsNavController = [[UINavigationController alloc]initWithRootViewController:conversationsViewController];
    [conversationsNavController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    conversationsNavController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Conversations" image:[UIImage imageNamed:@"speech_bubble_icon"] tag:90434];

    UITabBarController *tabBarController = [UITabBarController new];
    tabBarController.viewControllers = @[homeNavController,conversationsNavController];
    self.window.rootViewController = tabBarController;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"transparent_nav_bar"] forBarMetrics:UIBarMetricsDefault];
    [[[UINavigationBar appearance]layer]setShadowOffset:CGSizeMake(0, 5)];
    [[[UINavigationBar appearance]layer]setShadowColor:[[UIColor darkGrayColor]CGColor]];
    [[[UINavigationBar appearance]layer]setShadowOpacity:.5];
    [[UIBarButtonItem appearance]setTintColor:[UIColor colorWithWhite:.8 alpha:1]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // login user if not logged in
    if (![PFUser currentUser]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No User Detected" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sign Up",@"Login", nil];
        alert.tag = kAlertTag;
        [alert show];
    }
    
#if TARGET_IPHONE_SIMULATOR
    [[DCIntrospect sharedIntrospector] start];
#endif

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    // Store the deviceToken in the current Installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    [currentInstallation saveInBackground];
    [PFPush subscribeToChannelInBackground:@""];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    CBAPNType notificationType = (CBAPNType)[[userInfo objectForKey:CBAPNTypeKey]intValue];
    NSString *convoID = [userInfo objectForKey:CBAPNConvoIDKey];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
        tabBarController.selectedIndex = 1;
        
    }
    switch (notificationType) {
        case CBAPNTypeConversationStarted:{
            [[NSNotificationCenter defaultCenter]postNotificationName:CBNotificationTypeAPNActiveConvo object:self userInfo:[NSDictionary dictionaryWithObject:convoID forKey:CBNotificationKeyConvoId]];
            break;
        }
        case CBAPNTypeNewMessage:{
            [[NSNotificationCenter defaultCenter]postNotificationName:CBNotificationTypeAPNNewMessage object:self userInfo:[NSDictionary dictionaryWithObject:convoID forKey:CBNotificationKeyConvoId]];
            break;
        }
        case CBAPNTypeConversationEnded:{
            [[NSNotificationCenter defaultCenter]postNotificationName:CBNotificationTypeAPNEndedConvo object:self userInfo:[NSDictionary dictionaryWithObject:convoID forKey:CBNotificationKeyConvoId]];
            break;
        }
        default:
            break;
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if ([error code] == 3010) {
        NSLog(@"Push notifications don't work in the simulator!");
    } else {
        NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertTag) {
        if (buttonIndex != 0) {
            BOOL login = YES;
            if (buttonIndex == 1) {
                login = NO;
            }
            AuthenticationViewController *authVC = [[AuthenticationViewController alloc]initForLogin:login];
            UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:authVC];
            [navController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
            [self.window.rootViewController presentModalViewController:navController animated:YES];
        }
    }
}


@end
