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

@interface HRIntroViewController () <CLLocationManagerDelegate>

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
//    self.instructionStep = 4;
    self.instructionStep++;
    if(self.instructionStep == 3){
        self.mainAction.userInteractionEnabled = YES;
    }
    
    [UIView animateWithDuration:1.0 delay:0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.instructionLabel.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [self performSelectorOnMainThread:@selector(procceedStep) withObject:nil waitUntilDone:YES];
                     }];
}

- (void)procceedStep {
    if(self.instructionStep == 3){
        [self performSelector:@selector(begin) withObject:nil afterDelay:2.0];
    } else {
        NSLog(@"%d", self.instructionStep);
        [self showInstruction:self.instructionStep];
    }
}

- (void)startInstructions {
    [self requestPermissions];
    
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
        self.instructionLabel.text = @"Go to your bedroom.\nUse headphones.";
    } else if (step == 2) {
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

- (void)requestPermissions {
    
    // check camera authorization status
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (authStatus) {
        case AVAuthorizationStatusAuthorized: { // camera authorized
            [self requestGPS];
        }
            break;
        case AVAuthorizationStatusNotDetermined: { // request authorization
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if(granted) {
                        [self requestGPS];
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

- (void)requestGPS {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    self.locationManager.distanceFilter = 500; // meters
    [self.locationManager requestWhenInUseAuthorization];
}


- (void)viewDidAppear:(BOOL)animated{
    if(self.instructionStep == 3){
        [self showWithoutTap:3];
    } else if(self.instructionStep == 4){
        [self showWithoutTap:4];
    }
}

- (void)showWithoutTap:(int)step{
    if(step == 3){
        self.instructionStep++;
        self.instructionLabel.text = @"Pick up the phone.";
        self.mainAction.userInteractionEnabled = NO;
        [UIView animateWithDuration:1.0 delay:1.5 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.instructionLabel.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:1.0 delay:1.7 options:UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  self.instructionLabel.alpha = 0.0;
                                              }
                                              completion:^(BOOL finished) {
                                                  [self performSelector:@selector(begin) withObject:nil afterDelay:2.0];
                                                  
                                              }];
                         }];
    } else  {
        self.instructionLabel.text = @"You are not the one in control.";
        self.mainAction.userInteractionEnabled = NO;
        [UIView animateWithDuration:1.0 delay:1.5 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.instructionLabel.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             
                             [UIView animateWithDuration:1.0 delay:1.7 options:UIViewAnimationOptionCurveEaseIn
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
