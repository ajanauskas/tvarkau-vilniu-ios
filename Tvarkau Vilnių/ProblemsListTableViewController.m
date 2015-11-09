//
//  ProblemsListTableViewController.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 09/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "ProblemsListTableViewController.h"
#import "ProblemsListTableViewCell.h"
#import "MPISP.h"
#import "SingleProblemTableViewController.h"

static NSUInteger numberOfRowsPerLoad = 99;
static float reloadDistance = 40;

@implementation ProblemsListTableViewController
{
    AppDelegate *appDelegate;
    NSMutableArray *problems;
    UIImage *statusImageExecuted, *statusImageExecuting;
    BOOL loaded;
    NSInteger totalRows;
    NSMutableDictionary *filters;
    BOOL reloadBeforeAppear;
    BOOL allowReload;
}

@synthesize tableView = _tableView;
@synthesize filterReporter = _filterReporter;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(appDelegate == nil)
    {
        appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    
    self.clearsSelectionOnViewWillAppear = NO;
    
    allowReload = YES;
    [self updateProblemsList];
    
    reloadBeforeAppear = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(touchesSearch)];
    
    statusImageExecuted = [UIImage imageNamed:@"statusExecuted"];
    statusImageExecuting = [UIImage imageNamed:@"statusExecuting"];
    
    if(filters == nil)
    {
        filters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
         [NSNull null], @"description",
         [NSNull null], @"address",
         [NSNull null], @"problemType",
         [NSNull null], @"date",
         [NSNull null], @"docNo",
         nil];
    }
    
    if(reloadBeforeAppear)
    {
        [self updateProblemsList];
    }
}

- (void)updateProblemsList
{
    if(!allowReload)
    {
        return;
    }
    
    if(problems == nil)
    {
        problems = [[NSMutableArray alloc] init];
    }
    NSUInteger start = [problems count];
    id filterDescription = [filters objectForKey:@"description"];
    id filterAddress = [filters objectForKey:@"address"];
    id filterType = [filters objectForKey:@"problemType"];
    id filterDate = [filters objectForKey:@"date"];
    id filterDocNo = [filters objectForKey:@"docNo"];
    
    [MPISP getProblemsStarting:start limit:numberOfRowsPerLoad withFiltersDescription:filterDescription type:filterType address:filterAddress reporter:_filterReporter date:filterDate docNo:filterDocNo completionHandler:^(id problemsList, NSError *error) {
        if(error == nil)
        {
            if(problemsList == nil || problemsList == [NSNull null] || ![problemsList count])
            {
                allowReload = NO;
//                [[[UIAlertView alloc]initWithTitle:@"Klaida" message:@"Duomenų pagal pateiktą užklausą nepavyko gauti." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            }
            else
            {
//                for (NSDictionary *problem in problemsList) {
//                    if(![[problem valueForKey:@"status"] isEqualToString:@"Registruota"]) {
//                        NSLog(@"problem: %@ (%@)", [problem valueForKey:@"docNo"], [problem valueForKey:@"status"]);
//                    }
//                }
                [problems addObjectsFromArray:problemsList];
            }
        }
        else
        {
            [[[UIAlertView alloc]initWithTitle:@"Klaida" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        }
        
        totalRows = [problems count];
        [_tableView reloadData];
        loaded = YES;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return totalRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProblemsListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ProblemsListTableViewCell" forIndexPath:indexPath];
    if(cell == nil)
    {
        cell = [[ProblemsListTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ProblemsListTableViewCell"];
    }
    
    NSInteger index = [indexPath row];
    if([problems count] > index)
    {
        NSDictionary *problem = [problems objectAtIndex:index];
        if(problem != nil)
        {
            cell.tag = index;
            cell.title.hidden = NO;
            cell.problemDescription.hidden = NO;
            cell.status.hidden = NO;
            cell.loading.hidden = YES;
            
            cell.title.text = [problem valueForKey:@"docNo"];
            cell.problemDescription.text = [problem valueForKey:@"description"];
            if([[problem valueForKey:@"status"] isEqualToString:@"Atlikta"])
            {
                cell.status.image = statusImageExecuted;
            }
            else
            {
                cell.status.image = statusImageExecuting;
            }
        }
    }
    else
    {
        cell.title.hidden = YES;
        cell.problemDescription.hidden = YES;
        cell.status.hidden = YES;
        cell.loading.hidden = NO;
        [cell.loading startAnimating];
    }
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(allowReload && loaded)
    {
        CGPoint offset = scrollView.contentOffset;
        CGRect bounds = scrollView.bounds;
        CGSize size = scrollView.contentSize;
        UIEdgeInsets inset = scrollView.contentInset;
        float y = offset.y + bounds.size.height - inset.bottom;
        float h = size.height;
        
        if(y > h + reloadDistance) {
            loaded = NO;
            totalRows++;
            [_tableView reloadData];
            [self updateProblemsList];
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"SegueProblemsListToSingleProblem"]
        || [[segue identifier] isEqualToString:@"SegueProblemsListToSingleProblemView"])
    {
        NSDictionary *problem = [problems objectAtIndex:[sender tag]];
        SingleProblemTableViewController *singleProblemTableViewController = [segue destinationViewController];
        singleProblemTableViewController.docNo = [problem valueForKey:@"docNo"];
        singleProblemTableViewController.address = [problem valueForKey:@"address"];
    }
    else if ([[segue identifier] isEqualToString:@"SegueProblemsListToProblemsFilter"])
    {
        ProblemsFilterTableViewController *problemsFilter = [segue destinationViewController];
        problemsFilter.delegate = self;
    }
}

- (void)touchesSearch
{
    [self performSegueWithIdentifier:@"SegueProblemsListToProblemsFilter" sender:self];
}

- (void)problemsFilterWithAddress:(NSString*)address description:(NSString*)description type:(NSInteger)problemType registrationDate:(NSDate*)registrationDate docNo:(NSString *)docNo {
    allowReload = YES;
    reloadBeforeAppear = YES;
    
    [problems removeAllObjects];

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

@end
