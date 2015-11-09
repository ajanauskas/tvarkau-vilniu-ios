//
//  NewProblemTableViewController.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 16/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "AddressController.h"
#import "AppDelegate.h"
#import "PCAnnotation.h"
#import "NewProblemDelegate.h"

@interface NewProblemTableViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewAccessibilityDelegate, UIAlertViewDelegate, MKMapViewDelegate, UITextFieldDelegate, UITextViewDelegate, AddressControllerDelegate>
{
    AppDelegate *appDelegate;
    NSMutableArray *photos;
    UIActivityIndicatorView *activityIndicator;
    PCAnnotation *annotation;
    
    UIView *currentEditingView;
    NSUInteger currentlyEditingViewTag;
    
    NSUserDefaults *userDefaults;
    
    BOOL submitEnabled;

    AddressController *addressController;
    
    CGFloat bottomInset;
    
    UITextField *activeTextField;
    UITextView *activeTextView;
    
    CGFloat _keyboardHeight;
}

@property (weak, nonatomic) id<NewProblemDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIPickerView *problemType;
@property (weak, nonatomic) IBOutlet UITextView *problemDescription;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITableViewCell *imageCell;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *imageScrollViewContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageScrollViewContentWidth;
@property (weak, nonatomic) IBOutlet UIPageControl *imageScrollViewPageControl;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *addressDropDown;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressDropDownHeight;

@property (strong, nonatomic) CLLocationManager *locationManager;

- (IBAction)addPhoto:(id)sender;
- (IBAction)changeImageScrollViewPage:(UIPageControl*)sender;
- (IBAction)submitProblem:(id)sender;

- (IBAction)addressValueChanged:(id)sender;

@end
