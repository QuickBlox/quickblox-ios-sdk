//
//  QMAudioRecordView.h
//  Pods
//
//  Created by Vitaliy Gurkovsky on 3/7/17.
//
//

#import <UIKit/UIKit.h>

@protocol QMAudioRecordViewProtocol;

@interface QMAudioRecordView : UIView

@property (weak, nonatomic) id <QMAudioRecordViewProtocol> delegate;

- (void)setShowRecordingInterface:(BOOL)show velocity:(CGFloat)velocity;
- (void)updateInterfaceWithVelocity:(CGFloat)velocity;

- (void)audioRecordingStarted;
- (void)audioRecordingFinished;

+ (instancetype)loadAudioRecordView;

- (void)showErrorMessage:(NSString *)errorMessage completion:(void(^)())completion;

@end

@protocol QMAudioRecordViewProtocol <NSObject>

- (NSTimeInterval)currentDuration;
- (NSTimeInterval)maximumDuration;
- (void)shouldStopRecordingByTimeOut;

@end
