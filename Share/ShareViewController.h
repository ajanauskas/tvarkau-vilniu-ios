//
//  ShareViewController.h
//  Share
//
//  Created by Paulius Cesekas on 26/09/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "AddressController.h"
#import "MPISP.h"
#import "PCAnnotation.h"
#import "SVPCStaticKeys.h"
#import "NSString+Checks.h"

@interface ShareViewController : UIViewController <UIPickerViewDataSource, UIPickerViewAccessibilityDelegate, MKMapViewDelegate, AddressControllerDelegate, UIScrollViewDelegate, CLLocationManagerDelegate>
{
    NSUserDefaults *_userDefaults;
    NSArray *_problemTypes;
    
    CGFloat _mainScrollViewContentOffsetY;
    CGFloat _keyboardHeight;
    
    AddressController *_addressController;
    PCAnnotation *_annotation;
    CLLocationManager *_locationManager;

    BOOL _autoscroll;
    
    NSString *_session;
    
    NSInteger _totalPhotos;
    NSMutableArray *_photos;
    
    BOOL _saveInProgress;
}

@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *registerActivityIndicator;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (weak, nonatomic) IBOutlet UIView *imageScrollViewContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageScrollViewContentWidth;
@property (weak, nonatomic) IBOutlet UIPageControl *imageScrollViewPageControl;
@property (weak, nonatomic) IBOutlet UITextView *problemDescription;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UIPickerView *problemType;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITableView *addressDropDown;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressDropDownHeight;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)cancelProblemRegistration:(id)sender;
- (IBAction)registerProblem:(id)sender;
- (IBAction)addressValueChanged:(id)sender;
- (IBAction)addressEditingDone:(id)sender;

@end
