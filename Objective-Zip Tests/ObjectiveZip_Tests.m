//
//  ObjectiveZip_Tests.m
//  Objective-Zip
//
//  Created by Gianluca Bertani on 29/08/15.
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

- (void) test01ZipAndUnzip {
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
- (void) test02ZipAndUnzip5GB {
 
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

- (void) test03UnzipMacZipFile {
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

- (void) test04UnzipWinZipFile {
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

- (void) test05ErrorWrapping {
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


@end
