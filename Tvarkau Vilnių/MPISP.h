//
//  MPISP.h
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 06/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#define PC_DEBUG = 1;

@interface MPISP : NSObject

+ (void)loginUser:(NSString*)username withPassword:(NSString*)password completionHandler:(void (^)(NSDictionary *, NSError *))handler;
+ (void)logoutSession:(NSString*)session completionHandler:(void (^)(BOOL, NSError *))handler;
+ (NSString*)registerUser:(NSString*)username withPassword:(NSString*)password email:(NSString*)email phoneNo:(NSString*)phoneNo imei:(NSString*)imei error:(NSUInteger*)error;
+ (void)getProblemTypesWithCompletionHandler:(void (^)(NSArray *problemTypes, NSError *error))handler;
+ (void)newProblemWithSession:(NSString*)session description:(NSString*)description type:(NSString*)type address:(NSString*)address x:(float)x y:(float)y email:(NSString*)email phone:(NSString*)phone photos:(NSArray*)photos completionHandler:(void (^)(BOOL, NSError *))handler;

+ (void)getProblemsStarting:(NSUInteger)start limit:(NSUInteger)limit completionHandler:(void (^)(NSArray *, NSError *))handler;
+ (void)getProblemsStarting:(NSUInteger)start limit:(NSUInteger)limit withFiltersDescription:(NSString *)descriptionFilter type:(NSString *)typeFilter address:(NSString *)addressFilter reporter:(NSString *)reporterFilter date:(NSString *)dateFilter docNo:(NSString *)docNo completionHandler:(void (^)(NSArray *, NSError *))handler;

+ (void)getProblemWithDocNo:(NSString*)docNo completionHandler:(void (^)(NSDictionary *, NSError *))handler;

+ (void)getAddresses:(NSString*)address limit:(NSUInteger)limit completionHandler:(void (^)(NSArray *responseData, NSError *responseError)) handler;

+ (void)getAddressWithLocation:(CLLocationCoordinate2D)location completionHandler:(void (^)(NSString* address, NSError *responseError))handler;
+ (void)geolocationUsingAddress:(NSString *)address handle:(void (^)(CLLocationCoordinate2D location, NSError *error))handler;

@end
