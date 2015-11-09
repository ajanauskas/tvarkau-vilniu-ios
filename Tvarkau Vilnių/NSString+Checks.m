//
//  NSString+Email.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 18/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "NSString+Checks.h"

@implementation NSString (Checks)

- (BOOL)isValidEmail
{
    // stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    // laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"];
    return [emailTest evaluateWithObject:self];
}

- (BOOL)isLithuanianPhoneNumber
{
    NSPredicate *shortFormatPhoneNumberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"[0-9]{9}"];
    if([shortFormatPhoneNumberTest evaluateWithObject:self])
    {
        return YES;
    }

    NSPredicate *fullFormatPhoneNumberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", @"\\+370[0-9]{8}"];
    if([fullFormatPhoneNumberTest evaluateWithObject:self])
    {
        return YES;
    }
    
//    if([self characterAtIndex:0] == '+')
//    {
//        return [self length] == 12;
//    }
//    else
//    {
//        return [self length] == 9;
//    }
    
    return NO;
}

@end