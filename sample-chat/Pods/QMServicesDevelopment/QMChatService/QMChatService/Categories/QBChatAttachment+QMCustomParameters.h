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
@property (copy, nonatomic, readonly) NSString *fileExtension;

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

- (NSURL *)remoteURLWithToken:(BOOL)withToken;
- (NSURL *)remoteURL;

@end
