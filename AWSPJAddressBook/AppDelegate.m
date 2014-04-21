//
//  AppDelegate.m
//  AWSPJAddressBook
//
//  Created by Tanaka Koichi on 2014/04/10.
//  Copyright (c) 2014年 Tanaka Koichi. All rights reserved.
//

#import "AppDelegate.h"

#import "AddressListViewController.h"

@implementation AppDelegate

@synthesize addressArray;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self recoverArray];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[AddressListViewController alloc] initWithNibName:nil bundle:nil];
    } else {
        self.viewController = [[AddressListViewController alloc] initWithNibName:nil bundle:nil];
    }
    UINavigationController *AddressListViewNav = [[UINavigationController alloc] initWithRootViewController:self.viewController];
    self.window.rootViewController = AddressListViewNav;
    [self.window makeKeyAndVisible];
    
    
    [self checkAndCreateCacheDirectory];
    
    return YES;
}
- (NSMutableArray *)addressArray {
	
	if (addressArray != nil) {
		return addressArray;
	}
	addressArray = [[NSMutableArray alloc] initWithCapacity:20];
	return addressArray;
}

- (void)checkAndCreateCacheDirectory {
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *pathPhoto = [[self documentPath] stringByAppendingPathComponent:@"photo"];
    NSString *pathThumbnail = [[self documentPath] stringByAppendingPathComponent:@"thumbnail"];
	
	if (![fileManager fileExistsAtPath:pathPhoto]) {
		[fileManager createDirectoryAtPath:pathPhoto withIntermediateDirectories:NO attributes:nil error:nil];
		[fileManager createDirectoryAtPath:pathThumbnail withIntermediateDirectories:NO attributes:nil error:nil];
    }
}

//get documetPath use NSDocumentDirectory defined in NSPathUtilities.h
- (NSString *)documentPath {
    //NSUserDomainMask is homedirectory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

//get address data
- (void)recoverArray {
    
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path = [[self documentPath] stringByAppendingPathComponent:@"addressArray.dat"];
	
	if ([fileManager isReadableFileAtPath:path]) {
		NSMutableArray *recoveredArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
		self.addressArray = recoveredArray;
	}
    
}

//Save addressArray
- (void)saveArray {
    NSLog(@"self.addressArray%@",self.addressArray);
	NSString *path = [[self documentPath] stringByAppendingPathComponent:@"addressArray.dat"];
	[NSKeyedArchiver archiveRootObject: self.addressArray toFile:path];
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
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
    [self saveArray];
}
@end
