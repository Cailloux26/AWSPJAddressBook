//
//  AddressListViewController.m
//  AWSPJAddressBook
//
//  Created by Tanaka Koichi on 2014/04/10.
//  Copyright (c) 2014年 Tanaka Koichi. All rights reserved.
//

#import "AddressListViewController.h"
#import "AppDelegate.h"

@interface AddressListViewController ()

@end

@implementation AddressListViewController
@synthesize tableView, addressInputViewController, apiResponse,userid,listdata;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
    [tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
}
// FBSample logic
// This method is responsible for keeping UX and session state in sync
- (void)refresh {
    // if the session is open, then load the data for our view controller
    if (FBSession.activeSession.isOpen) {
        // Default to Seattle, this method calls loadData
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                if (!error) {
                    //login check
                    NSString *str = [NSString stringWithFormat:@"http://ec2-54-187-18-158.us-west-2.compute.amazonaws.com:3000/api/users/%@.json",user.id];
                    userid = user.id;
                    NSURL *url = [NSURL URLWithString:str];
                    //NSURLRequest NSMutableURLRequest
                    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
                    NSData *res = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
                    apiResponse = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingAllowFragments error:nil];
                    //NSLog(@"apiResponse=%@",[apiResponse objectForKey:@"fbid"]);
                    
                    if(!apiResponse){
                        NSLog(@"api null");
                        // register user
                        str = [NSString stringWithFormat:@"http://ec2-54-187-18-158.us-west-2.compute.amazonaws.com:3000/api/users.json"];
                        NSString *mail = [user objectForKey:@"email"];
                        NSString *name = user.name;
                        NSString *fbid = user.id;
                        NSString *body = [NSString stringWithFormat:@"mail=%@&name=%@&fbid=%@&service=reader", mail, name, fbid];
                        NSData *post = [body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];

                        [req setURL:[NSURL URLWithString:str]];
                        [req setHTTPMethod:@"POST"];
                        [req setHTTPBody:post];
                        
                        NSData *response = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
                        apiResponse = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
                        NSLog(@"after apiResponse:%@",[apiResponse description]);
                        
                    }else{
                        NSLog(@"api exists");
                        [self getListData];
                    }
                }
            }];
    } else {
        // if the session isn't open, we open it here, which may cause UX to log in the user
        NSArray *permissionsArray = @[ @"basic_info", @"email"];
        [FBSession openActiveSessionWithReadPermissions:permissionsArray
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (!error) {
                                              [self refresh];
                                          } else {
                                              [[[UIAlertView alloc] initWithTitle:@"Error"
                                                                          message:error.localizedDescription
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles:nil]
                                               show];
                                          }
                                      }];
    }
}
- (void)loadView {
    [super loadView];
    userid = @"";
    // Background
    UIImage *BaseImage = [UIImage imageNamed:@"backgroung.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:BaseImage];
    
    // navigation
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(24, 61, 49, 21)];
    title.backgroundColor = [UIColor clearColor];
    title.font = [UIFont fontWithName:@"Lato-Bold" size:22];
    title.text = @"Address book";
    title.textColor = [self hexToUIColor:@"ffffff" alpha:1];
    UIColor *color = [UIColor grayColor];
    title.layer.shadowColor = [color CGColor];
    title.layer.shadowRadius = 3.0f;
    title.layer.shadowOpacity = 1;
    title.layer.shadowOffset = CGSizeZero;
    title.layer.masksToBounds = NO;
    self.navigationItem.titleView = title;
    UIImage *navBGImage = [UIImage imageNamed:@"header_bg.png"];
    CGFloat width = 320;
    CGFloat height = 44;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [navBGImage drawInRect:CGRectMake(0, 0, width, height)];
    navBGImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.navigationController.navigationBar setBackgroundImage:navBGImage forBarMetrics:UIBarMetricsDefault];
    
    // add button
    UIBarButtonItem* addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(showAddressInputView)];
    addButton.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = addButton;
    
    // table view
    tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    tableView.dataSource = self;
    tableView.delegate = self;
    [self.view addSubview:tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refresh];
}
-(void)getListData{
    //get data
    NSString *str = [NSString stringWithFormat:@"http://ec2-54-187-18-158.us-west-2.compute.amazonaws.com:3000/api/adbooks/%@.json",userid];
    NSURL *url = [NSURL URLWithString:str];
    //NSURLRequest NSMutableURLRequest
    NSMutableURLRequest *req = [[NSMutableURLRequest alloc] initWithURL:url];
    NSData *res = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    apiResponse = [[NSMutableDictionary alloc]init];
    apiResponse = [NSJSONSerialization JSONObjectWithData:res options:NSJSONReadingAllowFragments error:nil];
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.addressArray = [[NSMutableArray alloc]init];
    for (NSMutableDictionary *data in apiResponse)
    {
        [appDelegate.addressArray addObject:data];
    }
    [tableView reloadData];
}
// define tableview
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	return [appDelegate.addressArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0;
}
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"FirstViewCell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

    NSLog(@"table data");
    /*
    get a image from S3;
    NSString *s3url = @"";
    NSURL *url = [NSURL URLWithString:s3url];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc] initWithData:data];
    */
	AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
	NSDictionary *dictionary = [appDelegate.addressArray objectAtIndex:indexPath.row];
	cell.textLabel.text = [dictionary objectForKey:@"first"];
	cell.detailTextLabel.text = [(NSDate *)[dictionary objectForKey:@"note"] description];
    
	NSString *thumbnail = [NSString stringWithFormat:@"%@/thumbnail/%@@2x.png", [appDelegate documentPath], [dictionary objectForKey:@"id"]];
	cell.imageView.image = [UIImage imageWithContentsOfFile:thumbnail];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSDictionary *listDict = [appDelegate.addressArray objectAtIndex:indexPath.row];
    NSString *id = [listDict objectForKey:@"id"];
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    AddressDetailViewController *detailViewController = [[AddressDetailViewController alloc] initWithNibName:nil bundle:nil];
    detailViewController.profileid = id;
    [self.navigationController pushViewController:detailViewController animated:YES];
}

// add address info
- (void)showAddressInputView {
	addressInputViewController = [[AddressInputViewController alloc] initWithNibName:nil bundle:nil];
    UINavigationController *addressInputNav = [[UINavigationController alloc]init];
    addressInputNav = [[UINavigationController alloc] initWithRootViewController:addressInputViewController];
    addressInputViewController.userid = userid;
    [self presentViewController:addressInputNav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(UIColor*) hexToUIColor:(NSString *)hex alpha:(CGFloat)a{
	NSScanner *colorScanner = [NSScanner scannerWithString:hex];
	unsigned int color;
	[colorScanner scanHexInt:&color];
	CGFloat r = ((color & 0xFF0000) >> 16)/255.0f;
	CGFloat g = ((color & 0x00FF00) >> 8) /255.0f;
	CGFloat b =  (color & 0x0000FF) /255.0f;
	//NSLog(@"HEX to RGB >> r:%f g:%f b:%f a:%f\n",r,g,b,a);
	return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
