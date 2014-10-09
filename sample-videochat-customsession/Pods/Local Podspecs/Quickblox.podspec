#
#  Be sure to run `pod spec lint QBSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name         = "Quickblox"
  s.version      = "1.9"
  s.summary      = "Library of classes to connect with Quickblox services"
  s.description  = <<-DESC
                   A longer description of QBSDK in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC
  s.homepage     = "http://quickblox.com"
  s.license      = "MIT"
  s.author             = { "Andrey Kozlov" => "Andrey.Kozlov@betfair.com" }
  # Or just: s.author    = "Andrey Kozlov"
  # s.authors            = { "Andrey Kozlov" => "Andrey.Kozlov@betfair.com" }
  # s.social_media_url   = "http://twitter.com/Andrey Kozlov"
  s.source       = { :git => "git@github.com:QuickBlox/SDK-ios.git", :branch => "feature/rearchitecture/cocoapods" }

  s.requires_arc = false
  s.platform     = :ios, "6.0"
  s.ios.deployment_target = '6.0'
  s.subspec 'QBAFNetworking' do |ss|
    ss.source_files = 'Framework/Core/External/AFNetworking-1.x/**/*.{h,m}'
    
    ss.requires_arc = true
    
    ss.dependency 'Quickblox/BaseServiceFramework'
    
    ss.frameworks    = "SystemConfiguration", "MobileCoreServices"
  end
  
  s.subspec 'QBBase64' do |ss|
    ss.source_files = 'Framework/Core/External/Base64/**/*.{h,m}'
    
    ss.requires_arc = true    
  end  
  
  s.subspec 'QBCore' do |ss|
    ss.source_files = 'Framework/QBCore/**/*.{h,m}'
    
    ss.requires_arc = true
    
    ss.dependency 'Quickblox/QBAFNetworking'
    ss.dependency 'Quickblox/UsersServiceFramework'
  end    

s.subspec 'BaseServiceFrameworkARC' do |ss|
ss.source_files = 'Framework/Core/External/XMPP/Vendor/CocoaAsyncSocket/QBGCDAsyncSocket.{h,m}', 'Framework/Core/External/XMPP/Utilities/QBGCDMulticastDelegate.{h,m}','Framework/Core/External/TURN/Vendors/QBGCDAsyncUdpSocket.{h,m}'
ss.requires_arc = true
end

  s.subspec 'BaseServiceFramework' do |ss|
    ss.source_files = 'Framework/Core/**/*.{h,m,mm}'

ss.exclude_files = 'Framework/Core/External/AFNetworking-1.x/**/*.{h,m}', 'Framework/Core/External/Base64/**/*.{h,m}', 'Framework/Core/External/XMPP/Vendor/CocoaAsyncSocket/QBGCDAsyncSocket.{h,m}','Framework/Core/External/XMPP/Utilities/QBGCDMulticastDelegate.{h,m}', 'Framework/Core/External/TURN/Vendors/QBGCDAsyncUdpSocket.{h,m}'

    ss.dependency 'Quickblox/QBCore'
    ss.dependency 'Quickblox/QBAFNetworking'
    ss.dependency 'Quickblox/QBBase64'
    ss.dependency 'Quickblox/AuthServiceFramework'
    ss.dependency 'Quickblox/ChatServiceFramework'
    ss.dependency 'Quickblox/UsersServiceFramework'
    ss.requires_arc = false
    ss.framework  = "SystemConfiguration"
    
    ss.vendored_library = 'Framework/Core/External/XMPP/Vendor/libidn/libidn.a'
    
    ss.libraries = 'xml2', 'stdc++', 'idn'
    ss.xcconfig = { 'HEADER_SEARCH_PATHS' => '"$(SDKROOT)/usr/include/libxml2"' }      
  end

  s.subspec 'AuthServiceFramework' do |ss|
    ss.source_files = 'Framework/AuthService/**/*.{h,m,mm}'
    
    ss.dependency 'Quickblox/BaseServiceFramework'
  end
  
  s.subspec 'UsersServiceFramework' do |ss|
    ss.source_files = 'Framework/UsersService/**/*.{h,m,mm}'
    
    ss.dependency 'Quickblox/BaseServiceFramework'
  end
  
  s.subspec 'LocationServiceFramework' do |ss|
    ss.source_files = 'Framework/LocationService/**/*.{h,m,mm}'
    
    ss.dependency 'Quickblox/BaseServiceFramework'
  end
  
  s.subspec 'MessagesServiceFramework' do |ss|
    ss.source_files = 'Framework/MessagesService/**/*.{h,m,mm}'
    
    ss.dependency 'Quickblox/BaseServiceFramework'
  end
  
  s.subspec 'ContentServiceFramework' do |ss|
    ss.source_files = 'Framework/ContentService/**/*.{h,m,mm}'
    
    ss.dependency 'Quickblox/BaseServiceFramework'
  end
  
  s.subspec 'RatingsServiceFramework' do |ss|
    ss.source_files = 'Framework/RatingsService/**/*.{h,m,mm}'
    
    ss.dependency 'Quickblox/BaseServiceFramework'
    ss.dependency 'Quickblox/LocationServiceFramework'
  end
  
  s.subspec 'ChatServiceFramework' do |ss|
    ss.source_files = 'Framework/ChatService/**/*.{h,m,mm}'
ss.exclude_files = 'Framework/ChatService/Classes/Net/Server/QBChat.{h,m}', 'Framework/ChatService/Classes/Net/Server/QBChat+Deprecated.m', 'Framework/ChatService/Classes/Net/Server/QBMulticastDelegate.{h,m}', 'Framework/ChatService/Classes/Business/Models/QBChatDialog.{h,m}', 'Framework/ChatService/Classes/Business/Models/QBChatRoom.{h,m}'
    ss.dependency 'Quickblox/BaseServiceFramework'
    ss.dependency 'Quickblox/UsersServiceFramework'
  end

  s.subspec 'ChatServiceFrameworkARC' do |ss|
    ss.source_files = 'Framework/ChatService/Classes/Net/Server/QBChat.{h,m}', 'Framework/ChatService/Classes/Net/Server/QBChat+Deprecated.m', 'Framework/ChatService/Classes/Net/Server/QBMulticastDelegate.{h,m}', 'Framework/ChatService/Classes/Business/Models/QBChatDialog.{h,m}', 'Framework/ChatService/Classes/Business/Models/QBChatRoom.{h,m}'
    ss.requires_arc = true
    ss.dependency 'Quickblox/BaseServiceFramework'
    ss.dependency 'Quickblox/UsersServiceFramework'
  end

  s.subspec 'CustomObjectsFramework' do |ss|
    ss.source_files = 'Framework/CustomObjects/**/*.{h,m,mm}'
    
    ss.dependency 'Quickblox/BaseServiceFramework'
  end
  

  s.subspec 'QBAuth' do |ss|
    ss.source_files = 'Framework/QBAuth/**/*.{h,m}'

    ss.requires_arc = true
    
    ss.dependency 'Quickblox/QBCore'
  end

  s.subspec 'QBCustomObjects' do |ss|
    ss.source_files = 'Framework/QBCustomObjects/**/*.{h,m}'
    
    ss.requires_arc = true
    
    ss.dependency 'Quickblox/QBCore'
    
    ss.dependency 'Quickblox/CustomObjectsFramework'
  end

  s.subspec 'QBLocation' do |ss|
    ss.source_files = 'Framework/QBLocation/**/*.{h,m}'
    
    ss.requires_arc = true
    
    ss.dependency 'Quickblox/QBCore'
    
    ss.dependency 'Quickblox/LocationServiceFramework'
  end
  s.subspec 'QBChat' do |ss|
    ss.source_files = 'Framework/QBChat/**/*.{h,m}'
    
    ss.requires_arc = true
    
    ss.dependency 'Quickblox/QBCore'
    
    ss.dependency 'Quickblox/ChatServiceFramework'
  end

  s.subspec 'QBUsers' do |ss|
    ss.source_files = 'Framework/QBUsers/**/*.{h,m}'
    
    ss.requires_arc = true
    
    ss.dependency 'Quickblox/QBCore'
    
    ss.dependency 'Quickblox/UsersServiceFramework'
  end

  s.subspec 'QBMessages' do |ss|
    ss.source_files = 'Framework/QBMessages/**/*{h,m}'

    ss.requires_arc = true

    ss.dependency 'Quickblox/QBCore'

    ss.dependency 'Quickblox/MessagesServiceFramework'
  end

  s.subspec 'QBContent' do |ss|
    ss.source_files = 'Framework/QBContent/**/*{h,m}'

    ss.requires_arc = true

    ss.dependency 'Quickblox/QBCore'

    ss.dependency 'Quickblox/ContentServiceFramework'
  end

  # ――― Resources ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  A list of resources included with the Pod. These are copied into the
  #  target bundle with a build phase script. Anything else will be cleaned.
  #  You can preserve files from being cleaned, please don't preserve
  #  non-essential files like tests, examples and documentation.
  #

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"


  # ――― Project Linking ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Link your library with frameworks, or libraries. Libraries do not include
  #  the lib prefix of their name.
  #

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"


  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  If your library depends on compiler flags you can set them in the xcconfig hash
  #  where they will only apply to your library. If you depend on other Podspecs
  #  you can include multiple dependencies to ensure it works.

  # s.requires_arc = true

  # s.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # s.dependency "JSONKit", "~> 1.4"

end
