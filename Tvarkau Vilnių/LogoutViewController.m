//
//  LogoutViewController.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 01/07/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "LogoutViewController.h"

@implementation LogoutViewController
{
    NSUserDefaults *userDefaults;
}

@synthesize activityIndicator = _activityIndicator;
@synthesize name = _name;

- (void)viewDidLoad
{
    [super viewDidLoad];

    userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.uk.co.es4b.VilniuTvarkau"];
        
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    _activityIndicator.hidden = YES;
    
    if(_appDelegate.userFullname)
    {
        _name.text = [NSString stringWithFormat:@"Prisijungta kaip\r\n%@", _appDelegate.userFullname];
    }

    _mainLogo.layer.cornerRadius = 10;
    _mainLogo.layer.borderColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1].CGColor;
    _mainLogo.layer.borderWidth = 0.5;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)logout:(id)sender {
    _activityIndicator.hidden = NO;
    
    [MPISP logoutSession:_appDelegate.userSession completionHandler:^(BOOL loggedOut, NSError *error) {
        _activityIndicator.hidden = YES;
        if(error == nil)
        {
            if(loggedOut)
            {
                _appDelegate.userSession = nil;
                _appDelegate.userFullname = nil;
                
                if([userDefaults objectForKey:KEY_LOGIN])
                {
                    [userDefaults removeObjectForKey:KEY_LOGIN];
                }
                if([userDefaults objectForKey:KEY_PASSWORD])
                {
                    [userDefaults removeObjectForKey:KEY_PASSWORD];
                }
                if([userDefaults objectForKey:KEY_SESSION])
                {
                    [userDefaults removeObjectForKey:KEY_SESSION];
                }
                
                if([userDefaults objectForKey:KEY_EMAIL])
                {
                    [userDefaults removeObjectForKey:KEY_EMAIL];
                }
                if([userDefaults objectForKey:KEY_PHONE])
                {
                    [userDefaults removeObjectForKey:KEY_PHONE];
                }
                if([userDefaults objectForKey:KEY_FIRSTNAME])
                {
                    [userDefaults removeObjectForKey:KEY_FIRSTNAME];
                }
                if([userDefaults objectForKey:KEY_LASTNAME])
                {
                    [userDefaults removeObjectForKey:KEY_LASTNAME];
                }
                
                if([userDefaults objectForKey:@"hideAnnotationPrivacyAlert"]) {
                    [userDefaults removeObjectForKey:@"hideAnnotationPrivacyAlert"];
                }
                
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else
        {
            [[[UIAlertView alloc]initWithTitle:@"Klaida" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
    }];
}

@end
