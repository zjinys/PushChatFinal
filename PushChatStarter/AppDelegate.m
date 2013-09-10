//
//  AppDelegate.m
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "AppDelegate.h"
#import "ChatViewController.h"
#import "DataModel.h"
#import "Message.h"

void ShowErrorAlert(NSString* text)
{
	UIAlertView* alertView = [[UIAlertView alloc]
                              initWithTitle:text
                              message:nil
                              delegate:nil
                              cancelButtonTitle:NSLocalizedString(@"OK", nil)
                              otherButtonTitles:nil];
    
	[alertView show];
}

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    _storyBoard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if (launchOptions != nil)
	{
		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if (dictionary != nil)
		{
			NSLog(@"Launched from push notification: %@", dictionary);
			[self addMessageFromRemoteNotification:dictionary updateUI:NO];
		}
	}
    return YES;
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
	[self addMessageFromRemoteNotification:userInfo updateUI:YES];
}

- (void)addMessageFromRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI
{
    UINavigationController *navigationController = (UINavigationController*)_window.rootViewController;
    ChatViewController *chatViewController =
    (ChatViewController*)[navigationController.viewControllers  objectAtIndex:0];
    
    DataModel *dataModel = chatViewController.dataModel;
    
	Message* message = [[Message alloc] init];
	message.date = [NSDate date];
    
	NSString* alertValue = [[userInfo valueForKey:@"aps"] valueForKey:@"alert"];
    
	NSMutableArray* parts = [NSMutableArray arrayWithArray:[alertValue componentsSeparatedByString:@": "]];
	message.senderName = [parts objectAtIndex:0];
	[parts removeObjectAtIndex:0];
	message.text = [parts componentsJoinedByString:@": "];
    
	int index = [dataModel addMessage:message];
    
	if (updateUI)
		[chatViewController didSaveMessage:message atIndex:index];
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
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)postUpdateRequest
{
    UINavigationController *navigationController = (UINavigationController*)_window.rootViewController;
    ChatViewController *chatViewController = (ChatViewController*)[navigationController.viewControllers objectAtIndex:0];
    
    DataModel *dataModel = chatViewController.dataModel;
    
    NSDictionary *params = @{@"cmd":@"update",
                             @"user_id":[dataModel userId],
                             @"token":[dataModel deviceToken]};
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:ServerApiURL]];
    [client
     postPath:@"/api.php"
     parameters:params
     success:nil failure:nil];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    UINavigationController *navigationController = (UINavigationController*)_window.rootViewController;
    ChatViewController *chatViewController = (ChatViewController*)[navigationController.viewControllers objectAtIndex:0];
    
    DataModel *dataModel = chatViewController.dataModel;
	NSString* oldToken = [dataModel deviceToken];
    
	NSString* newToken = [deviceToken description];
	newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
	NSLog(@"My token is: %@", newToken);
    
	[dataModel setDeviceToken:newToken];
    
	if ([dataModel joinedChat] && ![newToken isEqualToString:oldToken])
	{
		[self postUpdateRequest];
	}
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}
@end
