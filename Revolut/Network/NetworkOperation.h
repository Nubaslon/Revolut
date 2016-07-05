//
//  NetworkOperation.h
//  Revolut
//
//  Created by Samoilov Denis on 05.07.16.
//  Copyright © 2016 Nubaslon LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SuccessResult)(id result);
typedef void(^ErrorResult)(NSError *error);

@interface NetworkOperation : NSObject

+ (NetworkOperation*)sharedOperation;

//methods
-(void)requestCurrencysStatsOnSuccess:(SuccessResult)success
                            onFailure:(ErrorResult)failure;

@end
