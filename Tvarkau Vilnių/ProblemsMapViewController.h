//
//  ProblemsMapViewController.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 09/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ProblemsFilterTableViewController.h"
#import "AppDelegate.h"
#import "PCGroupAnnotation.h"

@interface ProblemsMapViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, ProblemsFilterDelegate>
{
    AppDelegate *appDelegate;
    NSMutableArray *annotations;
    NSMutableDictionary *filters;
    BOOL reloadBeforeAppear;
    
    CGFloat previousZoomLevel;
    NSMutableArray *groupedAnnotations;
}

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) NSString *filterReporter;
@property (weak, nonatomic) IBOutlet UISegmentedControl *mapTypeControl;

- (IBAction)changeMapType:(UISegmentedControl *)sender;

@end
