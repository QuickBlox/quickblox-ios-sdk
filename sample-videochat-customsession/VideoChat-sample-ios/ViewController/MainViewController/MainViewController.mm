//
//  MainViewController.m
//  SimpleSample-videochat-ios
//
//  Created by QuickBlox team on 1/02/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "CaptureSessionManager.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MainViewController ()
@property (nonatomic) CaptureSessionManager *captureSessionManager;
@end

@implementation MainViewController

@synthesize opponentID;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configure UI
    //
    opponentVideoView.layer.borderWidth = 1;
    opponentVideoView.layer.borderColor = [[UIColor grayColor] CGColor];
    opponentVideoView.layer.cornerRadius = 5;
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    navBar.topItem.title = appDelegate.currentUser == 1 ? @"User 1" : @"User 2";
    [callButton setTitle:appDelegate.currentUser == 1 ? @"Call User2" : @"Call User1" forState:UIControlStateNormal];
    
    if(!QB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")){
        audioOutput.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
        audioOutput.frame = CGRectMake(audioOutput.frame.origin.x-15, audioOutput.frame.origin.y, audioOutput.frame.size.width+50, audioOutput.frame.size.height);
        videoOutput.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
    }
    
    // Setup Video & Audio capture
    //
    _captureSessionManager = [CaptureSessionManager new];
    AVCaptureVideoPreviewLayer *videoPreviewLayer = [_captureSessionManager setupVideoCapture];
    [videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    CGRect layerRect = [[myVideoView layer] bounds];
    [videoPreviewLayer setBounds:layerRect];
    [videoPreviewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),CGRectGetMidY(layerRect))];
    myVideoView.hidden = NO;
    [myVideoView.layer addSublayer:videoPreviewLayer];
    //
    //
	[_captureSessionManager setupAudioCapture];
    
    
    // Set output blocks
    //
    __weak typeof(self) weakSelf = self;
    _captureSessionManager.audioOutputBlock = ^(AudioBuffer buffer){
        // forward audio data to video chat
        //
        [weakSelf.videoChat processVideoChatCaptureAudioBuffer:buffer];
    };
    _captureSessionManager.videoOutputBlock = ^(CMSampleBufferRef buffer){
        // forward video data to video chat
        //
        [weakSelf.videoChat processVideoChatCaptureVideoSample:buffer];
    };
    
    
    // Set block for recording result
    //
    _captureSessionManager.recordVideoResultBlock = ^(NSString *URL){
        
        [MTBlockAlertView showWithTitle:nil
                                message:@"Would you like to watch the recorded video?"
                      cancelButtonTitle:@"No"
                       otherButtonTitle:@"Yes"
                         alertViewStyle:UIAlertViewStyleDefault
                        completionBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                            // Yes
                            if (buttonIndex == 1) {
                                NSURL *videoURL = [NSURL fileURLWithPath:URL];
                                MPMoviePlayerViewController *playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
                                
                                // Present the movie player view controller
                                [weakSelf presentViewController:playerVC animated:YES completion:nil];
                            }
                        }];
    };
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // Start sending chat presence
    //
    [QBChat instance].delegate = self;
    [NSTimer scheduledTimerWithTimeInterval:30 target:[QBChat instance] selector:@selector(sendPresence) userInfo:nil repeats:YES];
}


#pragma mark -
#pragma mark Actions

- (IBAction)changeRecordingSwitch:(id)sender{
    
    // Enable/disable recording
    //
    _captureSessionManager.enabledRecording = [sender isOn];
}

- (IBAction)audioOutputDidChange:(UISegmentedControl *)sender{
    if(sender.selectedSegmentIndex == 0){
        [[QBAudioIOService shared] routeToSpeaker];
    }else{
        [[QBAudioIOService shared] routeToHeadphone];
    }
}

- (IBAction)videoOutputDidChange:(UISegmentedControl *)sender{
    [_captureSessionManager changeVideoOutput:sender.selectedSegmentIndex != 0];
}

- (IBAction)call:(id)sender{
    // Call
    if(callButton.tag == 101){
        callButton.tag = 102;
        
        // Setup video chat
        //
        if(self.videoChat == nil){
            self.videoChat = [[QBChat instance] createAndRegisterVideoChatInstance];
            self.videoChat.viewToRenderOpponentVideoStream = opponentVideoView;
            self.videoChat.viewToRenderOwnVideoStream = myVideoView;
        }
        
		// setup custom captures
        //
		self.videoChat.isUseCustomAudioChatSession = YES;
		self.videoChat.isUseCustomVideoChatCaptureSession = YES;
    
        // Call user by ID
        //
        [self.videoChat callUser:[opponentID integerValue] conferenceType:QBVideoChatConferenceTypeAudioAndVideo];

        callButton.hidden = YES;
        ringigngLabel.hidden = NO;
        ringigngLabel.text = @"Calling...";
        ringigngLabel.frame = CGRectMake(128, 375, 90, 37);
        callingActivityIndicator.hidden = NO;

    // Finish
    }else{
        callButton.tag = 101;
        
        // Finish call
        //
        [self.videoChat finishCall];
        
        myVideoView.hidden = YES;
        opponentVideoView.layer.contents = (id)[[UIImage imageNamed:@"person.png"] CGImage];
        opponentVideoView.image = [UIImage imageNamed:@"person.png"];
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [callButton setTitle:appDelegate.currentUser == 1 ? @"Call User2" : @"Call User1" forState:UIControlStateNormal];
        
        opponentVideoView.layer.borderWidth = 1;
        
        [startingCallActivityIndicator stopAnimating];
        
        
        // release video chat
        //
        [[QBChat instance] unregisterVideoChatInstance:self.videoChat];
        self.videoChat = nil;
    }
}

- (void)reject{
    // Reject call
    //
    if(self.videoChat == nil){
        self.videoChat = [[QBChat instance] createAndRegisterVideoChatInstanceWithSessionID:sessionID];
    }
    [self.videoChat rejectCallWithOpponentID:videoChatOpponentID];
    //
    //
    [[QBChat instance] unregisterVideoChatInstance:self.videoChat];
    self.videoChat = nil;

    // update UI
    callButton.hidden = NO;
    ringigngLabel.hidden = YES;
    
    // release player
    ringingPlayer = nil;
}

- (void)accept{
    NSLog(@"accept");
    
    // Setup video chat
    //
    if(self.videoChat == nil){
        self.videoChat = [[QBChat instance] createAndRegisterVideoChatInstanceWithSessionID:sessionID];
        self.videoChat.viewToRenderOpponentVideoStream = opponentVideoView;
        self.videoChat.viewToRenderOwnVideoStream = myVideoView;
    }
    
	// setup custom capture
    //
	self.videoChat.isUseCustomAudioChatSession = YES;
	self.videoChat.isUseCustomVideoChatCaptureSession = YES;
    
    // Accept call
    //
    [self.videoChat acceptCallWithOpponentID:videoChatOpponentID conferenceType:videoChatConferenceType];

    ringigngLabel.hidden = YES;
    callButton.hidden = NO;
    [callButton setTitle:@"Hang up" forState:UIControlStateNormal];
    callButton.tag = 102;
    
    opponentVideoView.layer.borderWidth = 0;
    
    [startingCallActivityIndicator startAnimating];
    
     myVideoView.hidden = NO;
    
    ringingPlayer = nil;
}

- (void)hideCallAlert{
    [self.callAlert dismissWithClickedButtonIndex:-1 animated:YES];
    self.callAlert = nil;
    
    callButton.hidden = NO;
}

#pragma mark -
#pragma mark AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    ringingPlayer = nil;
}


#pragma mark -
#pragma mark QBChatDelegate 
//
// VideoChat delegate

-(void) chatDidReceiveCallRequestFromUser:(NSUInteger)userID withSessionID:(NSString *)_sessionID conferenceType:(enum QBVideoChatConferenceType)conferenceType{
    NSLog(@"chatDidReceiveCallRequestFromUser %lu", (unsigned long)userID);
    
    // save  opponent data
    videoChatOpponentID = userID;
    videoChatConferenceType = conferenceType;
    sessionID = _sessionID;
    
    
    callButton.hidden = YES;
    
    // show call alert
    //
    if (self.callAlert == nil) {
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        NSString *message = [NSString stringWithFormat:@"%@ is calling. Would you like to answer?", appDelegate.currentUser == 1 ? @"User 2" : @"User 1"];
        self.callAlert = [[UIAlertView alloc] initWithTitle:@"Call" message:message delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
        [self.callAlert show];
    }
    
    // hide call alert if opponent has canceled call
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideCallAlert) object:nil];
    [self performSelector:@selector(hideCallAlert) withObject:nil afterDelay:4];
    
    // play call music
    //
    if(ringingPlayer == nil){
        NSString *path =[[NSBundle mainBundle] pathForResource:@"ringing" ofType:@"wav"];
        NSURL *url = [NSURL fileURLWithPath:path];
        ringingPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:NULL];
        ringingPlayer.delegate = self;
        [ringingPlayer setVolume:1.0];
        [ringingPlayer play];
    }
}

-(void) chatCallUserDidNotAnswer:(NSUInteger)userID{
    NSLog(@"chatCallUserDidNotAnswer %lu", (unsigned long)userID);
    
    callButton.hidden = NO;
    ringigngLabel.hidden = YES;
    callingActivityIndicator.hidden = YES;
    callButton.tag = 101;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QuickBlox VideoChat" message:@"User isn't answering. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(void) chatCallDidRejectByUser:(NSUInteger)userID{
     NSLog(@"chatCallDidRejectByUser %lu", (unsigned long)userID);
    
    callButton.hidden = NO;
    ringigngLabel.hidden = YES;
    callingActivityIndicator.hidden = YES;
    
    callButton.tag = 101;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"QuickBlox VideoChat" message:@"User has rejected your call." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

-(void) chatCallDidAcceptByUser:(NSUInteger)userID{
    NSLog(@"chatCallDidAcceptByUser %lu", (unsigned long)userID);
    
    ringigngLabel.hidden = YES;
    callingActivityIndicator.hidden = YES;
    
    opponentVideoView.layer.borderWidth = 0;
    
    callButton.hidden = NO;
    [callButton setTitle:@"Hang up" forState:UIControlStateNormal];
    callButton.tag = 102;
    
     myVideoView.hidden = NO;
    
    [startingCallActivityIndicator startAnimating];
}

-(void) chatCallDidStopByUser:(NSUInteger)userID status:(NSString *)status{
    NSLog(@"chatCallDidStopByUser %lu purpose %@", (unsigned long)userID, status);
    
    if([status isEqualToString:kStopVideoChatCallStatus_OpponentDidNotAnswer]){
        
        self.callAlert.delegate = nil;
        [self.callAlert dismissWithClickedButtonIndex:0 animated:YES];
        self.callAlert = nil;
     
        ringigngLabel.hidden = YES;
        
        ringingPlayer = nil;
    
    }else{
        myVideoView.hidden = YES;
        opponentVideoView.layer.contents = (id)[[UIImage imageNamed:@"person.png"] CGImage];
        opponentVideoView.layer.borderWidth = 1;
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [callButton setTitle:appDelegate.currentUser == 1 ? @"Call User2" : @"Call User1" forState:UIControlStateNormal];
        callButton.tag = 101;
    }
    
    callButton.hidden = NO;
    
    // release video chat
    //
    [[QBChat instance] unregisterVideoChatInstance:self.videoChat];
    self.videoChat = nil;
}

- (void)chatCallDidStartWithUser:(NSUInteger)userID sessionID:(NSString *)sessionID{
    [startingCallActivityIndicator stopAnimating];
}

- (void)didStartUseTURNForVideoChat{
//    NSLog(@"_____TURN_____TURN_____");
}

- (void)didReceiveAudioBuffer:(AudioBuffer)buffer{
    [_captureSessionManager processAudioBuffer:buffer];
}


#pragma mark -
#pragma mark UIAlertView

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    // Call alert
    switch (buttonIndex) {
        // Reject
        case 0:
            [self reject];
            break;
        // Accept
        case 1:
            [self accept];
            break;
            
        default:
            break;
    }
    
    self.callAlert = nil;
}

@end
