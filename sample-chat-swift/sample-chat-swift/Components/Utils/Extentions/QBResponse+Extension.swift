//
//  QBResponse+Extension.swift
//  sample-chat-swift
//
//  Created by Injoit on 16.09.2022.
//  Copyright © 2022 quickBlox. All rights reserved.
//

import Foundation
import Quickblox

struct ErrorCode {
    static let alreadyConnectedCode = -1000
    static let nodenameNorServnameProvided = 8
    static let socketIsNotConnected = 57
    static let socketClosedRemote = 7
    static let errorCodeTimeout = -1010
}

extension QBResponse {
    var localizedStatus: String {
        switch(status) {
        case .cancelled :             // NSURLErrorCancelled
            return "An asynchronous load has been canceled."
        case .accepted:               // 202
            return "The request has been received but not yet acted upon. "
        case .created:                // 201
            return "The request succeeded, and a new resource was created as a result."
        case .forbidden:              // 403
            return "Access has been refused."
        case .notFound:               // 404
            return "The requested resource could not be found."
        case .OK:                     // 200
            return "The request succeeded"
        case .badRequest:             // 400
            return "Missing or invalid parameter."
        case .serverError:            // 500
            return "Server encountered an error, try again later."
        case .unAuthorized:           // 401
            return "Authorization is missing or incorrect."
        case .validationFailed:       // 422
            return "The request was well-formed but was unable to be followed due to validation errors."
        default:
            return status.rawValue.localizedError
        }
    }
}

extension Int {
    var localizedError: String {
        switch(self) {
        case NSURLErrorAppTransportSecurityRequiresSecureConnection :
            return "App Transport Security disallowed a connection because there is no secure network connection."
        case NSURLErrorBackgroundSessionInUseByAnotherProcess :
            return "An app or app extension attempted to connect to a background session that is already connected to a process."
        case NSURLErrorBackgroundSessionRequiresSharedContainer :
            return "The shared container identifier of the URL session configuration is needed but hasn’t been set."
        case NSURLErrorBackgroundSessionWasDisconnected :
            return "The app is suspended or exits while a background data task is processing."
        case NSURLErrorBadServerResponse :
            return "The URL Loading System received bad data from the server."
        case NSURLErrorBadURL :
            return "A malformed URL prevented a URL request from being initiated."
        case NSURLErrorCallIsActive :
            return "A connection was attempted while a phone call was active on a network that doesn’t support simultaneous phone and data communication, such as EDGE or GPRS."
        case NSURLErrorCancelled :
            return "An asynchronous load has been canceled."
        case NSURLErrorCannotCloseFile :
            return "A download task couldn’t close the downloaded file on disk."
        case NSURLErrorCannotConnectToHost :
            return "An attempt to connect to a host failed."
        case NSURLErrorCannotCreateFile :
            return "A download task couldn’t create the downloaded file on disk because of an I/O failure."
        case NSURLErrorCannotDecodeContentData :
            return "Content data received during a connection request had an unknown content encoding."
        case NSURLErrorCannotDecodeRawData :
            return "Content data received during a connection request couldn’t be decoded for a known content encoding."
        case NSURLErrorCannotFindHost :
            return "The host name for a URL couldn’t be resolved."
        case NSURLErrorCannotLoadFromNetwork :
            return "A specific request to load an item only from the cache couldn't be satisfied."
        case NSURLErrorCannotMoveFile :
            return "A downloaded file on disk couldn’t be moved."
        case NSURLErrorCannotOpenFile :
            return "A downloaded file on disk couldn’t be opened."
        case NSURLErrorCannotParseResponse :
            return "A response to a connection request couldn’t be parsed."
        case NSURLErrorCannotRemoveFile :
            return "A downloaded file couldn’t be removed from disk."
        case NSURLErrorCannotWriteToFile :
            return "A download task couldn’t write the file to disk."
        case NSURLErrorClientCertificateRequired :
            return "A client certificate was required to authenticate an SSL connection during a connection request."
        case NSURLErrorDNSLookupFailed :
            return "The host address couldn’t be found via DNS lookup."
        case NSURLErrorDataLengthExceedsMaximum :
            return "The length of the resource data exceeded the maximum allowed."
        case NSURLErrorDataNotAllowed :
            return "The cellular network disallowed a connection."
        case NSURLErrorDownloadDecodingFailedMidStream :
            return "A download task failed to decode an encoded file during the download."
        case NSURLErrorDownloadDecodingFailedToComplete :
            return "A download task failed to decode an encoded file after downloading."
        case NSURLErrorFileDoesNotExist :
            return "The specified file doesn’t exist."
        case NSURLErrorFileIsDirectory :
            return "A request for an FTP file resulted in the server responding that the file is not a plain file, but a directory."
        case NSURLErrorFileOutsideSafeArea :
            return "An internal file operation failed."
        case NSURLErrorHTTPTooManyRedirects :
            return "A redirect loop was detected or the threshold for number of allowable redirects was exceeded (currently 16)."
        case NSURLErrorInternationalRoamingOff :
            return "The attempted connection required activating a data context while roaming, but international roaming is disabled."
        case NSURLErrorNetworkConnectionLost :
            return "A client or server connection was severed in the middle of an in-progress load."
        case NSURLErrorNoPermissionsToReadFile :
            return "A resource couldn’t be read because of insufficient permissions."
        case NSURLErrorNotConnectedToInternet :
            return "A network resource was requested, but an internet connection has not been established and can’t be established automatically."
        case NSURLErrorRedirectToNonExistentLocation :
            return "A redirect was specified by way of server response code, but the server didn’t accompany this code with a redirect URL."
        case NSURLErrorRequestBodyStreamExhausted :
            return "A body stream was needed but the client did not provide one."
        case NSURLErrorResourceUnavailable :
            return "A requested resource couldn’t be retrieved."
        case NSURLErrorSecureConnectionFailed :
            return "An attempt to establish a secure connection failed for reasons that can’t be expressed more specifically."
        case NSURLErrorServerCertificateHasBadDate :
            return "A server certificate is expired, or is not yet valid."
        case NSURLErrorServerCertificateHasUnknownRoot :
            return "A server certificate wasn’t signed by any root server."
        case NSURLErrorServerCertificateNotYetValid :
            return "A server certificate isn’t valid yet."
        case NSURLErrorServerCertificateUntrusted :
            return "A server certificate was signed by a root server that isn’t trusted."
        case NSURLErrorTimedOut :
            return "An asynchronous operation timed out."
        case NSURLErrorUnknown :
            return "The URL Loading System encountered an error that it can’t interpret."
        case NSURLErrorUnsupportedURL :
            return "A properly formed URL couldn’t be handled by the framework."
        case NSURLErrorUserAuthenticationRequired :
            return "Authentication was required to access a resource."
        case NSURLErrorUserCancelledAuthentication :
            return "An asynchronous request for authentication has been canceled by the user."
        case NSURLErrorZeroByteResource :
            return "A server reported that a URL has a non-zero content length, but terminated the network connection gracefully without sending any data."
        default:
            return "The error can’t interpret."
        }
    }
    
    var isNetworkError: Bool {
        let errors = [NSURLErrorNetworkConnectionLost,
                      NSURLErrorNotConnectedToInternet,
                      NSURLErrorDataNotAllowed,
                      NSURLErrorTimedOut,
                      ErrorCode.nodenameNorServnameProvided,
                      ErrorCode.socketIsNotConnected
        ]
        return errors.contains(self)
    }
}
