//
//  NSString+Email.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 18/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Checks)

@property (nonatomic, readonly) BOOL isValidEmail;
@property (nonatomic, readonly) BOOL isLithuanianPhoneNumber;

@end
