//
//  PublicKeyEncoding.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 27/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicKeyEncoding : NSObject
{
    SecKeyRef publicKeyRef;
    size_t maxPlainLength;
}

+ (id)publicKeyFromFile:(NSString*)filePath;
+ (id)publicKeyWithPathForResource:(NSString*)pathForResource ofType:(NSString*)typeOfResource;
- (id)initWithPublicKey:(NSString*)key;
- (NSString*)encryptStringWithString:(NSString *)content;

@end
