//
//  NSError+ObjectiveZip.m
//  Objective-Zip
//
//  Created by Bogdan Iusco on 08/06/14.
//  Copyright (c) 2014 yourcompany. All rights reserved.
//

#import "NSError+ObjectiveZip.h"

@implementation NSError (ObjectiveZip)

+ (instancetype)errorWithErrorCode:(OZErrorCode)code
                            reason:(NSString *)reason {
    return [[self alloc] initWithErrorCode:code reason:reason];
}

- (instancetype)initWithErrorCode:(OZErrorCode)code
                           reason:(NSString *)reason {
    NSDictionary *userInfo = nil;
    if (reason) {
        userInfo = @{NSLocalizedDescriptionKey : reason};
    }
    self = [self initWithDomain:kOZErrorDomanain code:code userInfo:userInfo];
    return self;
}

+ (instancetype)errorWithErrorCode:(OZErrorCode)code
                            reason:(NSString *)reason
                          forError:(NSError **)error {
    return [[[self class] alloc] initWithErrorCode:code reason:reason forError:error];
}

- (instancetype)initWithErrorCode:(OZErrorCode)code
                           reason:(NSString *)reason
                         forError:(NSError **)error {
    self = [[self class] errorWithErrorCode:code reason:reason];
    if (error) {
        *error = self;
    }
    return self;
}

@end
