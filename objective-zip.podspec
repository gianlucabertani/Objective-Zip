Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name         = "objective-zip"
  s.version      = "1.0.3"
  s.summary      = "An object-oriented friendly wrapper library for ZLib and MiniZip, in Objective-C for iOS and OS X"

  s.description  = <<-DESC
                   Objective-Zip is a small Objective-C library that wraps ZLib and
                   MiniZip in an object-oriented friendly way. It supports:

                   * Zipping and unzipping of common zip file formats.
                   * Multi-GB zip files thanks to 64-bit APIs, even with limited memory available.
                   * Per-file compression level and encryption.

                   Objective-Zip includes sources of latest versions of ZLib and MiniZip.
                   DESC

  s.homepage     = "https://github.com/gianlucabertani/Objective-Zip"


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license      = { :type => "BSD 2.0", :file => "LICENSE.md" }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author             = { "Gianluca Bertani" => "gianluca.bertani@email.it" }
  s.social_media_url   = "https://twitter.com/self_vs_this"


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.ios.deployment_target = "5.1"
  s.osx.deployment_target = "10.7"


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source       = { :git => "https://github.com/gianlucabertani/Objective-Zip.git",
                     :tag => s.version.to_s }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files  = "Objective-Zip/**/*.{h,m}", "MiniZip/**/*.{h,c}", "ZLib/**/*.{h,c}"


  # ――― Publich Headers ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.public_header_files = ["Objective-Zip/OZZipFile.h", "Objective-Zip/OZZipFile+Standard.h", "Objective-Zip/OZZipFile+NSError.h",
                           "Objective-Zip/OZZipFileMode.h", "Objective-Zip/OZZipCompressionLevel.h", "Objective-Zip/OZZipException.h",
                           "Objective-Zip/OZZipWriteStream.h", "Objective-Zip/OZZipWriteStream+Standard.h",
                           "Objective-Zip/OZZipWriteStream+NSError.h", "Objective-Zip/OZZipReadStream.h",
                           "Objective-Zip/OZZipReadStream+Standard.h", "Objective-Zip/OZZipReadStream+NSError.h",
                           "Objective-Zip/OZFileInZipInfo.h", "Objective-Zip/Objective-Zip.h", "Objective-Zip/Objective-Zip+NSError.h"]


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.requires_arc = true
  s.xcconfig = { "OTHER_LDFLAGS" => "-ObjC" }

end
