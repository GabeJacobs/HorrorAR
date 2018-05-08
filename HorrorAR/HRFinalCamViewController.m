//
//  HRFinalCamViewController.m
//  HorrorAR
//
//  Created by Gabe Jacobs on 3/27/18.
//  Copyright © 2018 Gabe Jacobs. All rights reserved.
//

#import "HRFinalCamViewController.h"

@interface HRFinalCamViewController ()

@end

@implementation HRFinalCamViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [super viewDidLoad];
    self.planes = [NSMutableDictionary dictionary];
    self.anchors = [NSMutableArray array];
    
    [UIApplication.sharedApplication setIdleTimerDisabled:YES];
    
    self.arConfig = [ARWorldTrackingConfiguration new];
    self.arConfig.planeDetection = ARPlaneDetectionHorizontal;
    
    self.sceneView = [[ARSCNView alloc] initWithFrame:self.view.frame];
    self.sceneView. debugOptions = ARSCNDebugOptionShowFeaturePoints;
    [self.view addSubview:self.sceneView];
    SCNScene *scene = [SCNScene new];
    self.sceneView.scene = scene;
    
    self.sceneView.delegate = self;
    self.sceneView.session.delegate = self;
    
    [self turnTorchOn:YES];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"hallowed" withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioPath error:nil];
    self.audioPlayer.delegate = self;
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
    
    self.planes = [NSMutableDictionary new];
    
    self.instructionLabel = [[UILabel alloc] initWithFrame:self.view.bounds];
    self.instructionLabel.frame = CGRectMake(22, 0, self.view.frame.size.width - 44, self.view.frame.size.height - 30);
    self.instructionLabel.numberOfLines = 2;
    self.instructionLabel.font = [UIFont fontWithName:@"Avenir-Black" size:25.0];
    self.instructionLabel.textColor = [UIColor whiteColor];
    self.instructionLabel.textAlignment = NSTextAlignmentCenter;
    self.instructionLabel.text = @"Go to your bathroom.";
    self.instructionLabel.hidden = NO;
    [self.view addSubview:self.instructionLabel];
    
//    [self performSelector:@selector(hideInstruction) withObject:nil afterDelay:3.0];
//    [self performSelector:@selector(showFirstARObject) withObject:nil afterDelay:17.0];
//    [self performSelector:@selector(showGlitch1) withObject:nil afterDelay:4.0];
//    
    self.cameraOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glitch"]];
    self.cameraOverlay.frame = self.view.frame;
    self.cameraOverlay.hidden = YES;
    [self.view addSubview:self.cameraOverlay];

}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.sceneView.session runWithConfiguration:self.arConfig];
    
    [self.view bringSubviewToFront:self.cameraOverlay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)hideInstruction {
    self.instructionLabel.hidden = YES;
}

- (void)showGlitch1 {
    self.cameraOverlay.hidden = NO;
    NSURL *glitchPath = [[NSBundle mainBundle] URLForResource:@"glitch1" withExtension:@"mp3"];
    self.glitchPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:glitchPath error:nil];
    [self.glitchPlayer prepareToPlay];
    [self.glitchPlayer play];
    [self performSelector:@selector(hideGlitch) withObject:nil afterDelay:.75];
    [self performSelector:@selector(showGlitch2) withObject:nil afterDelay:4];
    
}

- (void)showGlitch2 {
    self.cameraOverlay.image = [UIImage imageNamed:@"glitch2"];
    self.cameraOverlay.hidden = NO;
    NSURL *glitchPath = [[NSBundle mainBundle] URLForResource:@"glitch2" withExtension:@"mp3"];
    self.glitchPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:glitchPath error:nil];
    [self.glitchPlayer prepareToPlay];
    [self.glitchPlayer play];
    [self performSelector:@selector(hideGlitch) withObject:nil afterDelay:.75];
    [self performSelector:@selector(showGlitch3) withObject:nil afterDelay:5];
    
}

- (void)showGlitch3 {
    self.cameraOverlay.image = [UIImage imageNamed:@"glitch3"];
    self.cameraOverlay.hidden = NO;
    NSURL *glitchPath = [[NSBundle mainBundle] URLForResource:@"glitch3" withExtension:@"mp3"];
    self.glitchPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:glitchPath error:nil];
    [self.glitchPlayer prepareToPlay];
    [self.glitchPlayer play];
    [self performSelector:@selector(hideGlitch) withObject:nil afterDelay:.75];
    [self performSelector:@selector(showGlitch1) withObject:nil afterDelay:6];
    
}


- (void)hideGlitch {
    self.cameraOverlay.hidden = YES;
}

#pragma mark - ARSCNViewDelegate

- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {

}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {

}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    // Present an error message to the user
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    
}

- (void) turnTorchOn: (bool) on {
    
    // check if flashlight available
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
                //torchIsOn = YES; //define as a variable/property if you need to know status
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                //torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
    
    
}

- (void)showFirstARObject {
//    NSLog(@"showing first AR");
//
//    [self performSelector:@selector(showBedroomInstruction) withObject:nil afterDelay:20.0];
//
//
//    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/boogie.scn"];
//    SCNNode *boogie = [scene.rootNode childNodeWithName:@"boogie" recursively:YES];
//    SCNNode *ship = [scene.rootNode childNodeWithName:@"ship" recursively:YES];
//
//
//    matrix_float4x4 translation = matrix_identity_float4x4;
//    translation.columns[3][2] = -2; // Translate 10 cm in front of the camera
//    boogie.simdTransform = matrix_multiply(self.sceneView.session.currentFrame.camera.transform, translation);
//    ship.simdTransform = matrix_multiply(self.sceneView.session.currentFrame.camera.transform, translation);
//
//
//    SCNAction *rotate = [SCNAction rotateByX:0 y:(2 * 3.14) z:0 duration:10];
//    SCNAction *reprotate = [SCNAction repeatAction:rotate count:1000];
//    [boogie runAction:reprotate forKey:@"myrotate"];
//
//    self.sceneView.scene = scene;
    
    //    SCNAction *action = [SCNAction rotateByX:(2 * 3.14) y: 0 z:0 duration:10];
    //    SCNAction *repAction = [SCNAction repeatActionForever:action];
    //    SCNNode *ship = [scene.rootNode childNodeWithName:@"ship" recursively:YES];
    //    [ship runAction:repAction forKey:@"myrotate"];
    
}

- (void)showBedroomInstruction {
//    self.instructionLabel.text = @"Go back to your bedroom.";
//    self.instructionLabel.hidden = NO;
//
//    self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
//                                                       target:self
//                                                     selector:@selector(videoTimerDone)
//                                                     userInfo:nil
//                                                      repeats:NO];
//    SCNScene *scene = [SCNScene new];
//    self.sceneView.scene = scene;
    
    
}

- (void)videoTimerDone {
//    [self.audioPlayer pause];
//
//    HRFaceTimeViewController *ftVC = [[HRFaceTimeViewController alloc] init];
//    ftVC.noDecline = YES;
//    [self.navigationController pushViewController:ftVC animated:NO];
}

@end
