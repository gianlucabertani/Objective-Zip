//
//  OZViewController.m
//  Objective-Zip
//
//  Created by Bogdan Iusco on 6/8/14.
//  Copyright (c) 2014 yourcompany. All rights reserved.
//

#define HUGE_TEST_BLOCK_LENGTH             (50000)
#define HUGE_TEST_NUMBER_OF_BLOCKS        (100000)

#import "OZViewController.h"
#import "OZLib.h"

@interface OZViewController ()

@end

@implementation OZViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.textView.font= [UIFont fontWithName:@"Helvetica" size:11.0];
}


- (IBAction)zipUnzip {
    [self setUserInteractionMainQueue:NO];
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf test1];
    });
}

- (IBAction)zipUnzip2 {
    [self setUserInteractionMainQueue:NO];
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf test2];
    });
}

- (IBAction)zipCheck1  {
    [self setUserInteractionMainQueue:NO];
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf test3];
    });
}

- (IBAction)zipCheck2 {
    [self setUserInteractionMainQueue:NO];
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [weakSelf test4];
    });
}

- (void)setUserInteractionMainQueue:(BOOL)userInteraction {
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.view.userInteractionEnabled = userInteraction;
    });
}

#pragma mark - Test 1: zip & unzip

NSString * const kTest1File2Name = @"x/y/z/xyz.txt";
- (void)test1 {

    @autoreleasepool {
        NSString *testName = @"TEST 1";
        [self logStartTest:testName];
        NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *filePath= [documentsDir stringByAppendingPathComponent:@"test.zip"];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];

        [self log:@"Opening zip file for writing..."];
        OZZipFile *zipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate];

        [self test1WriteStream1:zipFile];
        [self test1WriteStream2:zipFile];
        [self closeZipFile:zipFile];

        [self log:@"Opening zip file for reading..."];
        OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip];
        [self printZipContent:unzipFile];

        [self test1ReadStream1:unzipFile];
        [self test1ReadStream2:unzipFile];

        [self closeZipFile:unzipFile];

        [self logEndTest:testName];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        [self setUserInteractionMainQueue:YES];
    }
}

- (void)test1WriteStream1:(OZZipFile *)zipFile {
    NSError *error;
    [self log:@"Adding first file..."];
    OZZipWriteStream *stream1 = [zipFile writeFileInZipWithName:@"abc.txt"
                                                       fileDate:[NSDate dateWithTimeIntervalSinceNow:-86400.0]
                                               compressionLevel:OZZipCompressionLevelBest
                                                          error:&error];
    [self log:@"Writing to first file's stream..."];
    [self logError:error];
    error = nil;

    NSString *text= @"abc";
    [stream1 writeData:[text dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    [self logError:error];
    error = nil;

    [self log:@"Closing first file's stream..."];
    [stream1 finishedWriting:&error];
    [self logError:error];
}

- (void)test1WriteStream2:(OZZipFile *)zipFile {
    NSError *error;
    [self log:@"Adding second file..."];

    OZZipWriteStream *stream2 = [zipFile writeFileInZipWithName:kTest1File2Name compressionLevel:OZZipCompressionLevelNone error:&error];
    [self logError:error];
    error = nil;

    [self log:@"Writing to second file's stream..."];
    NSString *text2 = @"XYZ";
    [stream2 writeData:[text2 dataUsingEncoding:NSUTF8StringEncoding] error:&error];
    [self logError:error];
    error = nil;

    [self log:@"Closing second file's stream..."];
    [stream2 finishedWriting:&error];
    [self logError:error];
    error = nil;
}

- (void)test1ReadStream1:(OZZipFile *)zipFile {
    NSError *error;
    [self log:@"Opening first file..."];
    [zipFile goToFirstFileInZip:&error];
    [self logError:error];
    error = nil;

    OZZipReadStream *readStream = [zipFile readCurrentFileInZip:&error];
    [self logError:error];
    error = nil;

    [self log:@"Reading from first file's stream..."];
    NSMutableData *data = [[NSMutableData alloc] initWithLength:256];
    int bytesRead = [readStream readDataWithBuffer:data error:&error];
    [self logError:error];
    error = nil;

    BOOL ok = NO;
    if (bytesRead == 3) {
        NSString *fileText = [[NSString alloc] initWithBytes:[data bytes] length:bytesRead encoding:NSUTF8StringEncoding];
        if ([fileText isEqualToString:@"abc"])
            ok= YES;
    }

    if (ok) {
        [self log:@"Content of first file is OK"];
    } else {
        [self log:@"Content of first file is WRONG"];
    }

    [self log:@"Closing first file's stream..."];
    [readStream finishedReading:&error];
    [self logError:error];
}

- (void)test1ReadStream2:(OZZipFile *)zipFile {
    NSError *error;
    BOOL ok;

    [self log:@"Opening second file..."];
    [zipFile locateFileInZip:kTest1File2Name error:&error];
    [self logError:error];
    error = nil;

    OZZipReadStream *readStream = [zipFile readCurrentFileInZip:&error];
    [self logError:error];
    error = nil;

    [self log:@"Reading from second file's stream..."];
    NSMutableData *data = [[NSMutableData alloc] initWithLength:256];
    int bytesRead = [readStream readDataWithBuffer:data error:&error];

    ok = NO;
    if (bytesRead == 3) {
        NSString *fileText2= [[NSString alloc] initWithBytes:[data bytes] length:bytesRead encoding:NSUTF8StringEncoding];
        if ([fileText2 isEqualToString:@"XYZ"])
            ok= YES;
    }

    if (ok) {
        [self log:@"Content of second file is OK"];
    } else {
        [self log:@"Content of second file is WRONG"];
    }
    [self log:@"Closing second file's stream..."];
    [readStream finishedReading:&error];
    [self logError:error];
}

- (void)printZipContent:(OZZipFile *)zipFile {
    [self log:@"Reading file infos..."];
    NSArray *infos= [zipFile listFileInZipInfos];
    for (OZFileInZipInfo *info in infos) {
        [self log:@"%@ %@ %d (%d)", info.name, info.date, info.size, info.level];
    }
}

- (void)closeZipFile:(OZZipFile *)zipFile {
    NSError *error;
    [self log:@"Closing zip file..."];
    [zipFile close:&error];
    [self logError:error];
}

#pragma mark - Test 2: zip & unzip 5 GB

- (void)test2 {

    @autoreleasepool {
        
        NSString *testName = @"TEST 2";
        [self logStartTest:testName];

        NSString *documentsDir= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *filePath = [documentsDir stringByAppendingPathComponent:@"huge_test.zip"];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];

        [self log:@"Test 2: opening zip file for writing..."];
        OZZipFile *zipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeCreate];

        NSData *data = [self test2addFile:zipFile];

        [self log:@"Opening zip file for reading..."];
        OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip];

        [self test2OpenFile:unzipFile compareTo:data];

        [self closeZipFile:unzipFile];
        [self logEndTest:testName];

        [[NSFileManager defaultManager] removeItemAtPath:filePath error:NULL];
        [self setUserInteractionMainQueue:YES];
    }
}

- (NSMutableData *)test2addFile:(OZZipFile *)zipFile {
    NSError *error;

    [self log:@"Adding file..."];
    OZZipWriteStream *stream= [zipFile writeFileInZipWithName:@"huge_file.txt" compressionLevel:OZZipCompressionLevelBest error:&error];
    [self logError:error];
    error = nil;
    [self log:@"Writing to file's stream..."];

    NSMutableData *data= [[NSMutableData alloc] initWithLength:HUGE_TEST_BLOCK_LENGTH];
    SecRandomCopyBytes(kSecRandomDefault, [data length], [data mutableBytes]);

    for (int i = 0; i < HUGE_TEST_NUMBER_OF_BLOCKS; i++) {
        [stream writeData:data error:&error];
        [self logError:error];
        error = nil;
        if (i % 100 == 0) {
            [self log:@"Written %d KB...", ([data length] / 1024) * (i +1)];
        }
    }

    [self log:@"Closing file's stream..."];
    [stream finishedWriting:&error];
    [self logError:error];
    error = nil;
    
    [self log:@"Closing zip file..."];
    [zipFile close:&error];
    [self logError:error];
    error = nil;
    
    return data;
}

- (void)test2OpenFile:(OZZipFile *)zipFile compareTo:(NSData *)data {
    NSError *error;
    NSMutableData *buffer= [[NSMutableData alloc] initWithLength:HUGE_TEST_BLOCK_LENGTH]; // For use later
    NSData *checkData= [data subdataWithRange:NSMakeRange(0, 100)];

    [self log:@"Opening file..."];
    [zipFile goToFirstFileInZip:&error];
    [self logError:error];
    error = nil;

    OZZipReadStream *read = [zipFile readCurrentFileInZip:&error];
    [self logError:error];
    error = nil;

    [self log:@"Reading from file's stream..."];
    for (int i= 0; i < HUGE_TEST_NUMBER_OF_BLOCKS; i++) {
        int bytesRead= [read readDataWithBuffer:buffer error:&error];
        [self logError:error];
        error = nil;
        BOOL ok = NO;
        if (bytesRead == [data length]) {
            NSRange range= [buffer rangeOfData:checkData options:0 range:NSMakeRange(0, [buffer length])];
            if (range.location == 0)
                ok= YES;
        }

        if (!ok)
            [self log:@"Content of file is WRONG at position %d KB", ([buffer length] / 1024) * i];
        
        if (i % 100 == 0)
            [self log:@"Read %d KB...", ([buffer length] / 1024) * (i +1)];
    }
    [self log:@"Closing file's stream..."];
    [read finishedReading:&error];
}

#pragma mark - Test 3: unzip & check Mac zip file

- (void)test3 {

    @autoreleasepool {

        NSString *testName = @"TEST 3";
        [self logStartTest:testName];

        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mac_test_file" ofType:@"zip"];
        NSError *error;

        [self log:@"Opening zip file for reading..."];
        OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip];
        
        [self log:@"Opening file..."];
        [unzipFile goToFirstFileInZip:&error];
        [self logError:error];
        error = nil;

        OZZipReadStream *read= [unzipFile readCurrentFileInZip:&error];
        [self logError:error];
        error = nil;

        [self log:@"Reading from file's stream..."];
        NSMutableData *buffer= [[NSMutableData alloc] initWithLength:1024];
        int bytesRead = [read readDataWithBuffer:buffer error:&error];
        [self logError:error];
        error = nil;

        NSString *fileText= [[NSString alloc] initWithBytes:[buffer bytes] length:bytesRead encoding:NSUTF8StringEncoding];
        if ([fileText isEqualToString:@"Objective-Zip Mac test file\n"]) {
            [self log:@"Content of Mac file is OK"];
        } else {
            [self log:@"Content of Mac file is WRONG"];
        }

        [self log:@"Closing file's stream..."];
        [read finishedReading:&error];
        [self logError:error];
        error = nil;

        [self closeZipFile:unzipFile];

        [self logEndTest:testName];
        [self setUserInteractionMainQueue:YES];
    }
}

#pragma mark - Test 4: unzip & check Win zip file

- (void)test4 {

    @autoreleasepool {
        
        NSString *testName = @"TEST 4";
        [self logStartTest:testName];

        NSString *filePath= [[NSBundle mainBundle] pathForResource:@"win_test_file" ofType:@"zip"];
        NSError *error;

        [self log:@"Opening zip file for reading..."];
        OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:filePath mode:OZZipFileModeUnzip];
        
        [self log:@"Opening file..."];
        [unzipFile goToFirstFileInZip:&error];
        [self logError:error];
        error = nil;
        OZZipReadStream *read= [unzipFile readCurrentFileInZip:&error];

        [self log:@"Reading from file's stream..."];
        NSMutableData *buffer = [[NSMutableData alloc] initWithLength:1024];
        int bytesRead = [read readDataWithBuffer:buffer error:&error];
        [self logError:error];
        error = nil;

        NSString *fileText = [[NSString alloc] initWithBytes:[buffer bytes] length:bytesRead encoding:NSUTF8StringEncoding];
        if ([fileText isEqualToString:@"Objective-Zip Windows test file\r\n"]) {
            [self log:@"Content of Win file is OK"];
        } else {
            [self log:@"Content of Win file is WRONG"];
        }

        [self log:@"Closing file's stream..."];
        [read finishedReading:&error];
        [self logError:error];
        error = nil;

        [self closeZipFile:unzipFile];

        [self logEndTest:testName];
        [self setUserInteractionMainQueue:YES];
    }
}


#pragma mark - Logging methods

- (void)logStartTest:(NSString *)testName {
    [self log:[NSString stringWithFormat:@"====== START %@ ======", testName]];
}

- (void)logEndTest:(NSString *)testName {
    [self log:[NSString stringWithFormat:@"====== END %@ ======", testName]];
}

- (void)log:(NSString *)format, ... {
    
	// Variable arguments formatting
	va_list arguments;
	va_start(arguments, format);
	NSString *logLine= [[NSString alloc] initWithFormat:format arguments:arguments];
	va_end(arguments);

	[self printLog:logLine];
}

- (void)logError:(NSError *)error {
    if (error) {
        [self printLog:[error description]];
    }
}

- (void)printLog:(NSString *)logLine {

    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", logLine);

        weakSelf.textView.text= [_textView.text stringByAppendingString:logLine];
        weakSelf.textView.text= [_textView.text stringByAppendingString:@"\n"];
        
        NSRange range;
        range.location= [_textView.text length] -6;
        range.length= 5;
        [weakSelf.textView scrollRangeToVisible:range];
    });
}

@end
