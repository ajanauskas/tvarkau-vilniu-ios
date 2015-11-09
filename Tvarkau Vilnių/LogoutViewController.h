//
//  LogoutViewController.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 01/07/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "MPISP.h"

@interface LogoutViewController : UIViewController

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *mainLogo;

- (IBAction)logout:(id)sender;

@end
