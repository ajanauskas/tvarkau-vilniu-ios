//
//  AddressController.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 21/07/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AddressControllerDelegate <NSObject>

- (void)addressDidSelect:(NSString *)address;
- (void)addressListDidUpdate;

@end

@interface AddressController : NSObject <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, weak) id<AddressControllerDelegate>delegate;
@property(nonatomic, readonly)NSMutableArray *addresses;

- (void)clearList;
- (void)updateListWithAddressStringPart:(NSString*)address;

@end
