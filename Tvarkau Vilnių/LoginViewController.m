//
//  LoginViewController.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 28/04/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "LoginViewController.h"

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.uk.co.es4b.VilniuTvarkau"];
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    _username.delegate = self;
    _password.delegate = self;
    
    _mainLogo.layer.cornerRadius = 10;
    _mainLogo.layer.borderColor = [UIColor colorWithRed:0.93 green:0.93 blue:0.93 alpha:1].CGColor;
    _mainLogo.layer.borderWidth = 0.5;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];

    _activityIndicator.hidden = YES;
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */



- (IBAction)hideKeyboard:(UITextField*)sender
{
    [sender resignFirstResponder];
}

- (IBAction)registration:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"http://www.vilnius.lt/lit/Registruotis/1"];
    if (![[UIApplication sharedApplication] openURL:url])
    {
        NSLog(@"Failed to open url: %@",[url description]);
    }
}

- (IBAction)login:(id)sender
{
    _activityIndicator.hidden = NO;
    
    PublicKeyEncoding *publicKeyEncoding = [PublicKeyEncoding publicKeyWithPathForResource:@"pubkey" ofType:@"pem"];
    
    NSString *password = [publicKeyEncoding encryptStringWithString:_password.text];
    NSString *login = _username.text;
    
    [MPISP loginUser:login withPassword:password completionHandler:^(NSDictionary *responseData, NSError *error) {
        _activityIndicator.hidden = YES;
        if(error == nil)
        {
            NSString *session = [responseData objectForKey:@"session_id"];
            NSString *email = [responseData objectForKey:@"email"];
            NSString *phone = [responseData objectForKey:@"phone_no"];
            NSString *firstname = [responseData objectForKey:@"user_name"];
            NSString *lastname = [responseData objectForKey:@"user_surname"];
            
            _appDelegate.userSession = session;
            _appDelegate.userFullname = [NSString stringWithFormat:@"%@ %@", firstname, lastname];
            
            if([_remember isOn])
            {
                [userDefaults setObject:login forKey:KEY_LOGIN];
                [userDefaults setObject:password forKey:KEY_PASSWORD];
                [userDefaults setObject:session forKey:KEY_SESSION];

                [userDefaults setObject:email forKey:KEY_EMAIL];
                [userDefaults setObject:phone forKey:KEY_PHONE];
                [userDefaults setObject:firstname forKey:KEY_FIRSTNAME];
                [userDefaults setObject:lastname forKey:KEY_LASTNAME];
            }
            
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
        {
            [[[UIAlertView alloc]initWithTitle:@"Klaida" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
        }
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat keyboardHeight = MIN(keyboardSize.width, keyboardSize.height);
    CGFloat visibleFrameHeight = self.view.frame.size.height - keyboardHeight;
    CGFloat activeFieldBottom = CGRectGetMaxY(activeField.frame);

    if(visibleFrameHeight < activeFieldBottom) {
        [_scrollView setContentOffset:CGPointMake(0, activeFieldBottom - visibleFrameHeight) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [_scrollView setContentOffset:CGPointZero animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

@end
