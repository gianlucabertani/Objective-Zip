//
//  ObjectiveZip_Tests.m
//  Objective-Zip v. 1.0.5
//
//  Created by Gianluca Bertani on 29/08/15.
//  Copyright 2009-2017 Gianluca Bertani. All rights reserved.
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

#import <XCTest/XCTest.h>

#import "Objective-Zip.h"
#import "Objective-Zip+NSError.h"


#define HUGE_TEST_BLOCK_LENGTH             (50000LL)
#define HUGE_TEST_NUMBER_OF_BLOCKS        (100000LL)

#define MAC_TEST_ZIP                           (@"UEsDBBQACAAIAPWF10IAAAAAAAAAAAAAAAANABAAdGVzdF9maWxlLnR4dFVYDACQCsdRjQrHUfYB9gHzT8pKTS7JLEvVjcosUPBNTFYoSS0uUUjLzEnlAgBQSwcIlXE92h4AAAAcAAAAUEsDBAoAAAAAAACG10IAAAAAAAAAAAAAAAAJABAAX19NQUNPU1gvVVgMAKAKx1GgCsdR9gH2AVBLAwQUAAgACAD1hddCAAAAAAAAAAAAAAAAGAAQAF9fTUFDT1NYLy5fdGVzdF9maWxlLnR4dFVYDACQCsdRjQrHUfYB9gFjYBVjZ2BiYPBNTFbwD1aIUIACkBgDJxAbAXElEIP4qxmIAo4hIUFQJkjHHCDmR1PCiBAXT87P1UssKMhJ1QtJrShxzUvOT8nMSwdKlpak6VpYGxqbGBmaW1qYAABQSwcIcBqNwF0AAACrAAAAUEsBAhUDFAAIAAgA9YXXQpVxPdoeAAAAHAAAAA0ADAAAAAAAAAAAQKSBAAAAAHRlc3RfZmlsZS50eHRVWAgAkArHUY0Kx1FQSwECFQMKAAAAAAAAhtdCAAAAAAAAAAAAAAAACQAMAAAAAAAAAABA/UFpAAAAX19NQUNPU1gvVVgIAKAKx1GgCsdRUEsBAhUDFAAIAAgA9YXXQnAajcBdAAAAqwAAABgADAAAAAAAAAAAQKSBoAAAAF9fTUFDT1NYLy5fdGVzdF9maWxlLnR4dFVYCACQCsdRjQrHUVBLBQYAAAAAAwADANwAAABTAQAAAAA=")
#define WIN_TEST_ZIP                           (@"UEsDBBQAAAAAAMmF10L4VbPKIQAAACEAAAANAAAAdGVzdF9maWxlLnR4dE9iamVjdGl2ZS1aaXAgV2luZG93cyB0ZXN0IGZpbGUNClBLAQIUABQAAAAAAMmF10L4VbPKIQAAACEAAAANAAAAAAAAAAEAIAAAAAAAAAB0ZXN0X2ZpbGUudHh0UEsFBgAAAAABAAEAOwAAAEwAAAAAAA==")


#pragma mark -
#pragma mark ObjectiveZip_Tests declaration

@interface ObjectiveZip_Tests : XCTestCase
@end


#pragma mark -
#pragma mark ObjectiveZip_Tests implementation

@implementation ObjectiveZip_Tests


#pragma mark -
#pragma mark Set up and tear down

- (void) setUp {
    [super setUp];
}

- (void) tearDown {
    [super tearDown];
}


#pragma mark -
#pragma mark Tests

- (void) test00_DOSDate {
    
    // NSDate to DOS date
    NSDateComponents *components= [[NSDateComponents alloc] init];
    [components setDay:25];
    [components setMonth:1];
    [components setYear:2016];
    [components setHour:17];
    [components setMinute:33];
    [components setSecond:4];
    
    NSCalendar *calendar= [NSCalendar currentCalendar];
    NSDate *date= [calendar dateFromComponents:components];
    
    uint32_t dosDate= [date dosDate];
    
    XCTAssertEqual(1211730978, dosDate);
    
    // DOS date to NSDate
    NSDate *date2= [NSDate fromDosDate:dosDate];
    NSDateComponents *components2= [calendar components:(NSCalendarUnitSecond | NSCalendarUnitMinute | NSCalendarUnitHour | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date2];
    
    XCTAssertEqual(25, [components2 day]);
    XCTAssertEqual(1, [components2 month]);
    XCTAssertEqual(2016, [components2 year]);
    XCTAssertEqual(17, [components2 hour]);
    XCTAssertEqual(33, [components2 minute]);
    XCTAssertEqual(4, [components2 second]);
}

- (void) test01_ZipAndUnzip {
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test.zip"];
    
    @try {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        
        NSLog(@"Test 1: opening zip file for writing...");
        
        OZZipFile *zipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate];
        
        XCTAssertNotNil(zipFile);
        
        NSLog(@"Test 1: adding first file...");
        
        OZZipWriteStream *stream1= [zipFile writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:OZZipCompressionLevelBest];

        XCTAssertNotNil(stream1);
        
        NSLog(@"Test 1: writing to first file's stream...");
        
        NSString *text= @"abc";
        [stream1 writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"Test 1: closing first file's stream...");
        
        [stream1 finishedWriting];
        
        NSLog(@"Test 1: adding second file...");
        
        NSString *file2name= @"x/y/z/xyz.txt";
        OZZipWriteStream *stream2= [zipFile writeFileInZipWithName:file2name compressionLevel:OZZipCompressionLevelNone];
        
        XCTAssertNotNil(stream2);
        
        NSLog(@"Test 1: writing to second file's stream...");
        
        NSString *text2= @"XYZ";
        [stream2 writeData:[text2 dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSLog(@"Test 1: closing second file's stream...");
        
        [stream2 finishedWriting];
        
        NSLog(@"Test 1: closing zip file...");
        
        [zipFile close];
        
        NSLog(@"Test 1: opening zip file for reading...");
        
        OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip];
        
        XCTAssertNotNil(unzipFile);
        
        NSLog(@"Test 1: reading file infos...");
        
        NSArray *infos= [unzipFile listFileInZipInfos];
        
        XCTAssertEqual(2, infos.count);
        
        OZFileInZipInfo *info1= [infos objectAtIndex:0];
        
        XCTAssertEqualWithAccuracy([[NSDate date] timeIntervalSinceReferenceDate], [info1.date timeIntervalSinceReferenceDate] + 86400, 5.0);
        
        NSLog(@"Test 1: - %@ %@ %lu (%ld)", info1.name, info1.date, (unsigned long) info1.size, (long) info1.level);
        
        OZFileInZipInfo *info2= [infos objectAtIndex:1];
        
        XCTAssertEqualWithAccuracy([[NSDate date] timeIntervalSinceReferenceDate], [info2.date timeIntervalSinceReferenceDate], 5.0);
        
        NSLog(@"Test 1: - %@ %@ %lu (%ld)", info2.name, info2.date, (unsigned long) info2.size, (long) info2.level);
        
        NSLog(@"Test 1: opening first file...");
        
        [unzipFile goToFirstFileInZip];
        OZZipReadStream *read1= [unzipFile readCurrentFileInZip];
        
        XCTAssertNotNil(read1);
        
        NSLog(@"Test 1: reading from first file's stream...");
        
        NSMutableData *data1= [[NSMutableData alloc] initWithLength:256];
        NSUInteger bytesRead1= [read1 readDataWithBuffer:data1];
        
        XCTAssertEqual(3, bytesRead1);
        
        NSString *fileText1= [[NSString alloc] initWithBytes:[data1 bytes] length:bytesRead1 encoding:NSUTF8StringEncoding];
        
        XCTAssertEqualObjects(@"abc", fileText1);
        
        NSLog(@"Test 1: closing first file's stream...");
        
        [read1 finishedReading];
        
        NSLog(@"Test 1: opening second file...");
        
        [unzipFile locateFileInZip:file2name];
        OZZipReadStream *read2= [unzipFile readCurrentFileInZip];
        
        XCTAssertNotNil(read2);
        
        NSLog(@"Test 1: reading from second file's stream...");
        
        NSMutableData *data2= [[NSMutableData alloc] initWithLength:256];
        NSUInteger bytesRead2= [read2 readDataWithBuffer:data2];
        
        XCTAssertEqual(3, bytesRead2);

        NSString *fileText2= [[NSString alloc] initWithBytes:[data2 bytes] length:bytesRead2 encoding:NSUTF8StringEncoding];
        
        XCTAssertEqualObjects(@"XYZ", fileText2);
        
        NSLog(@"Test 1: closing second file's stream...");
        
        [read2 finishedReading];
        
        NSLog(@"Test 1: closing zip file...");
        
        [unzipFile close];
        
        NSLog(@"Test 1: test terminated succesfully");
        
    } @catch (OZZipException *ze) {
        NSLog(@"Test 1: zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
        XCTFail(@"Zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
    } @catch (NSException *e) {
        NSLog(@"Test 1: generic exception caught: %@ - %@", [[e class] description], [e description]);
        
        XCTFail(@"Generic exception caught: %@ - %@", [[e class] description], [e description]);

    } @finally {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
}

/* 
 * Uncomment to execute this test, but be careful: takes 5 minutes and consumes 5 GB of disk space
 *
- (void) test02_ZipAndUnzip5GB {
 
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath= [documentsDir stringByAppendingPathComponent:@"huge_test.zip"];
    
    @try {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        
        NSLog(@"Test 2: opening zip file for writing...");
        
        OZZipFile *zipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate];
        
        XCTAssertNotNil(zipFile);
        
        NSLog(@"Test 2: adding file...");
        
        OZZipWriteStream *stream= [zipFile writeFileInZipWithName:@"huge_file.txt" compressionLevel:OZZipCompressionLevelBest];
        
        XCTAssertNotNil(stream);
        
        NSLog(@"Test 2: writing to file's stream...");
        
        NSMutableData *data= [[NSMutableData alloc] initWithLength:HUGE_TEST_BLOCK_LENGTH];
        SecRandomCopyBytes(kSecRandomDefault, [data length], [data mutableBytes]);
        
        NSData *checkData= [data subdataWithRange:NSMakeRange(0, 100)];
        
        NSMutableData *buffer= [[NSMutableData alloc] initWithLength:HUGE_TEST_BLOCK_LENGTH]; // For use later
        
        for (int i= 0; i < HUGE_TEST_NUMBER_OF_BLOCKS; i++) {
            [stream writeData:data];
            
            if (i % 100 == 0)
                NSLog(@"Test 2: written %lu KB...", (unsigned long) ([data length] / 1024) * (i +1));
        }
        
        NSLog(@"Test 2: closing file's stream...");
        
        [stream finishedWriting];
        
        NSLog(@"Test 2: closing zip file...");
        
        [zipFile close];
        
        NSLog(@"Test 2: opening zip file for reading...");
        
        OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip];
        
        XCTAssertNotNil(unzipFile);
        
        NSLog(@"Test 1: reading file infos...");
        
        NSArray *infos= [unzipFile listFileInZipInfos];
        
        XCTAssertEqual(1, infos.count);
        
        OZFileInZipInfo *info1= [infos objectAtIndex:0];
        
        XCTAssertEqual(info1.length, HUGE_TEST_NUMBER_OF_BLOCKS * HUGE_TEST_BLOCK_LENGTH);
        
        NSLog(@"Test 1: - %@ %@ %lu (%ld)", info1.name, info1.date, (unsigned long) info1.size, (long) info1.level);
        
        NSLog(@"Test 2: opening file...");
        
        [unzipFile goToFirstFileInZip];
        OZZipReadStream *read= [unzipFile readCurrentFileInZip];
        
        XCTAssertNotNil(read);
        
        NSLog(@"Test 2: reading from file's stream...");
        
        for (int i= 0; i < HUGE_TEST_NUMBER_OF_BLOCKS; i++) {
            NSUInteger bytesRead= [read readDataWithBuffer:buffer];
            
            XCTAssertEqual([data length], bytesRead);

            NSRange range= [buffer rangeOfData:checkData options:0 range:NSMakeRange(0, [buffer length])];
            
            XCTAssertEqual(0, range.location);
            
            if (i % 100 == 0)
                NSLog(@"Test 2: read %lu KB...", (unsigned long) ([buffer length] / 1024) * (i +1));
        }
        
        NSLog(@"Test 2: closing file's stream...");
        
        [read finishedReading];
        
        NSLog(@"Test 2: closing zip file...");
        
        [unzipFile close];
        
        NSLog(@"Test 2: test terminated succesfully");
        
    } @catch (OZZipException *ze) {
        NSLog(@"Test 2: zip exception caught: %ld - %@", (long) ze.error, [ze reason]);

        XCTFail(@"Zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
    } @catch (NSException *e) {
        NSLog(@"Test 2: generic exception caught: %@ - %@", [[e class] description], [e description]);

        XCTFail(@"Generic exception caught: %@ - %@", [[e class] description], [e description]);
        
    } @finally {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
}
 */

- (void) test03_UnzipMacZipFile {
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath= [documentsDir stringByAppendingPathComponent:@"mac_test_file.zip"];
    
    NSData *macZipData= [[NSData alloc] initWithBase64EncodedString:MAC_TEST_ZIP options:0];
    [macZipData writeToFile:filePath atomically:NO];
    
    @try {
        NSLog(@"Test 3: opening zip file for reading...");
        
        OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip];
        
        XCTAssertNotNil(unzipFile);
        
        NSLog(@"Test 3: opening file...");
        
        [unzipFile goToFirstFileInZip];
        OZZipReadStream *read= [unzipFile readCurrentFileInZip];
        
        XCTAssertNotNil(read);
        
        NSLog(@"Test 3: reading from file's stream...");
        
        NSMutableData *buffer= [[NSMutableData alloc] initWithLength:1024];
        
        NSUInteger bytesRead= [read readDataWithBuffer:buffer];
        
        NSString *fileText= [[NSString alloc] initWithBytes:[buffer bytes] length:bytesRead encoding:NSUTF8StringEncoding];
        
        XCTAssertEqualObjects(@"Objective-Zip Mac test file\n", fileText);
        
        NSLog(@"Test 3: closing file's stream...");
        
        [read finishedReading];
        
        NSLog(@"Test 3: closing zip file...");
        
        [unzipFile close];
        
        NSLog(@"Test 3: test terminated succesfully");
        
    } @catch (OZZipException *ze) {
        NSLog(@"Test 3: zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
        XCTFail(@"Zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
    } @catch (NSException *e) {
        NSLog(@"Test 3: generic exception caught: %@ - %@", [[e class] description], [e description]);
        
        XCTFail(@"Generic exception caught: %@ - %@", [[e class] description], [e description]);
        
    } @finally {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
}

- (void) test04_UnzipWinZipFile {
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath= [documentsDir stringByAppendingPathComponent:@"win_test_file.zip"];

    NSData *winZipData= [[NSData alloc] initWithBase64EncodedString:WIN_TEST_ZIP options:0];
    [winZipData writeToFile:filePath atomically:NO];
    
    @try {
        NSLog(@"Test 4: opening zip file for reading...");
        
        OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip];
        
        XCTAssertNotNil(unzipFile);
        
        NSLog(@"Test 4: opening file...");
        
        [unzipFile goToFirstFileInZip];
        OZZipReadStream *read= [unzipFile readCurrentFileInZip];
        
        XCTAssertNotNil(read);
        
        NSLog(@"Test 4: reading from file's stream...");
        
        NSMutableData *buffer= [[NSMutableData alloc] initWithLength:1024];
        
        NSUInteger bytesRead= [read readDataWithBuffer:buffer];
        
        NSString *fileText= [[NSString alloc] initWithBytes:[buffer bytes] length:bytesRead encoding:NSUTF8StringEncoding];
        
        XCTAssertEqualObjects(@"Objective-Zip Windows test file\r\n", fileText);
        
        NSLog(@"Test 4: closing file's stream...");
        
        [read finishedReading];
        
        NSLog(@"Test 4: closing zip file...");
        
        [unzipFile close];
        
        NSLog(@"Test 4: test terminated succesfully");
        
    } @catch (OZZipException *ze) {
        NSLog(@"Test 4: zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
        XCTFail(@"Zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
    } @catch (NSException *e) {
        NSLog(@"Test 4: generic exception caught: %@ - %@", [[e class] description], [e description]);
        
        XCTFail(@"Generic exception caught: %@ - %@", [[e class] description], [e description]);
        
    } @finally {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
}

- (void) test05_ErrorWrapping {
    NSString *filePath= @"/root.zip";
    
    @try {
        NSLog(@"Test 5: opening impossible zip file for writing...");
        
        OZZipFile *zipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate];

        [zipFile close];
        
        NSLog(@"Test 5: test failed, no error reported");
        
        XCTFail(@"No error reported");
        
    } @catch (OZZipException *ze) {
        
        XCTAssertEqual(OZ_ERROR_NO_SUCH_FILE, ze.error);
        
    } @catch (NSException *e) {
        NSLog(@"Test 5: generic exception caught: %@ - %@", [[e class] description], [e description]);
        
        XCTFail(@"Generic exception caught: %@ - %@", [[e class] description], [e description]);

    } @finally {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
    
    @try {
        NSLog(@"Test 5: opening again impossible zip file for writing...");
        
        NSError *error= nil;
        OZZipFile *zipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate error:&error];

        [zipFile close];
        
        XCTAssertNil(zipFile);
        XCTAssertNotNil(error);
        XCTAssertEqual(OZ_ERROR_NO_SUCH_FILE, error.code);
        
        NSLog(@"Test 5: test terminated succesfully");
        
    } @catch (NSException *e) {
        NSLog(@"Test 5: generic exception caught: %@ - %@", [[e class] description], [e description]);
        
        XCTFail(@"Generic exception caught: %@ - %@", [[e class] description], [e description]);
        
    } @finally {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
}

- (void) test06_Zip32AndUnzip64 {
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test32_64.zip"];
    
    @try {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        
        NSLog(@"Test 6: opening zip file for writing in 32 bit mode...");
        
        OZZipFile *zipFile32= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate legacy32BitMode:YES];
        
        XCTAssertNotNil(zipFile32);
        
        NSLog(@"Test 6: adding file...");
        
        OZZipWriteStream *stream= [zipFile32 writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:OZZipCompressionLevelDefault];
        
        XCTAssertNotNil(stream);
        
        NSLog(@"Test 6: writing to file's stream...");
        
        NSMutableData *writeData= [NSMutableData dataWithLength:4096];
        int result= SecRandomCopyBytes(kSecRandomDefault, [writeData length], [writeData mutableBytes]);
        
        XCTAssertEqual(0, result);
        
        [stream writeData:writeData];
        
        NSLog(@"Test 6: closing file's stream...");
        
        [stream finishedWriting];
        
        NSLog(@"Test 6: closing zip file...");
        
        [zipFile32 close];
        
        NSLog(@"Test 6: opening zip file for reading in 64 bit mode...");
        
        OZZipFile *unzipFile64= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip legacy32BitMode:NO];
        
        XCTAssertNotNil(unzipFile64);
        
        NSLog(@"Test 6: reading file infos...");
        
        NSArray *infos= [unzipFile64 listFileInZipInfos];
        
        XCTAssertEqual(1, infos.count);
        
        OZFileInZipInfo *info1= [infos objectAtIndex:0];
        
        XCTAssertEqualWithAccuracy([[NSDate date] timeIntervalSinceReferenceDate], [info1.date timeIntervalSinceReferenceDate] + 86400, 5.0);
        
        NSLog(@"Test 6: - %@ %@ %lu (%ld)", info1.name, info1.date, (unsigned long) info1.size, (long) info1.level);
        
        NSLog(@"Test 6: opening file...");
        
        [unzipFile64 goToFirstFileInZip];
        OZZipReadStream *read= [unzipFile64 readCurrentFileInZip];
        
        XCTAssertNotNil(read);
        
        NSLog(@"Test 6: reading from file's stream...");
        
        NSMutableData *readData= [[NSMutableData alloc] initWithLength:10240];
        NSUInteger bytesRead= [read readDataWithBuffer:readData];
        [readData setLength:bytesRead];
        
        XCTAssertEqual(4096, bytesRead);
        XCTAssertEqualObjects(writeData, readData);
        
        NSLog(@"Test 6: closing file's stream...");
        
        [read finishedReading];
        
        NSLog(@"Test 6: closing zip file...");
        
        [unzipFile64 close];
        
        NSLog(@"Test 6: test terminated succesfully");
        
    } @catch (OZZipException *ze) {
        NSLog(@"Test 6: zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
        XCTFail(@"Zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
    } @catch (NSException *e) {
        NSLog(@"Test 6: generic exception caught: %@ - %@", [[e class] description], [e description]);
        
        XCTFail(@"Generic exception caught: %@ - %@", [[e class] description], [e description]);
        
    } @finally {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
}

- (void) test07_Zip64AndUnzip32 {
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test64_32.zip"];
    
    @try {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        
        NSLog(@"Test 7: opening zip file for writing in 64 bit mode...");
        
        OZZipFile *zipFile64= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate legacy32BitMode:NO];
        
        XCTAssertNotNil(zipFile64);
        
        NSLog(@"Test 7: adding file...");
        
        OZZipWriteStream *stream= [zipFile64 writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:OZZipCompressionLevelDefault];
        
        XCTAssertNotNil(stream);
        
        NSLog(@"Test 7: writing to file's stream...");
        
        NSMutableData *writeData= [NSMutableData dataWithLength:4096];
        int result= SecRandomCopyBytes(kSecRandomDefault, [writeData length], [writeData mutableBytes]);
        
        XCTAssertEqual(0, result);
        
        [stream writeData:writeData];
        
        NSLog(@"Test 7: closing file's stream...");
        
        [stream finishedWriting];
        
        NSLog(@"Test 7: closing zip file...");
        
        [zipFile64 close];
        
        NSLog(@"Test 7: opening zip file for reading in 32 bit mode...");
        
        OZZipFile *unzipFile32= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip legacy32BitMode:YES];
        
        XCTAssertNotNil(unzipFile32);
        
        NSLog(@"Test 7: reading file infos...");
        
        NSArray *infos= [unzipFile32 listFileInZipInfos];
        
        XCTAssertEqual(1, infos.count);
        
        OZFileInZipInfo *info1= [infos objectAtIndex:0];
        
        XCTAssertEqualWithAccuracy([[NSDate date] timeIntervalSinceReferenceDate], [info1.date timeIntervalSinceReferenceDate] + 86400, 5.0);
        
        NSLog(@"Test 7: - %@ %@ %lu (%ld)", info1.name, info1.date, (unsigned long) info1.size, (long) info1.level);
        
        NSLog(@"Test 7: opening file...");
        
        [unzipFile32 goToFirstFileInZip];
        OZZipReadStream *read= [unzipFile32 readCurrentFileInZip];
        
        XCTAssertNotNil(read);
        
        NSLog(@"Test 7: reading from file's stream...");
        
        NSMutableData *readData= [[NSMutableData alloc] initWithLength:10240];
        NSUInteger bytesRead= [read readDataWithBuffer:readData];
        [readData setLength:bytesRead];
        
        XCTAssertEqual(4096, bytesRead);
        XCTAssertEqualObjects(writeData, readData);
        
        NSLog(@"Test 7: closing file's stream...");
        
        [read finishedReading];
        
        NSLog(@"Test 7: closing zip file...");
        
        [unzipFile32 close];
        
        NSLog(@"Test 7: test terminated succesfully");
        
    } @catch (OZZipException *ze) {
        NSLog(@"Test 7: zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
        XCTFail(@"Zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
    } @catch (NSException *e) {
        NSLog(@"Test 7: generic exception caught: %@ - %@", [[e class] description], [e description]);
        
        XCTFail(@"Generic exception caught: %@ - %@", [[e class] description], [e description]);
        
    } @finally {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
}

- (void) test08_ZipAndUnzip32WithPassword {
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test32_password.zip"];
    
    @try {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        
        NSLog(@"Test 8: opening zip file for writing in 32 bit mode...");
        
        OZZipFile *zipFile32= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate legacy32BitMode:YES];
        
        XCTAssertNotNil(zipFile32);
        
        NSLog(@"Test 8: adding file...");
        
        NSMutableData *writeData= [NSMutableData dataWithLength:4096];
        int result= SecRandomCopyBytes(kSecRandomDefault, [writeData length], [writeData mutableBytes]);
        
        XCTAssertEqual(0, result);

        uint32_t crc= [writeData crc32];

        OZZipWriteStream *stream= [zipFile32 writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:OZZipCompressionLevelDefault password:@"password" crc32:crc];
        
        XCTAssertNotNil(stream);
        
        NSLog(@"Test 8: writing to file's stream with password...");
        
        [stream writeData:writeData];
        
        NSLog(@"Test 8: closing file's stream...");
        
        [stream finishedWriting];
        
        NSLog(@"Test 8: closing zip file...");
        
        [zipFile32 close];
        
        NSLog(@"Test 8: opening zip file for reading in 32 bit mode...");
        
        OZZipFile *unzipFile32= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip legacy32BitMode:YES];
        
        XCTAssertNotNil(unzipFile32);
        
        NSLog(@"Test 8: reading file infos...");
        
        NSArray *infos= [unzipFile32 listFileInZipInfos];
        
        XCTAssertEqual(1, infos.count);
        
        OZFileInZipInfo *info1= [infos objectAtIndex:0];
        
        XCTAssertEqualWithAccuracy([[NSDate date] timeIntervalSinceReferenceDate], [info1.date timeIntervalSinceReferenceDate] + 86400, 5.0);
        
        NSLog(@"Test 8: - %@ %@ %lu (%ld)", info1.name, info1.date, (unsigned long) info1.size, (long) info1.level);
        
        NSLog(@"Test 8: opening file...");
        
        [unzipFile32 goToFirstFileInZip];
        OZZipReadStream *read= [unzipFile32 readCurrentFileInZipWithPassword:@"password"];
        
        XCTAssertNotNil(read);
        
        NSLog(@"Test 8: reading from file's stream with password...");
        
        NSMutableData *readData= [[NSMutableData alloc] initWithLength:10240];
        NSUInteger bytesRead= [read readDataWithBuffer:readData];
        [readData setLength:bytesRead];
        
        XCTAssertEqual(4096, bytesRead);
        XCTAssertEqualObjects(writeData, readData);
        
        NSLog(@"Test 8: closing file's stream...");
        
        [read finishedReading];
        
        NSLog(@"Test 8: closing zip file...");
        
        [unzipFile32 close];
        
        NSLog(@"Test 8: test terminated succesfully");
        
    } @catch (OZZipException *ze) {
        NSLog(@"Test 8: zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
        XCTFail(@"Zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
    } @catch (NSException *e) {
        NSLog(@"Test 8: generic exception caught: %@ - %@", [[e class] description], [e description]);
        
        XCTFail(@"Generic exception caught: %@ - %@", [[e class] description], [e description]);
        
    } @finally {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
}

- (void) test09_ZipAndUnzip64WithPassword {
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test64_password.zip"];
    
    @try {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        
        NSLog(@"Test 9: opening zip file for writing in 64 bit mode...");
        
        OZZipFile *zipFile64= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate legacy32BitMode:NO];
        
        XCTAssertNotNil(zipFile64);
        
        NSLog(@"Test 9: adding file...");
        
        NSMutableData *writeData= [NSMutableData dataWithLength:4096];
        int result= SecRandomCopyBytes(kSecRandomDefault, [writeData length], [writeData mutableBytes]);
        
        XCTAssertEqual(0, result);
        
        uint32_t crc= [writeData crc32];

        OZZipWriteStream *stream= [zipFile64 writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:OZZipCompressionLevelDefault password:@"password" crc32:crc];
        
        XCTAssertNotNil(stream);
        
        NSLog(@"Test 9: writing to file's stream with password...");
        
        [stream writeData:writeData];
        
        NSLog(@"Test 9: closing file's stream...");
        
        [stream finishedWriting];
        
        NSLog(@"Test 9: closing zip file...");
        
        [zipFile64 close];
        
        NSLog(@"Test 9: opening zip file for reading in 64 bit mode...");
        
        OZZipFile *unzipFile64= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip legacy32BitMode:NO];
        
        XCTAssertNotNil(unzipFile64);
        
        NSLog(@"Test 9: reading file infos...");
        
        NSArray *infos= [unzipFile64 listFileInZipInfos];
        
        XCTAssertEqual(1, infos.count);
        
        OZFileInZipInfo *info1= [infos objectAtIndex:0];
        
        XCTAssertEqualWithAccuracy([[NSDate date] timeIntervalSinceReferenceDate], [info1.date timeIntervalSinceReferenceDate] + 86400, 5.0);
        
        NSLog(@"Test 9: - %@ %@ %lu (%ld)", info1.name, info1.date, (unsigned long) info1.size, (long) info1.level);
        
        NSLog(@"Test 9: opening file...");
        
        [unzipFile64 goToFirstFileInZip];
        OZZipReadStream *read= [unzipFile64 readCurrentFileInZipWithPassword:@"password"];
        
        XCTAssertNotNil(read);
        
        NSLog(@"Test 9: reading from file's stream with password...");
        
        NSMutableData *readData= [[NSMutableData alloc] initWithLength:10240];
        NSUInteger bytesRead= [read readDataWithBuffer:readData];
        [readData setLength:bytesRead];
        
        XCTAssertEqual(4096, bytesRead);
        XCTAssertEqualObjects(writeData, readData);
        
        NSLog(@"Test 9: closing file's stream...");
        
        [read finishedReading];
        
        NSLog(@"Test 9: closing zip file...");
        
        [unzipFile64 close];
        
        NSLog(@"Test 9: test terminated succesfully");
        
    } @catch (OZZipException *ze) {
        NSLog(@"Test 9: zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
        XCTFail(@"Zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
    } @catch (NSException *e) {
        NSLog(@"Test 9: generic exception caught: %@ - %@", [[e class] description], [e description]);
        
        XCTFail(@"Generic exception caught: %@ - %@", [[e class] description], [e description]);
        
    } @finally {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
}

- (void) test10_Zip32AndUnzip64WithPassword {
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test32_64_password.zip"];
    
    @try {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        
        NSLog(@"Test 10: opening zip file for writing in 32 bit mode...");
        
        OZZipFile *zipFile32= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate legacy32BitMode:YES];
        
        XCTAssertNotNil(zipFile32);
        
        NSLog(@"Test 10: adding file...");
        
        NSMutableData *writeData= [NSMutableData dataWithLength:4096];
        int result= SecRandomCopyBytes(kSecRandomDefault, [writeData length], [writeData mutableBytes]);
        
        XCTAssertEqual(0, result);
        
        uint32_t crc= [writeData crc32];
        
        OZZipWriteStream *stream= [zipFile32 writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:OZZipCompressionLevelDefault password:@"password" crc32:crc];
        
        XCTAssertNotNil(stream);
        
        NSLog(@"Test 10: writing to file's stream with password...");
        
        [stream writeData:writeData];
        
        NSLog(@"Test 10: closing file's stream...");
        
        [stream finishedWriting];
        
        NSLog(@"Test 10: closing zip file...");
        
        [zipFile32 close];
        
        NSLog(@"Test 10: opening zip file for reading in 64 bit mode...");
        
        OZZipFile *unzipFile64= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip legacy32BitMode:NO];
        
        XCTAssertNotNil(unzipFile64);
        
        NSLog(@"Test 10: reading file infos...");
        
        NSArray *infos= [unzipFile64 listFileInZipInfos];
        
        XCTAssertEqual(1, infos.count);
        
        OZFileInZipInfo *info1= [infos objectAtIndex:0];
        
        XCTAssertEqualWithAccuracy([[NSDate date] timeIntervalSinceReferenceDate], [info1.date timeIntervalSinceReferenceDate] + 86400, 5.0);
        
        NSLog(@"Test 10: - %@ %@ %lu (%ld)", info1.name, info1.date, (unsigned long) info1.size, (long) info1.level);
        
        NSLog(@"Test 10: opening file...");
        
        [unzipFile64 goToFirstFileInZip];
        OZZipReadStream *read= [unzipFile64 readCurrentFileInZipWithPassword:@"password"];
        
        XCTAssertNotNil(read);
        
        NSLog(@"Test 10: reading from file's stream with password...");
        
        NSMutableData *readData= [[NSMutableData alloc] initWithLength:10240];
        NSUInteger bytesRead= [read readDataWithBuffer:readData];
        [readData setLength:bytesRead];
        
        XCTAssertEqual(4096, bytesRead);
        XCTAssertEqualObjects(writeData, readData);
        
        NSLog(@"Test 10: closing file's stream...");
        
        [read finishedReading];
        
        NSLog(@"Test 10: closing zip file...");
        
        [unzipFile64 close];
        
        NSLog(@"Test 10: test terminated succesfully");
        
    } @catch (OZZipException *ze) {
        NSLog(@"Test 10: zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
        XCTFail(@"Zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
    } @catch (NSException *e) {
        NSLog(@"Test 10: generic exception caught: %@ - %@", [[e class] description], [e description]);
        
        XCTFail(@"Generic exception caught: %@ - %@", [[e class] description], [e description]);
        
    } @finally {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
}

- (void) test11_Zip64AndUnzip32WithPassword {
    NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test64_32_password.zip"];
    
    @try {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        
        NSLog(@"Test 11: opening zip file for writing in 64 bit mode...");
        
        OZZipFile *zipFile64= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate legacy32BitMode:NO];
        
        XCTAssertNotNil(zipFile64);
        
        NSLog(@"Test 11: adding file...");
        
        NSMutableData *writeData= [NSMutableData dataWithLength:4096];
        int result= SecRandomCopyBytes(kSecRandomDefault, [writeData length], [writeData mutableBytes]);
        
        XCTAssertEqual(0, result);
        
        uint32_t crc= [writeData crc32];

        OZZipWriteStream *stream= [zipFile64 writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:OZZipCompressionLevelDefault password:@"password" crc32:crc];
        
        XCTAssertNotNil(stream);
        
        NSLog(@"Test 11: writing to file's stream with password...");
        
        [stream writeData:writeData];
        
        NSLog(@"Test 11: closing file's stream...");
        
        [stream finishedWriting];
        
        NSLog(@"Test 11: closing zip file...");
        
        [zipFile64 close];
        
        NSLog(@"Test 11: opening zip file for reading in 32 bit mode...");
        
        OZZipFile *unzipFile32= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip legacy32BitMode:YES];
        
        XCTAssertNotNil(unzipFile32);
        
        NSLog(@"Test 11: reading file infos...");
        
        NSArray *infos= [unzipFile32 listFileInZipInfos];
        
        XCTAssertEqual(1, infos.count);
        
        OZFileInZipInfo *info1= [infos objectAtIndex:0];
        
        XCTAssertEqualWithAccuracy([[NSDate date] timeIntervalSinceReferenceDate], [info1.date timeIntervalSinceReferenceDate] + 86400, 5.0);
        
        NSLog(@"Test 11: - %@ %@ %lu (%ld)", info1.name, info1.date, (unsigned long) info1.size, (long) info1.level);
        
        NSLog(@"Test 11: opening file...");
        
        [unzipFile32 goToFirstFileInZip];
        OZZipReadStream *read= [unzipFile32 readCurrentFileInZipWithPassword:@"password"];
        
        XCTAssertNotNil(read);
        
        NSLog(@"Test 11: reading from file's stream with password...");
        
        NSMutableData *readData= [[NSMutableData alloc] initWithLength:10240];
        NSUInteger bytesRead= [read readDataWithBuffer:readData];
        [readData setLength:bytesRead];
        
        XCTAssertEqual(4096, bytesRead);
        XCTAssertEqualObjects(writeData, readData);
        
        NSLog(@"Test 7: closing file's stream...");
        
        [read finishedReading];
        
        NSLog(@"Test 7: closing zip file...");
        
        [unzipFile32 close];
        
        NSLog(@"Test 7: test terminated succesfully");
        
    } @catch (OZZipException *ze) {
        NSLog(@"Test 7: zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
        XCTFail(@"Zip exception caught: %ld - %@", (long) ze.error, [ze reason]);
        
    } @catch (NSException *e) {
        NSLog(@"Test 7: generic exception caught: %@ - %@", [[e class] description], [e description]);
        
        XCTFail(@"Generic exception caught: %@ - %@", [[e class] description], [e description]);
        
    } @finally {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
    }
}


@end
