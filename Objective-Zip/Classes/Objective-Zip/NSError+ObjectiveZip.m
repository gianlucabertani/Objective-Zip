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

@end
