//
//  PCAnotation.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 09/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "PCAnnotation.h"

@implementation PCAnnotation

- (id)initWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude title:(NSString*)title subtitle:(NSString*)subtitle image:(NSString*)image docNo:(NSString*)docNo
{
    if(self == nil)
    {
        self = [super init];
    }
    
    _coordinate.latitude = latitude;
    _coordinate.longitude = longitude;
    _title = title;
    _subtitle = subtitle;
    _image = image;
    _docNo = docNo;
    
    return self;
}

- (NSString*)problemDescription
{
//    return  [NSString stringWithFormat:@"PCAnnotation. Coordinate:%f, %f Title:%@, Subtitle:%@, DocNo:%@ Image:%@",
//             _coordinate.latitude, _coordinate.longitude,
//             _title, _subtitle,
//             _docNo,
//             _image];
    
//    return  [NSString stringWithFormat:@"PCAnnotation. Coordinate:%f, %f Title:%@", _coordinate.latitude, _coordinate.longitude, _title];

    return  [NSString stringWithFormat:@"PCAnnotation. Coordinate:%f, %f", _coordinate.latitude, _coordinate.longitude];
}

@end
