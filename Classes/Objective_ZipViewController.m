//
//  Objective_ZipViewController.m
//  Objective-Zip
//
//  Created by Gianluca Bertani on 25/12/09.
//  Copyright Flying Dolphin Studio 2009. All rights reserved.
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

#import "Objective_ZipViewController.h"
#import "../Objective-Zip/OZZipFile.h"
#import "../Objective-Zip/OZZipException.h"
#import "../Objective-Zip/OZFileInZipInfo.h"
#import "../Objective-Zip/OZZipWriteStream.h"
#import "../Objective-Zip/OZZipReadStream.h"

#define HUGE_TEST_BLOCK_LENGTH             (50000)
#define HUGE_TEST_NUMBER_OF_BLOCKS        (100000)


@interface Objective_ZipViewController ()


#pragma mark -
#pragma mark Tests

- (void) test1;
- (void) test2;
- (void) test3;
- (void) test4;


#pragma mark -
#pragma mark Logging

- (void) log:(NSString *)format, ...;


@end


@implementation Objective_ZipViewController


- (void) loadView {
	[super loadView];
	
	_textView.font= [UIFont fontWithName:@"Helvetica" size:11.0];
}


- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction) zipUnzip {
	
	_testThread= [[NSThread alloc] initWithTarget:self selector:@selector(test1) object:nil];
	[_testThread start];
}

- (IBAction) zipUnzip2 {
	
	_testThread= [[NSThread alloc] initWithTarget:self selector:@selector(test2) object:nil];
	[_testThread start];
}

- (IBAction) zipCheck1 {
	
	_testThread= [[NSThread alloc] initWithTarget:self selector:@selector(test3) object:nil];
	[_testThread start];
}

- (IBAction) zipCheck2 {
	
	_testThread= [[NSThread alloc] initWithTarget:self selector:@selector(test4) object:nil];
	[_testThread start];
}


#pragma mark -
#pragma mark Test 1: zip & unzip

- (void) test1 {
    @autoreleasepool {

		NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
		NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test.zip"];

		@try {
			[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];

			[self log:@"Test 1: opening zip file for writing..."];
			
			OZZipFile *zipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate];

			[self log:@"Test 1: adding first file..."];
			
			OZZipWriteStream *stream1= [zipFile writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:OZZipCompressionLevelBest];

			[self log:@"Test 1: writing to first file's stream..."];

			NSString *text= @"abc";
			[stream1 writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];

			[self log:@"Test 1: closing first file's stream..."];
			
			[stream1 finishedWriting];
			
			[self log:@"Test 1: adding second file..."];
			
			NSString *file2name= @"x/y/z/xyz.txt";
			OZZipWriteStream *stream2= [zipFile writeFileInZipWithName:file2name compressionLevel:OZZipCompressionLevelNone];
			
			[self log:@"Test 1: writing to second file's stream..."];
			
			NSString *text2= @"XYZ";
			[stream2 writeData:[text2 dataUsingEncoding:NSUTF8StringEncoding]];
			
			[self log:@"Test 1: closing second file's stream..."];
			
			[stream2 finishedWriting];
			
			[self log:@"Test 1: closing zip file..."];
			
			[zipFile close];
			
			[self log:@"Test 1: opening zip file for reading..."];
			
			OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip];
			
			[self log:@"Test 1: reading file infos..."];
			
			NSArray *infos= [unzipFile listFileInZipInfos];
			for (OZFileInZipInfo *info in infos)
				[self log:@"Test 1: - %@ %@ %d (%d)", info.name, info.date, info.size, info.level];
			
			[self log:@"Test 1: opening first file..."];
			
			[unzipFile goToFirstFileInZip];
			OZZipReadStream *read1= [unzipFile readCurrentFileInZip];
			
			[self log:@"Test 1: reading from first file's stream..."];
			
			NSMutableData *data1= [[NSMutableData alloc] initWithLength:256];
			int bytesRead1= [read1 readDataWithBuffer:data1];
			
			BOOL ok= NO;
			if (bytesRead1 == 3) {
				NSString *fileText1= [[NSString alloc] initWithBytes:[data1 bytes] length:bytesRead1 encoding:NSUTF8StringEncoding];
				if ([fileText1 isEqualToString:@"abc"])
					ok= YES;
			}
			
			if (ok)
				[self log:@"Test 1: content of first file is OK"];
			else
				[self log:@"Test 1: content of first file is WRONG"];
				
			[self log:@"Test 1: closing first file's stream..."];
			
			[read1 finishedReading];
			
			[self log:@"Test 1: opening second file..."];

			[unzipFile locateFileInZip:file2name];
			OZZipReadStream *read2= [unzipFile readCurrentFileInZip];

			[self log:@"Test 1: reading from second file's stream..."];
			
			NSMutableData *data2= [[NSMutableData alloc] initWithLength:256];
			int bytesRead2= [read2 readDataWithBuffer:data2];
			
			ok= NO;
			if (bytesRead2 == 3) {
				NSString *fileText2= [[NSString alloc] initWithBytes:[data2 bytes] length:bytesRead2 encoding:NSUTF8StringEncoding];
				if ([fileText2 isEqualToString:@"XYZ"])
					ok= YES;
			}
			
			if (ok)
				[self log:@"Test 1: content of second file is OK"];
			else
				[self log:@"Test 1: content of second file is WRONG"];
			
			[self log:@"Test 1: closing second file's stream..."];
			
			[read2 finishedReading];
			
			[self log:@"Test 1: closing zip file..."];
			
			[unzipFile close];
			
			[self log:@"Test 1: test terminated succesfully"];
			
		} @catch (OZZipException *ze) {
			[self log:@"Test 1: caught a ZipException (see logs), terminating..."];
			
			NSLog(@"Test 1: ZipException caught: %d - %@", ze.error, [ze reason]);

		} @catch (id e) {
			[self log:@"Test 1: caught a generic exception (see logs), terminating..."];

			NSLog(@"Test 1: Exception caught: %@ - %@", [[e class] description], [e description]);

		} @finally {
			[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
		}
	}
}


#pragma mark -
#pragma mark Test 2: zip & unzip 5 GB

- (void) test2 {
    @autoreleasepool {
	
		NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
		NSString *filePath= [documentsDir stringByAppendingPathComponent:@"huge_test.zip"];

		@try {
			[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];

			[self log:@"Test 2: opening zip file for writing..."];
			
			OZZipFile *zipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate];
			
			[self log:@"Test 2: adding file..."];
			
			OZZipWriteStream *stream= [zipFile writeFileInZipWithName:@"huge_file.txt" compressionLevel:OZZipCompressionLevelBest];
			
			[self log:@"Test 2: writing to file's stream..."];
			
			NSMutableData *data= [[NSMutableData alloc] initWithLength:HUGE_TEST_BLOCK_LENGTH];
			SecRandomCopyBytes(kSecRandomDefault, [data length], [data mutableBytes]);
			
			NSData *checkData= [data subdataWithRange:NSMakeRange(0, 100)];

			NSMutableData *buffer= [[NSMutableData alloc] initWithLength:HUGE_TEST_BLOCK_LENGTH]; // For use later

			for (int i= 0; i < HUGE_TEST_NUMBER_OF_BLOCKS; i++) {
				[stream writeData:data];
				
				if (i % 100 == 0)
					[self log:@"Test 2: written %d KB...", ([data length] / 1024) * (i +1)];
			}
					
			[self log:@"Test 2: closing file's stream..."];
			
			[stream finishedWriting];
			
			[self log:@"Test 2: closing zip file..."];
			
			[zipFile close];
			
			[self log:@"Test 2: opening zip file for reading..."];
			
			OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip];
			
			[self log:@"Test 2: opening file..."];
			
			[unzipFile goToFirstFileInZip];
			OZZipReadStream *read= [unzipFile readCurrentFileInZip];
			
			[self log:@"Test 2: reading from file's stream..."];
			
			for (int i= 0; i < HUGE_TEST_NUMBER_OF_BLOCKS; i++) {
				int bytesRead= [read readDataWithBuffer:buffer];
				
				BOOL ok= NO;
				if (bytesRead == [data length]) {
					NSRange range= [buffer rangeOfData:checkData options:0 range:NSMakeRange(0, [buffer length])];
					if (range.location == 0)
						ok= YES;
				}
				
				if (!ok)
					[self log:@"Test 2: content of file is WRONG at position %d KB", ([buffer length] / 1024) * i];
				
				if (i % 100 == 0)
					[self log:@"Test 2: read %d KB...", ([buffer length] / 1024) * (i +1)];
			}
			
			[self log:@"Test 2: closing file's stream..."];
			
			[read finishedReading];
			
			[self log:@"Test 2: closing zip file..."];
			
			[unzipFile close];
			
			[self log:@"Test 2: test terminated succesfully"];
			
		} @catch (OZZipException *ze) {
			[self log:@"Test 2: caught a ZipException (see logs), terminating..."];
			
			NSLog(@"Test 2: ZipException caught: %d - %@", ze.error, [ze reason]);
			
		} @catch (id e) {
			[self log:@"Test 2: caught a generic exception (see logs), terminating..."];
			
			NSLog(@"Test 2: Exception caught: %@ - %@", [[e class] description], [e description]);
		
		} @finally {
			[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
		}
	
	}
}


#pragma mark -
#pragma mark Test 3: unzip & check Mac zip file

- (void) test3 {
    @autoreleasepool {
	
		NSString *filePath= [[NSBundle mainBundle] pathForResource:@"mac_test_file" ofType:@"zip"];
		
		@try {
			[self log:@"Test 3: opening zip file for reading..."];
			
			OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip];
			
			[self log:@"Test 3: opening file..."];
			
			[unzipFile goToFirstFileInZip];
			OZZipReadStream *read= [unzipFile readCurrentFileInZip];
			
			[self log:@"Test 3: reading from file's stream..."];
			
			NSMutableData *buffer= [[NSMutableData alloc] initWithLength:1024];

			int bytesRead= [read readDataWithBuffer:buffer];
			
			NSString *fileText= [[NSString alloc] initWithBytes:[buffer bytes] length:bytesRead encoding:NSUTF8StringEncoding];
			if ([fileText isEqualToString:@"Objective-Zip Mac test file\n"])
				[self log:@"Test 3: content of Mac file is OK"];
			else
				[self log:@"Test 3: content of Mac file is WRONG"];
			
			[self log:@"Test 3: closing file's stream..."];
			
			[read finishedReading];
			
			[self log:@"Test 3: closing zip file..."];
			
			[unzipFile close];
			
			[self log:@"Test 3: test terminated succesfully"];

		} @catch (OZZipException *ze) {
			[self log:@"Test 3: caught a ZipException (see logs), terminating..."];
			
			NSLog(@"Test 3: ZipException caught: %d - %@", ze.error, [ze reason]);
			
		} @catch (id e) {
			[self log:@"Test 3: caught a generic exception (see logs), terminating..."];
			
			NSLog(@"Test 3: Exception caught: %@ - %@", [[e class] description], [e description]);
		}
	}
}


#pragma mark -
#pragma mark Test 4: unzip & check Win zip file

- (void) test4 {
    @autoreleasepool {
	
		NSString *filePath= [[NSBundle mainBundle] pathForResource:@"win_test_file" ofType:@"zip"];
		
		@try {
			[self log:@"Test 4: opening zip file for reading..."];
			
			OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip];
			
			[self log:@"Test 4: opening file..."];
			
			[unzipFile goToFirstFileInZip];
			OZZipReadStream *read= [unzipFile readCurrentFileInZip];
			
			[self log:@"Test 4: reading from file's stream..."];
			
			NSMutableData *buffer= [[NSMutableData alloc] initWithLength:1024];
			
			int bytesRead= [read readDataWithBuffer:buffer];
			
			NSString *fileText= [[NSString alloc] initWithBytes:[buffer bytes] length:bytesRead encoding:NSUTF8StringEncoding];
			if ([fileText isEqualToString:@"Objective-Zip Windows test file\r\n"])
				[self log:@"Test 4: content of Win file is OK"];
			else
				[self log:@"Test 4: content of Win file is WRONG"];
			
			[self log:@"Test 4: closing file's stream..."];
			
			[read finishedReading];
			
			[self log:@"Test 4: closing zip file..."];
			
			[unzipFile close];
			
			[self log:@"Test 4: test terminated succesfully"];
			
		} @catch (OZZipException *ze) {
			[self log:@"Test 4: caught a ZipException (see logs), terminating..."];
			
			NSLog(@"Test 4: ZipException caught: %d - %@", ze.error, [ze reason]);
			
		} @catch (id e) {
			[self log:@"Test 4: caught a generic exception (see logs), terminating..."];
			
			NSLog(@"Test 4: Exception caught: %@ - %@", [[e class] description], [e description]);
		}
	}
}


#pragma mark -
#pragma mark Logging

- (void) log:(NSString *)format, ... {

	// Variable arguments formatting
	va_list arguments;
	va_start(arguments, format);
	NSString *logLine= [[NSString alloc] initWithFormat:format arguments:arguments];
	va_end(arguments);
	
	[self performSelectorOnMainThread:@selector(printLog:) withObject:logLine waitUntilDone:YES];
	
}

- (void) printLog:(NSString *)logLine {
	NSLog(@"%@", logLine);
	
	_textView.text= [_textView.text stringByAppendingString:logLine];
	_textView.text= [_textView.text stringByAppendingString:@"\n"];
	
	NSRange range;
	range.location= [_textView.text length] -6;
	range.length= 5;
	[_textView scrollRangeToVisible:range];
}


@end
