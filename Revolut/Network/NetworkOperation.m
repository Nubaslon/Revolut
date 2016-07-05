//
//  NetworkOperation.m
//  Revolut
//
//  Created by Samoilov Denis on 05.07.16.
//  Copyright © 2016 Nubaslon LLC. All rights reserved.
//

#import "NetworkOperation.h"

//frameworks
@import AFNetworking;
#import "XMLDictionary.h"

//path
static NSString* const BASE_URL = @"http://www.ecb.europa.eu/stats/eurofxref/";

@interface NetworkOperation ()

@property (strong, nonatomic) AFHTTPSessionManager *manager;

@end

@implementation NetworkOperation

+ (NetworkOperation*)sharedOperation {
    static NetworkOperation *operation = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        operation = [[NetworkOperation alloc]init];
    });
    
    return operation;
}

- (id)init {
    self = [super init];
    if (self) {
        self.manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/xml"];
        self.manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    }
    return self;
}

- (void)requestCurrencysStatsOnSuccess:(SuccessResult)success
                             onFailure:(ErrorResult)failure {
    NSString *path = @"eurofxref-daily.xml";
    [self.manager GET:path parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            NSDictionary *responseDic = [NSDictionary dictionaryWithXMLParser:responseObject];
            responseDic = [[responseDic objectForKey:@"Cube"] objectForKey:@"Cube"];
            success(responseDic);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
        }
    }];
}

@end
