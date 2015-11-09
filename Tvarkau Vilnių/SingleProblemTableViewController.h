//
//  SingleProblemTableViewController.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 10/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SingleProblemTableViewController : UITableViewController<UIScrollViewDelegate>
{
//    CGFloat imagesCellHeight, descriptionCellHeight, authorCellHeight, assigneeCellHeight;
    BOOL showPhotosRow;
    BOOL loaded;
    NSInteger cellHeight[6];
    id photos;
}

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITableViewCell *imagesCell;
@property (weak, nonatomic) IBOutlet UIScrollView *imagesScrollView;
@property (weak, nonatomic) IBOutlet UIView *imagesScrollViewContent;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesScrollViewContentWidth;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *titleDocNo;
@property (weak, nonatomic) IBOutlet UIImageView *statusImage;
@property (weak, nonatomic) IBOutlet UITextView *problemDescription;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionHeight;
@property (weak, nonatomic) IBOutlet UILabel *assignee;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property(strong, nonatomic) NSString *docNo;
@property(strong, nonatomic) NSString *address;

- (IBAction)changePage:(UIPageControl *)sender;

@end
