//
//  Objective-Zip_Swift_Tests.swift
//  Objective-Zip
//
//  Created by Gianluca Bertani on 20/09/15.
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
//  SUBSTITUTE GOODS OR SERVICES LOSS OF USE, DATA, OR PROFITS OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//

import XCTest

let HUGE_TEST_BLOCK_LENGTH = 50000
let HUGE_TEST_NUMBER_OF_BLOCKS = 100000

let MAC_TEST_ZIP = "UEsDBBQACAAIAPWF10IAAAAAAAAAAAAAAAANABAAdGVzdF9maWxlLnR4dFVYDACQCsdRjQrHUfYB9gHzT8pKTS7JLEvVjcosUPBNTFYoSS0uUUjLzEnlAgBQSwcIlXE92h4AAAAcAAAAUEsDBAoAAAAAAACG10IAAAAAAAAAAAAAAAAJABAAX19NQUNPU1gvVVgMAKAKx1GgCsdR9gH2AVBLAwQUAAgACAD1hddCAAAAAAAAAAAAAAAAGAAQAF9fTUFDT1NYLy5fdGVzdF9maWxlLnR4dFVYDACQCsdRjQrHUfYB9gFjYBVjZ2BiYPBNTFbwD1aIUIACkBgDJxAbAXElEIP4qxmIAo4hIUFQJkjHHCDmR1PCiBAXT87P1UssKMhJ1QtJrShxzUvOT8nMSwdKlpak6VpYGxqbGBmaW1qYAABQSwcIcBqNwF0AAACrAAAAUEsBAhUDFAAIAAgA9YXXQpVxPdoeAAAAHAAAAA0ADAAAAAAAAAAAQKSBAAAAAHRlc3RfZmlsZS50eHRVWAgAkArHUY0Kx1FQSwECFQMKAAAAAAAAhtdCAAAAAAAAAAAAAAAACQAMAAAAAAAAAABA/UFpAAAAX19NQUNPU1gvVVgIAKAKx1GgCsdRUEsBAhUDFAAIAAgA9YXXQnAajcBdAAAAqwAAABgADAAAAAAAAAAAQKSBoAAAAF9fTUFDT1NYLy5fdGVzdF9maWxlLnR4dFVYCACQCsdRjQrHUVBLBQYAAAAAAwADANwAAABTAQAAAAA="
let WIN_TEST_ZIP = "UEsDBBQAAAAAAMmF10L4VbPKIQAAACEAAAANAAAAdGVzdF9maWxlLnR4dE9iamVjdGl2ZS1aaXAgV2luZG93cyB0ZXN0IGZpbGUNClBLAQIUABQAAAAAAMmF10L4VbPKIQAAACEAAAANAAAAAAAAAAEAIAAAAAAAAAB0ZXN0X2ZpbGUudHh0UEsFBgAAAAABAAEAOwAAAEwAAAAAAA=="

class Objective_Zip_Swift_Tests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test01ZipAndUnzip() {
        let documentsUrl = NSURL(fileURLWithPath:NSHomeDirectory(), isDirectory:true).URLByAppendingPathComponent("Documents")
        let fileUrl = documentsUrl.URLByAppendingPathComponent("test.zip")
        let filePath = fileUrl.path!
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
        } catch {}
        
        defer {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filePath)
            } catch {}
        }
        
        do {
            NSLog("Test 1: opening zip file for writing...")
            
            let zipFile = try OZZipFile(fileName:filePath, mode:OZZipFileMode.Create)
            
            XCTAssertNotNil(zipFile)
            
            NSLog("Test 1: adding first file...")
            
            let stream1 = try zipFile.writeFileInZipWithName("abc.txt", fileDate:NSDate(timeIntervalSinceNow:-86400.0), compressionLevel:OZZipCompressionLevel.Best)
            
            XCTAssertNotNil(stream1)
            
            NSLog("Test 1: writing to first file's stream...")
            
            let text = "abc"
            try stream1.writeData(text.dataUsingEncoding(NSUTF8StringEncoding)!)
            
            NSLog("Test 1: closing first file's stream...")
            
            try stream1.finishedWriting()
            
            NSLog("Test 1: adding second file...")
            
            let file2name = "x/y/z/xyz.txt"
            let stream2 = try zipFile.writeFileInZipWithName(file2name, compressionLevel:OZZipCompressionLevel.None)
            
            XCTAssertNotNil(stream2)
            
            NSLog("Test 1: writing to second file's stream...")
            
            let text2 = "XYZ"
            try stream2.writeData(text2.dataUsingEncoding(NSUTF8StringEncoding)!)
            
            NSLog("Test 1: closing second file's stream...")
            
            try stream2.finishedWriting()
            
            NSLog("Test 1: closing zip file...")
            
            try zipFile.close()
            
            NSLog("Test 1: opening zip file for reading...")
            
            let unzipFile = try OZZipFile(fileName:filePath, mode:OZZipFileMode.Unzip)
            
            XCTAssertNotNil(unzipFile)
            
            NSLog("Test 1: reading file infos...")
            
            let infos = try unzipFile.listFileInZipInfos()
            
            XCTAssertEqual(2, infos.count)
            
            let info1 = infos[0] as! OZFileInZipInfo
            
            XCTAssertEqualWithAccuracy(NSDate().timeIntervalSinceReferenceDate, info1.date.timeIntervalSinceReferenceDate + 86400, accuracy:5.0)
            
            NSLog("Test 1: - \(info1.name) \(info1.date) \(info1.size) (\(info1.level))")
            
            let info2 = infos[1] as! OZFileInZipInfo
            
            XCTAssertEqualWithAccuracy(NSDate().timeIntervalSinceReferenceDate, info2.date.timeIntervalSinceReferenceDate, accuracy:5.0)
            
            NSLog("Test 1: - \(info2.name) \(info2.date) \(info2.size) (\(info2.level))")
            
            NSLog("Test 1: opening first file...")
            
            try unzipFile.goToFirstFileInZip()
            let read1 = try unzipFile.readCurrentFileInZip()
            
            XCTAssertNotNil(read1)
            
            NSLog("Test 1: reading from first file's stream...")
            
            let data1 = NSMutableData(length:256)!
            let bytesRead1 = try read1.readDataWithBuffer(data1)
            
            XCTAssertEqual(3, bytesRead1)
            
            let fileText1 = NSString(bytes:data1.bytes, length:Int(bytesRead1), encoding:NSUTF8StringEncoding)
            
            XCTAssertEqual("abc", fileText1)
            
            NSLog("Test 1: closing first file's stream...")
            
            try read1.finishedReading()
            
            NSLog("Test 1: opening second file...")
            
            try unzipFile.locateFileInZip(file2name)
            let read2 = try unzipFile.readCurrentFileInZip()
            
            XCTAssertNotNil(read2)
            
            NSLog("Test 1: reading from second file's stream...")
            
            let data2 = NSMutableData(length:256)!
            let bytesRead2 = try read2.readDataWithBuffer(data2)
            
            XCTAssertEqual(3, bytesRead2)
            
            let fileText2 = NSString(bytes:data2.bytes, length:Int(bytesRead2), encoding:NSUTF8StringEncoding)
            
            XCTAssertEqual("XYZ", fileText2)
            
            NSLog("Test 1: closing second file's stream...")
            
            try read2.finishedReading()
            
            NSLog("Test 1: closing zip file...")
            
            try unzipFile.close()
            
            NSLog("Test 1: test terminated succesfully")
        
        } catch let error as NSError {
            NSLog("Test 1: error caught: \(error.code) - \(error.userInfo[NSLocalizedFailureReasonErrorKey])")
            
            XCTFail("Error caught: \(error.code) - \(error.userInfo[NSLocalizedFailureReasonErrorKey])")

        } catch let error {
            NSLog("Test 1: generic error caught: \(error)")
            
            XCTFail("Generic error caught: \(error)")
        }
    }
    
    /* 
     * Uncomment to execute this test, but be careful: takes 5 minutes and consumes 5 GB of disk space
     *
    func test02ZipAndUnzip5GB() {
    
        let documentsUrl = NSURL(fileURLWithPath:NSHomeDirectory(), isDirectory:true).URLByAppendingPathComponent("Documents")
        let fileUrl = documentsUrl.URLByAppendingPathComponent("huge_test.zip")
        let filePath = fileUrl.path!
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
        } catch {}

        defer {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filePath)
            } catch {}
        }
        
        do {
            NSLog("Test 2: opening zip file for writing...")
            
            let zipFile = try OZZipFile(fileName:filePath, mode:OZZipFileMode.Create)
            
            XCTAssertNotNil(zipFile)
            
            NSLog("Test 2: adding file...")
            
            let stream = try zipFile.writeFileInZipWithName("huge_file.txt", compressionLevel:OZZipCompressionLevel.Best)
            
            XCTAssertNotNil(stream)
            
            NSLog("Test 2: writing to file's stream...")
            
            let data = NSMutableData(length:HUGE_TEST_BLOCK_LENGTH)!
            SecRandomCopyBytes(kSecRandomDefault, data.length, UnsafeMutablePointer<UInt8>(data.mutableBytes))
            
            let checkData = data.subdataWithRange(NSMakeRange(0, 100))
            
            let buffer = NSMutableData(length:HUGE_TEST_BLOCK_LENGTH)! // For use later
            
            for (var i = 0; i < HUGE_TEST_NUMBER_OF_BLOCKS; i++) {
                try stream.writeData(data)
                
                if (i % 100 == 0) {
                    NSLog("Test 2: written \((data.length / 1024) * (i + 1))  KB...")
                }
            }
            
            NSLog("Test 2: closing file's stream...")
            
            try stream.finishedWriting()
            
            NSLog("Test 2: closing zip file...")
            
            try zipFile.close()
            
            NSLog("Test 2: opening zip file for reading...")
            
            let unzipFile = try OZZipFile(fileName:filePath, mode:OZZipFileMode.Unzip)
            
            XCTAssertNotNil(unzipFile)
            
            NSLog("Test 1: reading file infos...")
            
            let infos = try unzipFile.listFileInZipInfos()
            
            XCTAssertEqual(1, infos.count)
            
            let info1 = infos[0] as! OZFileInZipInfo
            
            XCTAssertEqual(info1.length, UInt64(HUGE_TEST_NUMBER_OF_BLOCKS) * UInt64(HUGE_TEST_BLOCK_LENGTH))
            
            NSLog("Test 1: - \(info1.name) \(info1.date) \(info1.size) (\(info1.level))")
            
            NSLog("Test 2: opening file...")
            
            try unzipFile.goToFirstFileInZip()
            let read = try unzipFile.readCurrentFileInZip()
            
            XCTAssertNotNil(read)
            
            NSLog("Test 2: reading from file's stream...")
            
            for (var i = 0; i < HUGE_TEST_NUMBER_OF_BLOCKS; i++) {
                let bytesRead = try read.readDataWithBuffer(buffer)
                
                XCTAssertEqual(data.length, bytesRead)
                
                let range = buffer.rangeOfData(checkData, options:NSDataSearchOptions(), range:NSMakeRange(0, buffer.length))
                
                XCTAssertEqual(0, range.location)
                
                if (i % 100 == 0) {
                    NSLog("Test 2: read \((buffer.length / 1024) * (i + 1))) KB...")
                }
            }
            
            NSLog("Test 2: closing file's stream...")
            
            try read.finishedReading()
            
            NSLog("Test 2: closing zip file...")
            
            try unzipFile.close()
            
            NSLog("Test 2: test terminated succesfully")
        
        } catch let error as NSError {
            NSLog("Test 2: error caught: \(error.code) - \(error.userInfo[NSLocalizedFailureReasonErrorKey])")
            
            XCTFail("Error caught: \(error.code) - \(error.userInfo[NSLocalizedFailureReasonErrorKey])")
        }
    }
     */
    
    func test03UnzipMacZipFile() -> () {
        let documentsUrl = NSURL(fileURLWithPath:NSHomeDirectory(), isDirectory:true).URLByAppendingPathComponent("Documents")
        let fileUrl = documentsUrl.URLByAppendingPathComponent("mac_test_file.zip")
        let filePath = fileUrl.path!
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
        } catch {}

        let macZipData = NSData(base64EncodedString:MAC_TEST_ZIP, options:NSDataBase64DecodingOptions())!
        macZipData.writeToFile(filePath, atomically:false)
        
        defer {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filePath)
            } catch {}
        }
        
        do {
            NSLog("Test 3: opening zip file for reading...")
            
            let unzipFile = try OZZipFile(fileName:filePath, mode:OZZipFileMode.Unzip)
            
            XCTAssertNotNil(unzipFile)
            
            NSLog("Test 3: opening file...")
            
            try unzipFile.goToFirstFileInZip()
            let read = try unzipFile.readCurrentFileInZip()
            
            XCTAssertNotNil(read)
            
            NSLog("Test 3: reading from file's stream...")
            
            let buffer = NSMutableData(length:1024)!
            let bytesRead = try read.readDataWithBuffer(buffer)
            
            let fileText = NSString(bytes:buffer.bytes, length:Int(bytesRead), encoding:NSUTF8StringEncoding)
            
            XCTAssertEqual("Objective-Zip Mac test file\n", fileText)
            
            NSLog("Test 3: closing file's stream...")
            
            try read.finishedReading()
            
            NSLog("Test 3: closing zip file...")
            
            try unzipFile.close()
            
            NSLog("Test 3: test terminated succesfully")
        
        } catch let error as NSError {
            NSLog("Test 3: error caught: \(error.code) - \(error.userInfo[NSLocalizedFailureReasonErrorKey])")
            
            XCTFail("Error caught: \(error.code) - \(error.userInfo[NSLocalizedFailureReasonErrorKey])")
        }
    }
    
    func test04UnzipWinZipFile() {
        let documentsUrl = NSURL(fileURLWithPath:NSHomeDirectory(), isDirectory:true).URLByAppendingPathComponent("Documents")
        let fileUrl = documentsUrl.URLByAppendingPathComponent("win_test_file.zip")
        let filePath = fileUrl.path!
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(filePath)
        } catch {}

        let winZipData = NSData(base64EncodedString:WIN_TEST_ZIP, options:NSDataBase64DecodingOptions())!
        winZipData.writeToFile(filePath, atomically:false)
        
        defer {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filePath)
            } catch {}
        }
        
        do {
            NSLog("Test 4: opening zip file for reading...")
            
            let unzipFile = try OZZipFile(fileName:filePath, mode:OZZipFileMode.Unzip)
            
            XCTAssertNotNil(unzipFile)
            
            NSLog("Test 4: opening file...")
            
            try unzipFile.goToFirstFileInZip()
            let read = try unzipFile.readCurrentFileInZip()
            
            XCTAssertNotNil(read)
            
            NSLog("Test 4: reading from file's stream...")
            
            let buffer = NSMutableData(length:1024)!
            let bytesRead = try read.readDataWithBuffer(buffer)
            
            let fileText = NSString(bytes:buffer.bytes, length:Int(bytesRead), encoding:NSUTF8StringEncoding)
            
            XCTAssertEqual("Objective-Zip Windows test file\r\n", fileText)
            
            NSLog("Test 4: closing file's stream...")
            
            try read.finishedReading()
            
            NSLog("Test 4: closing zip file...")
            
            try unzipFile.close()
            
            NSLog("Test 4: test terminated succesfully")
        
        } catch let error as NSError {
            NSLog("Test 4: error caught: \(error.code) - \(error.userInfo[NSLocalizedFailureReasonErrorKey])")
            
            XCTFail("Error caught: \(error.code) - \(error.userInfo[NSLocalizedFailureReasonErrorKey])")
        }
    }
    
    func test05ErrorWrapping() {
        let fileUrl = NSURL(fileURLWithPath:"/root.zip", isDirectory:false)
        let filePath = fileUrl.path!
        
        defer {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(filePath)
            } catch {}
        }

        do {
            NSLog("Test 5: opening impossible zip file for writing...")
            
            let zipFile = try OZZipFile(fileName:filePath, mode:OZZipFileMode.Create)
            
            try zipFile.close()
            
            NSLog("Test 5: test failed, no error reported")
            
            XCTFail("No error reported")
        
        } catch let error as NSError {
            XCTAssertEqual(OZ_ERROR_NO_SUCH_FILE, error.code)
            
            NSLog("Test 5: test terminated succesfully")
        }
    }
}
