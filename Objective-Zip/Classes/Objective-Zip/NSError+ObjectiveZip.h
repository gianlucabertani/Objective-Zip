//
//  NSError+ObjectiveZip.h
//  Objective-Zip
//
//  Created by Bogdan Iusco on 08/06/14.
//  Copyright (c) 2014 yourcompany. All rights reserved.
//

@import Foundation;

#import "OZConstants.h"

@interface NSError (ObjectiveZip)

+ (instancetype)errorWithErrorCode:(OZErrorCode)code
                            reason:(NSString *)reason;

- (instancetype)initWithErrorCode:(OZErrorCode)code
                           reason:(NSString *)reason;

@end
