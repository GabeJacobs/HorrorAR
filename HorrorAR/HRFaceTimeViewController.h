//
//  HRFaceTimeViewController.h
//  HorrorAR
//
//  Created by Gabe Jacobs on 3/12/18.
//  Copyright © 2018 Gabe Jacobs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FastttCamera.h>
#import <AVFoundation/AVFoundation.h>

@interface HRFaceTimeViewController : UIViewController

@property (nonatomic, strong) UIView *cameraOverlay;
@property (nonatomic, strong) FastttCamera *camera;
@property (nonatomic, strong) UILabel *unknownLabel;
@property (nonatomic, strong) UILabel *wouldLikeTo;
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) UIButton *accept;
@property (nonatomic, strong) UIButton *decline;
@property (nonatomic, strong) UILabel *acceptLabel;
@property (nonatomic, strong) UILabel *declineLabel;
@property (nonatomic) BOOL noDecline;
@property (nonatomic) BOOL trackingThem;
@property (nonatomic) NSString *location;

@property (nonatomic, strong) UIView *videoLayer;
@property (nonatomic) AVPlayer *videoPlayer;

@end
