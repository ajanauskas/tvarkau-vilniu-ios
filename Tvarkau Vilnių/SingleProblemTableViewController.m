//
//  SingleProblemTableViewController.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 10/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "SingleProblemTableViewController.h"
#import "MPISP.h"
#import "PCAnnotation.h"

@implementation SingleProblemTableViewController

@synthesize tableView = _tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    UIPinchGestureRecognizer *mapGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
    [_mapView addGestureRecognizer:mapGestureRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    if(!loaded) {
        [self.navigationController setNavigationBarHidden:NO];
        self.navigationItem.title = _address;
        
        cellHeight[0] = 221;
        cellHeight[1] = 30;
        cellHeight[2] = 100;
        cellHeight[3] = 30;
        cellHeight[4] = 300;
        cellHeight[5] = 10;
        showPhotosRow = YES;
        
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cellHeight[4] = 379;
        }
        
        _activityIndicator.hidden = NO;
        _imagesScrollView.hidden = YES;
        _pageControl.hidden = YES;
        _titleDocNo.hidden = YES;
        _statusImage.hidden = YES;
        _problemDescription.hidden = YES;
        _mapView.hidden = YES;
        
        [MPISP getProblemWithDocNo:_docNo completionHandler:^(NSDictionary *problem, NSError *error) {
            if(error == nil) {
                _titleDocNo.text = [problem valueForKey:@"docNo"];
                _titleDocNo.hidden = NO;
                
                if([[problem valueForKey:@"status"] isEqualToString:@"Atlikta"]) {
                    _statusImage.image = [UIImage imageNamed:@"statusExecuted"];
                } else {
                    _statusImage.image = [UIImage imageNamed:@"statusExecuting"];
                }
                _statusImage.hidden = NO;
                
                NSString *question = [problem valueForKey:@"description"];
                NSString *answer = [problem valueForKey:@"answer"];
                [self initDescriptionWithQuestion:question answer:answer];
                
                NSString *problemAssignee = [problem valueForKey:@"assignee"];
                [self initProblemAssignee:problemAssignee];
                
                NSNumber *latitude = [problem objectForKey:@"y"];
                NSNumber *longitude = [problem objectForKey:@"x"];
                [self initMapAtLatitude:[latitude doubleValue] longitude:[longitude doubleValue]];
                
                photos = [problem objectForKey:@"photo"];
                [self initPhotos:photos];
                
                [self.tableView reloadData];
                _activityIndicator.hidden = YES;
                loaded = YES;
            } else {
                [[[UIAlertView alloc]initWithTitle:@"Klaida" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
        }];
    }
}

- (void)initMapAtLatitude:(double)latitude longitude:(double)longitude
{
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(latitude, longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.02, 0.02);
    [_mapView setRegion:MKCoordinateRegionMake(center, span) animated:YES];
    PCAnnotation *annotation = [[PCAnnotation alloc] init];
    annotation.coordinate = center;
    [_mapView addAnnotation:annotation];
    _mapView.hidden = NO;
    
}

- (void)initProblemAssignee:(NSString*)problemAssignee
{
    UIFont *bold = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    
    NSMutableAttributedString *str;
    if(problemAssignee && (id)problemAssignee != [NSNull null]) {
        str = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"Vykdytojas: %@", problemAssignee]];
    } else {
        str = [[NSMutableAttributedString alloc] initWithString:@"Vykdytojas: "];
    }
    [str addAttribute:NSFontAttributeName value:bold range:NSMakeRange(0, 12)];
    _assignee.attributedText = str;
    cellHeight[3] = [self calculateRequiredLabelHeight:_assignee] + 9;
}

- (void)initPhotos:(id)photo
{
    NSUInteger photosCount = 0;
    if(photo != nil && photo != [NSNull null]) {
        if([photo isKindOfClass:[NSArray class]]) {
            for (NSUInteger index = 0; index < [photo count]; index++) {
                [self addPhoto:[photo objectAtIndex:index] atX:photosCount * _imagesScrollView.frame.size.width];
                photosCount++;
            }
        } else {
            [self addPhoto:photo atX:photosCount * _imagesScrollView.frame.size.width];
            photosCount++;
        }
    }
    _imagesScrollViewContentWidth.constant = photosCount * _imagesScrollView.frame.size.width;
    _imagesScrollView.hidden = NO;
    
    if(photosCount > 0) {
        _imagesScrollView.delegate = self;
        _pageControl.numberOfPages = photosCount;
        _pageControl.currentPage = 0;
        _pageControl.hidden = NO;
    } else {
        showPhotosRow = NO;
        [_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    }
}

- (void)initDescriptionWithQuestion:(NSString*)question answer:(NSString*)answer
{
    UIFont *bold = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    
    NSString *questionString = [NSString stringWithFormat:@"Problemos aprašymas: %@", question];
    NSMutableAttributedString *descriptionText = [[NSMutableAttributedString alloc] initWithString:questionString];
    [descriptionText addAttribute:NSFontAttributeName value:bold range:NSMakeRange(0, 20)];
    if(answer && (id)answer != [NSNull null]) {
        NSMutableAttributedString *lineBreak = [[NSMutableAttributedString alloc] initWithString:@"\r\n\r\n"];
        [descriptionText appendAttributedString:lineBreak];
        
        NSString *answerString = [NSString stringWithFormat:@"Atsakymas: %@", answer];
        NSMutableAttributedString *answerText = [[NSMutableAttributedString alloc] initWithString:answerString];
        [answerText addAttribute:NSFontAttributeName value:bold range:NSMakeRange(0, 10)];
        [descriptionText appendAttributedString:answerText];
    }
    _problemDescription.editable = YES;
    _problemDescription.attributedText = descriptionText;
    CGFloat descriptionHeight = [self textViewHeightForAttributedText:descriptionText withWidth:_problemDescription.frame.size.width];
    _descriptionHeight.constant = descriptionHeight + 5;
    cellHeight[2] = _descriptionHeight.constant + 9;
    _problemDescription.hidden = NO;
    _problemDescription.editable = NO;
}

- (void)addPhoto:(NSString*)photo atX:(CGFloat)x
{
    CGRect frame = CGRectMake(x, 0, _imagesScrollView.frame.size.width, _imagesScrollView.frame.size.height);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"data:image;base64,%@", photo]];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:imageData];
    imageView.image = image;
    [_imagesScrollViewContent addSubview:imageView];
}

- (CGFloat)textViewHeightForAttributedText:(NSAttributedString*)text withWidth:(CGFloat)width {
    UITextView *calculationView = [[UITextView alloc] init];
    [calculationView setAttributedText:text];
    CGSize size = [calculationView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

- (CGFloat)calculateRequiredLabelHeight:(UILabel*)view
{
    CGSize maxSize = CGSizeMake(view.frame.size.width, CGFLOAT_MAX);
    NSAttributedString *attributedText = view.attributedText;
    CGRect attributedTextRect = [attributedText boundingRectWithSize:maxSize
                                                             options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                             context:nil];
    return attributedTextRect.size.height;
}

- (void)handlePinch:(UIPinchGestureRecognizer*)recognizer {
    static MKCoordinateRegion originalRegion;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        originalRegion = _mapView.region;
    }
    double latdelta = MAX(MIN(originalRegion.span.latitudeDelta / recognizer.scale, 130), 0.002);
    double londelta = MAX(MIN(originalRegion.span.longitudeDelta / recognizer.scale, 130), 0.002);
    MKCoordinateSpan span = MKCoordinateSpanMake(latdelta, londelta);
    [_mapView setRegion:MKCoordinateRegionMake(originalRegion.center, span) animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger additionalRows = 0;
    if(showPhotosRow) {
        additionalRows++;
    }
    
    return 4 + additionalRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger index = [indexPath row];
    if(!showPhotosRow) {
        index++;
    }
    return cellHeight[index];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    if(!showPhotosRow) {
        row++;
    }
    indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if([scrollView isEqual:_imagesScrollView]) {
        CGFloat pageWidth = scrollView.frame.size.width;
        _pageControl.currentPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    }
}

- (IBAction)changePage:(UIPageControl *)sender {
    CGPoint contentOffset = CGPointMake(_imagesScrollView.frame.size.width * sender.currentPage, 0);
    [_imagesScrollView setContentOffset:contentOffset animated:YES];
}

- (void)orientationChanged:(NSNotification *)notification
{
    if(showPhotosRow && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        for (UIView *childView in _imagesScrollViewContent.subviews) {
            [childView removeFromSuperview];
        }
        
        [self initPhotos:photos];
    }
}

@end
