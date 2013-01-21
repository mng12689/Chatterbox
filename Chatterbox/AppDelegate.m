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
#import "ChatterboxDataStore.h"
#import "Conversation.h"

typedef enum {
    CBAPNTypeConversationStarted,
    CBAPNTypeNewMessage
}CBAPNType;

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
    homeViewController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Categories" image:[UIImage imageNamed:@"category_tab_bar_icon"] tag:589340];

    ConversationsViewController *conversationsViewController = [ConversationsViewController new];
    UINavigationController *navController = [[UINavigationController alloc]initWithRootViewController:conversationsViewController];
    [navController.navigationBar setBarStyle:UIBarStyleBlackTranslucent];
    navController.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"Conversations" image:[UIImage imageNamed:@"speech_bubble_icon"] tag:589340];

    UITabBarController *tabBarController = [UITabBarController new];
    tabBarController.viewControllers = @[homeViewController,navController];
    self.window.rootViewController = tabBarController;
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"transparent_nav_bar"] forBarMetrics:UIBarMetricsDefault];
    [[[UINavigationBar appearance]layer]setShadowOffset:CGSizeMake(0, 5)];
    [[[UINavigationBar appearance]layer]setShadowColor:[[UIColor darkGrayColor]CGColor]];
    [[[UINavigationBar appearance]layer]setShadowOpacity:.5];
    [[UIBarButtonItem appearance]setTintColor:[UIColor colorWithWhite:.97 alpha:1]];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
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
    // Tell Parse about the device token.
    [PFPush storeDeviceToken:newDeviceToken];
    // Subscribe to the global broadcast channel.
    [PFPush subscribeToChannelInBackground:@""];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
    
    /*CBAPNType notificationType = [[userInfo objectForKey:@"notifType"]intValue];
    NSString *convoID = [userInfo objectForKey:@"convoID"];
    Conversation *conversation = [ChatterboxDataStore createConversationFromParseObject:parseConversation];
    switch (notificationType) {
        case CBAPNTypeConversationStarted:{
            //grab convo from parse
            break;
        }
        case CBAPNTypeNewMessage:{
            
            PFQuery *query = [PFQuery queryWithClassName:@"Message"];
            [query whereKey:@"conversation.id" equalTo:convoID];
            [query whereKey:@"createdAt" greaterThan:conversation.createdAt];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                for (PFObject *object in objects) {
                    [ChatterboxDataStore createMessageFromParseObject:object andConversation:conversation];
                }
                NSError *err;
                [ChatterboxDataStore saveContext:&err];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"NewMessages" object:self userInfo:[NSDictionary dictionaryWithObject:conversation forKey:@"conversation"]];
            }];
            break;
        }
        default:
            break;
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:@"PushReceived" object:self userInfo:userInfo];*/
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if ([error code] == 3010) {
        NSLog(@"Push notifications don't work in the simulator!");
    } else {
        NSLog(@"didFailToRegisterForRemoteNotificationsWithError: %@", error);
    }
}

@end
