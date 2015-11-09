//
//  NewProblem_iPad_ViewController.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 04/09/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "NewProblem_iPad_ViewController.h"

@implementation NewProblem_iPad_ViewController

static NSUInteger TAG_ALERTVIEW_ADDRESS = 1;
static NSUInteger TAG_ALERTVIEW_CAMERA = 2;
static NSUInteger TAG_ALERTVIEW_ANNOTATION = 3;
static NSUInteger TAG_ALERTVIEW_SAVED = 4;
static NSUInteger TAG_ALERTVIEW_LOCATION_SERVICE_DISABLED = 5;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Saugoti" style:UIBarButtonItemStylePlain target:self action:@selector(submitProblem:)];
    
    userDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.uk.co.es4b.VilniuTvarkau"];
    
    if(appDelegate == nil) {
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    if(!appDelegate.problemTypes || ![appDelegate.problemTypes count]) {
        [MPISP getProblemTypesWithCompletionHandler:^(NSArray *problemTypes, NSError *error) {
            if(error == nil) {
                appDelegate.problemTypes = problemTypes;
                [_problemType reloadComponent:0];
            } else {
                [[[UIAlertView alloc]initWithTitle:@"Klaida" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        }];
    }
    
    [self initAddressRow];
    
    photos = [[NSMutableArray alloc] init];
    
    _imageScrollView.delegate = self;
    _imageScrollViewPageControl.pageIndicatorTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    _imageScrollViewPageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    _imageScrollViewPageControl.numberOfPages = 0;
    
    _problemType.layer.borderWidth = _problemDescription.layer.borderWidth = 0.75f;
    _problemType.layer.borderColor = _problemDescription.layer.borderColor = [[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor];
    _problemType.layer.cornerRadius = _problemDescription.layer.cornerRadius = 8;
    _problemType.delegate = self;
    if([appDelegate.problemTypes count] > 8) {
        [_problemType selectRow:4 inComponent:0 animated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(self.view.frame.size.height / 2, self.view.frame.size.width / 2);
    activityIndicator.hidden = YES;
    [self.view addSubview:activityIndicator];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DIsValid(appDelegate.userLocation) ? appDelegate.userLocation : CLLocationCoordinate2DMake(54.685884, 25.277651);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, 20000, 20000);
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
    [_mapView setRegion:adjustedRegion animated:YES];
    
    if(annotation == nil) {
        annotation = [[PCAnnotation alloc] init];
        if(CLLocationCoordinate2DIsValid(appDelegate.userLocation)) {
            annotation.coordinate = appDelegate.userLocation;
        }
        [_mapView addAnnotation:annotation];
    }
    
    _email.delegate = _phone.delegate = _address.delegate = self;
    
    if(appDelegate.userAddress) {
        _address.text = appDelegate.userAddress;
    }
    
    submitEnabled = YES;
    
    [self initDefaults];
    [self initGestureRecognizers];
}

- (void)initAddressRow
{
    addressController = [[AddressController alloc] init];
    addressController.delegate = self;
    
    _addressDropDown.delegate = addressController;
    _addressDropDown.dataSource = addressController;
    _addressDropDown.layer.cornerRadius = 3;
    _addressDropDown.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _addressDropDown.layer.borderWidth = 0.5;
    
    [self hideDropDown];
}

- (void)initDefaults
{
    if([userDefaults objectForKey:KEY_EMAIL]) {
        _email.text = [userDefaults objectForKey:KEY_EMAIL];
        if([_email.text isValidEmail]) {
            _email.enabled = NO;
        }
    }
    
    if([userDefaults objectForKey:KEY_PHONE]) {
        _phone.text = [userDefaults objectForKey:KEY_PHONE];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    NSNumber *hideAnnotationAlert = [userDefaults objectForKey:@"hideAnnotationAlert"];
    if(!hideAnnotationAlert && (id)hideAnnotationAlert != [NSNull null] && ![hideAnnotationAlert boolValue]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Žymėjimas" message:@"Palieskite ir palaikykite norėdami pažymėti naują vietą žemėlapyje" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:@"Daugiau neberodyti", nil];
        alert.tag = TAG_ALERTVIEW_ANNOTATION;
        [alert show];
    }
    
    if(![CLLocationManager locationServicesEnabled] || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Jūsų vieta" message:@"Reikia įjungti \"Location Services\", kad būtų matoma jūsų buvimo vieta" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        alert.tag = TAG_ALERTVIEW_LOCATION_SERVICE_DISABLED;
        [alert show];
    }
}

#pragma mark Gestures

- (void)initGestureRecognizers
{
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMap:)];
    [_mapView addGestureRecognizer:recognizer];
    
    UITapGestureRecognizer *tapOutsideGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                           initWithTarget:self
                                                           action:@selector(tapOutside:)];
    tapOutsideGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapOutsideGestureRecognizer];
}

- (IBAction)tapOutside:(UITapGestureRecognizer *)recognizer {
    if(_problemDescription.isFirstResponder) {
        [_problemDescription resignFirstResponder];
    } else if(_phone.isFirstResponder) {
        [_phone resignFirstResponder];
    } else if(_address.isFirstResponder) {
        [_address resignFirstResponder];
    }
}

- (IBAction)tapOnMap:(UIGestureRecognizer *)recognizer {
    CGPoint point = [recognizer locationInView:_mapView];
    CLLocationCoordinate2D tapCoordinateLocation = [_mapView convertPoint:point toCoordinateFromView:_mapView];
    annotation.coordinate = tapCoordinateLocation;
    
    [MPISP getAddressWithLocation:tapCoordinateLocation completionHandler:^(NSString *address, NSError *responseError) {
        if(address && (id)address != [NSNull null]) {
            _address.text = address;
        }
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField.tag == _email.tag) {
        if(![textField.text length] || [textField.text isValidEmail]) {
            [_phone becomeFirstResponder];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Klaida" message:@"Nurodykite teisingą elektroninį paštą." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    } else if (textField.tag == _phone.tag) {
        if(![textField.text length] || [textField.text isLithuanianPhoneNumber]) {
            [_address becomeFirstResponder];
        } else {
            [[[UIAlertView alloc] initWithTitle:@"Klaida" message:@"Nurodykite teisingą telefono numerį." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }
    else if (textField.tag == _address.tag) {
        [_address resignFirstResponder];
    }
    
    return NO;
}

#pragma mark Actions

- (IBAction)addressValueChanged:(id)sender
{
    [addressController clearList];
    
    NSString *text = ((UITextField*)sender).text;
    if(text.length) {
        [addressController updateListWithAddressStringPart:text];
    } else {
        [self hideDropDown];
    }
}

- (IBAction)addPhoto:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Nuotraukos šaltinis" message:@"Pasirinkite nuotraukos šaltinį" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        [alertView addButtonWithTitle:@"Nuotraukų albumas"];
    }
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [alertView addButtonWithTitle:@"Nuotraukų biblioteka"];
    }
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertView addButtonWithTitle:@"Kamera"];
    }
    
    [alertView addButtonWithTitle:@"Atšaukti"];
    
    alertView.tag = TAG_ALERTVIEW_CAMERA;
    [alertView show];
}

- (IBAction)changeImageScrollViewPage:(UIPageControl*)sender {
    CGPoint contentOffset = CGPointMake(_imageScrollView.frame.size.width * sender.currentPage, 0);
    [_imageScrollView setContentOffset:contentOffset animated:YES];
}

- (void)showDropDown
{
    if(_addressDropDown.hidden) {
        _addressDropDownHeight.constant = 192;
        _addressDropDown.hidden = NO;
    }
}

- (void)hideDropDown
{
    if(!_addressDropDown.hidden) {
        _addressDropDown.hidden = YES;
        _addressDropDownHeight.constant = 3;
    }
}

- (void)showActivityIndicator {
    [activityIndicator startAnimating];
    activityIndicator.hidden = NO;
}

- (IBAction)submitProblem:(id)sender {
    NSString *session = appDelegate.userSession;
    NSString *description = _problemDescription.text;
    NSString *problemType = [appDelegate.problemTypes objectAtIndex:[_problemType selectedRowInComponent:0]];
    NSString *address = _address.text;
    NSString *email = _email.text;
    NSString *phone = _phone.text;
    
    if(session == nil || ![session length]) {
        [[[UIAlertView alloc] initWithTitle:@"Klaida" message:@"Norėdami užregistruoti problemą privalote prisijungti." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    if([description length] < 10) {
        [[[UIAlertView alloc] initWithTitle:@"Klaida" message:@"Užpildykite privalomus laukus. Apibūdinkite problemą keliais sakiniais." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    if([email length] && ![email isValidEmail]) {
        [[[UIAlertView alloc] initWithTitle:@"Klaida" message:@"Nurodykite teisingą elektroninį paštą." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    if([phone length] && ![phone isLithuanianPhoneNumber]) {
        [[[UIAlertView alloc] initWithTitle:@"Klaida" message:@"Nurodykite teisingą telefono numerį." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    if(![address length]) {
        [[[UIAlertView alloc] initWithTitle:@"Klaida" message:@"Užpildykite privalomus laukus. Nurodykite adresą." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    if(!annotation.coordinate.latitude || !annotation.coordinate.longitude) {
        [[[UIAlertView alloc] initWithTitle:@"Klaida" message:@"Užpildykite privalomus laukus. Pažymėkite vietą žemėlapyje." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return;
    }
    
    if(submitEnabled) {
        submitEnabled = NO;
    } else {
        return;
    }
    
    activityIndicator.hidden = NO;
    [activityIndicator startAnimating];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problema sėkmingai užregistruota" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
    alert.tag = TAG_ALERTVIEW_SAVED;
    [alert show];
    
    [MPISP newProblemWithSession:session description:description type:problemType address:address x:annotation.coordinate.latitude y:annotation.coordinate.longitude email:email phone:phone photos:photos completionHandler:^(BOOL saved, NSError *responseError) {
        submitEnabled = YES;
        activityIndicator.hidden = YES;
        if(saved) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Problema sėkmingai užregistruota" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            alert.tag = TAG_ALERTVIEW_SAVED;
            [alert show];
        } else if (responseError) {
            [[[UIAlertView alloc] initWithTitle:@"Klaida" message:responseError.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        } else {
            
            [[[UIAlertView alloc] initWithTitle:@"Klaida" message:@"Išsaugoti nepavyko. Bandykite dar kartą." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SegueNewProblemToMyProblems"]) {
        ProblemsListTableViewController *destinationViewController = [segue destinationViewController];
        destinationViewController.filterReporter = [userDefaults objectForKey:KEY_EMAIL];
        destinationViewController.title = @"Mano problemos";
    }
}

#pragma mark Images

- (void)showImagePicker:(NSString*)pickerType {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    
    if([pickerType isEqualToString:@"Kamera"]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        if([pickerType isEqualToString:@"Nuotraukų albumas"]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePicker];
        [popover presentPopoverFromRect:CGRectMake(0, 0, self.view.frame.size.width / 2, self.view.frame.size.height / 2) inView:[self.imageScrollView superview] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        self.popover = popover;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    if(image != nil) {
        [photos addObject:image];
        [self updateImageScrollView];

        NSUInteger photosCount = [photos count];
        _imageScrollViewPageControl.numberOfPages = photosCount;
        _imageScrollViewPageControl.currentPage = photosCount - 1;
        [self changeImageScrollViewPage:_imageScrollViewPageControl];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)appendImage:(UIImage*)image atX:(CGFloat)x withTag:(NSUInteger)tag {
    CGRect frame = CGRectMake(x, 0, _imageScrollView.frame.size.width, _imageScrollViewContent.frame.size.height);
    UIView *container = [[UIView alloc] initWithFrame:frame];
    
    frame.origin.x = 0;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [container addSubview:imageView];
    
    UIButton *removeButton = [[UIButton alloc] initWithFrame:CGRectMake(_imageScrollView.frame.size.width - 95, 20, 75, 30)];
    removeButton.tag = tag;
    removeButton.titleLabel.font = [UIFont systemFontOfSize:14];
    removeButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    removeButton.layer.borderColor = [[[UIColor grayColor]  colorWithAlphaComponent:0.5f] CGColor];
    removeButton.layer.borderWidth = 0.5f;
    removeButton.layer.cornerRadius = 8;
    removeButton.backgroundColor = [UIColor whiteColor];
    [removeButton setTitle:@"Pašalinti" forState:UIControlStateNormal];
    [removeButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [removeButton addTarget:self action:@selector(removePhotoContainer:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:removeButton];
    
    [_imageScrollViewContent addSubview:container];
}

- (void)removePhotoContainer:(UIButton*)button {
    [photos removeObjectAtIndex:button.tag];
    
    [self updateImageScrollView];
}

- (void)updateImageScrollView {
    for (UIView *subview in [_imageScrollViewContent subviews]) {
        [subview removeFromSuperview];
    }
    
    NSUInteger photosCount = [photos count];
    for (NSUInteger i = 0; i < photosCount; i++) {
        [self appendImage:[photos objectAtIndex:i] atX:i * _imageScrollView.frame.size.width withTag:i];
    }
    
    _imageScrollViewPageControl.numberOfPages = photosCount;
    
    if(photosCount > 0) {
        _imageScrollViewContentWidthConstraint.constant = photosCount * _imageScrollView.frame.size.width;

        if(_imageScrollViewPageControl.currentPage >= photosCount) {
            _imageScrollViewPageControl.currentPage = photosCount - 1;
        }
        [self changeImageScrollViewPage:_imageScrollViewPageControl];
    }
    
//    [_imageScrollView setContentOffset:CGPointMake(photosCount * _imageScrollViewContentWidthConstraint.constant, 0)];
}

#pragma mark Delegates

- (void)addressListDidUpdate
{
    if([addressController.addresses count]) {
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
            annotation.coordinate = location;
            [_mapView setCenterCoordinate:location animated:YES];
        }
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if([scrollView isEqual:_imageScrollView]) {
        CGFloat pageWidth = scrollView.frame.size.width;
        _imageScrollViewPageControl.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat keyboardHeight = MIN(keyboardSize.width, keyboardSize.height);

    if(activeField == _address) {
        [_scrollView setContentOffset:CGPointMake(0, keyboardHeight - 10) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [_scrollView setContentOffset:CGPointZero animated:YES];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [appDelegate.problemTypes count];
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
    
    if([appDelegate.problemTypes count] > row) {
        pickerLabel.text = [appDelegate.problemTypes objectAtIndex:row];
    }
    
    return pickerLabel;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSString *text = [alertView buttonTitleAtIndex:buttonIndex];
    if(alertView.tag == TAG_ALERTVIEW_ADDRESS) {
        if(![text isEqualToString:@"Atšaukti"]) {
            _address.text = text;
            if(_address.isFirstResponder) {
                [_address resignFirstResponder];
            }
            
            NSString *fullAddress = [NSString stringWithFormat:@"Lithuania, Vilnius, %@", text];
            [MPISP geolocationUsingAddress:fullAddress handle:^(CLLocationCoordinate2D location, NSError *error) {
                if(location.latitude && location.longitude) {
                    annotation.coordinate = location;
                }
            }];
        }
    } else if (alertView.tag == TAG_ALERTVIEW_CAMERA) {
        if(![text isEqualToString:@"Atšaukti"]) {
            [self showImagePicker:text];
        }
    } else if (alertView.tag == TAG_ALERTVIEW_ANNOTATION) {
        if(![text isEqualToString:@"Ok"]) {
            [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"hideAnnotationAlert"];
        }
    } else if (alertView.tag == TAG_ALERTVIEW_SAVED) {
        [self.navigationController popViewControllerAnimated:NO];
        [_delegate newProblemSuccessfullySaved];
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

#pragma mark Other

- (void)orientationChanged:(NSNotification *)notification
{
    [self updateImageScrollView];
    [self changeImageScrollViewPage:_imageScrollViewPageControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
