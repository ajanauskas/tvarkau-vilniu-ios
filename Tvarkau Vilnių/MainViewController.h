//
//  MainViewController.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 03/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"
#import "PCNetworkConnectivity.h"
#import "NewProblemDelegate.h"
#import "NewProblem_iPad_ViewController.h"
#import "NewProblemTableViewController.h"

@interface MainViewController : UIViewController <CLLocationManagerDelegate, NewProblemDelegate, UIAlertViewDelegate>
{
    NSUserDefaults *_userDefaults;
}

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (weak, nonatomic) IBOutlet UIImageView *mainLogo;
@property (weak, nonatomic) IBOutlet UIButton *buttonAddProblem;
@property (weak, nonatomic) IBOutlet UIButton *buttonMyProblems;
@property (weak, nonatomic) IBOutlet UIButton *buttonProblemsList;
@property (weak, nonatomic) IBOutlet UIButton *buttonProblemsMap;

- (IBAction)addProblem:(id)sender;
- (IBAction)myProblems:(id)sender;
- (IBAction)problemsMap:(id)sender;
- (IBAction)problemsList:(id)sender;

@end
