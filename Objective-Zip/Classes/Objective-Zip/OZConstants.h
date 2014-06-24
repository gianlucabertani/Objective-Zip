//
//  OZConstants.h
//  Objective-Zip
//
//  Created by Bogdan Iusco on 08/06/14.
//  Copyright (c) 2014 yourcompany. All rights reserved.
//

@import Foundation;

typedef NS_ENUM(NSInteger, OZZipFileMode) {
    OZZipFileModeUnzip,
    OZZipFileModeCreate,
    OZZipFileModeAppend
};

typedef NS_ENUM(NSInteger, OZZipCompressionLevel) {
    OZZipCompressionLevelDefault = -1,
    OZZipCompressionLevelNone    = 0,
    OZZipCompressionLevelFastest = 1,
    OZZipCompressionLevelBest    = 9
};

NSString * const kOZErrorDomanain;

typedef NS_ENUM(NSInteger, OZErrorCode) {
    OZErrorCodeGeneral     = -1,
    OZErrorCodeCannotOpen  = -2,
    OZErrorCodeCannotRead  = -3,
    OZErrorCodeCannotWrite = -4,
    OZErrorCodeCannotClose = -5,
    OZErrorCodeNotOpened   = -6,
    OZErrorCodeNotAllowed  = -7
};
