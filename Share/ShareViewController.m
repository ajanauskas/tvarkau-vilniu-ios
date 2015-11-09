//
//  ShareViewController.m
//  Share
//
//  Created by Paulius Cesekas on 26/09/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "ShareViewController.h"

@implementation ShareViewController

#pragma mark View

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    _mainScrollView.hidden = YES;
    
    _userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.uk.co.es4b.VilniuTvarkau"];
    
    _session = [_userDefaults objectForKey:KEY_SESSION];
    
    _problemTypes = [_userDefaults objectForKey:@"ProblemTypes"];
    
    _mainScrollView.delegate = self;
    
    _scrollContentView.layer.cornerRadius = 8;
    
    _problemType.layer.borderWidth = _problemDescription.layer.borderWidth = _addressDropDown.layer.borderWidth = 0.5f;
    _problemType.layer.borderColor = _problemDescription.layer.borderColor = _addressDropDown.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    _problemType.layer.cornerRadius = _problemDescription.layer.cornerRadius = 8;
    _addressDropDown.layer.cornerRadius = 5;
    
    _problemType.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIApplicationDidChangeStatusBarFrameNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self initPhotos];
    [self initAddress];
}

- (void)viewDidAppear:(BOOL)animated
{
    if((id)_session == [NSNull null] || !_session || !_session.length) {
        [self requireLogin];
    } else {
        self.view.backgroundColor = [UIColor colorWithWhite:0.5f alpha:0.8f];
        _mainScrollView.hidden = NO;
        _activityIndicator.hidden = YES;
        
        if((id)_problemTypes == [NSNull null] || !_problemTypes || !_problemTypes.count) {
            
            [MPISP getProblemTypesWithCompletionHandler:^(NSArray *problemTypes, NSError *error) {
                if(error == nil) {
                    [_userDefaults setObject:problemTypes forKey:@"ProblemTypes"];
                    [_userDefaults synchronize];
                    _problemTypes = problemTypes;
                    [_problemType reloadAllComponents];
//                } else {
//                    [self requireLogin];
                }
            }];
        }
    }
}

- (void)requireLogin
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Reikia prisijungti" message:@"Norėdami registruoti problemą turite prisijungti. Įjunkite programėle ir joje prisijunkite." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelProblemRegistrationAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self cancelProblemRegistration:self];
    }];
    [alertController addAction:cancelProblemRegistrationAction];
    [self showViewController:alertController sender:self];
}

#pragma mark Photos

- (void)initPhotos
{
    _imageScrollView.delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        _totalPhotos = 0;
        NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                _totalPhotos++;
            }
        }
        
        _photos = [[NSMutableArray alloc] init];
        int index = 0;
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_photos addObject:image];
                        
                        CGRect frame = CGRectMake(index * _imageScrollView.frame.size.width, 0, _imageScrollView.frame.size.width, _imageScrollViewContent.frame.size.height);
                        UIView *container = [[UIView alloc] initWithFrame:frame];
                        
                        frame.origin.x = 0;
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
                        imageView.contentMode = UIViewContentModeScaleAspectFit;
                        imageView.image = image;
                        [container addSubview:imageView];
                        
                        [_imageScrollViewContent addSubview:container];
                        
                        if(_photos.count >= _totalPhotos && _saveInProgress) {
                            [self registerProblem:self];
                        }
                    });
                }];
            }
            
            index++;
        }
        
        _imageScrollViewContentWidth.constant = index * _imageScrollView.frame.size.width;
        _imageScrollViewPageControl.numberOfPages = index;
    });
}


- (void)orientationChanged:(NSNotification *)notification
{
    for(UIView *subview in _imageScrollViewContent.subviews) {
        [subview removeFromSuperview];
    }
    
    [self performSelector:@selector(updateImagesView) withObject:nil afterDelay:1];
}

- (void)updateImagesView
{
    int index = 0;
    for (UIImage *image in _photos) {
        CGRect frame = CGRectMake(index * _imageScrollView.frame.size.width, 0, _imageScrollView.frame.size.width, _imageScrollViewContent.frame.size.height);
        UIView *container = [[UIView alloc] initWithFrame:frame];
        
        frame.origin.x = 0;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = image;
        [container addSubview:imageView];
        
        [_imageScrollViewContent addSubview:container];
        
        if(_photos.count >= _totalPhotos && _saveInProgress) {
            [self registerProblem:self];
        }
        index++;
    }
    
    _imageScrollViewContentWidth.constant = index * _imageScrollView.frame.size.width;
    
    [_imageScrollView scrollRectToVisible:CGRectMake(0, 0,  _imageScrollView.frame.size.width, _imageScrollViewContent.frame.size.height) animated:NO];
}

#pragma mark Submition

- (IBAction)cancelProblemRegistration:(id)sender
{
    NSError *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
    [self.extensionContext cancelRequestWithError:error];
}

- (void)registrationInAction:(BOOL)inAction
{
    if(inAction) {
        _registerButton.enabled = NO;
        _registerButton.hidden = YES;
        _registerActivityIndicator.hidden = NO;
        [_registerActivityIndicator startAnimating];
    } else {
        _registerButton.enabled = YES;
        _registerButton.hidden = NO;
        _registerActivityIndicator.hidden = YES;
    }
}

- (IBAction)registerProblem:(id)sender {
    [self registrationInAction:YES];

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Klaida" message:@"Klaida" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    [alertController addAction:okAction];

    NSString *description = _problemDescription.text;
    NSString *problemType = [_problemTypes objectAtIndex:[_problemType selectedRowInComponent:0]];
    NSString *address = _address.text;
    NSString *email = [_userDefaults objectForKey:KEY_EMAIL];
    NSString *phone = _phone.text;
    
    if(!_session.length) {
        [self requireLogin];

        [self registrationInAction:NO];
        return;
    }
    
    if([description length] < 10) {
        alertController.message = @"Užpildykite privalomus laukus. Apibūdinkite problemą keliais sakiniais.";
        [self showViewController:alertController sender:self];
        
        [self registrationInAction:NO];
        return;
    }
    
    if(![email length] || ![email isValidEmail]) {
        [self requireLogin];

        [self registrationInAction:NO];
        return;
    }
    
    if(![phone length] || ![phone isLithuanianPhoneNumber]) {
        alertController.message = @"Nurodykite teisingą telefono numerį.";
        [self showViewController:alertController sender:self];
        
        [self registrationInAction:NO];
        return;
    }
    
    if(![address length]) {
        alertController.message = @"Užpildykite privalomus laukus. Nurodykite adresą.";
        [self showViewController:alertController sender:self];
        
        [self registrationInAction:NO];
        return;
    }
    
    if(!_annotation.coordinate.latitude || !_annotation.coordinate.longitude) {
        alertController.message = @"Užpildykite privalomus laukus. Pažymėkite vietą žemėlapyje.";
        [self showViewController:alertController sender:self];
        
        [self registrationInAction:NO];
        return;
    }

    
    if(_photos.count >= _totalPhotos) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [MPISP newProblemWithSession:_session description:description type:problemType address:address x:_annotation.coordinate.latitude y:_annotation.coordinate.longitude email:email phone:phone photos:_photos completionHandler:^(BOOL saved, NSError *responseError) {
                [self registrationInAction:NO];
                
                UIAlertController *successAlertController = [UIAlertController alertControllerWithTitle:@"Išsaugota" message:@"Duomenys sėkmingai išsaugoti" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *successOkAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [successAlertController dismissViewControllerAnimated:YES completion:nil];
                    [self.extensionContext completeRequestReturningItems:nil completionHandler:nil];
                }];
                [successAlertController addAction:successOkAction];
                [self showViewController:successAlertController sender:self];
                
            }];
        });
    } else {
        _saveInProgress = true;
    }
}

#pragma mark Problems Types

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_problemTypes count];
}

- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *pickerLabel = (UILabel*)view;
    if(pickerLabel == nil) {
        CGRect frame = CGRectMake(0.0, 0.0, _problemType.frame.size.width, 32);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:12]];
    }
    
    pickerLabel.adjustsFontSizeToFitWidth = YES;
    pickerLabel.minimumScaleFactor = 1.5; // value of regular font size divided into minimum font size;
    
    if([_problemTypes count] > row) {
        pickerLabel.text = [_problemTypes objectAtIndex:row];
    }
    
    return pickerLabel;
}

#pragma mark Address

- (void)initAddress
{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(54.685884, 25.277651);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, 20000, 20000);
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
    [_mapView setRegion:adjustedRegion animated:YES];
    
    if(_annotation == nil) {
        _annotation = [[PCAnnotation alloc] init];
        [_mapView addAnnotation:_annotation];
    }
    
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMap:)];
    [_mapView addGestureRecognizer:recognizer];
    
    _addressController = [[AddressController alloc] init];
    _addressController.delegate = self;
    
    _addressDropDown.delegate = _addressController;
    _addressDropDown.dataSource = _addressController;
    _addressDropDown.layer.borderColor = [[[UIColor grayColor]  colorWithAlphaComponent:0.5f] CGColor];
    _addressDropDown.layer.borderWidth = 0.5f;
    
    [self hideDropDown];
    
    if([CLLocationManager locationServicesEnabled]) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        [_locationManager startUpdatingLocation];
    }
}

- (void)showDropDown
{
    if(_addressDropDown.hidden) {
        if([UIScreen mainScreen].bounds.size.height >= 568) {
            _addressDropDownHeight.constant = _addressDropDown.rowHeight * 6.5f;
        } else {
            _addressDropDownHeight.constant = _addressDropDown.rowHeight * 3.8f;
        }
        _addressDropDown.hidden = NO;
        
        CGFloat visibleFrameHeight = self.view.frame.size.height - _keyboardHeight;
        CGFloat activeFieldBottom = _addressDropDown.frame.origin.y + _addressDropDownHeight.constant + _addressDropDown.superview.frame.origin.y;
        if(visibleFrameHeight < activeFieldBottom - _mainScrollView.contentOffset.y) {
            _autoscroll = YES;
            
            [_mainScrollView setContentOffset:CGPointMake(0, activeFieldBottom - visibleFrameHeight) animated:YES];
        }
    }
}

- (void)hideDropDown
{
    if(!_addressDropDown.hidden) {
        _addressDropDown.hidden = YES;
        _addressDropDownHeight.constant = 3;
    }
}

- (IBAction)addressValueChanged:(id)sender
{
    [_addressController clearList];
    
    NSString *text = ((UITextField*)sender).text;
    if(text.length) {
        [_addressController updateListWithAddressStringPart:text];
    } else {
        [self hideDropDown];
    }
}

- (IBAction)addressEditingDone:(id)sender {
    [self hideKeyboard];
}

- (void)addressListDidUpdate
{
    if([_addressController.addresses count]) {
        [_addressDropDown reloadData];
        [self showDropDown];
    } else {
        [self hideDropDown];
    }
}

- (void)addressDidSelect:(NSString *)address
{
    [self hideDropDown];
    _address.text = address;
    
    NSString *fullAddress = [NSString stringWithFormat:@"Lithuania, Vilnius, %@", address];
    [MPISP geolocationUsingAddress:fullAddress handle:^(CLLocationCoordinate2D location, NSError *error) {
        if(location.latitude && location.longitude) {
            _annotation.coordinate = location;
            [_mapView setCenterCoordinate:location animated:YES];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status != kCLAuthorizationStatusNotDetermined && status != kCLAuthorizationStatusRestricted && status != kCLAuthorizationStatusDenied) {
        [_locationManager startUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *currentLocation = [locations objectAtIndex:0];
    [_locationManager stopUpdatingLocation];
    
    _annotation.coordinate = currentLocation.coordinate;
    [_mapView setCenterCoordinate:currentLocation.coordinate animated:NO];
    _mapView.centerCoordinate = currentLocation.coordinate;
    
    [MPISP getAddressWithLocation:currentLocation.coordinate completionHandler:^(NSString *address, NSError *responseError) {
        if(address) {
            _address.text = address;
        }
    }];
}

- (IBAction)tapOnMap:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:_mapView];
    CLLocationCoordinate2D tapCoordinateLocation = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    _annotation.coordinate = tapCoordinateLocation;
    
    [MPISP getAddressWithLocation:tapCoordinateLocation completionHandler:^(NSString *address, NSError *responseError) {
        if(address && (id)address != [NSNull null]) {
            _address.text = address;
        }
    }];
}

#pragma mark Scroll View

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    _autoscroll = NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if([scrollView isEqual:_imageScrollView]) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        _imageScrollViewPageControl.currentPage = page;
    } else {
        if (_autoscroll) {
            return;
        }
        
        CGFloat offset = _mainScrollViewContentOffsetY - scrollView.contentOffset.y;
        if(offset > 5 || offset < -20) {
            [self hideKeyboard];
        }
        
        _mainScrollViewContentOffsetY = scrollView.contentOffset.y;
    }
}

#pragma mark Keyboard

- (void)hideKeyboard
{
    if(_problemDescription.isFirstResponder) {
        [_problemDescription resignFirstResponder];
    } else if(_phone.isFirstResponder) {
        [_phone resignFirstResponder];
    } else if(_address.isFirstResponder) {
        [_address resignFirstResponder];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    _autoscroll = YES;
}

- (void)keyboardWasShown:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    _keyboardHeight = MIN(keyboardSize.width, keyboardSize.height);
    _mainScrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, _keyboardHeight, 0.0);
    
    CGFloat visibleFrameHeight = self.view.frame.size.height - _keyboardHeight;
    CGFloat activeFieldBottom;
    if(_problemDescription.isFirstResponder) {
        activeFieldBottom = _problemDescription.frame.origin.y + _problemDescription.frame.size.height + _problemDescription.superview.frame.origin.y;
//        activeFieldBottom = CGRectGetMaxY(_problemDescription.frame);//rowHeight[0] + CGRectGetMaxY(_problemDescription.frame) + 8;
    } else if(_address.isFirstResponder) {
        activeFieldBottom = _address.frame.origin.y + _address.frame.size.height + _address.superview.frame.origin.y;
//        activeFieldBottom = CGRectGetMaxY(_address.frame);
    } else if(_phone.isFirstResponder) {
        activeFieldBottom = _phone.frame.origin.y + _phone.frame.size.height + _phone.superview.frame.origin.y;
//        activeFieldBottom = CGRectGetMaxY(_phone.frame);
    }
    
    if(visibleFrameHeight < activeFieldBottom - _mainScrollView.contentOffset.y) {
        [_mainScrollView setContentOffset:CGPointMake(0, activeFieldBottom - visibleFrameHeight) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    _keyboardHeight = 0;
    _mainScrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);;
}

@end




