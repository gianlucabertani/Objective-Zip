//
//  OZZipFile.m
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

#import "OZZipFile.h"
#import "OZZipException.h"
#import "OZZipException+Internals.h"
#import "OZZipReadStream.h"
#import "OZZipReadStream+Internals.h"
#import "OZZipWriteStream.h"
#import "OZZipWriteStream+Internals.h"
#import "OZFileInZipInfo.h"
#import "OZFileInZipInfo+Internals.h"

#include "zip.h"
#include "unzip.h"

#define FILE_IN_ZIP_MAX_NAME_LENGTH (256)


#pragma mark -
#pragma mark OZZipFile extension

@interface OZZipFile () {
    NSString *_fileName;
    OZZipFileMode _mode;
    BOOL _legacy32BitMode;
    
@private
    zipFile _zipFile;
    unzFile _unzFile;
}


@end


#pragma mark -
#pragma mark OZZipFile implementation

@implementation OZZipFile


#pragma mark -
#pragma mark Initialization

- (instancetype) initWithFileName:(NSString *)fileName mode:(OZZipFileMode)mode {
    return [self initWithFileName:fileName mode:mode legacy32BitMode:NO];
}

- (instancetype) initWithFileName:(NSString *)fileName mode:(OZZipFileMode)mode legacy32BitMode:(BOOL)legacy32BitMode {
	if (self= [super init]) {
		_fileName= fileName;
		_mode= mode;
        _legacy32BitMode= legacy32BitMode;
		
        const char *path= [_fileName cStringUsingEncoding:NSUTF8StringEncoding];
		switch (mode) {
			case OZZipFileModeUnzip:
                
                // Support for legacy 32 bit mode: here we use 32 or 64 bit version
                // alternatively, as internal (common) version is not exposed
                _unzFile= (_legacy32BitMode ? unzOpen(path) : unzOpen64(path));
				if (_unzFile == NULL) {
					NSString *reason= [NSString stringWithFormat:@"Can't open '%@'", _fileName];
					@throw [[OZZipException alloc] initWithReason:reason];
				}
				break;
				
			case OZZipFileModeCreate:
                
                // Support for legacy 32 bit mode: here we use the common version
                _zipFile= zipOpen3(path, APPEND_STATUS_CREATE, 0, NULL, NULL);
				if (_zipFile == NULL) {
					NSString *reason= [NSString stringWithFormat:@"Can't open '%@'", _fileName];
					@throw [[OZZipException alloc] initWithReason:reason];
				}
				break;
				
			case OZZipFileModeAppend:
                
                // Support for legacy 32 bit mode: here we use the common version
                _zipFile= zipOpen3(path, APPEND_STATUS_ADDINZIP, 0, NULL, NULL);
				if (_zipFile == NULL) {
					NSString *reason= [NSString stringWithFormat:@"Can't open '%@'", _fileName];
					@throw [[OZZipException alloc] initWithReason:reason];
				}
				break;
				
			default: {
				NSString *reason= [NSString stringWithFormat:@"Unknown mode %d", _mode];
				@throw [[OZZipException alloc] initWithReason:reason];
			}
		}
	}
	
	return self;
}


#pragma mark -
#pragma mark File writing

- (OZZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip compressionLevel:(OZZipCompressionLevel)compressionLevel {
	if (_mode == OZZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted with Unzip mode"];
		@throw [[OZZipException alloc] initWithReason:reason];
	}
	
	NSDate *now= [NSDate date];
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDateComponents *date= [calendar components:(NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:now];
	zip_fileinfo zi;
	zi.tmz_date.tm_sec= (uInt) [date second];
	zi.tmz_date.tm_min= (uInt) [date minute];
	zi.tmz_date.tm_hour= (uInt) [date hour];
	zi.tmz_date.tm_mday= (uInt) [date day];
	zi.tmz_date.tm_mon= (uInt) [date month] -1;
	zi.tmz_date.tm_year= (uInt) [date year];
	zi.internal_fa= 0;
	zi.external_fa= 0;
	zi.dosDate= 0;
	
    // Support for legacy 32 bit mode: here we use the common version,
    // passing a flag to tell if it is a 32 or 64 bit file
	int err= zipOpenNewFileInZip3_64(_zipFile,
									 [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
									 &zi,
									 NULL, 0, NULL, 0, NULL,
									 (compressionLevel != OZZipCompressionLevelNone) ? Z_DEFLATED : 0,
									 compressionLevel, 0,
									 -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
                                     NULL, 0,
                                     (_legacy32BitMode ? 0 : 1));
    
	if (err != ZIP_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening '%@' in zipfile", fileNameInZip];
		@throw [[OZZipException alloc] initWithError:err reason:reason];
	}
	
	return [[OZZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip];
}

- (OZZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip fileDate:(NSDate *)fileDate compressionLevel:(OZZipCompressionLevel)compressionLevel {
	if (_mode == OZZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted with Unzip mode"];
		@throw [[OZZipException alloc] initWithReason:reason];
	}
	
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDateComponents *date= [calendar components:(NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:fileDate];
	zip_fileinfo zi;
	zi.tmz_date.tm_sec= (uInt) [date second];
	zi.tmz_date.tm_min= (uInt) [date minute];
	zi.tmz_date.tm_hour= (uInt) [date hour];
	zi.tmz_date.tm_mday= (uInt) [date day];
	zi.tmz_date.tm_mon= (uInt) [date month] -1;
	zi.tmz_date.tm_year= (uInt) [date year];
	zi.internal_fa= 0;
	zi.external_fa= 0;
	zi.dosDate= 0;
	
    // Support for legacy 32 bit mode: here we use the common version,
    // passing a flag to tell if it is a 32 or 64 bit file
	int err= zipOpenNewFileInZip3_64(_zipFile,
									 [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
									 &zi,
									 NULL, 0, NULL, 0, NULL,
									 (compressionLevel != OZZipCompressionLevelNone) ? Z_DEFLATED : 0,
									 compressionLevel, 0,
									 -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
									 NULL, 0,
                                     (_legacy32BitMode ? 0 : 1));
    
	if (err != ZIP_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening '%@' in zipfile", fileNameInZip];
		@throw [[OZZipException alloc] initWithError:err reason:reason];
	}
	
	return [[OZZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip];
}

- (OZZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip fileDate:(NSDate *)fileDate compressionLevel:(OZZipCompressionLevel)compressionLevel password:(NSString *)password crc32:(NSUInteger)crc32 {
	if (_mode == OZZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted with Unzip mode"];
		@throw [[OZZipException alloc] initWithReason:reason];
	}
	
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDateComponents *date= [calendar components:(NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:fileDate];
	zip_fileinfo zi;
	zi.tmz_date.tm_sec= (uInt) [date second];
	zi.tmz_date.tm_min= (uInt) [date minute];
	zi.tmz_date.tm_hour= (uInt) [date hour];
	zi.tmz_date.tm_mday= (uInt) [date day];
	zi.tmz_date.tm_mon= (uInt) [date month] -1;
	zi.tmz_date.tm_year= (uInt) [date year];
	zi.internal_fa= 0;
	zi.external_fa= 0;
	zi.dosDate= 0;
	
    // Support for legacy 32 bit mode: here we use the common version,
    // passing a flag to tell if it is a 32 or 64 bit file
	int err= zipOpenNewFileInZip3_64(_zipFile,
									 [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
									 &zi,
									 NULL, 0, NULL, 0, NULL,
									 (compressionLevel != OZZipCompressionLevelNone) ? Z_DEFLATED : 0,
									 compressionLevel, 0,
									 -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
									 [password cStringUsingEncoding:NSUTF8StringEncoding], crc32,
                                     (_legacy32BitMode ? 0 : 1));
    
	if (err != ZIP_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening '%@' in zipfile", fileNameInZip];
		@throw [[OZZipException alloc] initWithError:err reason:reason];
	}
	
	return [[OZZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip];
}


#pragma mark -
#pragma mark File seeking and info

- (void) goToFirstFileInZip {
	if (_mode != OZZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[OZZipException alloc] initWithReason:reason];
	}
	
	int err= unzGoToFirstFile(_unzFile);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error going to first file in zip in '%@'", _fileName];
		@throw [[OZZipException alloc] initWithError:err reason:reason];
	}
}

- (BOOL) goToNextFileInZip {
	if (_mode != OZZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[OZZipException alloc] initWithReason:reason];
	}
	
	int err= unzGoToNextFile(_unzFile);
	if (err == UNZ_END_OF_LIST_OF_FILE)
		return NO;

	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error going to next file in zip in '%@'", _fileName];
		@throw [[OZZipException alloc] initWithError:err reason:reason];
	}
	
	return YES;
}

- (BOOL) locateFileInZip:(NSString *)fileNameInZip {
	if (_mode != OZZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[OZZipException alloc] initWithReason:reason];
	}
	
	int err= unzLocateFile(_unzFile, [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding], NULL);
	if (err == UNZ_END_OF_LIST_OF_FILE)
		return NO;

	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error localting file in zip in '%@'", _fileName];
		@throw [[OZZipException alloc] initWithError:err reason:reason];
	}
	
	return YES;
}

- (NSArray *) listFileInZipInfos {
    NSUInteger num= [self numFilesInZip];
    if (num < 1)
        return [[NSArray alloc] init];
    
    NSMutableArray *files= [[NSMutableArray alloc] initWithCapacity:num];
    
    [self goToFirstFileInZip];
    for (int i= 0; i < num; i++) {
        OZFileInZipInfo *info= [self getCurrentFileInZipInfo];
        [files addObject:info];
        
        if ((i +1) < num)
            [self goToNextFileInZip];
    }
    
    return files;
}

- (OZFileInZipInfo *) getCurrentFileInZipInfo {
	if (_mode != OZZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[OZZipException alloc] initWithReason:reason];
	}

	char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
	unz_file_info64 file_info;
	
    // Support for legacy 32 bit mode: here we use the 64 bit version,
    // as it also internally called from the 32 bit version
	int err= unzGetCurrentFileInfo64(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error getting current file info in '%@'", _fileName];
		@throw [[OZZipException alloc] initWithError:err reason:reason];
	}
	
	NSString *name= [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];
	
	OZZipCompressionLevel level= OZZipCompressionLevelNone;
	if (file_info.compression_method != 0) {
		switch ((file_info.flag & 0x6) / 2) {
			case 0:
				level= OZZipCompressionLevelDefault;
				break;
				
			case 1:
				level= OZZipCompressionLevelBest;
				break;
				
			default:
				level= OZZipCompressionLevelFastest;
				break;
		}
	}
	
	BOOL crypted= ((file_info.flag & 1) != 0);
	
	NSDateComponents *components= [[NSDateComponents alloc] init];
	[components setDay:file_info.tmu_date.tm_mday];
	[components setMonth:file_info.tmu_date.tm_mon +1];
	[components setYear:file_info.tmu_date.tm_year];
	[components setHour:file_info.tmu_date.tm_hour];
	[components setMinute:file_info.tmu_date.tm_min];
	[components setSecond:file_info.tmu_date.tm_sec];
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDate *date= [calendar dateFromComponents:components];
	
	OZFileInZipInfo *info= [[OZFileInZipInfo alloc] initWithName:name length:file_info.uncompressed_size level:level crypted:crypted size:file_info.compressed_size date:date crc32:file_info.crc];
	return info;
}


#pragma mark -
#pragma mark File reading

- (OZZipReadStream *) readCurrentFileInZip {
	if (_mode != OZZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[OZZipException alloc] initWithReason:reason];
	}

	char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
	unz_file_info64 file_info;
	
    // Support for legacy 32 bit mode: here we use the 64 bit version,
    // as it also internally called from the 32 bit version
	int err= unzGetCurrentFileInfo64(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error getting current file info in '%@'", _fileName];
		@throw [[OZZipException alloc] initWithError:err reason:reason];
	}
	
	NSString *fileNameInZip= [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];
	
	err= unzOpenCurrentFilePassword(_unzFile, NULL);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening current file in '%@'", _fileName];
		@throw [[OZZipException alloc] initWithError:err reason:reason];
	}
	
	return [[OZZipReadStream alloc] initWithUnzFileStruct:_unzFile fileNameInZip:fileNameInZip];
}

- (OZZipReadStream *) readCurrentFileInZipWithPassword:(NSString *)password {
	if (_mode != OZZipFileModeUnzip) {
		NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
		@throw [[OZZipException alloc] initWithReason:reason];
	}
	
	char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
	unz_file_info64 file_info;
	
    // Support for legacy 32 bit mode: here we use the 64 bit version,
    // as it also internally called from the 32 bit version
	int err= unzGetCurrentFileInfo64(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error getting current file info in '%@'", _fileName];
		@throw [[OZZipException alloc] initWithError:err reason:reason];
	}
	
	NSString *fileNameInZip= [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];

	err= unzOpenCurrentFilePassword(_unzFile, [password cStringUsingEncoding:NSUTF8StringEncoding]);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening current file in '%@'", _fileName];
		@throw [[OZZipException alloc] initWithError:err reason:reason];
	}
	
	return [[OZZipReadStream alloc] initWithUnzFileStruct:_unzFile fileNameInZip:fileNameInZip];
}


#pragma mark -
#pragma mark Closing

- (void) close {
	switch (_mode) {
		case OZZipFileModeUnzip: {
			int err= unzClose(_unzFile);
			if (err != UNZ_OK) {
				NSString *reason= [NSString stringWithFormat:@"Error closing '%@'", _fileName];
				@throw [[OZZipException alloc] initWithError:err reason:reason];
			}
			break;
		}
			
		case OZZipFileModeCreate: {
			int err= zipClose(_zipFile, NULL);
			if (err != ZIP_OK) {
				NSString *reason= [NSString stringWithFormat:@"Error closing '%@'", _fileName];
				@throw [[OZZipException alloc] initWithError:err reason:reason];
			}
			break;
		}
			
		case OZZipFileModeAppend: {
			int err= zipClose(_zipFile, NULL);
			if (err != ZIP_OK) {
				NSString *reason= [NSString stringWithFormat:@"Error closing '%@'", _fileName];
				@throw [[OZZipException alloc] initWithError:err reason:reason];
			}
			break;
		}

		default: {
			NSString *reason= [NSString stringWithFormat:@"Unknown mode %d", _mode];
			@throw [[OZZipException alloc] initWithReason:reason];
		}
	}
}


#pragma mark -
#pragma mark Properties

@synthesize fileName= _fileName;
@synthesize mode= _mode;
@synthesize legacy32BitMode= _legacy32BitMode;

@dynamic numFilesInZip;

- (NSUInteger) numFilesInZip {
    if (_mode != OZZipFileModeUnzip) {
        NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
        @throw [[OZZipException alloc] initWithReason:reason];
    }
    
    // Support for legacy 32 bit mode: here we use the 32 or 64 bit
    // version alternatively, as there is not internal (common) version
    if (_legacy32BitMode) {
        unz_global_info gi;
        
        int err= unzGetGlobalInfo(_unzFile, &gi);
        if (err != UNZ_OK) {
            NSString *reason= [NSString stringWithFormat:@"Error getting global info in '%@'", _fileName];
            @throw [[OZZipException alloc] initWithError:err reason:reason];
        }
        
        return gi.number_entry;
        
    } else {
        unz_global_info64 gi;
        
        int err= unzGetGlobalInfo64(_unzFile, &gi);
        if (err != UNZ_OK) {
            NSString *reason= [NSString stringWithFormat:@"Error getting global info in '%@'", _fileName];
            @throw [[OZZipException alloc] initWithError:err reason:reason];
        }
        
        return gi.number_entry;
    }
}


@end
