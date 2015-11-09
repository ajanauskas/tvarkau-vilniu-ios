//
//  XRSA.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 27/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XRSA : NSObject {
    SecKeyRef publicKey;
    SecCertificateRef certificate;
    SecPolicyRef policy;
    SecTrustRef trust;
    size_t maxPlainLen;
}

- (id)initWithData:(NSData *)keyData;
- (id)initWithPublicKey:(NSString *)publicKeyPath;

- (NSData *) encryptWithData:(NSData *)content;
- (NSData *) encryptWithString:(NSString *)content;
- (NSString *) encryptToString:(NSString *)content;

@end