//
//  AddressController.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 21/07/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "AddressController.h"
#import "MPISP.h"

@implementation AddressController

static int ADDRESS_LIMIT = 20;

- (instancetype)init
{
    self = [super init];
    if(self) {
        _addresses = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)clearList
{
    [_addresses removeAllObjects];
}

- (void)updateListWithAddressStringPart:(NSString*)address
{
    [_addresses removeAllObjects];
    
    if([address rangeOfString:@"Vilnius, "].location == 0) {
        address = [address stringByReplacingOccurrencesOfString:@"Vilnius, " withString:@""];
    }
    
    [MPISP getAddresses:address limit:ADDRESS_LIMIT completionHandler:^(NSArray *responseData, NSError *responseError) {
        if(responseData != nil && (id)responseData != [NSNull null] && [responseData count]) {
            for (NSDictionary *address in responseData) {
                [_addresses addObject:[address objectForKey:@"value"]];
            }
        }
        
        [_delegate addressListDidUpdate];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_addresses count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressCell"];
    }
    cell.textLabel.text = [_addresses objectAtIndex:[indexPath row]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [_delegate addressDidSelect:[_addresses objectAtIndex:[indexPath row]]];
}

@end



