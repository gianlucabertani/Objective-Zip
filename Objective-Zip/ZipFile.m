//
//  ZipFile.m
//  Objective-Zip v. 0.8.3
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

#import "ZipFile.h"
#import "ZipException.h"
#import "ZipReadStream.h"
#import "ZipWriteStream.h"
#import "FIleInZipInfo.h"

#define FILE_IN_ZIP_MAX_NAME_LENGTH (256)


@implementation ZipFile


- (id) initWithFileName:(NSString *)fileName mode:(ZipFileMode)mode {
    if (self= [super init]) {
        _fileName= [fileName ah_retain];
        _mode= mode;
        
        switch (mode) {
            case ZipFileModeUnzip:
                _unzFile= unzOpen64([_fileName cStringUsingEncoding:NSUTF8StringEncoding]);
                if (_unzFile == NULL) {
                    return nil;
                }
                break;
                
            case ZipFileModeCreate:
                _zipFile= zipOpen64([_fileName cStringUsingEncoding:NSUTF8StringEncoding], APPEND_STATUS_CREATE);
                if (_zipFile == NULL) {
                    return nil;
                }
                break;
                
            case ZipFileModeAppend:
                _zipFile= zipOpen64([_fileName cStringUsingEncoding:NSUTF8StringEncoding], APPEND_STATUS_ADDINZIP);
                if (_zipFile == NULL) {
                    return nil;
                }
                break;
                
            default: {
                return nil;
            }
        }
    }
    
    return self;
}

- (void) dealloc {
    [_fileName release];
    
    [super ah_dealloc];
}

- (ZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip compressionLevel:(ZipCompressionLevel)compressionLevel withError:(NSError *__autoreleasing *) error {
    if (_mode == ZipFileModeUnzip) {
        NSString *reason= [NSString stringWithFormat:@"Operation not permitted with Unzip mode"];
        ZipException * exception = [[[ZipException alloc] initWithReason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    NSDate *now= [NSDate date];
    NSCalendar *calendar= [NSCalendar currentCalendar];
    NSDateComponents *date= [calendar components:(NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:now];
    zip_fileinfo zi;
    zi.tmz_date.tm_sec= (uInt)[date second];
    zi.tmz_date.tm_min= (uInt)[date minute];
    zi.tmz_date.tm_hour= (uInt)[date hour];
    zi.tmz_date.tm_mday= (uInt)[date day];
    zi.tmz_date.tm_mon= (uInt)[date month] -1;
    zi.tmz_date.tm_year= (uInt)[date year];
    zi.internal_fa= 0;
    zi.external_fa= 0;
    zi.dosDate= 0;
    
    int err= zipOpenNewFileInZip3_64(
                                     _zipFile,
                                     [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
                                     &zi,
                                     NULL, 0, NULL, 0, NULL,
                                     (compressionLevel != ZipCompressionLevelNone) ? Z_DEFLATED : 0,
                                     compressionLevel, 0,
                                     -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
                                     NULL, 0, 1);
    if (err != ZIP_OK) {
        NSString *reason= [NSString stringWithFormat:@"Error opening '%@' in zipfile", fileNameInZip];
        ZipException * exception = [[[ZipException alloc] initWithError:err reason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    return [[[ZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip] autorelease];
}

- (ZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip fileDate:(NSDate *)fileDate compressionLevel:(ZipCompressionLevel)compressionLevel withError:(NSError *__autoreleasing *) error {
    if (_mode == ZipFileModeUnzip) {
        NSString *reason= [NSString stringWithFormat:@"Operation not permitted with Unzip mode"];
        ZipException * exception =[[[ZipException alloc] initWithReason:reason] autorelease];
        [self handleException:exception withError:error];
        
    }
    
    NSCalendar *calendar= [NSCalendar currentCalendar];
    NSDateComponents *date= [calendar components:(NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:fileDate];
    zip_fileinfo zi;
    zi.tmz_date.tm_sec= (uInt)[date second];
    zi.tmz_date.tm_min= (uInt)[date minute];
    zi.tmz_date.tm_hour= (uInt)[date hour];
    zi.tmz_date.tm_mday= (uInt)[date day];
    zi.tmz_date.tm_mon= (uInt)[date month] -1;
    zi.tmz_date.tm_year= (uInt)[date year];
    zi.internal_fa= 0;
    zi.external_fa= 0;
    zi.dosDate= 0;
    
    int err= zipOpenNewFileInZip3_64(
                                     _zipFile,
                                     [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
                                     &zi,
                                     NULL, 0, NULL, 0, NULL,
                                     (compressionLevel != ZipCompressionLevelNone) ? Z_DEFLATED : 0,
                                     compressionLevel, 0,
                                     -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
                                     NULL, 0, 1);
    if (err != ZIP_OK) {
        NSString *reason= [NSString stringWithFormat:@"Error opening '%@' in zipfile", fileNameInZip];
        ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    return [[[ZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip] autorelease];
}

- (ZipWriteStream *) writeFileInZipWithName:(NSString *)fileNameInZip fileDate:(NSDate *)fileDate compressionLevel:(ZipCompressionLevel)compressionLevel password:(NSString *)password crc32:(NSUInteger)crc32 withError:(NSError *__autoreleasing *) error {
    if (_mode == ZipFileModeUnzip) {
        NSString *reason= [NSString stringWithFormat:@"Operation not permitted with Unzip mode"];
        ZipException * exception =[[[ZipException alloc] initWithReason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    NSCalendar *calendar= [NSCalendar currentCalendar];
    NSDateComponents *date= [calendar components:(NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:fileDate];
    zip_fileinfo zi;
    zi.tmz_date.tm_sec= (uInt)[date second];
    zi.tmz_date.tm_min= (uInt)[date minute];
    zi.tmz_date.tm_hour= (uInt)[date hour];
    zi.tmz_date.tm_mday= (uInt)[date day];
    zi.tmz_date.tm_mon= (uInt)[date month] -1;
    zi.tmz_date.tm_year= (uInt)[date year];
    zi.internal_fa= 0;
    zi.external_fa= 0;
    zi.dosDate= 0;
    
    int err= zipOpenNewFileInZip3_64(
                                     _zipFile,
                                     [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding],
                                     &zi,
                                     NULL, 0, NULL, 0, NULL,
                                     (compressionLevel != ZipCompressionLevelNone) ? Z_DEFLATED : 0,
                                     compressionLevel, 0,
                                     -MAX_WBITS, DEF_MEM_LEVEL, Z_DEFAULT_STRATEGY,
                                     [password cStringUsingEncoding:NSUTF8StringEncoding], crc32, 1);
    if (err != ZIP_OK) {
        NSString *reason= [NSString stringWithFormat:@"Error opening '%@' in zipfile", fileNameInZip];
        ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    return [[[ZipWriteStream alloc] initWithZipFileStruct:_zipFile fileNameInZip:fileNameInZip] autorelease];
}

- (NSString*) fileNameWithError:(NSError *__autoreleasing *)error {
    return _fileName;
}

- (NSUInteger) numFilesInZipWithError:(NSError *__autoreleasing *)error {
    if (_mode != ZipFileModeUnzip) {
        NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
        ZipException * exception =[[[ZipException alloc] initWithReason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    unz_global_info64 gi;
    int err= unzGetGlobalInfo64(_unzFile, &gi);
    if (err != UNZ_OK) {
        NSString *reason= [NSString stringWithFormat:@"Error getting global info in '%@'", _fileName];
        ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    return (NSUInteger)gi.number_entry;
}

- (NSArray *) listFileInZipInfosWithError:(NSError *__autoreleasing *)error {
    int num= (int)[self numFilesInZipWithError:error];
    if (num < 1)
        return [[[NSArray alloc] init] autorelease];
    
    NSMutableArray *files= [[[NSMutableArray alloc] initWithCapacity:num] autorelease];
    
    [self goToFirstFileInZipWithError:error];
    for (int i= 0; i < num; i++) {
        FileInZipInfo *info= [self getCurrentFileInZipInfoWithError:error];
        [files addObject:info];
        
        if ((i +1) < num)
            [self goToNextFileInZipWithError:error];
    }
    
    return files;
}

- (void) goToFirstFileInZipWithError:(NSError *__autoreleasing *)error {
    if (_mode != ZipFileModeUnzip) {
        NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
        ZipException * exception =[[[ZipException alloc] initWithReason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    int err= unzGoToFirstFile(_unzFile);
    if (err != UNZ_OK) {
        NSString *reason= [NSString stringWithFormat:@"Error going to first file in zip in '%@'", _fileName];
        ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
        [self handleException:exception withError:error];
    }
}

- (BOOL) goToNextFileInZipWithError:(NSError *__autoreleasing *)error {
    if (_mode != ZipFileModeUnzip) {
        NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
        ZipException * exception =[[[ZipException alloc] initWithReason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    int err= unzGoToNextFile(_unzFile);
    if (err == UNZ_END_OF_LIST_OF_FILE)
        return NO;
    
    if (err != UNZ_OK) {
        NSString *reason= [NSString stringWithFormat:@"Error going to next file in zip in '%@'", _fileName];
        ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    return YES;
}

- (BOOL) locateFileInZip:(NSString *)fileNameInZip withError:(NSError *__autoreleasing *) error {
    if (_mode != ZipFileModeUnzip) {
        NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
        ZipException * exception =[[[ZipException alloc] initWithReason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    int err= unzLocateFile(_unzFile, [fileNameInZip cStringUsingEncoding:NSUTF8StringEncoding], NULL);
    if (err == UNZ_END_OF_LIST_OF_FILE)
        return NO;
    
    if (err != UNZ_OK) {
        NSString *reason= [NSString stringWithFormat:@"Error localting file in zip in '%@'", _fileName];
        ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    return YES;
}

- (FileInZipInfo *) getCurrentFileInZipInfoWithError:(NSError *__autoreleasing *)error {
    if (_mode != ZipFileModeUnzip) {
        NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
        ZipException * exception =[[[ZipException alloc] initWithReason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
    unz_file_info64 file_info;
    
    int err= unzGetCurrentFileInfo64(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
    if (err != UNZ_OK) {
        NSString *reason= [NSString stringWithFormat:@"Error getting current file info in '%@'", _fileName];
        ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    NSString *name= [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];
    
    ZipCompressionLevel level= ZipCompressionLevelNone;
    if (file_info.compression_method != 0) {
        switch ((file_info.flag & 0x6) / 2) {
            case 0:
                level= ZipCompressionLevelDefault;
                break;
                
            case 1:
                level= ZipCompressionLevelBest;
                break;
                
            default:
                level= ZipCompressionLevelFastest;
                break;
        }
    }
    
    BOOL crypted= ((file_info.flag & 1) != 0);
    
    NSDateComponents *components= [[[NSDateComponents alloc] init] autorelease];
    [components setDay:file_info.tmu_date.tm_mday];
    [components setMonth:file_info.tmu_date.tm_mon +1];
    [components setYear:file_info.tmu_date.tm_year];
    [components setHour:file_info.tmu_date.tm_hour];
    [components setMinute:file_info.tmu_date.tm_min];
    [components setSecond:file_info.tmu_date.tm_sec];
    NSCalendar *calendar= [NSCalendar currentCalendar];
    NSDate *date= [calendar dateFromComponents:components];
    
    FileInZipInfo *info= [[FileInZipInfo alloc] initWithName:name length:file_info.uncompressed_size level:level crypted:crypted size:file_info.compressed_size date:date crc32:file_info.crc];
    return [info autorelease];
}

- (ZipReadStream *) readCurrentFileInZipWithError:(NSError *__autoreleasing *)error {
    if (_mode != ZipFileModeUnzip) {
        NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
        ZipException * exception =[[[ZipException alloc] initWithReason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
    unz_file_info64 file_info;
    
    int err= unzGetCurrentFileInfo64(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
    if (err != UNZ_OK) {
        NSString *reason= [NSString stringWithFormat:@"Error getting current file info in '%@'", _fileName];
        ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    NSString *fileNameInZip= [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];
    
    err= unzOpenCurrentFilePassword(_unzFile, NULL);
    if (err != UNZ_OK) {
        NSString *reason= [NSString stringWithFormat:@"Error opening current file in '%@'", _fileName];
        ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    return [[[ZipReadStream alloc] initWithUnzFileStruct:_unzFile fileNameInZip:fileNameInZip] autorelease];
}

- (ZipReadStream *) readCurrentFileInZipWithPassword:(NSString *)password withError:(NSError *__autoreleasing *) error {
    if (_mode != ZipFileModeUnzip) {
        NSString *reason= [NSString stringWithFormat:@"Operation not permitted without Unzip mode"];
        ZipException * exception =[[[ZipException alloc] initWithReason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    char filename_inzip[FILE_IN_ZIP_MAX_NAME_LENGTH];
    unz_file_info64 file_info;
    
    int err= unzGetCurrentFileInfo64(_unzFile, &file_info, filename_inzip, sizeof(filename_inzip), NULL, 0, NULL, 0);
    if (err != UNZ_OK) {
        NSString *reason= [NSString stringWithFormat:@"Error getting current file info in '%@'", _fileName];
        ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    NSString *fileNameInZip= [NSString stringWithCString:filename_inzip encoding:NSUTF8StringEncoding];
    
    err= unzOpenCurrentFilePassword(_unzFile, [password cStringUsingEncoding:NSUTF8StringEncoding]);
    if (err != UNZ_OK) {
        NSString *reason= [NSString stringWithFormat:@"Error opening current file in '%@'", _fileName];
        ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
        [self handleException:exception withError:error];
    }
    
    return [[[ZipReadStream alloc] initWithUnzFileStruct:_unzFile fileNameInZip:fileNameInZip] autorelease];
}

- (void) closeWithError:(NSError *__autoreleasing *)error {
    switch (_mode) {
        case ZipFileModeUnzip: {
            int err= unzClose(_unzFile);
            if (err != UNZ_OK) {
                NSString *reason= [NSString stringWithFormat:@"Error closing '%@'", _fileName];
                ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
                [self handleException:exception withError:error];
            }
            break;
        }
            
        case ZipFileModeCreate: {
            int err= zipClose(_zipFile, NULL);
            if (err != ZIP_OK) {
                NSString *reason= [NSString stringWithFormat:@"Error closing '%@'", _fileName];
                ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
                [self handleException:exception withError:error];
            }
            break;
        }
            
        case ZipFileModeAppend: {
            int err= zipClose(_zipFile, NULL);
            if (err != ZIP_OK) {
                NSString *reason= [NSString stringWithFormat:@"Error closing '%@'", _fileName];
                ZipException * exception =[[[ZipException alloc] initWithError:err reason:reason] autorelease];
                [self handleException:exception withError:error];
            }
            break;
        }
            
        default: {
            NSString *reason= [NSString stringWithFormat:@"Unknown mode %d", _mode];
            ZipException * exception =[[[ZipException alloc] initWithReason:reason] autorelease];
            [self handleException:exception withError:error];
        }
    }
}

#pragma MARK:- Exception handling

- (void) handleException:(ZipException*) exception withError:(NSError* __autoreleasing *) error {
    if (error == nil) {
        @throw exception;
    }
    else {
        *error = exception.toNSError;
    }
}


@end
