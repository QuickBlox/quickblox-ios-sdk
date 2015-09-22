#
#  Be sure to run `pod spec lint QMServices.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "QMServices"
  s.version      = "0.2"
  s.summary      = "Easy-to-use services for Quickblox SDK, for speeding up development of iOS chat applications."
  s.homepage     = "https://github.com/QuickBlox/q-municate-services-ios"
  s.license      = { :type => 'MIT', :file => 'LICENSE.txt' }
  s.author       = { "Gleb Ustimenko" => "gleb.ustimenko@injoit.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/QuickBlox/q-municate-services-ios.git", :branch => 'development'}
  s.source_files  = "Classes", "**/*.{h,m}"
  s.exclude_files = "Pods"
  s.requires_arc = true
  s.ios.frameworks      = "MobileCoreServices", "SystemConfiguration", "AVFoundation", "CoreVideo", "Accelerate", "CoreMedia", "AudioToolbox", "CoreLocation", "CoreData", "CoreGraphics", "CFNetwork", "UIKit"
  s.libraries           = "resolv", "xml2", "stdc++", "z"
  s.xcconfig            = { 'HEADER_SEARCH_PATHS' => '/usr/include/libxml2', "FRAMEWORK_SEARCH_PATHS" => "$(PODS_ROOT)/../../Framework"}
  s.prefix_header_contents = 
  '#import <Quickblox/Quickblox.h>
#import <CoreData/CoreData.h>
#import <Quickblox/QBMulticastDelegate.h>'
  s.resource_bundle = {'QMChatCacheModel' => 'QMChatCache/QMChatCache/CoreData/QMChatServiceModel.xcdatamodeld', 'QMContactListCacheModel' => 'QMContactListCache/QMContactListCache/CoreData/QMContactListModel.xcdatamodeld'}
end