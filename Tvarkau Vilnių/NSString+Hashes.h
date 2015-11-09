//
//  NSString+SHA1.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 02/05/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Hashes)

@property (nonatomic, readonly) NSString *md5;
@property (nonatomic, readonly) NSString *sha1;
@property (nonatomic, readonly) NSString *sha224;
@property (nonatomic, readonly) NSString *sha256;
@property (nonatomic, readonly) NSString *sha384;
@property (nonatomic, readonly) NSString *sha512;

@end
