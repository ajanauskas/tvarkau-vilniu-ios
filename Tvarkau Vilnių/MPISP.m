//
//  MPISP.m
//  Tvarkau Vilnių
//
//  Created by Paulius Cesekas on 06/06/14.
//  Copyright (c) 2014 ES4B. All rights reserved.
//

#import "MPISP.h"

static CGFloat MAX_IMAGE_SIZE = 1280.0;
static NSString *googleApiKey = @"AIzaSyAfMZcFV6MhKolBW5MlxRvVj-LffguNwjY";
static NSInteger ERROR_CODE_EMPTY_RESPONSE = 91919111;

@implementation MPISP

+ (void)loginUser:(NSString*)username withPassword:(NSString*)password completionHandler:(void (^)(NSDictionary *, NSError *))handler
{
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                username, @"login",
                                password, @"password",
                                nil];
    [self requestAsynchronousToMethod:@"login" withID:[[NSNumber alloc] initWithInt:1] parameters:parameters completionHandler:^(NSData *responseData, NSError *responseError) {
        if(responseError == nil)
        {
            NSError *parseError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&parseError];
            if(parseError == nil)
            {
                NSLog(@"LOGIN RESPONSE: %@", json);
                id error = [json objectForKey:@"error"];
                if(error == nil || error == [NSNull null])
                {
                    NSDictionary *result = [json objectForKey:@"result"];
                    handler(result, nil);
                }
                else
                {
                    NSInteger errorCode = [error integerValue];
                    NSDictionary *userInfo = [MPISP generateErrorWithCode:errorCode];
                    handler(nil, [NSError errorWithDomain:@"MPISP" code:0 userInfo:userInfo]);
                }
            }
            else
            {
                handler(nil, parseError);
            }
        }
        else
        {
            handler(nil, responseError);
        }
    }];
}

+ (void)logoutSession:(NSString*)session completionHandler:(void (^)(BOOL, NSError *))handler
{
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                session, @"session_id",
                                nil];
    [self requestAsynchronousToMethod:@"logout" withID:[[NSNumber alloc] initWithInt:2] parameters:parameters completionHandler:^(NSData *responseData, NSError *responseError) {
        if(responseError == nil)
        {
            NSError *parseError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&parseError];
            if(parseError == nil)
            {
                id error = [json objectForKey:@"error"];
                if(error == nil || error == [NSNull null])
                {
                    NSNumber *result = [json objectForKey:@"result"];
                    handler([result boolValue], nil);
                }
                else
                {
                    NSInteger errorCode = [error integerValue];
                    NSDictionary *userInfo = [MPISP generateErrorWithCode:errorCode];
                    handler(NO, [NSError errorWithDomain:@"MPISP" code:0 userInfo:userInfo]);
                }
            }
            else
            {
                handler(NO, parseError);
            }
        }
        else
        {
            handler(NO, responseError);
        }
    }];
}

+ (NSString*)registerUser:(NSString*)username withPassword:(NSString*)password email:(NSString*)email phoneNo:(NSString*)phoneNo imei:(NSString*)imei error:(NSUInteger*)error
{
    return nil;
}

+ (void)getProblemTypesWithCompletionHandler:(void (^)(NSArray *, NSError *))handler
{
    [self requestAsynchronousToMethod:@"get_problem_types" withID:[[NSNumber alloc] initWithInt:4] parameters:nil completionHandler:^(NSData *responseData, NSError *responseError) {
        if(responseError == nil)
        {
            NSError *parseError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&parseError];
            if(parseError == nil)
            {
                id error = [json objectForKey:@"error"];
                if(error == nil || error == [NSNull null])
                {
                    NSArray *problemTypes = [json objectForKey:@"result"];
                    handler(problemTypes, nil);
                }
                else
                {
                    NSInteger errorCode = [error integerValue];
                    NSDictionary *userInfo = [MPISP generateErrorWithCode:errorCode];
                    handler(nil, [NSError errorWithDomain:@"MPISP" code:0 userInfo:userInfo]);
                }
            }
            else
            {
                handler(nil, parseError);
            }
        }
        else
        {
            handler(nil, responseError);
        }
    }];
}

+ (void)newProblemWithSession:(NSString*)session description:(NSString*)description type:(NSString*)type address:(NSString*)address x:(float)x y:(float)y email:(NSString*)email phone:(NSString*)phone photos:(NSArray*)photos completionHandler:(void (^)(BOOL, NSError *))handler
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       session, @"session_id",
                                       description, @"description",
                                       type, @"type",
                                       address, @"address",
                                       [[NSNumber alloc] initWithFloat:x], @"x",
                                       [[NSNumber alloc] initWithFloat:y], @"y",
                                       email, @"email",
                                       phone, @"phone",
                                       [NSNull null], @"message_description",
                                       [NSNull null], @"photo",
                                       nil];

    if(![email length])
    {
        [parameters setValue:[NSNull null] forKey:@"email"];
    }
    if(![phone length])
    {
        [parameters setValue:[NSNull null] forKey:@"phone"];
    }
    
    if(photos != nil && [photos count] > 0)
    {
        if([photos count] > 1)
        {
            NSMutableArray *photosArray = [[NSMutableArray alloc] init];
            for (UIImage *photo in photos) {
                NSString *encodedString = [self encodedBase64StringWithImage:photo];
                [photosArray addObject:encodedString];
            }
            [parameters setValue:photosArray forKey:@"photo"];
        }
        else
        {
            UIImage *photo = [photos objectAtIndex:0];
            NSString *encodedString = [self encodedBase64StringWithImage:photo];
            [parameters setValue:encodedString forKey:@"photo"];
        }
    }
    
//    NSLog(@"parameters: %@", parameters);
//    handler(YES, nil);
    
    [self requestAsynchronousToMethod:@"new_problem" withID:[[NSNumber alloc] initWithInt:5] parameters:parameters completionHandler:^(NSData *responseData, NSError *responseError) {
        if(responseError == nil)
        {
            NSError *parseError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&parseError];
            if(parseError == nil)
            {
                id error = [json objectForKey:@"error"];
                if(error == nil || error == [NSNull null])
                {
                    handler(YES, nil);
                }
                else
                {
                    NSInteger errorCode = [error integerValue];
                    NSDictionary *userInfo = [MPISP generateErrorWithCode:errorCode];
                    handler(NO, [NSError errorWithDomain:@"MPISP" code:0 userInfo:userInfo]);
                }
            }
            else
            {
                handler(NO, parseError);
            }
        }
        else
        {
            handler(NO, responseError);
        }
    }];
}

+ (void)getProblemsStarting:(NSUInteger)start limit:(NSUInteger)limit completionHandler:(void (^)(NSArray *, NSError *))handler
{
    [self getProblemsStarting:start limit:limit withFiltersDescription:nil type:nil address:nil reporter:nil date:nil docNo:nil completionHandler:^(NSArray *problems, NSError *error) {
        handler(problems, error);
    }];
}

+ (void)getProblemsStarting:(NSUInteger)start limit:(NSUInteger)limit withFiltersDescription:(NSString *)descriptionFilter type:(NSString *)typeFilter address:(NSString *)addressFilter reporter:(NSString *)reporterFilter date:(NSString *)dateFilter docNo:(NSString *)docNo completionHandler:(void (^)(NSArray *, NSError *))handler
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                       [[NSNumber alloc] initWithInteger:start], @"start",
                                       [[NSNumber alloc] initWithInteger:limit], @"limit",
                                       [NSNull null], @"description_filter",
                                       [NSNull null], @"type_filter",
                                       [NSNull null], @"address_filter",
                                       [NSNull null], @"reporter_filter",
                                       [NSNull null], @"date_filter",
                                       [NSNull null], @"docNo_filter",
                                       nil];
    if(descriptionFilter != nil)
    {
        [parameters setValue:descriptionFilter forKey:@"description_filter"];
    }
    if(typeFilter != nil)
    {
        [parameters setValue:typeFilter forKey:@"type_filter"];
    }
    if(addressFilter != nil)
    {
        [parameters setValue:addressFilter forKey:@"address_filter"];
    }
    if(reporterFilter != nil)
    {
        [parameters setValue:reporterFilter forKey:@"reporter_filter"];
    }
    if(dateFilter != nil)
    {
        [parameters setValue:dateFilter forKey:@"date_filter"];
    }
    if(docNo != nil)
    {
        [parameters setValue:docNo forKey:@"docNo_filter"];
    }
    
    NSString *method = @"get_problems";
    if(!reporterFilter) {
        method = @"find_problems";
    }
    
    [self requestAsynchronousToMethod:method withID:[[NSNumber alloc] initWithInt:6] parameters:parameters completionHandler:^(NSData *responseData, NSError *responseError) {
        if(responseError == nil)
        {
            NSError *parseError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&parseError];
            if(parseError == nil)
            {
                id error = [json objectForKey:@"error"];
                if(error == nil || error == [NSNull null])
                {
                    NSArray *problems = [json objectForKey:@"result"];
                    handler(problems, nil);
                }
                else
                {
                    NSInteger errorCode = [error integerValue];
                    NSDictionary *userInfo = [MPISP generateErrorWithCode:errorCode];
                    handler(nil, [NSError errorWithDomain:@"MPISP" code:0 userInfo:userInfo]);
                }
            }
            else
            {
                NSLog(@"ERROR: %@", [parseError description]);
                NSLog(@"Response: %@", [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                handler(nil, parseError);
            }
        }
        else
        {
            if(responseError.code == ERROR_CODE_EMPTY_RESPONSE) {
                handler(nil, nil);
            } else {
                handler(nil, responseError);
            }
        }
    }];
}

+ (void)getProblemWithDocNo:(NSString*)docNo completionHandler:(void (^)(NSDictionary *, NSError *))handler
{
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:docNo, @"id", nil];
    [self requestAsynchronousToMethod:@"get_problem" withID:[[NSNumber alloc] initWithInt:7] parameters:parameters completionHandler:^(NSData *responseData, NSError *responseError) {
        if(responseError == nil)
        {
            NSError *parseError = nil;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&parseError];
            if(parseError == nil)
            {
                id error = [json objectForKey:@"error"];
                if(error == nil || error == [NSNull null])
                {
                    NSArray *problem = [json objectForKey:@"result"];
                    handler([problem objectAtIndex:0], nil);
                }
                else
                {
                    NSInteger errorCode = [error integerValue];
                    NSDictionary *userInfo = [MPISP generateErrorWithCode:errorCode];
                    handler(nil, [NSError errorWithDomain:@"MPISP" code:0 userInfo:userInfo]);
                }
            }
            else
            {
                handler(nil, parseError);
            }
        }
        else
        {
            handler(nil, responseError);
        }
    }];
}

+ (void)getAddresses:(NSString*)address limit:(NSUInteger)limit completionHandler:(void (^)(NSArray *responseData, NSError *responseError)) handler
{
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
                                address, @"string",
                                [[NSNumber alloc] initWithInteger:limit], @"limit",
                                nil];
    [self requestAsynchronousToMethod:@"get_addresses" withID:[[NSNumber alloc] initWithInt:8] parameters:parameters completionHandler:^(NSData *responseData, NSError *responseError) {
        if(responseError == nil)
        {
            NSError *parseError = nil;
            id json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&parseError];
            if([json isKindOfClass:[NSDictionary class]])
            {
                if(parseError == nil)
                {
                    id error = [json objectForKey:@"error"];
                    if(error == nil || error == [NSNull null])
                    {
                        NSArray *result = [json objectForKey:@"result"];
                        handler(result, nil);
                    }
                    else
                    {
                        NSInteger errorCode = [error integerValue];
                        NSDictionary *userInfo = [MPISP generateErrorWithCode:errorCode];
                        handler(nil, [NSError errorWithDomain:@"MPISP" code:0 userInfo:userInfo]);
                    }
                }
                else
                {
                    handler(nil, parseError);
                }
            }
            else
            {
                handler(json, nil);
            }
        }
        else
        {
            handler(nil, responseError);
        }
    }];
}

+ (void)requestAsynchronousToMethod:(NSString*)method withID:(NSNumber *)requestID parameters:(id)parameters completionHandler:(void (^)(NSData* responseData, NSError *responseError)) handler
{
    NSDictionary *post;
    
    if(parameters == nil)
    {
        post = [[NSDictionary alloc] initWithObjectsAndKeys:
                requestID, @"id",
                method, @"method",
                [NSNull null], @"params",
                nil];
    }
    else
    {
        post = [[NSDictionary alloc] initWithObjectsAndKeys:
                requestID, @"id",
                method, @"method",
                parameters, @"params",
                nil];
    }

    NSError *jsonError;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:post options:0 error:&jsonError];
    if(jsonError != nil)
    {
        NSString *errorDescription = [NSString stringWithFormat:@"Can't create postData. Error: %@", jsonError];
        NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, nil];
        handler(nil, [NSError errorWithDomain:@"MPISP" code:0 userInfo:userInfo]);
        return;
    }
    
    NSURL *url = [NSURL URLWithString:@"http://www.vilnius.lt/m/m_problems/files/mobile/server.php"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *connectionError) {
        if(connectionError == nil)
        {
            if(responseData == nil || responseData.length == 0)
            {
                NSString *errorDescription = @"Response empty";
                NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, nil];
                handler(nil, [NSError errorWithDomain:@"MPISP" code:ERROR_CODE_EMPTY_RESPONSE userInfo:userInfo]);
                return;
            }
            else
            {
#ifdef PC_DEBUG
                id json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
                if([json isKindOfClass:[NSDictionary class]])
                {
                    id error = [json objectForKey:@"error"];
                    if(error != [NSNull null])
                    {
                        NSLog(@"REQUEST:%@", [NSString stringWithUTF8String:[postData bytes]]);
                    }
                }
#endif
                
                handler(responseData, nil);
            }
        }
        else
        {
            NSString *errorDescription = [NSString stringWithFormat:@"Nėra interneto ryšio"];
            NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, nil];
            handler(nil, [NSError errorWithDomain:@"MPISP" code:0 userInfo:userInfo]);
            return;
        }
    }];
}

+ (NSDictionary*)generateErrorWithCode:(NSInteger)errorCode
{
    switch (errorCode) {
        case 1:
            return [[NSDictionary alloc] initWithObjectsAndKeys:@"Serverio klaida", NSLocalizedDescriptionKey, nil];
            break;
        case 2:
            return [[NSDictionary alloc] initWithObjectsAndKeys:@"Neteisingai suformuota užklausa", NSLocalizedDescriptionKey, nil];
            break;
        case 3:
            return [[NSDictionary alloc] initWithObjectsAndKeys:@"Nenurodyti būtini parametrai", NSLocalizedDescriptionKey, nil];
            break;
        case 4:
            return [[NSDictionary alloc] initWithObjectsAndKeys:@"Klaidingas vartotojo vardas", NSLocalizedDescriptionKey, nil];
            break;
        case 5:
            return [[NSDictionary alloc] initWithObjectsAndKeys:@"Neteisingas sesijos ID", NSLocalizedDescriptionKey, nil];
            break;
            
        default:
            return [[NSDictionary alloc] initWithObjectsAndKeys:@"Nežinoma klaida", NSLocalizedDescriptionKey, nil];
            break;
    }
}

+ (NSString *)encodedBase64StringWithImage:(UIImage *)image
{
    CGSize newSize = CGSizeZero;
    BOOL portrait = image.size.width < image.size.height;
    if(portrait)
    {
        if(image.size.height > MAX_IMAGE_SIZE)
        {
            newSize.height = MAX_IMAGE_SIZE;
            newSize.width = image.size.width * MAX_IMAGE_SIZE / image.size.height;
        }
        else
        {
            newSize = image.size;
        }
    }
    else
    {
        if(image.size.width > MAX_IMAGE_SIZE)
        {
            newSize.width = MAX_IMAGE_SIZE;
            newSize.height = image.size.height * MAX_IMAGE_SIZE / image.size.width;
        }
        else
        {
            newSize = image.size;
        }
    }
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // encode image to base64
    NSData *imageData = UIImageJPEGRepresentation(UIGraphicsGetImageFromCurrentImageContext(), 0.9);
    UIGraphicsEndImageContext();
    NSString *encodedString = [imageData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedString;
}

+ (void)getAddressWithLocation:(CLLocationCoordinate2D)location completionHandler:(void (^)(NSString* address, NSError *responseError))handler
{
    NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&key=%@&location_type=ROOFTOP&result_type=street_address", location.latitude, location.longitude, googleApiKey];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *connectionError) {
        if(connectionError == nil)
        {
            if(responseData == nil)
            {
                NSString *errorDescription = @"Response empty";
                NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, nil];
                handler(nil, [NSError errorWithDomain:@"maps.googleapis.com" code:0 userInfo:userInfo]);
                return;
            }
            else
            {
                NSString *address = [self generateAddressWithGoogleResponseData:responseData];
                if(address) {
                    handler(address, nil);
                    return;
                } else {
                    NSString *errorDescription = [NSString stringWithFormat:@"Nepavyko surasti adreso"];
                    NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, nil];
                    NSError *error = [NSError errorWithDomain:@"maps.googleapis.com" code:0 userInfo:userInfo];
                    handler(nil, error);
                    return;
                }
            }
        }
        else
        {
            NSString *errorDescription = [NSString stringWithFormat:@"Nėra interneto ryšio"];
            NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, nil];
            handler(nil, [NSError errorWithDomain:@"maps.googleapis.com" code:0 userInfo:userInfo]);
            return;
        }
    }];
}

+ (NSString*)generateAddressWithGoogleResponseData:(NSData*)responseData
{
    NSError *parseError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:&parseError];
    if((parseError && (id)parseError != [NSNull null]) || !json || (id)json == [NSNull null]) {
        return nil;
    }
    
    NSArray *results = [json objectForKey:@"results"];
    if(!results || (id)results == [NSNull null] || ![results count]) {
        return nil;
    }

    NSArray *address_components = [[results objectAtIndex:0] objectForKey:@"address_components"];
    if(!address_components || (id)address_components == [NSNull null] || ![address_components count]) {
        return nil;
    }
        
    NSString *city = @"", *street = @"", *houseNumber = @"";
    for (NSDictionary *single_address_component in address_components) {
        NSString *value = [single_address_component objectForKey:@"short_name"];
        NSArray *types = [single_address_component objectForKey:@"types"];
        for (NSString *single_type in types) {
            if([single_type isEqualToString:@"street_number"]) {
                houseNumber = value;
            } else if([single_type isEqualToString:@"route"]) {
                street = value;
            } else if([single_type isEqualToString:@"locality"]) {
                city = value;
            }
        }
    }

    NSString *address = [NSString stringWithFormat:@"%@, %@ %@", city, street, houseNumber];
    return address;
}

+ (void)geolocationUsingAddress:(NSString *)address handle:(void (^)(CLLocationCoordinate2D location, NSError *error))handler
{
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request addValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *responseData, NSError *connectionError) {
        if(connectionError == nil)
        {
            if(responseData == nil)
            {
                NSString *errorDescription = @"Response empty";
                NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, nil];
                handler(CLLocationCoordinate2DMake(0, 0), [NSError errorWithDomain:@"maps.googleapis.com" code:0 userInfo:userInfo]);
                return;
            }
            else
            {
                NSString *result = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                double latitude = 0, longitude = 0;
                if (result) {
                    NSScanner *scanner = [NSScanner scannerWithString:result];
                    if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
                        [scanner scanDouble:&latitude];
                        if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                            [scanner scanDouble:&longitude];
                        }
                    }
                }
                
                handler(CLLocationCoordinate2DMake(latitude, longitude), nil);
            }
        }
        else
        {
            NSString *errorDescription = [NSString stringWithFormat:@"Nėra interneto ryšio"];
            NSDictionary *userInfo = [[NSDictionary alloc] initWithObjectsAndKeys:errorDescription, NSLocalizedDescriptionKey, nil];
            handler(CLLocationCoordinate2DMake(0, 0), [NSError errorWithDomain:@"maps.googleapis.com" code:0 userInfo:userInfo]);
            return;
        }
    }];
}

@end






