//
//  HRFaceTimeViewController.m
//  HorrorAR
//
//  Created by Gabe Jacobs on 3/12/18.
//  Copyright © 2018 Gabe Jacobs. All rights reserved.
//r

#import "HRFaceTimeViewController.h"
#import "HRCamViewController.h"
#import "HRFinalCamViewController.h"

@interface HRFaceTimeViewController () <FastttCameraDelegate, AVAudioPlayerDelegate >

@end

@implementation HRFaceTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cameraOverlay = [[UIView alloc] initWithFrame:self.view.frame];
    self.cameraOverlay.backgroundColor = [UIColor colorWithWhite:0 alpha:.45];
    [self.view addSubview:self.cameraOverlay];
    
    self.camera = [FastttCamera new];
    self.camera.delegate = self;
    if ([FastttCamera isCameraDeviceAvailable:FastttCameraDeviceFront]) {
        [self.camera setCameraDevice:FastttCameraDeviceFront];
    }
    self.camera.view.frame = self.view.frame;
    [self fastttAddChildViewController:self.camera belowSubview:self.cameraOverlay];
    
    [self performSelector:@selector(setupOverylay) withObject:nil afterDelay:.5];
    
    [self setNeedsStatusBarAppearanceUpdate];
    [self playRing];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupOverylay {
    self.unknownLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, 40)];
    self.unknownLabel.numberOfLines = 1;
    self.unknownLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:33.0];
    self.unknownLabel.textColor = [UIColor whiteColor];
    self.unknownLabel.textAlignment = NSTextAlignmentCenter;
    self.unknownLabel.text = @"Unknown Caller";
    [self.cameraOverlay addSubview:self.unknownLabel];
    
    self.wouldLikeTo = [[UILabel alloc] initWithFrame:CGRectMake(0, self.unknownLabel.frame.size.height + self.unknownLabel.frame.origin.y, self.view.frame.size.width, 40)];
    self.wouldLikeTo.font = [UIFont fontWithName:@"Avenir" size:18.0];
    self.wouldLikeTo.numberOfLines = 1;
    self.wouldLikeTo.textColor = [UIColor whiteColor];
    self.wouldLikeTo.textAlignment = NSTextAlignmentCenter;
    self.wouldLikeTo.text = @"would like FaceTime...";
    [self.cameraOverlay addSubview:self.wouldLikeTo];
    
    self.accept = [UIButton buttonWithType:UIButtonTypeCustom];
    self.accept.frame = CGRectMake(self.view.frame.size.width - 135, self.view.frame.size.height - 155, 75, 75);
    [self.accept setImage:[UIImage imageNamed:@"Accept"] forState:UIControlStateNormal];
    [self.accept addTarget:self action:@selector(tappedAccept) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraOverlay addSubview:self.accept];
    
    self.acceptLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.accept.frame.origin.x, self.accept.frame.size.height + self.accept.frame.origin.y + 10, self.accept.frame.size.width, 20)];
    self.acceptLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16.0];
    self.acceptLabel.numberOfLines = 1;
    self.acceptLabel.textColor = [UIColor whiteColor];
    self.acceptLabel.textAlignment = NSTextAlignmentCenter;
    self.acceptLabel.text = @"Accept";
    [self.cameraOverlay addSubview:self.acceptLabel];
    
    self.decline = [UIButton buttonWithType:UIButtonTypeCustom];
    self.decline.frame = CGRectMake(60, self.view.frame.size.height - 155, 75, 75);
    [self.decline setImage:[UIImage imageNamed:@"Decline"] forState:UIControlStateNormal];
    [self.decline addTarget:self action:@selector(tappedDecline) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraOverlay addSubview:self.decline];
    
    self.declineLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.decline.frame.origin.x, self.decline.frame.size.height + self.decline.frame.origin.y + 10, self.decline.frame.size.width, 20)];
    self.declineLabel.font = [UIFont fontWithName:@"Avenir-Medium" size:16.0];
    self.declineLabel.numberOfLines = 1;
    self.declineLabel.textColor = [UIColor whiteColor];
    self.declineLabel.textAlignment = NSTextAlignmentCenter;
    self.declineLabel.text = @"Decline";
    [self.cameraOverlay addSubview:self.declineLabel];
    
    if(self.noDecline == YES){
        self.declineLabel.hidden = YES;
        self.decline.hidden = YES;
     
        self.accept.frame = CGRectMake(self.view.frame.size.width/2 - 75/2, self.view.frame.size.height - 155, 75, 75);
        
        self.acceptLabel.frame = CGRectMake(self.accept.frame.origin.x, self.accept.frame.size.height + self.accept.frame.origin.y + 10, self.accept.frame.size.width, 20);
    }
    
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)playRing {
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];

    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"facetime" withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioPath error:nil];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)playanswer {
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"facetimeanswer" withExtension:@"wav"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioPath error:nil];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}

- (void)tappedAccept {
    [self.audioPlayer pause];
    [self playanswer];
    [self performSelector:@selector(acceptedFT) withObject:nil afterDelay:.75];
}

- (void)acceptedFT {
//  self.camera.view.layer.anchorPoint = CGPointMake(.5,0);
    
    self.camera.view.frame = CGRectMake(self.view.frame.size.width - (self.view.frame.size.width*.25) - 15, self.view.frame.size.height - (self.view.frame.size.height*.25), self.view.frame.size.width*.25, self.view.frame.size.height *.2);
    self.videoLayer = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.videoLayer];
    [self.view bringSubviewToFront:self.camera.view];
    [UIView animateWithDuration:1.0
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.unknownLabel.alpha = 0.0;
                         self.wouldLikeTo.alpha = 0.0;
                         self.accept.alpha = 0.0;
                         self.acceptLabel.alpha = 0.0;
                         self.declineLabel.alpha = 0.0;
                         self.decline.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {

                     }];
    
    NSString *filepath;
    if(self.trackingThem == YES){
        if([self.location isEqualToString:@"NY"]){
            filepath = [[NSBundle mainBundle] pathForResource:@"ny2-cut" ofType:@"mov"];
        } else if([self.location isEqualToString:@"LA"]){
            filepath = [[NSBundle mainBundle] pathForResource:@"la-cut" ofType:@"mov"];
        } else if([self.location isEqualToString:@"SF"]){
            filepath = [[NSBundle mainBundle] pathForResource:@"sf-cut" ofType:@"mov"];
        } else {
            filepath = [[NSBundle mainBundle] pathForResource:@"yw-cut" ofType:@"mov"];
        }
    } else{
        filepath = [[NSBundle mainBundle] pathForResource:@"great" ofType:@"MOV"];
    }
//    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"demo" ofType:@"mov"];

    NSURL *fileURL = [NSURL fileURLWithPath:filepath];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:fileURL];
    self.videoPlayer = [AVPlayer playerWithPlayerItem:item];
    self.videoPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    AVPlayerLayer *videoLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPlayer];
    videoLayer.frame = self.videoLayer.bounds;
    videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.videoLayer.layer addSublayer:videoLayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:item];

    
    [self.videoPlayer play];
}

- (void)tappedDecline {
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)itemDidFinishPlaying:(NSNotification *) notification {
    if(self.trackingThem){
        HRFinalCamViewController *ARVC = [[HRFinalCamViewController alloc] init];
        [self.navigationController pushViewController:ARVC animated:NO];
    } else{
        HRCamViewController *ARVC = [[HRCamViewController alloc] init];
        [self.navigationController pushViewController:ARVC animated:NO];
    }

    
}


@end
