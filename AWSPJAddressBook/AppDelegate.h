//
//  AppDelegate.h
//  AWSPJAddressBook
//
//  Created by Tanaka Koichi on 2014/04/10.
//  Copyright (c) 2014年 Tanaka Koichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@class AddressListViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>{
    NSMutableArray *addressArray;
}

@property (retain, nonatomic) UIWindow *window;
@property (nonatomic, retain) NSMutableArray *addressArray;
@property (strong, nonatomic) AddressListViewController *viewController;

- (NSString *)documentPath;
- (void)checkAndCreateCacheDirectory;
- (void)recoverArray;
- (void)saveArray;

@end

