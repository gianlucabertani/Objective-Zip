//
//  OZZipFile.h
//  Objective-Zip v. 0.8.3
//
//  Created by Gianluca Bertani on 25/12/09.
//  Copyright 2009-2015 Gianluca Bertani. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without 
//  modification, are permitted provided that the following conditions 
//  are met:
//
//  * Redistributions of source code must retain the above copyright notice, 
//    this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright notice, 
//    this list of conditions and the following disclaimer in the documentation 
//    and/or other materials provided with the distribution.
//  * Neither the name of Gianluca Bertani nor the names of its contributors 
//    may be used to endorse or promote products derived from this software 
//    without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//  POSSIBILITY OF SUCH DAMAGE.
//

#import <Foundation/Foundation.h>

#import "OZZipFileMode.h"
#import "OZZipCompressionLevel.h"


@class OZZipReadStream;
@class OZZipWriteStream;
@class OZFileInZipInfo;

@interface OZZipFile : NSObject


#pragma mark -
#pragma mark Initialization

- (instancetype) initWithFileName:(NSString *)fileName mode:(OZZipFileMode)mode;


#pragma mark -
#pragma mark File writing

- (OZZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip compressionLevel:(OZZipCompressionLevel)compressionLevel;
- (OZZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip fileDate:(NSDate *)fileDate compressionLevel:(OZZipCompressionLevel)compressionLevel;
- (OZZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip fileDate:(NSDate *)fileDate compressionLevel:(OZZipCompressionLevel)compressionLevel password:(NSString *)password crc32:(NSUInteger)crc32;


#pragma mark -
#pragma mark File seeking and info

- (void) goToFirstFileInZip;
- (BOOL) goToNextFileInZip;
- (BOOL) locateFileInZip:(NSString *)fileNameInZip;

- (NSArray *) listFileInZipInfos;
- (OZFileInZipInfo *) getCurrentFileInZipInfo;


#pragma mark -
#pragma mark File reading

- (OZZipReadStream *) readCurrentFileInZip;
- (OZZipReadStream *) readCurrentFileInZipWithPassword:(NSString *)password;


#pragma mark -
#pragma mark Closing

- (void) close;


#pragma mark -
#pragma mark Properties

@property (nonatomic, readonly) NSString *fileName;
@property (nonatomic, readonly) NSUInteger numFilesInZip;


@end
