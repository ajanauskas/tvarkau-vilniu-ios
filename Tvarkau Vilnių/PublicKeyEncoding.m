//
//  PublicKeyEncoding.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 27/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "PublicKeyEncoding.h"
#import "NSData+Base64.h"

@implementation PublicKeyEncoding

+ (id)publicKeyWithPathForResource:(NSString*)pathForResource ofType:(NSString*)typeOfResource
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:pathForResource ofType:typeOfResource];
    NSString *keyData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    PublicKeyEncoding *publicKeyEncoding = [[PublicKeyEncoding alloc] initWithPublicKey:keyData];
    
    return publicKeyEncoding;
}

+ (id)publicKeyFromFile:(NSString *)filePath
{
    NSString *keyData = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    PublicKeyEncoding *publicKeyEncoding = [[PublicKeyEncoding alloc] initWithPublicKey:keyData];

    return publicKeyEncoding;
}

- (id)initWithPublicKey:(NSString*)key
{
    self = [super init];
    if(self)
    {
        NSString *s_key = [NSString string];
        NSArray  *a_key = [key componentsSeparatedByString:@"\n"];
        BOOL     f_key  = FALSE;
        
        for (NSString *a_line in a_key)
        {
            if ([a_line isEqualToString:@"-----BEGIN PUBLIC KEY-----"])
            {
                f_key = TRUE;
            }
            else if ([a_line isEqualToString:@"-----END PUBLIC KEY-----"])
            {
                f_key = FALSE;
            }
            else if (f_key)
            {
                s_key = [s_key stringByAppendingString:a_line];
            }
        }
        if (s_key.length == 0)
        {
            return nil;
        }
        
        // This will be base64 encoded, decode it.
        NSData *d_key = [NSData dataFromBase64String:s_key];
        d_key = [self stripPublicKeyHeader:d_key];
        if (d_key == nil)
        {
            return nil;
        }
        
        NSString *tag = @"pubkey";
        NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
        
        // Delete any old lingering key with the same tag
        NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
        [publicKey setObject:(id) CFBridgingRelease(kSecClassKey) forKey:(id)CFBridgingRelease(kSecClass)];
        [publicKey setObject:(id) CFBridgingRelease(kSecAttrKeyTypeRSA) forKey:(id)CFBridgingRelease(kSecAttrKeyType)];
        [publicKey setObject:d_tag forKey:(id)CFBridgingRelease(kSecAttrApplicationTag)];
        SecItemDelete((CFDictionaryRef)CFBridgingRetain(publicKey));
        
        CFTypeRef persistKey = nil;
        
        // Add persistent version of the key to system keychain
        [publicKey setObject:d_key forKey:(id)CFBridgingRelease(kSecValueData)];
        [publicKey setObject:(id) CFBridgingRelease(kSecAttrKeyClassPublic) forKey:(id)
         CFBridgingRelease(kSecAttrKeyClass)];
        [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)
         CFBridgingRelease(kSecReturnPersistentRef)];
        
        OSStatus secStatus = SecItemAdd((CFDictionaryRef)CFBridgingRetain(publicKey), &persistKey);
        if (persistKey != nil)
        {
            CFRelease(persistKey);
        }
        
        if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
        {
            publicKey = nil;
            return nil;
        }
        
        // Now fetch the SecKeyRef version of the key
        publicKeyRef = nil;
        
        [publicKey removeObjectForKey:(id)CFBridgingRelease(kSecValueData)];
        [publicKey removeObjectForKey:(id)CFBridgingRelease(kSecReturnPersistentRef)];
        [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(id)CFBridgingRelease(kSecReturnRef)];
        [publicKey setObject:(id) CFBridgingRelease(kSecAttrKeyTypeRSA) forKey:(id)CFBridgingRelease(kSecAttrKeyType)];
        secStatus = SecItemCopyMatching((CFDictionaryRef)CFBridgingRetain(publicKey), (CFTypeRef *)&publicKeyRef);
        
        if (publicKeyRef == nil)
        {
            return nil;
        }
        
        maxPlainLength = SecKeyGetBlockSize(publicKeyRef) - 12;
    }
    
    return self;
}

- (NSData *)stripPublicKeyHeader:(NSData *)d_key
{
    // Skip ASN.1 public key header
    if (d_key == nil)
    {
        return nil;
    }
    
    NSUInteger len = [d_key length];
    if (!len)
    {
        return nil;
    }
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx    = 0;
    
    if (c_key[idx++] != 0x30)
    {
        return(nil);
    }
    
    if (c_key[idx] > 0x80)
    {
        idx += c_key[idx] - 0x80 + 1;
    }
    else
    {
        idx++;
    }
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] = { 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15))
    {
        return(nil);
    }
    
    idx += 15;
    
    if (c_key[idx++] != 0x03)
    {
        return(nil);
    }
    
    if (c_key[idx] > 0x80)
    {
        idx += c_key[idx] - 0x80 + 1;
    }
    else
    {
        idx++;
    }
    
    if (c_key[idx++] != '\0')
    {
        return(nil);
    }
    
    return [NSData dataWithBytes:&c_key[idx] length:len - idx];
}

- (NSData *)wrapSymmetricKey:(NSData *)content
{
    OSStatus sanityCheck = noErr;
    size_t cipherBufferSize = 0;
    size_t keyBufferSize = 0;
    
    NSData * cipher = nil;
    uint8_t * cipherBuffer = NULL;
    
    SecPadding kTypeOfWrapPadding = kSecPaddingPKCS1;
    
    // Calculate the buffer sizes.
    cipherBufferSize = SecKeyGetBlockSize(publicKeyRef);
    keyBufferSize = [content length];
    
    if (kTypeOfWrapPadding == kSecPaddingNone) {
        if(keyBufferSize > cipherBufferSize)
        {
            NSLog(@"Nonce integer is too large and falls outside multiplicative group.");
        }
    } else {
        if(keyBufferSize > (cipherBufferSize - 11))
        {
            NSLog(@"Nonce integer is too large and falls outside multiplicative group.");
        }
    }
    
    // Allocate some buffer space. I don't trust calloc.
    cipherBuffer = malloc( cipherBufferSize * sizeof(uint8_t) );
    memset((void *)cipherBuffer, 0x0, cipherBufferSize);
    
    // Encrypt using the public key.
    sanityCheck = SecKeyEncrypt(	publicKeyRef,
                                kTypeOfWrapPadding,
                                (const uint8_t *)[content bytes],
                                keyBufferSize,
                                cipherBuffer,
                                &cipherBufferSize
                                );
    
    if(sanityCheck != noErr) {
        NSLog(@"Error encrypting, OSStatus == %d.", (int)sanityCheck);
    }
    
    // Build up cipher text blob.
    cipher = [NSData dataWithBytes:(const void *)cipherBuffer length:(NSUInteger)cipherBufferSize];
    
    if (cipherBuffer) free(cipherBuffer);
    
    return cipher;
}

- (NSData*)encryptDataWithData:(NSData *)content {
    NSLog(@"secKeyRef: %@", publicKeyRef);
    
    size_t plainLen = [content length];
    if (plainLen > maxPlainLength) {
        NSLog(@"content(%ld) is too long, must < %ld", plainLen, maxPlainLength);
        return nil;
    }
    
    void *plain = malloc(plainLen);
    [content getBytes:plain length:plainLen];
    
    size_t cipherLen = 128; // currently RSA key length is set to 128 bytes
    void *cipher = malloc(cipherLen);
    
    OSStatus returnCode = SecKeyEncrypt(publicKeyRef, kSecPaddingPKCS1, plain, plainLen, cipher, &cipherLen);
    
    NSData *result = nil;
    if (returnCode != 0)
    {
        NSLog(@"SecKeyEncrypt fail. Error Code: %d", (int)returnCode);
    }
    else
    {
        result = [NSData dataWithBytes:cipher
                                length:cipherLen];
    }
    
    free(plain);
    free(cipher);
    
    return result;
}

- (NSData *)encryptDataWithString:(NSString *)content
{
    return [self wrapSymmetricKey:[content dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSString*)encryptStringWithString:(NSString *)content
{
    NSData *data = [self encryptDataWithString:content];
    return [data base64EncodedString];// [self base64forData:data];
}

@end
