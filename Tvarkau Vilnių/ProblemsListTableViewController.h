//
//  ProblemsListTableViewController.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 09/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ProblemsFilterTableViewController.h"

@interface ProblemsListTableViewController : UITableViewController<ProblemsFilterDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSString *filterReporter;

@end
