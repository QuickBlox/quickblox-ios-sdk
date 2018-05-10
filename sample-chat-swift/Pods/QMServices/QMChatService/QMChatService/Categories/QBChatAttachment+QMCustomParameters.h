//
//  QBChatAttachment+QMCustomParameters.h
//  QMChatService
//
//  Created by Vitaliy Gurkovsky on 3/26/17.
//
//

#import <Quickblox/Quickblox.h>

typedef NS_ENUM(NSInteger, QMAttachmentType) {
    
    QMAttachmentContentTypeAudio = 1,
    QMAttachmentContentTypeVideo,
    QMAttachmentContentTypeImage,
    QMAttachmentContentTypeCustom = 999
};


extern NSString *const kQMAttachmentTypeAudio;
extern NSString *const kQMAttachmentTypeImage;
extern NSString *const kQMAttachmentTypeVideo;
extern NSString *const kQMAttachmentTypeLocation;


@interface QBChatAttachment (QMCustomParameters)

@property (assign, nonatomic) QMAttachmentType attachmentType;

/**
 *  The URL that identifies locally saved attachment resource.
 */
@property (copy, nonatomic) NSURL *localFileURL;

/**
 *  Determinates attachment's content type(MIME)
 *  https://en.wikipedia.org/wiki/Media_type
 */
@property (copy, nonatomic) NSString *contentType;

/**
 *  Determinates attachment's file extension. 'Content type' should be specified.
 */
@property (nonatomic, readonly) NSString *fileExtension;


/**
 *  Determinates attachment's core type identifier. 'Content type' should be specified.
 *  @see UTCoreTypes.h.
 */
@property (nonatomic, readonly) NSString *typeIdentifier;

/**
 *  Image of attachment (for video/image).
 */
@property (strong, nonatomic) UIImage *image;

/**
 *  Width of attachment (for video/image).
 */
@property (nonatomic, assign) NSInteger width;

/**
 *  Height of attachment (for video/image).
 */
@property (nonatomic, assign) NSInteger height;

/**
 *  Duration in seconds (for video/audio).
 */
@property (nonatomic, assign) NSInteger duration;

/**
 *  Size of attachment in bytes.
 */
@property (nonatomic, assign) NSInteger size;

/**
 *  Attachment has all needed values
 */
@property (nonatomic, assign, getter=isPrepared, readonly) BOOL prepared;

/**
 *  The NSData instance that identifies attachment resource.
 */
@property (nonatomic, copy) NSData *fileData;

- (NSURL *)remoteURLWithToken:(BOOL)withToken;
- (NSURL *)remoteURL;

@end
