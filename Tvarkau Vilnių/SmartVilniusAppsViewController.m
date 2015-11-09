//
//  SmartVilniusAppsViewController.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 21/07/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "SmartVilniusAppsViewController.h"

@implementation SmartVilniusAppsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)openMParking:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/lt/app/m.parking/id695574873?mt=8"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)openMTicket:(id)sender {
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/lt/app/m.ticket/id751301884?mt=8"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)openVisitVilnius:(id)sender
{
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/lt/app/visit-vilnius/id814351651?mt=8"];
    [[UIApplication sharedApplication] openURL:url];
}

@end
