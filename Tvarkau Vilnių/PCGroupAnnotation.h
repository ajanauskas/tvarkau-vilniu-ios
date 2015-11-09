//
//  PCGroupAnnotation.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 23/07/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PCAnnotation.h"

@interface PCGroupAnnotation : NSObject<MKAnnotation>

@property(nonatomic, readonly) NSMutableArray *annotations;
@property(nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (NSInteger)size;
- (instancetype)initAtCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)addAnnotation:(PCAnnotation *)annotation;

@end
