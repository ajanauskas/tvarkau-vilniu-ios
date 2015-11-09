//
//  PCGroupAnnotation.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 23/07/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "PCGroupAnnotation.h"

@implementation PCGroupAnnotation

- (instancetype)init
{
    self = [super init];
    if(self) {
        _annotations = [[NSMutableArray alloc] init];
        _coordinate = CLLocationCoordinate2DMake(0, 0);
    }
    
    return self;
}

- (NSInteger)size
{
    return [_annotations count];
}

- (instancetype)initAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    self = [self init];
    if(self) {
        _coordinate = coordinate;
    }
    
    return self;
}

- (void)addAnnotation:(PCAnnotation *)annotation
{
    [_annotations addObject:annotation];
}

- (NSString *)problemDescription
{
    return [NSString stringWithFormat:@"PCGroupAnnotation. Latitude:%f Longitude:%f Size:%ld",
            _coordinate.latitude, _coordinate.longitude,
            (long)[self size]];
//    return [NSString stringWithFormat:@"PCGroupAnnotation. Coordinates:%f, %f Size:%ld X:%@",
//            _coordinate.latitude, _coordinate.longitude,
//            (long)[self size],
//            _annotations[0]];
}

@end
