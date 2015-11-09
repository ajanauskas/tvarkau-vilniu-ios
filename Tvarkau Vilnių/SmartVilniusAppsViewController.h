//
//  SmartVilniusAppsViewController.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 21/07/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SmartVilniusAppsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *checkMParking;
@property (weak, nonatomic) IBOutlet UIImageView *checkMTicket;
@property (weak, nonatomic) IBOutlet UIImageView *checkVisitVilnius;

- (IBAction)openMParking:(id)sender;
- (IBAction)openMTicket:(id)sender;
- (IBAction)openVisitVilnius:(id)sender;

@end
