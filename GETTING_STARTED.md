

Getting started with Objective-Zip
==================================

Objective-Zip exposes basic functionalities to read and write zip files,
encapsulating both ZLib for the compression mechanism and MiniZip for
the zip wrapping.


Adding Objective-Zip to your project
------------------------------------

The library is distributed as source only, so simply download the unit
test application and copy-paste these directories in your own project:

- ARCHelper
- ZLib
- MiniZip
- Objective-Zip

The first two are simply copies of the distribution of version 1.2.7 of
ZLib and of version 1.1 of MiniZip (which is itself part of ZLib
contributions), while the third is their Objective-C wrapper.


Main concepts
-------------

Objective-Zip is centered on a class called (with a lack of fantasy)
ZipFile. It can be created with the common Objective-C procedure of an
alloc followed by an init, specifying in the latter if the zip file is
being created, appended or unzipped:

	ZipFile *zipFile= [[ZipFile alloc] initWithFileName:@"test.zip"
		mode:ZipFileModeCreate];

Creating and appending are both write-only modalities, while unzipping
is a read-only modality. You can not request reading operations on a
write-mode zip file, nor request writing operations on a read-mode zip
file.


Adding a file to a zip file
---------------------------

The ZipFile class has a couple of methods to add new files to a zip
file, one of which keeps the file in clear and the other encrypts it
with a password. Both methods return an instance of a ZipWriteStream
class, which will be used solely for the scope of writing the content of
the file, and then must be closed:

	ZipWriteStream *stream= [zipFile writeFileInZipWithName:@"abc.txt"
		compressionLevel:ZipCompressionLevelBest];

	[stream writeData:abcData];
	[stream finishedWriting];


Reading a file from a zip file
------------------------------

The ZipFile class, when used in unzip mode, must be treated like a
cursor: you position the instance on a file at a time, either by
step-forwarding or by locating the file by name. Once you are on the
correct file, you can obtain an instance of a ZipReadStream that will
let you read the content (and then must be closed):

	ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:@"test.zip"
		mode:ZipFileModeUnzip];

	[unzipFile goToFirstFileInZip];

	ZipReadStream *read= [unzipFile readCurrentFileInZip];
	NSMutableData *data= [[NSMutableData alloc] initWithLength:256];
	int bytesRead= [read readDataWithBuffer:data];

	[read finishedReading];

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

	ZipFile *unzipFile= [[ZipFile alloc] initWithFileName:@"test.zip"
		mode:ZipFileModeUnzip];

	NSArray *infos= [unzipFile listFileInZipInfos];
	for (FileInZipInfo *info in infos) {
		NSLog(@"- %@ %@ %d (%d)", info.name, info.date, info.size,
    		info.level);

		// Locate the file in the zip
		[unzipFile locateFileInZip:info.name];

		// Expand the file in memory
		ZipReadStream *read= [unzipFile readCurrentFileInZip];
		NSMutableData *data= [[NSMutableData alloc] initWithLength:256];
		int bytesRead= [read readDataWithBuffer:data];
		[read finishedReading];
	}

Note that the FileInZipInfo class provide two sizes:

- **length** is the original (uncompressed) file size, while
- **size** is the compressed file size.


Closing the zip file
--------------------

Remember, when you are done, to close your ZipFile instance to avoid
file corruption problems:

	[zipFile close];


Notes
=====


File/folder hierarchy inide the zip
-----------------------------------

Please note that inside the zip files there is no representation of a
file-folder hierarchy: it is simply embedded in file names (i.e.: a file
with a name like "x/y/z/file.txt"). It is up to the program that
extracts the files to consider these file names as expressing a
structure and rebuild it on the file system (and viceversa during
creation). Common zippers/unzippers simply follow this rule.


Memory management
-----------------

If you need to extract huge files that cannot be contained in memory,
you can do so using a read-then-write buffered loop like this:

	NSFileHandle *file= [NSFileHandle fileHandleForWritingAtPath:filePath];
	NSMutableData *buffer= [[NSMutableData alloc]
		initWithLength:BUFFER_SIZE];

	ZipReadStream *read= [unzipFile readCurrentFileInZip];

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


Exception handling
------------------

If something goes wrong during an operation, Objective-Zip will always
throw an exception of class ZipException, which contains a property with
the specific error number of MiniZip. With that number you are supposed
to find the reason of the error.

