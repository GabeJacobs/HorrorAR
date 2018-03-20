//
//  HRIntroViewController.m
//  HorrorAR
//
//  Created by Gabe Jacobs on 3/12/18.
//  Copyright © 2018 Gabe Jacobs. All rights reserved.
//

#import "HRIntroViewController.h"
#import "HRFaceTimeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface HRIntroViewController ()

@end

@implementation HRIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.instructionStep = 0;
    
    self.mainAction = [UIButton buttonWithType:UIButtonTypeCustom];
    self.mainAction.frame = self.view.bounds;
    [self.mainAction addTarget:self action:@selector(tappedScreen) forControlEvents:UIControlEventTouchUpInside];
    self.mainAction.userInteractionEnabled = NO;
    [self.view addSubview:self.mainAction];
    
    self.instructionLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    self.instructionLabel.frame = CGRectMake(22, 0, self.view.frame.size.width - 44, self.view.frame.size.height - 30);
    self.instructionLabel.numberOfLines = 4;
    self.instructionLabel.font = [UIFont fontWithName:@"Avenir-Black" size:15.0];
    self.instructionLabel.textColor = [UIColor whiteColor];
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionLabel.text = @"Turn off the lights in your home.";
    self.instructionLabel.alpha = 0.0;
    [self.view addSubview:self.instructionLabel];
    
    [self performSelector:@selector(startInstructions) withObject:nil afterDelay:1.0];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tappedScreen {
    self.mainAction.userInteractionEnabled = NO;
    self.instructionStep = 4;
    //self.instructionStep++;
    if(self.instructionStep == 4){
        self.mainAction.userInteractionEnabled = YES;
    }
    
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.instructionLabel.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         if(self.instructionStep == 4){
                             [self performSelector:@selector(begin) withObject:nil afterDelay:2.0];
                         } else {
                             [self showInstruction:self.instructionStep];
                         }
                     }];
}

- (void)startInstructions {
    [self requestCameraPermissionsIfNeeded];
    
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.instructionLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         self.mainAction.userInteractionEnabled = YES;
                     }];
}

- (void)showInstruction:(int)step{
    if(step == 1){
        self.instructionLabel.text = @"Use headphones.\nTurn up the volume on your device.";
    } else if (step == 2) {
        self.instructionLabel.text = @"Go to your bedroom.\nPlace your phone flat on the floor. Screen up.";
    } else if (step == 3) {
        self.instructionLabel.text = @"Tap to begin.";
    }
    [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.instructionLabel.alpha = 1.0;
                     }
                     completion:^(BOOL finished) {
                         self.mainAction.userInteractionEnabled = YES;
                     }];
}

- (void)begin {
    HRFaceTimeViewController *ftVC = [[HRFaceTimeViewController alloc] init];
    [self.navigationController pushViewController:ftVC animated:NO];
}

- (void)beginNoDecline {
    HRFaceTimeViewController *ftVC = [[HRFaceTimeViewController alloc] init];
    ftVC.noDecline = YES;
    [self.navigationController pushViewController:ftVC animated:NO];
}

- (void)requestCameraPermissionsIfNeeded {
    
    // check camera authorization status
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized: { // camera authorized
            // do camera intensive stuff
        }
            break;
        case AVAuthorizationStatusNotDetermined: { // request authorization
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if(granted) {
                        // do camera intensive stuff
                    } else {
//                        [self notifyUserOfCameraAccessDenial];
                    }
                });
            }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied: {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self notifyUserOfCameraAccessDenial];
            });
        }
            break;
        default:
            break;
    }
}

- (void)viewDidAppear:(BOOL)animated{
    if(self.instructionStep == 4){
        [self showWithoutTap:4];
    } else if(self.instructionStep == 5){
        [self showWithoutTap:5];
    }
}

- (void)showWithoutTap:(int)step{
    if(step == 4){
        self.instructionStep++;
        self.instructionLabel.text = @"Pick up the phone.";
        self.mainAction.userInteractionEnabled = NO;
        [UIView animateWithDuration:1.0 delay:1.5 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.instructionLabel.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:1.0 delay:2.5 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  self.instructionLabel.alpha = 0.0;
                                              }
                                              completion:^(BOOL finished) {
                                                  [self performSelector:@selector(begin) withObject:nil afterDelay:2.0];
                                                  
                                              }];
                         }];
    } else  {
        self.instructionLabel.text = @"You are not the one in control...";
        self.mainAction.userInteractionEnabled = NO;
        [UIView animateWithDuration:1.0 delay:1.5 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.instructionLabel.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:1.0 delay:2.5 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  self.instructionLabel.alpha = 0.0;
                                              }
                                              completion:^(BOOL finished) {
                                                  [self performSelector:@selector(beginNoDecline) withObject:nil afterDelay:2.0];
                                                  
                                              }];
                         }];
    }
   
}

@end
