//
//  MainViewController.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 03/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "MainViewController.h"
#import "MPISP.h"
#import "PublicKeyEncoding.h"
#import "ProblemsListTableViewController.h"

@implementation MainViewController {
    BOOL loadedView;
    CLLocationManager *locationManager;
    BOOL openMyProblems;
}

@synthesize appDelegate = _appDelegate;

- (void)viewDidLoad {
    [super viewDidLoad];

    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.uk.co.es4b.VilniuTvarkau"];
    
    [MPISP getProblemTypesWithCompletionHandler:^(NSArray *problemTypes, NSError *error) {
        if(error == nil) {
            _appDelegate.problemTypes = problemTypes;
            [_userDefaults setObject:problemTypes forKey:@"ProblemTypes"];
            [_userDefaults synchronize];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Klaida" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
    
    if([CLLocationManager locationServicesEnabled]) {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;

        [locationManager startUpdatingLocation];
    }
    
    UITapGestureRecognizer *mainLogoTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(mainLogoTapped:)];
    [_mainLogo addGestureRecognizer:mainLogoTapGestureRecognizer];
    _mainLogo.layer.cornerRadius = 10;
    _mainLogo.layer.borderColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1].CGColor;
    _mainLogo.layer.borderWidth = 0.5;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    if(_appDelegate.userFullname) {
        self.navigationItem.title = _appDelegate.userFullname;
        
        self.navigationItem.leftItemsSupplementBackButton = NO;
        UIImage *leftButtonImage = [UIImage imageNamed:@"navigationBarLogout"];
        UIButton *leftButton = [UIButton  buttonWithType:UIButtonTypeCustom];
        leftButton.frame = CGRectMake(0, 0, leftButtonImage.size.width, leftButtonImage.size.height);
        [leftButton setImage:leftButtonImage forState:UIControlStateNormal];
        [leftButton addTarget:self action:@selector(navigationLogout:) forControlEvents:UIControlEventTouchDown];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
        
        UIImage *rightButtonImage = [UIImage imageNamed:@"navigationBarSmartVilnius"];
        UIButton *rightButton = [UIButton  buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, rightButtonImage.size.width, rightButtonImage.size.height);
        [rightButton setImage:rightButtonImage forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(navigationSmartVilnius:) forControlEvents:UIControlEventTouchDown];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.title = @"Tvarkau Vilnių";
        
        UIImage *rightButtonImage = [UIImage imageNamed:@"navigationBarSmartVilnius"];
        UIButton *rightButton = [UIButton  buttonWithType:UIButtonTypeCustom];
        rightButton.frame = CGRectMake(0, 0, rightButtonImage.size.width, rightButtonImage.size.height);
        [rightButton setImage:rightButtonImage forState:UIControlStateNormal];
        [rightButton addTarget:self action:@selector(navigationSmartVilnius:) forControlEvents:UIControlEventTouchDown];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    }
    
    if([CLLocationManager locationServicesEnabled]) {
        NSString *version = [[UIDevice currentDevice] systemVersion];
        if ([version floatValue] < 8.0) {
            [locationManager startUpdatingLocation];
        } else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
            [locationManager requestWhenInUseAuthorization];
#pragma GCC diagnostic pop
            [locationManager startUpdatingLocation];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    loadedView = YES;
    //    [self performSegueWithIdentifier:@"SegueToProblemsMap" sender:self];
}

- (IBAction)mainLogoTapped:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://www.vilnius.lt/"];
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"Failed to open url: %@",[url description]);
    }
}

- (IBAction)navigationSmartVilnius:(id)sender
{
    [self performSegueWithIdentifier:@"SegueToSmartVilniusList" sender:self];
}

- (IBAction)navigationLogout:(id)sender
{
    [self performSegueWithIdentifier:@"SegueLogout" sender:self];
}

-(BOOL)shouldAutorotate {
    return false;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)addProblem:(id)sender {
    if(![PCNetworkConnectivity isNetworkAvailable]) {
        return;
    }
    
    if(_appDelegate.userSession == nil) {
        [self performSegueWithIdentifier:@"SegueUserLogin" sender:self];
    } else {
        [self performSegueWithIdentifier:@"SegueToNewProblem" sender:self];
    }
}

- (IBAction)myProblems:(id)sender {
    if(![PCNetworkConnectivity isNetworkAvailable]) {
        return;
    }
    
    if(_appDelegate.userSession == nil) {
        [self performSegueWithIdentifier:@"SegueUserLogin" sender:self];
    } else {
        //        [self performSegueWithIdentifier:@"SegueToMyProblems" sender:self];
        openMyProblems = YES;
        [self performSegueWithIdentifier:@"SegueToProblemList" sender:self];
    }
}

- (IBAction)problemsMap:(id)sender {
}

- (IBAction)problemsList:(id)sender {
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusRestricted && status != kCLAuthorizationStatusDenied) {
        [locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations objectAtIndex:0];
    [locationManager stopUpdatingLocation];
    
    _appDelegate.userLocation = currentLocation.coordinate;
    
    [MPISP getAddressWithLocation:currentLocation.coordinate completionHandler:^(NSString *address, NSError *responseError) {
        if(address) {
            _appDelegate.userAddress = address;
        }
    }];
}

- (void)newProblemSuccessfullySaved
{
    [self myProblems:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SegueToNewProblem"]) {
        if([[segue destinationViewController] isKindOfClass:[NewProblem_iPad_ViewController class]]) {
            NewProblem_iPad_ViewController *newProblemViewController = [segue destinationViewController];
            newProblemViewController.delegate = self;
        } else {
            NewProblemTableViewController *newProblemViewController = [segue destinationViewController];
            newProblemViewController.delegate = self;
        }
    } else if ([[segue identifier] isEqualToString:@"SegueToProblemList"] && openMyProblems) {
        openMyProblems = NO;
        ProblemsListTableViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.filterReporter = [_userDefaults objectForKey:KEY_EMAIL];
        destinationViewController.title = @"Mano pranešimai";
    }
}

@end



