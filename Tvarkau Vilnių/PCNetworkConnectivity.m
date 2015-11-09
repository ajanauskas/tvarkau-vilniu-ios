//
//  NetworkConnectivity.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 04/07/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "PCNetworkConnectivity.h"
#include <unistd.h>
#include <netdb.h>

@implementation PCNetworkConnectivity

+ (BOOL)isNetworkAvailable
{
    char *hostname;
    struct hostent *hostinfo;
    hostname = "google.com";
    hostinfo = gethostbyname(hostname);
    if (hostinfo == NULL)
    {
        [[[UIAlertView alloc] initWithTitle:@"Klaida" message:@"Nėra interneto ryšio" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
        return NO;
    }
    else
    {
        return YES;
    }
}

@end
