#
#  Be sure to run `pod spec lint QBSDK.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
    s.name = "Quickblox"
    s.version = "2.1"
    s.summary = "Library of classes to connect with Quickblox services"
    s.homepage = "http://quickblox.com"
    s.license = "MIT"
    s.author = { "Andrey Kozlov" => "Andrey.Kozlov@betfair.com" }
    s.source = { :git => "git@github.com:QuickBlox/SDK-ios.git", :branch => "feature/rearchitecture/development" }
    s.requires_arc = false
    s.platform     = :ios, "6.0"
    s.ios.deployment_target = '6.0'
    s.xcconfig = { 'OTHER_LDFLAGS' => '-ObjC' }

    s.subspec 'Header' do |ss|
        ss.source_files = 'Framework/Quickblox.{h}'
        ss.requires_arc = true
    end

    s.subspec 'QBAFNetworking' do |ss|
        ss.source_files = 'Framework/Core/External/AFNetworking-1.x/**/*.{h,m}'
        ss.requires_arc = true
        ss.frameworks =
        "SystemConfiguration",
        "MobileCoreServices"
    end

    s.subspec 'QBBase64' do |ss|
        ss.source_files = 'Framework/Core/External/Base64/**/*.{h,m}'
        ss.requires_arc = true    
    end
      
    s.subspec 'QBCore' do |ss|
        ss.source_files = 'Framework/QBCore/**/*.{h,m}'
        ss.requires_arc = true
    end

    s.subspec 'BaseServiceFrameworkARC' do |ss|
        ss.requires_arc = true
        
        ss.source_files =
        'Framework/Core/External/XMPP/**/*.{h,m}',        
        'Framework/Core/External/TURN/Vendors/QBGCDAsyncUdpSocket.{h,m}',
        'Framework/Core/Helpers/AsyncCanceler/AsyncCanceler.{h,m}',
        'Framework/Core/Net/Queries/Common/Base/QBQuery.{h,m}',
        'Framework/Core/Net/REST/Request/QBRestRequest.{h,m}',
        'Framework/Core/Net/REST/Response/QBRestResponse.{h,m}',
        'Framework/Core/External/AFNetworking-1.x/**/*.{h,m}',
        'Framework/Core/External/Base64/**/*.{h,m}'
    end

    s.subspec 'BaseServiceFramework' do |ss|
        ss.source_files = 'Framework/Core/**/*.{h,m,mm}'
        
        ss.exclude_files =        
        'Framework/Core/External/XMPP/**/*.{h,m}',        
        'Framework/Core/External/TURN/Vendors/QBGCDAsyncUdpSocket.{h,m}',
        'Framework/Core/Helpers/AsyncCanceler/AsyncCanceler.{h,m}',
        'Framework/Core/Net/Queries/Common/Base/QBQuery.{h,m}',
        'Framework/Core/Net/REST/Request/QBRestRequest.{h,m}',
        'Framework/Core/Net/REST/Response/QBRestResponse.{h,m}',
        'Framework/Core/External/AFNetworking-1.x/**/*.{h,m}',
        'Framework/Core/External/Base64/**/*.{h,m}'

        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/QBAFNetworking'
        ss.dependency 'Quickblox/QBBase64'

        ss.framework  = "SystemConfiguration"
        ss.vendored_library = 'Framework/Core/External/XMPP/Vendor/libidn/libidn.a'
        ss.libraries = 'iconv','xml2', 'stdc++', 'idn'
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
        
        ss.exclude_files =
        'Framework/ChatService/Classes/Net/Server/QBChat.{h,m}',
        'Framework/ChatService/Classes/Net/Server/QBChat+Deprecated.m',
        'Framework/ChatService/Classes/Net/Server/QBMulticastDelegate.{h,m}',
        'Framework/ChatService/Classes/Business/Models/QBChatDialog.{h,m}',
        'Framework/ChatService/Classes/Business/Models/QBChatRoom.{h,m}',
	'Framework/ChatService/Classes/Utils/QBXMLDictionary.{h,m}'
        
        ss.dependency 'Quickblox/BaseServiceFramework'
        ss.dependency 'Quickblox/UsersServiceFramework'
    end

    s.subspec 'ChatServiceFrameworkARC' do |ss|
        ss.requires_arc = true
        ss.source_files =
        'Framework/ChatService/Classes/Net/Server/QBChat.{h,m}',
        'Framework/ChatService/Classes/Net/Server/QBChat+Deprecated.m',
        'Framework/ChatService/Classes/Net/Server/QBMulticastDelegate.{h,m}',
        'Framework/ChatService/Classes/Business/Models/QBChatDialog.{h,m}',
        'Framework/ChatService/Classes/Business/Models/QBChatRoom.{h,m}',
	'Framework/ChatService/Classes/Utils/QBXMLDictionary.{h,m}'
        
        ss.dependency 'Quickblox/UsersServiceFramework'
        ss.dependency 'Quickblox/BaseServiceFramework'
    end

    s.subspec 'CustomObjectsFramework' do |ss|
        ss.source_files = 'Framework/CustomObjects/**/*.{h,m,mm}'
        ss.dependency 'Quickblox/BaseServiceFramework'
    end

    s.subspec 'QBAuth' do |ss|
        ss.requires_arc = true
        ss.source_files = 'Framework/QBAuth/**/*.{h,m}'
        ss.dependency 'Quickblox/QBCore'
    end

    s.subspec 'QBCustomObjects' do |ss|
        ss.requires_arc = true
        ss.source_files = 'Framework/QBCustomObjects/**/*.{h,m}'
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/CustomObjectsFramework'
    end

    s.subspec 'QBLocation' do |ss|
        ss.requires_arc = true
        ss.source_files = 'Framework/QBLocation/**/*.{h,m}'
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/LocationServiceFramework'
    end
      
    s.subspec 'QBChat' do |ss|
        ss.requires_arc = true
        ss.source_files = 'Framework/QBChat/**/*.{h,m}'
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/ChatServiceFramework'
    end

    s.subspec 'QBUsers' do |ss|
        ss.requires_arc = true
        ss.source_files = 'Framework/QBUsers/**/*.{h,m}'
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/UsersServiceFramework'
    end

    s.subspec 'QBMessages' do |ss|
        ss.requires_arc = true
        ss.source_files = 'Framework/QBMessages/**/*{h,m}'
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/MessagesServiceFramework'
    end

    s.subspec 'QBContent' do |ss|
        ss.requires_arc = true
        ss.source_files = 'Framework/QBContent/**/*{h,m}'
        ss.dependency 'Quickblox/QBCore'
        ss.dependency 'Quickblox/ContentServiceFramework'
    end
    
end