//
//  NewProblem_iPad_ViewController.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 04/09/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AddressController.h"
#import "AppDelegate.h"
#import "PCAnnotation.h"
#import "MPISP.h"
#import "NSString+Checks.h"
#import "ProblemsListTableViewController.h"
#import "NewProblemDelegate.h"

@interface NewProblem_iPad_ViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate, UIPickerViewDataSource, UIPickerViewAccessibilityDelegate, UIAlertViewDelegate, MKMapViewDelegate, UITextFieldDelegate, AddressControllerDelegate>
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
    
    UITextField *activeField;
}

@property (weak, nonatomic) id<NewProblemDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPickerView *problemType;
@property (weak, nonatomic) IBOutlet UITextView *problemDescription;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *imageScrollViewContent;
@property (weak, nonatomic) IBOutlet UIPageControl *imageScrollViewPageControl;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *addressDropDown;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressDropDownHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageScrollViewContentWidthConstraint;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) UIPopoverController *popover;

- (IBAction)addPhoto:(id)sender;
- (IBAction)changeImageScrollViewPage:(UIPageControl*)sender;
- (IBAction)submitProblem:(id)sender;
- (IBAction)addressValueChanged:(id)sender;

@end
