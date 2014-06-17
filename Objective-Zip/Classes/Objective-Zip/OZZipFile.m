//
//  OZZipFile.m
//  Objective-Zip v. 1.0.0
//
//  Created by Gianluca Bertani on 25/12/09.
//  Copyright 2009-10 Flying Dolphin Studio. All rights reserved.
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
#import "OZZipReadStream.h"
#import "OZZipWriteStream.h"
#import "OZFileInZipInfo.h"
#import "NSError+ObjectiveZip.h"

#define FILE_IN_ZIP_MAX_NAME_LENGTH (256)

#define CHECK_IF_ZIP_IS_OPENED(zipFile) if (!zipFile) { \
                                            [NSError errorWithErrorCode:OZErrorCodeNotOpened reason:nil forError:error]; \
                                            return nil; \
                                        }

#define CHECK_IF_MODE_IS_NOT_UNZIP(mode) if (mode == OZZipFileModeUnzip) { \
                                         NSString *reason= @"Operation not permitted with Unzip mode"; \
                                         [NSError errorWithErrorCode:OZErrorCodeNotAllowed reason:reason forError:error]; \
                                         return nil; \
                                     }

#define CHECK_IF_MODE_IS_UNZIP(mode) if (self.mode != OZZipFileModeUnzip) { \
                                          NSString *reason = @"Operation not permitted without Unzip mode"; \
                                          [NSError errorWithErrorCode:OZErrorCodeNotAllowed reason:reason forError:error]; \
                                     }

#define CHECK_IF_MODE_IS_UNZIP_RETURN(mode) if (self.mode != OZZipFileModeUnzip) { \
                                                NSString *reason = @"Operation not permitted without Unzip mode"; \
                                                [NSError errorWithErrorCode:OZErrorCodeNotAllowed reason:reason forError:error]; \
                                                return NO; \
                                            }

@interface OZZipFile () {
    zipFile _zipFile;
    unzFile _unzFile;
}

@property (nonatomic, copy, readwrite) NSString *fileName;
@property (nonatomic, assign, readwrite) NSUInteger numFilesInZip;
@property (nonatomic, assign) OZZipFileMode mode;

@end


@implementation OZZipFile

- (instancetype)initWithFileName:(NSString *)fileName mode:(OZZipFileMode)mode {
    self = [super init];
	if (self) {
		self.fileName= fileName;
		self.mode = mode;
        _zipFile = NULL;
        _unzFile = NULL;
        [self openZipFile];
	}
	return self;
}

- (void)openZipFile {

    switch (self.mode) {
        case OZZipFileModeUnzip:
            _unzFile = unzOpen64([_fileName cStringUsingEncoding:NSUTF8StringEncoding]);
            break;
        case OZZipFileModeCreate:
            _zipFile = zipOpen64([_fileName cStringUsingEncoding:NSUTF8StringEncoding], APPEND_STATUS_CREATE);
            break;
        case OZZipFileModeAppend:
            _zipFile = zipOpen64([_fileName cStringUsingEncoding:NSUTF8StringEncoding], APPEND_STATUS_ADDINZIP);
            break;
    }

}

- (OZZipWriteStream *)writeFileInZipWithName:(NSString *)fileNameInZip compressionLevel:(OZZipCompressionLevel)compressionLevel error:(NSError **)error {
    CHECK_IF_ZIP_IS_OPENED(_zipFile);
    CHECK_IF_MODE_IS_NOT_UNZIP(self.mode);

	NSDate *now= [NSDate date];
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDateComponents *date= [calendar components:(NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit |
                                                  NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:now];
	zip_fileinfo zi;
	zi.tmz_date.tm_sec= [date second];
	zi.tmz_date.tm_min= [date minute];
	zi.tmz_date.tm_hour= [date hour];
	zi.tmz_date.tm_mday= [date day];
	zi.tmz_date.tm_mon= [date month] -1;
	zi.tmz_date.tm_year= [date year];
	zi.internal_fa= 0;
	zi.external_fa= 0;
	zi.dosDate= 0;

	int err = zipOpenNewFileInZip3_64(
									 _zipFile,
									 [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
									 &zi,
									 NULL, 0, NULL, 0, NULL,
									 (compressionLevel != OZZipCompressionLevelNone) ? Z_DEFLATED : 0,
									 compressionLevel, 0,
									 -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
									 NULL, 0, 1);
	if (err != ZIP_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening '%@' in zipfile", fileNameInZip];
        [NSError errorWithErrorCode:OZErrorCodeCannotOpen reason:reason forError:error];
        return nil;
	}

	return [[OZZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip];
}

- (OZZipWriteStream *)writeFileInZipWithName:(NSString *)fileNameInZip
                                    fileDate:(NSDate *)fileDate
                            compressionLevel:(OZZipCompressionLevel)compressionLevel
                                       error:(NSError **)error {
    CHECK_IF_ZIP_IS_OPENED(_zipFile);
    CHECK_IF_MODE_IS_NOT_UNZIP(self.mode);
	
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDateComponents *date= [calendar components:(NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit |
                                                  NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:fileDate];
	zip_fileinfo zi;
	zi.tmz_date.tm_sec= [date second];
	zi.tmz_date.tm_min= [date minute];
	zi.tmz_date.tm_hour= [date hour];
	zi.tmz_date.tm_mday= [date day];
	zi.tmz_date.tm_mon= [date month] -1;
	zi.tmz_date.tm_year= [date year];
	zi.internal_fa= 0;
	zi.external_fa= 0;
	zi.dosDate= 0;
	
	int err= zipOpenNewFileInZip3_64(
									 _zipFile,
									 [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
									 &zi,
									 NULL, 0, NULL, 0, NULL,
									 (compressionLevel != OZZipCompressionLevelNone) ? Z_DEFLATED : 0,
									 compressionLevel, 0,
									 -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
									 NULL, 0, 1);
	if (err != ZIP_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening '%@' in zipfile", fileNameInZip];
        [NSError errorWithErrorCode:OZErrorCodeCannotOpen reason:reason forError:error];
        return nil;
	}

	return [[OZZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip];
}

- (OZZipWriteStream *)writeFileInZipWithName:(NSString *)fileNameInZip
                                    fileDate:(NSDate *)fileDate
                            compressionLevel:(OZZipCompressionLevel)compressionLevel
                                    password:(NSString *)password
                                       crc32:(NSUInteger)crc32
                                       error:(NSError **)error {
    CHECK_IF_ZIP_IS_OPENED(_zipFile);
    CHECK_IF_MODE_IS_NOT_UNZIP(self.mode);
	
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDateComponents *date= [calendar components:(NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit |
                                                  NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:fileDate];
	zip_fileinfo zi;
	zi.tmz_date.tm_sec= [date second];
	zi.tmz_date.tm_min= [date minute];
	zi.tmz_date.tm_hour= [date hour];
	zi.tmz_date.tm_mday= [date day];
	zi.tmz_date.tm_mon= [date month] -1;
	zi.tmz_date.tm_year= [date year];
	zi.internal_fa= 0;
	zi.external_fa= 0;
	zi.dosDate= 0;
	
	int err = zipOpenNewFileInZip3_64(
									 _zipFile,
									 [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
									 &zi,
									 NULL, 0, NULL, 0, NULL,
									 (compressionLevel != OZZipCompressionLevelNone) ? Z_DEFLATED : 0,
									 compressionLevel, 0,
									 -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
									 [password cStringUsingEncoding:NSUTF8StringEncoding], crc32, 1);
	if (err != ZIP_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening '%@' in zipfile", fileNameInZip];
        [NSError errorWithErrorCode:OZErrorCodeCannotOpen reason:reason forError:error];
	}

	return [[OZZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip];
}


- (NSUInteger)numFilesInZip {
	if (self.mode != OZZipFileModeUnzip) {
        return 0;
	}

	unz_global_info64 gi;
	int err= unzGetGlobalInfo64(_unzFile, &gi);
	if (err != UNZ_OK) {
        return 0;
	}

    _numFilesInZip = (NSUInteger)gi.number_entry;
	return _numFilesInZip;
}

- (NSArray *)listFileInZipInfos {
	int num = self.numFilesInZip;
	if (num < 1) {
		return @[];
	}

	NSMutableArray *files= [[NSMutableArray alloc] initWithCapacity:num];

	[self goToFirstFileInZip:nil];
	for (NSUInteger i = 0; i < num; i++) {
		OZFileInZipInfo *info= [self getCurrentFileInZipInfo:nil];
		[files addObject:info];

		if ((i +1) < num)
			[self goToNextFileInZip:nil];
	}

	return files;
}

- (void)goToFirstFileInZip:(NSError **)error {
    CHECK_IF_MODE_IS_UNZIP(self.mode);

	int err = unzGoToFirstFile(_unzFile);
	if (err != UNZ_OK) {
		NSString *reason = [NSString stringWithFormat:@"Error going to first file in zip in '%@'", self.fileName];
        [NSError errorWithErrorCode:OZErrorCodeGeneral reason:reason forError:error];
	}
}

- (BOOL)goToNextFileInZip:(NSError **)error {
    CHECK_IF_MODE_IS_UNZIP_RETURN(self.mode);

	int err= unzGoToNextFile(_unzFile);
	if (err == UNZ_END_OF_LIST_OF_FILE) {
		return NO;
    }

	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error going to next file in zip in '%@'", self.fileName];
        [NSError errorWithErrorCode:OZErrorCodeGeneral reason:reason forError:error];
		return NO;
	}

	return YES;
}

- (BOOL)locateFileInZip:(NSString *)fileNameInZip error:(NSError **)error {
    CHECK_IF_MODE_IS_UNZIP_RETURN(self.mode);

	int err= unzLocateFile(_unzFile, [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding], NULL);
	if (err == UNZ_END_OF_LIST_OF_FILE) {
		return NO;
    }

	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error localting file in zip in '%@'", self.fileName];
        [NSError errorWithErrorCode:OZErrorCodeGeneral reason:reason forError:error];
		return NO;
	}

	return YES;
}

- (OZFileInZipInfo *)getCurrentFileInZipInfo:(NSError **)error {
    CHECK_IF_MODE_IS_UNZIP_RETURN(self.mode);

	char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
	unz_file_info64 file_info;

	int err= unzGetCurrentFileInfo64(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error getting current file info in '%@'", self.fileName];
        [NSError errorWithErrorCode:OZErrorCodeGeneral reason:reason forError:error];
	}

	NSString *name = [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];

	OZZipCompressionLevel level = OZZipCompressionLevelNone;
	if (file_info.compression_method != 0) {
		switch ((file_info.flag & 0x6) / 2) {
			case 0:
				level = OZZipCompressionLevelDefault;
				break;
				
			case 1:
				level = OZZipCompressionLevelBest;
				break;
				
			default:
				level = OZZipCompressionLevelFastest;
				break;
		}
	}

	BOOL crypted= ((file_info.flag & 1) != 0);
	
	NSDateComponents *components= [NSDateComponents new];
	[components setDay:file_info.tmu_date.tm_mday];
	[components setMonth:file_info.tmu_date.tm_mon +1];
	[components setYear:file_info.tmu_date.tm_year];
	[components setHour:file_info.tmu_date.tm_hour];
	[components setMinute:file_info.tmu_date.tm_min];
	[components setSecond:file_info.tmu_date.tm_sec];
	NSCalendar *calendar= [NSCalendar currentCalendar];
	NSDate *date= [calendar dateFromComponents:components];
	
	OZFileInZipInfo *info= [[OZFileInZipInfo alloc] initWithName:name
                                                          length:(NSUInteger)file_info.uncompressed_size
                                                           level:level
                                                         crypted:crypted
                                                            size:(NSUInteger)file_info.compressed_size
                                                            date:date
                                                           crc32:(NSUInteger)file_info.crc];
	return info;
}

- (OZZipReadStream *)readCurrentFileInZip:(NSError **)error {
	if (self.mode != OZZipFileModeUnzip) {
		NSString *reason = @"Operation not permitted without Unzip mode";
        *error = [NSError errorWithErrorCode:OZErrorCodeNotAllowed reason:reason];
        return nil;
	}

	char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
	unz_file_info64 file_info;
	
	int err= unzGetCurrentFileInfo64(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error getting current file info in '%@'", _fileName];
        [NSError errorWithErrorCode:OZErrorCodeNotAllowed reason:reason forError:error];
        return nil;
	}

	NSString *fileNameInZip= [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];
	err = unzOpenCurrentFilePassword(_unzFile, NULL);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening current file in '%@'", self.fileName];
        [NSError errorWithErrorCode:OZErrorCodeCannotOpen reason:reason forError:error];
        return nil;
	}

	return [[OZZipReadStream alloc] initWithUnzFileStruct:_unzFile fileNameInZip:fileNameInZip];
}

- (OZZipReadStream *)readCurrentFileInZipWithPassword:(NSString *)password error:(NSError **)error {
    if (self.mode != OZZipFileModeUnzip) {
        NSString *reason = @"Operation not permitted without Unzip mode";
        *error = [NSError errorWithErrorCode:OZErrorCodeNotAllowed reason:reason];
        return nil;
    }

	char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
	unz_file_info64 file_info;
	
	int err= unzGetCurrentFileInfo64(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error getting current file info in '%@'", _fileName];
        [NSError errorWithErrorCode:OZErrorCodeNotAllowed reason:reason forError:error];
        return nil;
	}

	NSString *fileNameInZip = [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];
	err = unzOpenCurrentFilePassword(_unzFile, [password cStringUsingEncoding:NSUTF8StringEncoding]);
	if (err != UNZ_OK) {
		NSString *reason= [NSString stringWithFormat:@"Error opening current file in '%@'", _fileName];
        [NSError errorWithErrorCode:OZErrorCodeCannotOpen reason:reason forError:error];
        return nil;
	}

	return [[OZZipReadStream alloc] initWithUnzFileStruct:_unzFile fileNameInZip:fileNameInZip];
}

- (void)close:(NSError **)error {
	switch (self.mode) {
		case OZZipFileModeUnzip: {
			int err= unzClose(_unzFile);
			if (err != UNZ_OK) {
				NSString *reason = [NSString stringWithFormat:@"Error closing '%@'", self.fileName];
                [NSError errorWithErrorCode:OZErrorCodeCannotClose reason:reason forError:error];
			}
			break;
		}

		case OZZipFileModeCreate: {
			int err= zipClose(_zipFile, NULL);
			if (err != ZIP_OK) {
				NSString *reason= [NSString stringWithFormat:@"Error closing '%@'", self.fileName];
                [NSError errorWithErrorCode:OZErrorCodeCannotClose reason:reason forError:error];
			}
			break;
		}

		case OZZipFileModeAppend: {
			int err = zipClose(_zipFile, NULL);
			if (err != ZIP_OK) {
				NSString *reason= [NSString stringWithFormat:@"Error closing '%@'", self.fileName];
                [NSError errorWithErrorCode:OZErrorCodeCannotClose reason:reason forError:error];
			}
			break;
		}
	}
}

@end
