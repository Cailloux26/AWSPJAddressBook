//
//  AddressListViewController.h
//  AWSPJAddressBook
//
//  Created by Tanaka Koichi on 2014/04/10.
//  Copyright (c) 2014年 Tanaka Koichi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AddressInputViewController.h"
#import "AddressDetailViewController.h"

@interface AddressListViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>{
	UITableView *tableView;
    AddressInputViewController *addressInputViewController;
    NSMutableDictionary *apiResponse;
    NSString *userid;
    NSMutableArray *listdata;
}
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) AddressInputViewController *addressInputViewController;
@property (nonatomic, retain) NSMutableDictionary *apiResponse;
@property (nonatomic, retain) NSMutableArray *listdata;
@property (nonatomic, retain) NSString *userid;

@end
