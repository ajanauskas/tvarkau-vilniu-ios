//
//  ProblemsFilterTableViewController.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 12/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "ProblemsFilterTableViewController.h"
#import "AppDelegate.h"

@implementation ProblemsFilterTableViewController
{
    AppDelegate *appDelegate;
    NSUInteger registrationDateCellHeight, submitCellHeight;
}

@synthesize delegate = _delegate;
@synthesize problemDescription = _problemDescription;
@synthesize problemType = _problemType;
@synthesize registrationDateSwitch = _registrationDateSwitch;
@synthesize registrationDatePicker = _registrationDatePicker;
@synthesize docNo = _docNo;

- (void)viewWillAppear:(BOOL)animated
{
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        registrationDateCellHeight = 218;
        _registrationDatePicker.hidden = NO;
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
            submitCellHeight = 312;
        } else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            submitCellHeight = 56;
        }
    } else {
        registrationDateCellHeight = 48;
        _registrationDatePicker.hidden = YES;
        submitCellHeight = 64;
    }
    
    _problemType.delegate = self;
    
    _address.delegate = _problemDescription.delegate = _docNo.delegate = self;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filtruoti" style:UIBarButtonItemStylePlain target:self action:@selector(filter:)];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [indexPath row];
    switch (index) {
        case 0:
            return 74;
        case 1:
            return 74;
        case 2:
            return 208;
        case 3:
            return registrationDateCellHeight;
        case 4:
            return 74;
        case 5:
            return submitCellHeight;
            
        default:
            return 999;
            break;
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [appDelegate.problemTypes count] + 1;
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *pickerLabel = (UILabel*)view;
    if(pickerLabel == nil)
    {
        CGRect frame = CGRectMake(0.0, 0.0, _problemType.frame.size.width, 32);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:12]];
    }

    pickerLabel.adjustsFontSizeToFitWidth = YES;
    pickerLabel.minimumScaleFactor = 1.5; // value of regular font size divided into minimum font size;
    
    if(row == 0)
    {
        pickerLabel.text = @"Visos";
    }
    else if([appDelegate.problemTypes count] >= row)
    {
        pickerLabel.text = [appDelegate.problemTypes objectAtIndex:row - 1];
    }
    
    return pickerLabel;
}

- (IBAction)filter:(id)sender {
    NSDate* date = nil;
    if(_registrationDateSwitch.on)
    {
        date = _registrationDatePicker.date;
    }
    [self.delegate problemsFilterWithAddress:_address.text description:_problemDescription.text type:[_problemType selectedRowInComponent:0] registrationDate:date docNo:_docNo.text];

    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)hideKeyboard:(UITextField*)sender
{
    [sender resignFirstResponder];
}

- (IBAction)showHideRegistrationDatePicker:(UISwitch *)sender {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return;
    }
    
    if(sender.on) {
        registrationDateCellHeight = 218;
        _registrationDatePicker.hidden = NO;
    } else {
        registrationDateCellHeight = 48;
        _registrationDatePicker.hidden = YES;
    }
    
    [self.tableView reloadData];
}

- (void)keyboardWasShown:(NSNotification *)notification
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if(activeField == _docNo) {
            CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
            CGFloat keyboardHeight = MIN(keyboardSize.width, keyboardSize.height);
            CGFloat visibleFrameHeight = self.view.frame.size.height - keyboardHeight;
            CGFloat activeFieldBottom = 74 + 74 + 208 + registrationDateCellHeight + 74;
            NSLog(@"kh: %f", keyboardHeight);
            NSLog(@"vfh: %f", visibleFrameHeight);
            NSLog(@"afb: %f", activeFieldBottom);
            
            if(visibleFrameHeight < activeFieldBottom) {
                [self.tableView setContentOffset:CGPointMake(0, activeFieldBottom - visibleFrameHeight) animated:YES];
            }
        }
    } else {
        CGFloat keyboardHeight = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
        self.tableView.contentInset = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0);
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.tableView setContentOffset:CGPointZero animated:YES];
    } else {
        self.tableView.contentInset = UIEdgeInsetsZero;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    activeField = nil;
}

- (void)orientationChanged:(NSNotification *)notification
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
            submitCellHeight = 312;
        } else if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            submitCellHeight = 56;
        }
        [self.tableView reloadData];
    }
}

@end
