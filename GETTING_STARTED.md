

Getting started with Objective-Zip
==================================

Objective-Zip exposes basic functionalities to read and write zip files,
encapsulating both ZLib for the compression mechanism and MiniZip for
the zip wrapping.


Adding Objective-Zip to your project
------------------------------------

The library is distributed via CocoaPods, you can add a dependency in you pod
file with the following line:

    pod 'Objective-Zip', '~> 1.0'

You can then access Objective-Zip classes with the following import
statement if you plan to use exception handling:

```objective-c
#import "Objective-Zip.h"
```

Alternatively you can use the following import statement if you plan to use
Apple's NSError pattern:

```objective-c
#import "Objective-Zip+NSError.h"
```

More on error handling at the end of this document.


Main concepts
-------------

Objective-Zip is centered on a class called (with a lack of fantasy)
OZZipFile. It can be created with the common Objective-C procedure of an
alloc followed by an init, specifying in the latter if the zip file is
being created, appended or unzipped:

```objective-c
OZZipFile *zipFile= [[OZZipFile alloc] initWithFileName:@"test.zip"
    mode:OZZipFileModeCreate];
```

Creating and appending are both write-only modalities, while unzipping
is a read-only modality. You can not request reading operations on a
write-mode zip file, nor request writing operations on a read-mode zip
file.


Adding a file to a zip file
---------------------------

The ZipFile class has a couple of methods to add new files to a zip
file, one of which keeps the file in clear and the other encrypts it
with a password. Both methods return an instance of a OZZipWriteStream
class, which will be used solely for the scope of writing the content of
the file, and then must be closed:

```objective-c
OZZipWriteStream *stream= [zipFile writeFileInZipWithName:@"abc.txt"
    compressionLevel:OZZipCompressionLevelBest];

[stream writeData:abcData];
[stream finishedWriting];
```


Reading a file from a zip file
------------------------------

The OZZipFile class, when used in unzip mode, must be treated like a
cursor: you position the instance on a file at a time, either by
step-forwarding or by locating the file by name. Once you are on the
correct file, you can obtain an instance of a OZZipReadStream that will
let you read the content (and then must be closed):

```objective-c
OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:@"test.zip"
    mode:OZZipFileModeUnzip];

[unzipFile goToFirstFileInZip];

OZZipReadStream *read= [unzipFile readCurrentFileInZip];
NSMutableData *data= [[NSMutableData alloc] initWithLength:256];
int bytesRead= [read readDataWithBuffer:data];

[read finishedReading];
```

Note that the NSMutableData instance that acts as the read buffer must
have been set with a length greater than 0: the readDataWithBuffer API
will use that length to know how many bytes it can fetch from the zip
file.


Listing files in a zip file
---------------------------

When the ZipFile class is used in unzip mode, it can also list the files
contained in zip by filling an NSArray with instances of FileInZipInfo
class. You can then use its name property to locate the file inside the
zip and expand it:

```objective-c
OZZipFile *unzipFile= [[OZZipFile alloc] initWithFileName:@"test.zip"
    mode:ZipFileModeUnzip];

NSArray *infos= [unzipFile listFileInZipInfos];
for (OZFileInZipInfo *info in infos) {
    NSLog(@"- %@ %@ %d (%d)", info.name, info.date, info.size,
        info.level);

    // Locate the file in the zip
    [unzipFile locateFileInZip:info.name];

    // Expand the file in memory
    OZZipReadStream *read= [unzipFile readCurrentFileInZip];
    NSMutableData *data= [[NSMutableData alloc] initWithLength:256];
    int bytesRead= [read readDataWithBuffer:data];
    [read finishedReading];
}
```

Note that the OZFileInZipInfo class provide two sizes:

- **length** is the original (uncompressed) file size, while
- **size** is the compressed file size.


Closing the zip file
--------------------

Remember, when you are done, to close your OZZipFile instance to avoid
file corruption problems:

```objective-c
[zipFile close];
```


Notes
=====


File/folder hierarchy inide the zip
-----------------------------------

Please note that inside the zip files there is no representation of a
file-folder hierarchy: it is simply embedded in file names (i.e.: a file
with a name like "x/y/z/file.txt"). It is up to the program that
extracts files to consider these file names as expressing a structure and
rebuild it on the file system (and viceversa during creation). Common
zippers/unzippers simply follow this rule.


Memory management
-----------------

If you need to extract huge files that cannot be contained in memory,
you can do so using a read-then-write buffered loop like this:

```objective-c
NSFileHandle *file= [NSFileHandle fileHandleForWritingAtPath:filePath];
NSMutableData *buffer= [[NSMutableData alloc]
    initWithLength:BUFFER_SIZE];

OZZipReadStream *read= [unzipFile readCurrentFileInZip];

// Read-then-write buffered loop
do {

    // Reset buffer length
    [buffer setLength:BUFFER_SIZE];

    // Expand next chunk of bytes
    int bytesRead= [read readDataWithBuffer:buffer];
    if (bytesRead > 0) {

        // Write what we have read
        [buffer setLength:bytesRead];
        [file writeData:buffer];

    } else
        break;

} while (YES);

// Clean up
[file closeFile];
[read finishedReading];
[buffer release];
```


Error handling
--------------

Objective-Zip provides two kinds of error handling:

- standard exception handling;
- Apple's NSError pattern.

With standard exception handling, Objective-Zip will throw an exception of
class OZZipException any time an error occurs (programmer or runtime errors).

To use standard exception handling import Objective-Zip in your project with
this statement:

```objective-c
#import "Objective-Zip.h"
```

With Apple's NSError pattern, Objective-Zip will expect a NSError
pointer-to-pointer argument and will fill it with an NSError instance
whenever a runtime error occurs. Will revert to throwing an exception (of
OZZipException class) in case of programmer errors.

To use Apple's NSError pattern import Objective-Zip in your project with this
statement:

```objective-c
#import "Objective-Zip+NSError.h"
```

Apple's NSError pattern is of course mandatory with Swift programming
language, since it does not support exception handling.

