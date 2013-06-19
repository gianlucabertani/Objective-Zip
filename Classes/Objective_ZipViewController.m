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
#import "../Objective-Zip/ZipFile.h"
#import "../Objective-Zip/ZipException.h"
#import "../Objective-Zip/FileInZipInfo.h"
#import "../Objective-Zip/ZipWriteStream.h"
#import "../Objective-Zip/ZipReadStream.h"


@implementation Objective_ZipViewController


- (void) loadView {
	[super loadView];
	
	_textView.font= [UIFont fontWithName:@"Helvetica" size:11.0];
}

- (void) dealloc {
	if (_testThread)
		[_testThread release];
    [super dealloc];
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction) zipUnzip {
	if (_testThread)
		[_testThread release];
	
	_testThread= [[NSThread alloc] initWithTarget:self selector:@selector(test) object:nil];
	[_testThread start];
}

- (IBAction) zipUnzip2 {
	if (_testThread)
		[_testThread release];
	
	_testThread= [[NSThread alloc] initWithTarget:self selector:@selector(test2) object:nil];
	[_testThread start];
}

- (void) test {
    NSAutoreleasePool *pool= [[NSAutoreleasePool alloc] init];

	@try {
		NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
		NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test.zip"];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: opening zip file for writing..." waitUntilDone:YES];
		
		ZipFile *zipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: adding first file..." waitUntilDone:YES];
		
		ZipWriteStream *stream1= [zipFile writeFileInZipWithName:@"abc.txt" fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0] compressionLevel:ZipCompressionLevelBest];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: writing to first file's stream..." waitUntilDone:YES];

		NSString *text= @"abc";
		[stream1 writeData:[text dataUsingEncoding:NSUTF8StringEncoding]];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: closing first file's stream..." waitUntilDone:YES];
		
		[stream1 finishedWriting];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: adding second file..." waitUntilDone:YES];
		
		ZipWriteStream *stream2= [zipFile writeFileInZipWithName:@"x/y/z/xyz.txt" compressionLevel:ZipCompressionLevelNone];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: writing to second file's stream..." waitUntilDone:YES];
		
		NSString *text2= @"XYZ";
		[stream2 writeData:[text2 dataUsingEncoding:NSUTF8StringEncoding]];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: closing second file's stream..." waitUntilDone:YES];
		
		[stream2 finishedWriting];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: closing zip file..." waitUntilDone:YES];
		
		[zipFile close];
		[zipFile release];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: opening zip file for reading..." waitUntilDone:YES];
		
		ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: reading file infos..." waitUntilDone:YES];
		
		NSArray *infos= [unzipFile listFileInZipInfos];
		for (FileInZipInfo *info in infos) {
			NSString *fileInfo= [NSString stringWithFormat:@"Test 1: - %@ %@ %d (%d)", info.name, info.date, info.size, info.level];
			[self performSelectorOnMainThread:@selector(log:) withObject:fileInfo waitUntilDone:YES];
		}
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: opening first file..." waitUntilDone:YES];
		
		[unzipFile goToFirstFileInZip];
		ZipReadStream *read1= [unzipFile readCurrentFileInZip];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: reading from first file's stream..." waitUntilDone:YES];
		
		NSMutableData *data1= [[[NSMutableData alloc] initWithLength:256] autorelease];
		int bytesRead1= [read1 readDataWithBuffer:data1];
		
		BOOL ok= NO;
		if (bytesRead1 == 3) {
			NSString *fileText1= [[[NSString alloc] initWithBytes:[data1 bytes] length:bytesRead1 encoding:NSUTF8StringEncoding] autorelease];
			if ([fileText1 isEqualToString:@"abc"])
				ok= YES;
		}
		
		if (ok)
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: content of first file is OK" waitUntilDone:YES];
		else
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: content of first file is WRONG" waitUntilDone:YES];
			
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: closing first file's stream..." waitUntilDone:YES];
		
		[read1 finishedReading];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: opening second file..." waitUntilDone:YES];

		[unzipFile goToNextFileInZip];
		ZipReadStream *read2= [unzipFile readCurrentFileInZip];

		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: reading from second file's stream..." waitUntilDone:YES];
		
		NSMutableData *data2= [[[NSMutableData alloc] initWithLength:256] autorelease];
		int bytesRead2= [read2 readDataWithBuffer:data2];
		
		ok= NO;
		if (bytesRead2 == 3) {
			NSString *fileText2= [[[NSString alloc] initWithBytes:[data2 bytes] length:bytesRead2 encoding:NSUTF8StringEncoding] autorelease];
			if ([fileText2 isEqualToString:@"XYZ"])
				ok= YES;
		}
		
		if (ok)
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: content of second file is OK" waitUntilDone:YES];
		else
			[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: content of second file is WRONG" waitUntilDone:YES];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: closing second file's stream..." waitUntilDone:YES];
		
		[read2 finishedReading];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: closing zip file..." waitUntilDone:YES];
		
		[unzipFile close];
		[unzipFile release];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: test terminated succesfully" waitUntilDone:YES];
		
	} @catch (ZipException *ze) {
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: caught a ZipException (see logs), terminating..." waitUntilDone:YES];
		
		NSLog(@"Test 1: ZipException caught: %d - %@", ze.error, [ze reason]);

	} @catch (id e) {
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 1: caught a generic exception (see logs), terminating..." waitUntilDone:YES];

		NSLog(@"Test 1: Exception caught: %@ - %@", [[e class] description], [e description]);
	}
	
	[pool drain];
}

- (void) test2 {
    NSAutoreleasePool *pool= [[NSAutoreleasePool alloc] init];
	
	@try {
		NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
		NSString *filePath= [documentsDir stringByAppendingPathComponent:@"huge_test.zip"];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: opening zip file for writing..." waitUntilDone:YES];
		
		ZipFile *zipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeCreate];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: adding file..." waitUntilDone:YES];
		
		ZipWriteStream *stream= [zipFile writeFileInZipWithName:@"huge_file.txt" compressionLevel:ZipCompressionLevelBest];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: writing to file's stream..." waitUntilDone:YES];
		
		NSString *line= @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ\n"; // 63 bytes

		NSMutableString *buffer= [[NSMutableString alloc] init]; // 63000 bytes
		for (int i= 0; i < 1000; i++)
			[buffer appendString:line];
		
		NSData *bufferData= [buffer dataUsingEncoding:NSUTF8StringEncoding];

		NSMutableData *data= [[NSMutableData alloc] initWithLength:[buffer length]]; // For use later
		NSData *lineData= [line dataUsingEncoding:NSUTF8StringEncoding]; // For use later

		for (int i= 0; i < 100000; i++) { // 6300000000 bytes
			[stream writeData:bufferData];
			
			if (i % 100 == 0) {
				NSString *logLine= [[NSString alloc] initWithFormat:@"Test 2: written %d KB...", [line length] * (i +1)];
				[self performSelectorOnMainThread:@selector(log:) withObject:logLine waitUntilDone:YES];
				[logLine release];
			}
		}
				
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: closing file's stream..." waitUntilDone:YES];
		
		[stream finishedWriting];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: closing zip file..." waitUntilDone:YES];
		
		[zipFile close];
		[zipFile release];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: opening zip file for reading..." waitUntilDone:YES];
		
		ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:filePath mode:ZipFileModeUnzip];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: opening file..." waitUntilDone:YES];
		
		[unzipFile goToFirstFileInZip];
		ZipReadStream *read= [unzipFile readCurrentFileInZip];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: reading from file's stream..." waitUntilDone:YES];
		
		for (int i= 0; i < 100000; i++) {
			int bytesRead= [read readDataWithBuffer:data];
			
			BOOL ok= NO;
			if (bytesRead == [buffer length]) {
				NSRange range= [data rangeOfData:lineData options:NSDataSearchBackwards range:NSMakeRange(0, [buffer length])];
				if (range.location == [buffer length] - [line length])
					ok= YES;
			}
			
			if (!ok) {
				NSString *logLine= [[NSString alloc] initWithFormat:@"Test 2: content of file is WRONG at position %d000", [line length] * i];
				[self performSelectorOnMainThread:@selector(log:) withObject:logLine waitUntilDone:YES];
				[logLine release];
			}
			
			if (i % 100 == 0) {
				NSString *logLine= [[NSString alloc] initWithFormat:@"Test 2: read %d KB...", [line length] * (i +1)];
				[self performSelectorOnMainThread:@selector(log:) withObject:logLine waitUntilDone:YES];
				[logLine release];
			}
		}
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: closing file's stream..." waitUntilDone:YES];
		
		[read finishedReading];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: closing zip file..." waitUntilDone:YES];
		
		[unzipFile close];
		[unzipFile release];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: deleting zip file..." waitUntilDone:YES];
		
		[[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
		
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: test terminated succesfully" waitUntilDone:YES];
		
		[buffer release];
		[data release];
		
	} @catch (ZipException *ze) {
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: caught a ZipException (see logs), terminating..." waitUntilDone:YES];
		
		NSLog(@"Test 2: ZipException caught: %d - %@", ze.error, [ze reason]);
		
	} @catch (id e) {
		[self performSelectorOnMainThread:@selector(log:) withObject:@"Test 2: caught a generic exception (see logs), terminating..." waitUntilDone:YES];
		
		NSLog(@"Test 2: Exception caught: %@ - %@", [[e class] description], [e description]);
	}
	
	[pool drain];
}

- (void) log:(NSString *)text {
	NSLog(@"%@", text);
	
	_textView.text= [_textView.text stringByAppendingString:text];
	_textView.text= [_textView.text stringByAppendingString:@"\n"];
	
	NSRange range;
	range.location= [_textView.text length] -6;
	range.length= 5;
	[_textView scrollRangeToVisible:range];
}

@end
