//
//  ProblemsMapViewController.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 09/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "ProblemsMapViewController.h"
#import "MPISP.h"
#import "PCAnnotation.h"
#import "SingleProblemTableViewController.h"

static NSUInteger MAX_PROBLEMS_IN_SINGLE_DOWNLOAD = 99;
static CGFloat ANNOTATIONS_EXPAND_FACTOR = 0.06f;
static CGFloat ANNOTATIONS_EXPAND_FACTOR2 = 0.02f;
static CGFloat ANNOTATIONS_GROUP_FACTOR = 0.04;
static CGFloat ANNOTATIONS_GROUP_FACTOR2 = 0.02f;
static NSUInteger TAG_ANNOTATION_VIEW_LABEL = 2901;

@implementation ProblemsMapViewController

@synthesize mapView = _mapView;
@synthesize activityIndicator = _activityIndicator;
@synthesize filterReporter = _filterReporter;

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(touchesSearch)];
    
    if(reloadBeforeAppear) {
        [_mapView removeAnnotations:_mapView.annotations];
        _activityIndicator.hidden = NO;
        [self updateProblemsList];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    filters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
               [NSNull null], @"description",
               [NSNull null], @"address",
               [NSNull null], @"problemType",
               [NSNull null], @"date",
               [NSNull null], @"docNo",
               nil];
    
    [_mapView setDelegate:self];
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(54.685884, 25.277651);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, 20000, 20000);
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
    previousZoomLevel = adjustedRegion.span.latitudeDelta;
    [_mapView setRegion:adjustedRegion animated:YES];

    _mapTypeControl.backgroundColor = [UIColor whiteColor];
    _mapTypeControl.layer.cornerRadius = 5;
    [_mapTypeControl setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}
                                   forState:UIControlStateSelected];
    
    [self updateProblemsList];
    
    reloadBeforeAppear = NO;
}

- (void)updateProblemsList
{
    annotations = [[NSMutableArray alloc] init];
    
    id filterDescription = [filters objectForKey:@"description"];
    id filterAddress = [filters objectForKey:@"address"];
    id filterType = [filters objectForKey:@"problemType"];
    id filterDate = [filters objectForKey:@"date"];
    id filterDocNo = [filters objectForKey:@"docNo"];
    
    [self downloadProblemsStarting:0 withFiltersDescription:filterDescription type:filterType address:filterAddress reporter:_filterReporter date:filterDate docNo:filterDocNo];
}

- (void)downloadProblemsStarting:(NSUInteger)start withFiltersDescription:(NSString *)descriptionFilter type:(NSString *)typeFilter address:(NSString *)addressFilter reporter:(NSString *)reporterFilter date:(NSString *)dateFilter docNo:(NSString *)docNo
{
    [MPISP getProblemsStarting:start limit:MAX_PROBLEMS_IN_SINGLE_DOWNLOAD withFiltersDescription:descriptionFilter type:typeFilter address:addressFilter reporter:reporterFilter date:dateFilter docNo:docNo completionHandler:^(NSArray *problemsList, NSError *error) {
        if(error == nil) {
            if(problemsList == nil || (id)problemsList == [NSNull null]) {
                if([annotations count]) {
                    [self updateMapAnnotationsGroupedWithFactor:ANNOTATIONS_GROUP_FACTOR];
                    if(reloadBeforeAppear) {
                        [self centerToVilniusMapView:_mapView];
                    }
                    
                    reloadBeforeAppear = NO;
                } else {
                    [[[UIAlertView alloc] initWithTitle:@"Klaida" message:@"Duomenų pagal pateiktą užklausą nepavyko gauti." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
                }
            } else {
                if([problemsList count]) {
                    for (NSDictionary *problem in problemsList) {
                        PCAnnotation *annotation = [[PCAnnotation alloc] init];
                        annotation.coordinate = CLLocationCoordinate2DMake([[problem objectForKey:@"y"] doubleValue], [[problem objectForKey:@"x"] doubleValue]);
                        annotation.title = [problem valueForKey:@"address"];
                        annotation.subtitle = [problem valueForKey:@"description"];
                        annotation.docNo = [problem valueForKey:@"docNo"];
                        if([[problem valueForKey:@"status"] isEqualToString:@"Atlikta"]) {
                            annotation.image = @"pin-green";
                        } else {
                            annotation.image = @"pin-red";
                        }
                        
                        [annotations addObject:annotation];
                    }
                    
                    [self downloadProblemsStarting:[annotations count] withFiltersDescription:descriptionFilter type:typeFilter address:addressFilter reporter:reporterFilter date:dateFilter docNo:docNo];
//
                    // @TODO: debug speedup
//                    [self updateMapAnnotationsGroupedWithFactor:ANNOTATIONS_GROUP_FACTOR];
//                    if(reloadBeforeAppear) {
//                        [self centerToVilniusMapView:_mapView];
//                    }
//                    
//                    reloadBeforeAppear = NO;
                } else {
                    [self updateMapAnnotationsGroupedWithFactor:ANNOTATIONS_GROUP_FACTOR];
                    if(reloadBeforeAppear) {
                        [self centerToVilniusMapView:_mapView];
                    }
                    
                    reloadBeforeAppear = NO;
                }
            }
        } else {
            [[[UIAlertView alloc]initWithTitle:@"Klaida" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
    }];
}

- (void)centerToVilniusMapView:(MKMapView *)mapView
{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(54.685884, 25.277651);
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, 20000, 20000);
    MKCoordinateRegion adjustedRegion = [_mapView regionThatFits:viewRegion];
    previousZoomLevel = adjustedRegion.span.latitudeDelta;
    [_mapView setRegion:adjustedRegion animated:YES];
}

- (void)updateMapAnnotationsGroupedWithFactor:(CGFloat)groupFactor
{
    groupedAnnotations = [[NSMutableArray  alloc] init];
    
    NSMutableArray *annotationsCopy = [NSMutableArray arrayWithArray:annotations];
    for (int i = 0; i < [annotationsCopy count]; i++) {
        PCAnnotation *mainAnnotation = annotationsCopy[i];
        [annotationsCopy removeObject:mainAnnotation];
        
        PCGroupAnnotation *groupAnnotation = [[PCGroupAnnotation alloc] initAtCoordinate:mainAnnotation.coordinate];
        [groupAnnotation addAnnotation:mainAnnotation];
        
        for (int j = 0; j < [annotationsCopy count]; j++) {
            PCAnnotation *testAnnotation = annotationsCopy[j];
            if(fabs(testAnnotation.coordinate.latitude - mainAnnotation.coordinate.latitude) < groupFactor
               && fabs(testAnnotation.coordinate.longitude - mainAnnotation.coordinate.longitude) < groupFactor) {
                [groupAnnotation addAnnotation:testAnnotation];
                [annotationsCopy removeObject:testAnnotation];
            }
        }
        
        [groupedAnnotations addObject:groupAnnotation];
    }
    
    for (int i = 0; i < [groupedAnnotations count]; i++) {
        PCGroupAnnotation *groupAnnotation = groupedAnnotations[i];
        if(groupAnnotation.coordinate.latitude > 56.483185 ||
           groupAnnotation.coordinate.latitude < 53.884336 ||
           groupAnnotation.coordinate.longitude > 26.869350 ||
           groupAnnotation.coordinate.longitude < 20.780434) {
            NSLog(@"Outside Lithuania borders %@", groupAnnotation);
            [groupedAnnotations removeObject:groupAnnotation];
        }
    }
    [_mapView addAnnotations:groupedAnnotations];

    _activityIndicator.hidden = YES;
}

- (void)touchesSearch
{
    [self performSegueWithIdentifier:@"SegueProblemsMapToProblemsFilter" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[PCGroupAnnotation class]]) {
        PCGroupAnnotation *groupAnnotation = annotation;
        
        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:@"PCGroupAnnotation"];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:groupAnnotation reuseIdentifier:@"PCGroupAnnotation"];
            annotationView.image = [UIImage imageNamed:@"groupAnnotation"];

            CGRect labelFrame = annotationView.frame;
            labelFrame.origin = CGPointMake(5, 2);
            labelFrame.size.width -= 10;
            labelFrame.size.height -= 10;
            UILabel *label = [[UILabel alloc] initWithFrame:labelFrame];
            label.tag = TAG_ANNOTATION_VIEW_LABEL;
            label.text = [NSString stringWithFormat:@"%ld", (long)[groupAnnotation size]];
            label.textColor = [UIColor whiteColor];
            label.textAlignment = NSTextAlignmentCenter;
            label.adjustsFontSizeToFitWidth = YES;
            [annotationView addSubview:label];
        } else {
            annotationView.annotation = groupAnnotation;
            for (UIView *view in [annotationView subviews]) {
                if(view.tag == TAG_ANNOTATION_VIEW_LABEL) {
                    UILabel *label = (UILabel *)view;
                    label.text = [NSString stringWithFormat:@"%ld", (long)[groupAnnotation size]];
                }
            }
        }
        
        return annotationView;
    } else if([annotation isKindOfClass:[PCAnnotation class]]) {
        PCAnnotation *pcAnnotation = annotation;

        MKAnnotationView *annotationView = [_mapView dequeueReusableAnnotationViewWithIdentifier:@"PCAnnotation"];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:pcAnnotation reuseIdentifier:@"PCAnnotation"];
        } else {
            annotationView.annotation = pcAnnotation;
        }
        
        annotationView.canShowCallout = YES;
        annotationView.image = [UIImage imageNamed:pcAnnotation.image];
        annotationView.calloutOffset = CGPointMake(0, 0);
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return annotationView;
    } else {
        NSLog(@"nil");
        return nil;
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if([view.annotation isKindOfClass:[PCAnnotation class]]) {
        PCAnnotation *annotation = view.annotation;
        
        [self performSegueWithIdentifier:@"SegueProblemsMapToSingleProblem" sender:annotation];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SegueProblemsMapToSingleProblem"])
    {
        PCAnnotation *annotation = sender;
        SingleProblemTableViewController *singleProblemTableViewController = [segue destinationViewController];
        singleProblemTableViewController.docNo = annotation.docNo;
        singleProblemTableViewController.address = annotation.title;
    }
    else if ([[segue identifier] isEqualToString:@"SegueProblemsMapToProblemsFilter"])
    {
        ProblemsFilterTableViewController *problemsFilter = [segue destinationViewController];
        problemsFilter.delegate = self;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if(mapView.region.span.latitudeDelta < ANNOTATIONS_EXPAND_FACTOR2) {
        if(previousZoomLevel >= ANNOTATIONS_EXPAND_FACTOR2) {
            NSSet *annotationSet = [mapView annotationsInMapRect:mapView.visibleMapRect];
            [_mapView removeAnnotations:groupedAnnotations];
            for (id annotation in annotationSet) {
                if([annotation isKindOfClass:[PCGroupAnnotation class]]) {
                    PCGroupAnnotation *groupAnnotation = annotation;
                    [_mapView addAnnotations:groupAnnotation.annotations];
                }
            }
        } else {
            [mapView removeAnnotations:mapView.annotations];
            
            for (PCAnnotation *annotation in annotations) {
                MKMapPoint point = MKMapPointForCoordinate(annotation.coordinate);
                if(MKMapRectContainsPoint(mapView.visibleMapRect, point)) {
                    [mapView addAnnotation:annotation];
                }
            }
        }
    } else if(mapView.region.span.latitudeDelta > ANNOTATIONS_EXPAND_FACTOR2 &&
              mapView.region.span.latitudeDelta < ANNOTATIONS_EXPAND_FACTOR &&
              (previousZoomLevel <= ANNOTATIONS_EXPAND_FACTOR2 || previousZoomLevel > ANNOTATIONS_EXPAND_FACTOR)) {
        [mapView removeAnnotations:mapView.annotations];
        [self updateMapAnnotationsGroupedWithFactor:ANNOTATIONS_GROUP_FACTOR2];
    } else if(mapView.region.span.latitudeDelta > ANNOTATIONS_EXPAND_FACTOR &&
              previousZoomLevel <= ANNOTATIONS_EXPAND_FACTOR) {
        [mapView removeAnnotations:mapView.annotations];
        [self updateMapAnnotationsGroupedWithFactor:ANNOTATIONS_GROUP_FACTOR];
    }
    
    previousZoomLevel = mapView.region.span.latitudeDelta;
}

- (void)problemsFilterWithAddress:(NSString*)address description:(NSString*)description type:(NSInteger)problemType registrationDate:(NSDate*)registrationDate docNo:(NSString *)docNo {
    reloadBeforeAppear = YES;
    [annotations removeAllObjects];
    [groupedAnnotations removeAllObjects];
    
    if([address length]) {
        [filters setValue:address forKey:@"address"];
    } else {
        [filters setValue:[NSNull null] forKey:@"address"];
    }
    
    if([description length]) {
        [filters setValue:description forKey:@"description"];
    } else {
        [filters setValue:[NSNull null] forKey:@"description"];
    }
    
    if(problemType) {
        [filters setValue:[appDelegate.problemTypes objectAtIndex:problemType - 1] forKey:@"problemType"];
    } else {
        [filters setValue:[NSNull null] forKey:@"problemType"];
    }
    
    if(registrationDate != nil) {
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        NSString *date = [dateFormat stringFromDate:registrationDate];
        
        [filters setValue:date forKey:@"date"];
    } else {
        [filters setValue:[NSNull null] forKey:@"date"];
    }
    
    if([docNo length]) {
        [filters setValue:docNo forKey:@"docNo"];
    } else {
        [filters setValue:[NSNull null] forKey:@"docNo"];
    }
}

- (IBAction)changeMapType:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [_mapView setMapType:MKMapTypeSatellite];
            break;
        case 1:
            [_mapView setMapType:MKMapTypeHybrid];
            break;
        case 2:
            [_mapView setMapType:MKMapTypeStandard];
            break;
            
        default:
            break;
    }
}

@end





