//
//  LoginViewController.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 28/04/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "NSString+Hashes.h"
#import "MPISP.h"
#import "PublicKeyEncoding.h"

@interface LoginViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>
{
    UITextField *activeField;
    NSUserDefaults *userDefaults;
}

@property (strong, nonatomic) AppDelegate *appDelegate;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UISwitch *remember;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *registrationButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *mainLogo;

- (IBAction)hideKeyboard:(UITextField*)sender;
- (IBAction)registration:(id)sender;
- (IBAction)login:(id)sender;



@end
