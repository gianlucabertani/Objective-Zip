Pod::Spec.new do |s|
  s.name         = "objective-zip"
  s.version      = "0.8.3"
  s.summary      = "An object-oriented friendly wrapper library for ZLib and MiniZip, in Objective-C for iOS and OS X."
  s.homepage     = "https://github.com/loderunner/objective-zip"
  s.license      = "BSD 2"
  s.author       = { "Gianluca Bertani" => "gianluca@flyingdolphinstudio.com", "Charles Francoise" => "charles.francoise@gmail.com" }
  s.source       = { :git => "https://github.com/loderunner/objective-zip.git", :tag => "0.8.3" }
  s.ios.deployment_target = '4.0'
  s.osx.deployment_target = '10.6'
  s.source_files = 'Objective-Zip/*.{m,h}', 'MiniZip/*.{h,c}', 'ARCHelper/*.h'
  s.library   = 'z'
end