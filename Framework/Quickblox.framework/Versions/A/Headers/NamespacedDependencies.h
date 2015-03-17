// Namespaced Header

#ifndef __NS_SYMBOL
// We need to have multiple levels of macros here so that __NAMESPACE_PREFIX_ is
// properly replaced by the time we concatenate the namespace prefix.
#define __NS_REWRITE(ns, symbol) ns ## _ ## symbol
#define __NS_BRIDGE(ns, symbol) __NS_REWRITE(ns, symbol)
#define __NS_SYMBOL(symbol) __NS_BRIDGE(QB, symbol)
#endif


// Classes
#ifndef DDASLLogger
#define DDASLLogger __NS_SYMBOL(DDASLLogger)
#endif

#ifndef DDAbstractDatabaseLogger
#define DDAbstractDatabaseLogger __NS_SYMBOL(DDAbstractDatabaseLogger)
#endif

#ifndef DDAbstractLogger
#define DDAbstractLogger __NS_SYMBOL(DDAbstractLogger)
#endif

#ifndef DDContextBlacklistFilterLogFormatter
#define DDContextBlacklistFilterLogFormatter __NS_SYMBOL(DDContextBlacklistFilterLogFormatter)
#endif

#ifndef DDContextWhitelistFilterLogFormatter
#define DDContextWhitelistFilterLogFormatter __NS_SYMBOL(DDContextWhitelistFilterLogFormatter)
#endif

#ifndef DDDispatchQueueLogFormatter
#define DDDispatchQueueLogFormatter __NS_SYMBOL(DDDispatchQueueLogFormatter)
#endif

#ifndef DDFileLogger
#define DDFileLogger __NS_SYMBOL(DDFileLogger)
#endif

#ifndef DDList
#define DDList __NS_SYMBOL(DDList)
#endif

#ifndef DDListEnumerator
#define DDListEnumerator __NS_SYMBOL(DDListEnumerator)
#endif

#ifndef DDLog
#define DDLog __NS_SYMBOL(DDLog)
#endif

#ifndef DDLogFileFormatterDefault
#define DDLogFileFormatterDefault __NS_SYMBOL(DDLogFileFormatterDefault)
#endif

#ifndef DDLogFileInfo
#define DDLogFileInfo __NS_SYMBOL(DDLogFileInfo)
#endif

#ifndef DDLogFileManagerDefault
#define DDLogFileManagerDefault __NS_SYMBOL(DDLogFileManagerDefault)
#endif

#ifndef DDLogMessage
#define DDLogMessage __NS_SYMBOL(DDLogMessage)
#endif

#ifndef DDLoggerNode
#define DDLoggerNode __NS_SYMBOL(DDLoggerNode)
#endif

#ifndef DDLoggingContextSet
#define DDLoggingContextSet __NS_SYMBOL(DDLoggingContextSet)
#endif

#ifndef DDMultiFormatter
#define DDMultiFormatter __NS_SYMBOL(DDMultiFormatter)
#endif

#ifndef DDTTYLogger
#define DDTTYLogger __NS_SYMBOL(DDTTYLogger)
#endif

#ifndef DDTTYLoggerColorProfile
#define DDTTYLoggerColorProfile __NS_SYMBOL(DDTTYLoggerColorProfile)
#endif

#ifndef DDXMLAttributeNode
#define DDXMLAttributeNode __NS_SYMBOL(DDXMLAttributeNode)
#endif

#ifndef DDXMLDocument
#define DDXMLDocument __NS_SYMBOL(DDXMLDocument)
#endif

#ifndef DDXMLElement
#define DDXMLElement __NS_SYMBOL(DDXMLElement)
#endif

#ifndef DDXMLInvalidNode
#define DDXMLInvalidNode __NS_SYMBOL(DDXMLInvalidNode)
#endif

#ifndef DDXMLNamespaceNode
#define DDXMLNamespaceNode __NS_SYMBOL(DDXMLNamespaceNode)
#endif

#ifndef DDXMLNode
#define DDXMLNode __NS_SYMBOL(DDXMLNode)
#endif

#ifndef GCDAsyncReadPacket
#define GCDAsyncReadPacket __NS_SYMBOL(GCDAsyncReadPacket)
#endif

#ifndef GCDAsyncSocket
#define GCDAsyncSocket __NS_SYMBOL(GCDAsyncSocket)
#endif

#ifndef GCDAsyncSocketPreBuffer
#define GCDAsyncSocketPreBuffer __NS_SYMBOL(GCDAsyncSocketPreBuffer)
#endif

#ifndef GCDAsyncSpecialPacket
#define GCDAsyncSpecialPacket __NS_SYMBOL(GCDAsyncSpecialPacket)
#endif

#ifndef GCDAsyncWritePacket
#define GCDAsyncWritePacket __NS_SYMBOL(GCDAsyncWritePacket)
#endif

#ifndef GCDMulticastDelegate
#define GCDMulticastDelegate __NS_SYMBOL(GCDMulticastDelegate)
#endif

#ifndef GCDMulticastDelegateEnumerator
#define GCDMulticastDelegateEnumerator __NS_SYMBOL(GCDMulticastDelegateEnumerator)
#endif

#ifndef GCDMulticastDelegateNode
#define GCDMulticastDelegateNode __NS_SYMBOL(GCDMulticastDelegateNode)
#endif

#ifndef GCDTimerWrapper
#define GCDTimerWrapper __NS_SYMBOL(GCDTimerWrapper)
#endif

#ifndef RFImageToDataTransformer
#define RFImageToDataTransformer __NS_SYMBOL(RFImageToDataTransformer)
#endif

#ifndef RPCID
#define RPCID __NS_SYMBOL(RPCID)
#endif

#ifndef TURNSocket
#define TURNSocket __NS_SYMBOL(TURNSocket)
#endif

#ifndef XEP_0223
#define XEP_0223 __NS_SYMBOL(XEP_0223)
#endif

#ifndef XMPPAnonymousAuthentication
#define XMPPAnonymousAuthentication __NS_SYMBOL(XMPPAnonymousAuthentication)
#endif

#ifndef XMPPAttentionModule
#define XMPPAttentionModule __NS_SYMBOL(XMPPAttentionModule)
#endif

#ifndef XMPPAutoPing
#define XMPPAutoPing __NS_SYMBOL(XMPPAutoPing)
#endif

#ifndef XMPPAutoTime
#define XMPPAutoTime __NS_SYMBOL(XMPPAutoTime)
#endif

#ifndef XMPPBandwidthMonitor
#define XMPPBandwidthMonitor __NS_SYMBOL(XMPPBandwidthMonitor)
#endif

#ifndef XMPPBasicTrackingInfo
#define XMPPBasicTrackingInfo __NS_SYMBOL(XMPPBasicTrackingInfo)
#endif

#ifndef XMPPBlocking
#define XMPPBlocking __NS_SYMBOL(XMPPBlocking)
#endif

#ifndef XMPPBlockingQueryInfo
#define XMPPBlockingQueryInfo __NS_SYMBOL(XMPPBlockingQueryInfo)
#endif

#ifndef XMPPCapabilities
#define XMPPCapabilities __NS_SYMBOL(XMPPCapabilities)
#endif

#ifndef XMPPCapabilitiesCoreDataStorage
#define XMPPCapabilitiesCoreDataStorage __NS_SYMBOL(XMPPCapabilitiesCoreDataStorage)
#endif

#ifndef XMPPCapsCoreDataStorageObject
#define XMPPCapsCoreDataStorageObject __NS_SYMBOL(XMPPCapsCoreDataStorageObject)
#endif

#ifndef XMPPCapsResourceCoreDataStorageObject
#define XMPPCapsResourceCoreDataStorageObject __NS_SYMBOL(XMPPCapsResourceCoreDataStorageObject)
#endif

#ifndef XMPPCoreDataStorage
#define XMPPCoreDataStorage __NS_SYMBOL(XMPPCoreDataStorage)
#endif

#ifndef XMPPDateTimeProfiles
#define XMPPDateTimeProfiles __NS_SYMBOL(XMPPDateTimeProfiles)
#endif

#ifndef XMPPDeprecatedDigestAuthentication
#define XMPPDeprecatedDigestAuthentication __NS_SYMBOL(XMPPDeprecatedDigestAuthentication)
#endif

#ifndef XMPPDeprecatedPlainAuthentication
#define XMPPDeprecatedPlainAuthentication __NS_SYMBOL(XMPPDeprecatedPlainAuthentication)
#endif

#ifndef XMPPDigestMD5Authentication
#define XMPPDigestMD5Authentication __NS_SYMBOL(XMPPDigestMD5Authentication)
#endif

#ifndef XMPPElement
#define XMPPElement __NS_SYMBOL(XMPPElement)
#endif

#ifndef XMPPElementReceipt
#define XMPPElementReceipt __NS_SYMBOL(XMPPElementReceipt)
#endif

#ifndef XMPPFileTransfer
#define XMPPFileTransfer __NS_SYMBOL(XMPPFileTransfer)
#endif

#ifndef XMPPGoogleSharedStatus
#define XMPPGoogleSharedStatus __NS_SYMBOL(XMPPGoogleSharedStatus)
#endif

#ifndef XMPPGroupCoreDataStorageObject
#define XMPPGroupCoreDataStorageObject __NS_SYMBOL(XMPPGroupCoreDataStorageObject)
#endif

#ifndef XMPPIDTracker
#define XMPPIDTracker __NS_SYMBOL(XMPPIDTracker)
#endif

#ifndef XMPPIQ
#define XMPPIQ __NS_SYMBOL(XMPPIQ)
#endif

#ifndef XMPPIncomingFileTransfer
#define XMPPIncomingFileTransfer __NS_SYMBOL(XMPPIncomingFileTransfer)
#endif

#ifndef XMPPJID
#define XMPPJID __NS_SYMBOL(XMPPJID)
#endif

#ifndef XMPPJabberRPCModule
#define XMPPJabberRPCModule __NS_SYMBOL(XMPPJabberRPCModule)
#endif

#ifndef XMPPLastActivity
#define XMPPLastActivity __NS_SYMBOL(XMPPLastActivity)
#endif

#ifndef XMPPMUC
#define XMPPMUC __NS_SYMBOL(XMPPMUC)
#endif

#ifndef XMPPMessage
#define XMPPMessage __NS_SYMBOL(XMPPMessage)
#endif

#ifndef XMPPMessageArchiving
#define XMPPMessageArchiving __NS_SYMBOL(XMPPMessageArchiving)
#endif

#ifndef XMPPMessageArchivingCoreDataStorage
#define XMPPMessageArchivingCoreDataStorage __NS_SYMBOL(XMPPMessageArchivingCoreDataStorage)
#endif

#ifndef XMPPMessageArchiving_Contact_CoreDataObject
#define XMPPMessageArchiving_Contact_CoreDataObject __NS_SYMBOL(XMPPMessageArchiving_Contact_CoreDataObject)
#endif

#ifndef XMPPMessageArchiving_Message_CoreDataObject
#define XMPPMessageArchiving_Message_CoreDataObject __NS_SYMBOL(XMPPMessageArchiving_Message_CoreDataObject)
#endif

#ifndef XMPPMessageCarbons
#define XMPPMessageCarbons __NS_SYMBOL(XMPPMessageCarbons)
#endif

#ifndef XMPPMessageDeliveryReceipts
#define XMPPMessageDeliveryReceipts __NS_SYMBOL(XMPPMessageDeliveryReceipts)
#endif

#ifndef XMPPModule
#define XMPPModule __NS_SYMBOL(XMPPModule)
#endif

#ifndef XMPPOutgoingFileTransfer
#define XMPPOutgoingFileTransfer __NS_SYMBOL(XMPPOutgoingFileTransfer)
#endif

#ifndef XMPPParser
#define XMPPParser __NS_SYMBOL(XMPPParser)
#endif

#ifndef XMPPPing
#define XMPPPing __NS_SYMBOL(XMPPPing)
#endif

#ifndef XMPPPingInfo
#define XMPPPingInfo __NS_SYMBOL(XMPPPingInfo)
#endif

#ifndef XMPPPlainAuthentication
#define XMPPPlainAuthentication __NS_SYMBOL(XMPPPlainAuthentication)
#endif

#ifndef XMPPPresence
#define XMPPPresence __NS_SYMBOL(XMPPPresence)
#endif

#ifndef XMPPPrivacy
#define XMPPPrivacy __NS_SYMBOL(XMPPPrivacy)
#endif

#ifndef XMPPPrivacyQueryInfo
#define XMPPPrivacyQueryInfo __NS_SYMBOL(XMPPPrivacyQueryInfo)
#endif

#ifndef XMPPProcessOne
#define XMPPProcessOne __NS_SYMBOL(XMPPProcessOne)
#endif

#ifndef XMPPPubSub
#define XMPPPubSub __NS_SYMBOL(XMPPPubSub)
#endif

#ifndef XMPPRebindAuthentication
#define XMPPRebindAuthentication __NS_SYMBOL(XMPPRebindAuthentication)
#endif

#ifndef XMPPReconnect
#define XMPPReconnect __NS_SYMBOL(XMPPReconnect)
#endif

#ifndef XMPPRegistration
#define XMPPRegistration __NS_SYMBOL(XMPPRegistration)
#endif

#ifndef XMPPResourceCoreDataStorageObject
#define XMPPResourceCoreDataStorageObject __NS_SYMBOL(XMPPResourceCoreDataStorageObject)
#endif

#ifndef XMPPResourceMemoryStorageObject
#define XMPPResourceMemoryStorageObject __NS_SYMBOL(XMPPResourceMemoryStorageObject)
#endif

#ifndef XMPPResultSet
#define XMPPResultSet __NS_SYMBOL(XMPPResultSet)
#endif

#ifndef XMPPRoom
#define XMPPRoom __NS_SYMBOL(XMPPRoom)
#endif

#ifndef XMPPRoomCoreDataStorage
#define XMPPRoomCoreDataStorage __NS_SYMBOL(XMPPRoomCoreDataStorage)
#endif

#ifndef XMPPRoomHybridStorage
#define XMPPRoomHybridStorage __NS_SYMBOL(XMPPRoomHybridStorage)
#endif

#ifndef XMPPRoomMemoryStorage
#define XMPPRoomMemoryStorage __NS_SYMBOL(XMPPRoomMemoryStorage)
#endif

#ifndef XMPPRoomMessageCoreDataStorageObject
#define XMPPRoomMessageCoreDataStorageObject __NS_SYMBOL(XMPPRoomMessageCoreDataStorageObject)
#endif

#ifndef XMPPRoomMessageHybridCoreDataStorageObject
#define XMPPRoomMessageHybridCoreDataStorageObject __NS_SYMBOL(XMPPRoomMessageHybridCoreDataStorageObject)
#endif

#ifndef XMPPRoomMessageMemoryStorageObject
#define XMPPRoomMessageMemoryStorageObject __NS_SYMBOL(XMPPRoomMessageMemoryStorageObject)
#endif

#ifndef XMPPRoomOccupantCoreDataStorageObject
#define XMPPRoomOccupantCoreDataStorageObject __NS_SYMBOL(XMPPRoomOccupantCoreDataStorageObject)
#endif

#ifndef XMPPRoomOccupantHybridMemoryStorageObject
#define XMPPRoomOccupantHybridMemoryStorageObject __NS_SYMBOL(XMPPRoomOccupantHybridMemoryStorageObject)
#endif

#ifndef XMPPRoomOccupantMemoryStorageObject
#define XMPPRoomOccupantMemoryStorageObject __NS_SYMBOL(XMPPRoomOccupantMemoryStorageObject)
#endif

#ifndef XMPPRoster
#define XMPPRoster __NS_SYMBOL(XMPPRoster)
#endif

#ifndef XMPPRosterCoreDataStorage
#define XMPPRosterCoreDataStorage __NS_SYMBOL(XMPPRosterCoreDataStorage)
#endif

#ifndef XMPPRosterMemoryStorage
#define XMPPRosterMemoryStorage __NS_SYMBOL(XMPPRosterMemoryStorage)
#endif

#ifndef XMPPSCRAMSHA1Authentication
#define XMPPSCRAMSHA1Authentication __NS_SYMBOL(XMPPSCRAMSHA1Authentication)
#endif

#ifndef XMPPSRVRecord
#define XMPPSRVRecord __NS_SYMBOL(XMPPSRVRecord)
#endif

#ifndef XMPPSRVResolver
#define XMPPSRVResolver __NS_SYMBOL(XMPPSRVResolver)
#endif

#ifndef XMPPSoftwareVersion
#define XMPPSoftwareVersion __NS_SYMBOL(XMPPSoftwareVersion)
#endif

#ifndef XMPPStream
#define XMPPStream __NS_SYMBOL(XMPPStream)
#endif

#ifndef XMPPStreamManagement
#define XMPPStreamManagement __NS_SYMBOL(XMPPStreamManagement)
#endif

#ifndef XMPPStreamManagementIncomingStanza
#define XMPPStreamManagementIncomingStanza __NS_SYMBOL(XMPPStreamManagementIncomingStanza)
#endif

#ifndef XMPPStreamManagementMemoryStorage
#define XMPPStreamManagementMemoryStorage __NS_SYMBOL(XMPPStreamManagementMemoryStorage)
#endif

#ifndef XMPPStreamManagementOutgoingStanza
#define XMPPStreamManagementOutgoingStanza __NS_SYMBOL(XMPPStreamManagementOutgoingStanza)
#endif

#ifndef XMPPStringPrep
#define XMPPStringPrep __NS_SYMBOL(XMPPStringPrep)
#endif

#ifndef XMPPTime
#define XMPPTime __NS_SYMBOL(XMPPTime)
#endif

#ifndef XMPPTimeQueryInfo
#define XMPPTimeQueryInfo __NS_SYMBOL(XMPPTimeQueryInfo)
#endif

#ifndef XMPPTimer
#define XMPPTimer __NS_SYMBOL(XMPPTimer)
#endif

#ifndef XMPPTransports
#define XMPPTransports __NS_SYMBOL(XMPPTransports)
#endif

#ifndef XMPPUserCoreDataStorageObject
#define XMPPUserCoreDataStorageObject __NS_SYMBOL(XMPPUserCoreDataStorageObject)
#endif

#ifndef XMPPUserMemoryStorageObject
#define XMPPUserMemoryStorageObject __NS_SYMBOL(XMPPUserMemoryStorageObject)
#endif

#ifndef XMPPXFacebookPlatformAuthentication
#define XMPPXFacebookPlatformAuthentication __NS_SYMBOL(XMPPXFacebookPlatformAuthentication)
#endif

#ifndef XMPPXOAuth2Google
#define XMPPXOAuth2Google __NS_SYMBOL(XMPPXOAuth2Google)
#endif

#ifndef XMPPvCardAvatarCoreDataStorageObject
#define XMPPvCardAvatarCoreDataStorageObject __NS_SYMBOL(XMPPvCardAvatarCoreDataStorageObject)
#endif

#ifndef XMPPvCardAvatarModule
#define XMPPvCardAvatarModule __NS_SYMBOL(XMPPvCardAvatarModule)
#endif

#ifndef XMPPvCardCoreDataStorage
#define XMPPvCardCoreDataStorage __NS_SYMBOL(XMPPvCardCoreDataStorage)
#endif

#ifndef XMPPvCardCoreDataStorageObject
#define XMPPvCardCoreDataStorageObject __NS_SYMBOL(XMPPvCardCoreDataStorageObject)
#endif

#ifndef XMPPvCardTemp
#define XMPPvCardTemp __NS_SYMBOL(XMPPvCardTemp)
#endif

#ifndef XMPPvCardTempAdr
#define XMPPvCardTempAdr __NS_SYMBOL(XMPPvCardTempAdr)
#endif

#ifndef XMPPvCardTempAdrTypes
#define XMPPvCardTempAdrTypes __NS_SYMBOL(XMPPvCardTempAdrTypes)
#endif

#ifndef XMPPvCardTempBase
#define XMPPvCardTempBase __NS_SYMBOL(XMPPvCardTempBase)
#endif

#ifndef XMPPvCardTempCoreDataStorageObject
#define XMPPvCardTempCoreDataStorageObject __NS_SYMBOL(XMPPvCardTempCoreDataStorageObject)
#endif

#ifndef XMPPvCardTempEmail
#define XMPPvCardTempEmail __NS_SYMBOL(XMPPvCardTempEmail)
#endif

#ifndef XMPPvCardTempLabel
#define XMPPvCardTempLabel __NS_SYMBOL(XMPPvCardTempLabel)
#endif

#ifndef XMPPvCardTempModule
#define XMPPvCardTempModule __NS_SYMBOL(XMPPvCardTempModule)
#endif

#ifndef XMPPvCardTempTel
#define XMPPvCardTempTel __NS_SYMBOL(XMPPvCardTempTel)
#endif

// Functions
#ifndef doesAppRunInBackground
#define doesAppRunInBackground __NS_SYMBOL(doesAppRunInBackground)
#endif

#ifndef sortItems
#define sortItems __NS_SYMBOL(sortItems)
#endif

#ifndef DDExtractFileNameWithoutExtension
#define DDExtractFileNameWithoutExtension __NS_SYMBOL(DDExtractFileNameWithoutExtension)
#endif

// Externs
#ifndef XMPPSINamespace
#define XMPPSINamespace __NS_SYMBOL(XMPPSINamespace)
#endif

#ifndef XMPPSIProfileFileTransferNamespace
#define XMPPSIProfileFileTransferNamespace __NS_SYMBOL(XMPPSIProfileFileTransferNamespace)
#endif

#ifndef XMPPFeatureNegNamespace
#define XMPPFeatureNegNamespace __NS_SYMBOL(XMPPFeatureNegNamespace)
#endif

#ifndef XMPPBytestreamsNamespace
#define XMPPBytestreamsNamespace __NS_SYMBOL(XMPPBytestreamsNamespace)
#endif

#ifndef XMPPIBBNamespace
#define XMPPIBBNamespace __NS_SYMBOL(XMPPIBBNamespace)
#endif

#ifndef XMPPDiscoItemsNamespace
#define XMPPDiscoItemsNamespace __NS_SYMBOL(XMPPDiscoItemsNamespace)
#endif

#ifndef XMPPDiscoInfoNamespace
#define XMPPDiscoInfoNamespace __NS_SYMBOL(XMPPDiscoInfoNamespace)
#endif

#ifndef XMPPLastActivityNamespace
#define XMPPLastActivityNamespace __NS_SYMBOL(XMPPLastActivityNamespace)
#endif

#ifndef XMPPRegistrationErrorDomain
#define XMPPRegistrationErrorDomain __NS_SYMBOL(XMPPRegistrationErrorDomain)
#endif

#ifndef XMPPJabberRPCErrorDomain
#define XMPPJabberRPCErrorDomain __NS_SYMBOL(XMPPJabberRPCErrorDomain)
#endif

#ifndef XMPPIDTrackerTimeoutNone
#define XMPPIDTrackerTimeoutNone __NS_SYMBOL(XMPPIDTrackerTimeoutNone)
#endif

#ifndef kXMPPvCardAvatarElement
#define kXMPPvCardAvatarElement __NS_SYMBOL(kXMPPvCardAvatarElement)
#endif

#ifndef kXMPPvCardAvatarNS
#define kXMPPvCardAvatarNS __NS_SYMBOL(kXMPPvCardAvatarNS)
#endif

#ifndef kXMPPvCardAvatarPhotoElement
#define kXMPPvCardAvatarPhotoElement __NS_SYMBOL(kXMPPvCardAvatarPhotoElement)
#endif

#ifndef XMPPProcessOneSessionID
#define XMPPProcessOneSessionID __NS_SYMBOL(XMPPProcessOneSessionID)
#endif

#ifndef XMPPProcessOneSessionJID
#define XMPPProcessOneSessionJID __NS_SYMBOL(XMPPProcessOneSessionJID)
#endif

#ifndef XMPPProcessOneSessionDate
#define XMPPProcessOneSessionDate __NS_SYMBOL(XMPPProcessOneSessionDate)
#endif

#ifndef XMPPDiscoverItemsNamespace
#define XMPPDiscoverItemsNamespace __NS_SYMBOL(XMPPDiscoverItemsNamespace)
#endif

#ifndef XMPPMUCErrorDomain
#define XMPPMUCErrorDomain __NS_SYMBOL(XMPPMUCErrorDomain)
#endif

#ifndef XMPPGoogleSharedStatusShow
#define XMPPGoogleSharedStatusShow __NS_SYMBOL(XMPPGoogleSharedStatusShow)
#endif

#ifndef XMPPGoogleSharedStatusInvisible
#define XMPPGoogleSharedStatusInvisible __NS_SYMBOL(XMPPGoogleSharedStatusInvisible)
#endif

#ifndef XMPPGoogleSharedStatusStatus
#define XMPPGoogleSharedStatusStatus __NS_SYMBOL(XMPPGoogleSharedStatusStatus)
#endif

#ifndef XMPPGoogleSharedStatusShowAvailable
#define XMPPGoogleSharedStatusShowAvailable __NS_SYMBOL(XMPPGoogleSharedStatusShowAvailable)
#endif

#ifndef XMPPGoogleSharedStatusShowBusy
#define XMPPGoogleSharedStatusShowBusy __NS_SYMBOL(XMPPGoogleSharedStatusShowBusy)
#endif

#ifndef XMPPGoogleSharedStatusShowIdle
#define XMPPGoogleSharedStatusShowIdle __NS_SYMBOL(XMPPGoogleSharedStatusShowIdle)
#endif

#ifndef XMPPBlockingErrorDomain
#define XMPPBlockingErrorDomain __NS_SYMBOL(XMPPBlockingErrorDomain)
#endif

#ifndef XMPPSRVResolverErrorDomain
#define XMPPSRVResolverErrorDomain __NS_SYMBOL(XMPPSRVResolverErrorDomain)
#endif

#ifndef XMPPPrivacyErrorDomain
#define XMPPPrivacyErrorDomain __NS_SYMBOL(XMPPPrivacyErrorDomain)
#endif

#ifndef XMPPIncomingFileTransferErrorDomain
#define XMPPIncomingFileTransferErrorDomain __NS_SYMBOL(XMPPIncomingFileTransferErrorDomain)
#endif

#ifndef kXMPPNSvCardTemp
#define kXMPPNSvCardTemp __NS_SYMBOL(kXMPPNSvCardTemp)
#endif

#ifndef kXMPPvCardTempElement
#define kXMPPvCardTempElement __NS_SYMBOL(kXMPPvCardTempElement)
#endif

#ifndef XMPPOutgoingFileTransferErrorDomain
#define XMPPOutgoingFileTransferErrorDomain __NS_SYMBOL(XMPPOutgoingFileTransferErrorDomain)
#endif

#ifndef XMPPStreamErrorDomain
#define XMPPStreamErrorDomain __NS_SYMBOL(XMPPStreamErrorDomain)
#endif

#ifndef XMPPStreamDidChangeMyJIDNotification
#define XMPPStreamDidChangeMyJIDNotification __NS_SYMBOL(XMPPStreamDidChangeMyJIDNotification)
#endif

#ifndef XMPPStreamTimeoutNone
#define XMPPStreamTimeoutNone __NS_SYMBOL(XMPPStreamTimeoutNone)
#endif

#ifndef QBGCDAsyncSocketException
#define QBGCDAsyncSocketException __NS_SYMBOL(QBGCDAsyncSocketException)
#endif

#ifndef QBGCDAsyncSocketErrorDomain
#define QBGCDAsyncSocketErrorDomain __NS_SYMBOL(QBGCDAsyncSocketErrorDomain)
#endif

#ifndef QBGCDAsyncSocketQueueName
#define QBGCDAsyncSocketQueueName __NS_SYMBOL(QBGCDAsyncSocketQueueName)
#endif

#ifndef QBGCDAsyncSocketThreadName
#define QBGCDAsyncSocketThreadName __NS_SYMBOL(QBGCDAsyncSocketThreadName)
#endif

#ifndef QBGCDAsyncSocketManuallyEvaluateTrust
#define QBGCDAsyncSocketManuallyEvaluateTrust __NS_SYMBOL(QBGCDAsyncSocketManuallyEvaluateTrust)
#endif

#ifndef QBGCDAsyncSocketUseCFStreamForTLS
#define QBGCDAsyncSocketUseCFStreamForTLS __NS_SYMBOL(QBGCDAsyncSocketUseCFStreamForTLS)
#endif

#ifndef QBGCDAsyncSocketSSLPeerID
#define QBGCDAsyncSocketSSLPeerID __NS_SYMBOL(QBGCDAsyncSocketSSLPeerID)
#endif

#ifndef QBGCDAsyncSocketSSLProtocolVersionMin
#define QBGCDAsyncSocketSSLProtocolVersionMin __NS_SYMBOL(QBGCDAsyncSocketSSLProtocolVersionMin)
#endif

#ifndef QBGCDAsyncSocketSSLProtocolVersionMax
#define QBGCDAsyncSocketSSLProtocolVersionMax __NS_SYMBOL(QBGCDAsyncSocketSSLProtocolVersionMax)
#endif

#ifndef QBGCDAsyncSocketSSLSessionOptionFalseStart
#define QBGCDAsyncSocketSSLSessionOptionFalseStart __NS_SYMBOL(QBGCDAsyncSocketSSLSessionOptionFalseStart)
#endif

#ifndef QBGCDAsyncSocketSSLSessionOptionSendOneByteRecord
#define QBGCDAsyncSocketSSLSessionOptionSendOneByteRecord __NS_SYMBOL(QBGCDAsyncSocketSSLSessionOptionSendOneByteRecord)
#endif

#ifndef QBGCDAsyncSocketSSLCipherSuites
#define QBGCDAsyncSocketSSLCipherSuites __NS_SYMBOL(QBGCDAsyncSocketSSLCipherSuites)
#endif

