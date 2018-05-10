//
//  HRCamViewController.m
//  
//
//  Created by Gabe Jacobs on 3/15/18.
//

#import "HRCamViewController.h"
#import <math.h>
#import "HRFaceTimeViewController.h"
#import <Photos/Photos.h>

@interface HRCamViewController () <ARSCNViewDelegate, ARSessionDelegate, CLLocationManagerDelegate>

@end

@implementation HRCamViewController


- (void)viewDidLoad {

    [super viewDidLoad];
    self.planes = [NSMutableDictionary dictionary];
    self.planesArrary = [NSMutableArray array];
    self.anchors = [NSMutableArray array];

    [UIApplication.sharedApplication setIdleTimerDisabled:YES];
    
    self.arConfig = [ARWorldTrackingConfiguration new];
    self.arConfig.planeDetection = ARPlaneDetectionHorizontal;
    
    self.sceneView = [[ARSCNView alloc] initWithFrame:self.view.frame];

    [self.view addSubview:self.sceneView];
    SCNScene *scene = [SCNScene new];
    self.sceneView.scene = scene;
    self.sceneView.autoenablesDefaultLighting = YES;
    self.sceneView.delegate = self;
    self.sceneView.session.delegate = self;
    [self turnTorchOn:YES];
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error: nil];
    
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"hallowed" withExtension:@"mp3"];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioPath error:nil];
//    self.audioPlayer.delegate = self;
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
    
    [self performSelector:@selector(hideInstruction) withObject:nil afterDelay:3.0];
    [self performSelector:@selector(allowPlanes) withObject:nil afterDelay:9.0];
    [self performSelector:@selector(showFirstARObject) withObject:nil afterDelay:20.0];
    [self performSelector:@selector(showGlitch1) withObject:nil afterDelay:4.0];

    self.cameraOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glitch"]];
    self.cameraOverlay.frame = self.view.frame;
    self.cameraOverlay.hidden = YES;
    [self.view addSubview:self.cameraOverlay];
    
    self.maskOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Mask"]];
    self.maskOverlay.frame = self.view.frame;
    [self.view addSubview:self.maskOverlay];
    
    SCNScene *paperScene = [SCNScene sceneNamed:@"art.scnassets/paper.scn"];
    self.paperNode = [paperScene.rootNode childNodeWithName:@"paperSheet" recursively:YES];

    [super viewDidLoad];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.geocoder = [[CLGeocoder alloc] init];
    [self.locationManager startUpdatingLocation];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.sceneView.session runWithConfiguration:self.arConfig];
    [self.view bringSubviewToFront:self.cameraOverlay];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)hideInstruction {
    self.instructionLabel.hidden = YES;
}

- (void)showGlitch1 {
    if(!self.finished){
        self.cameraOverlay.hidden = NO;
        NSURL *glitchPath = [[NSBundle mainBundle] URLForResource:@"glitch1" withExtension:@"wav"];
        self.glitchPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:glitchPath error:nil];
        [self.glitchPlayer prepareToPlay];
        [self.glitchPlayer play];
        [self performSelector:@selector(hideGlitch) withObject:nil afterDelay:.4];
        [self performSelector:@selector(showGlitch2) withObject:nil afterDelay:5];
    }
}

- (void)showGlitch2 {
    if(!self.finished){
        self.cameraOverlay.image = [UIImage imageNamed:@"glitch2"];
        self.cameraOverlay.hidden = NO;
        NSURL *glitchPath = [[NSBundle mainBundle] URLForResource:@"glitch4" withExtension:@"wav"];
        self.glitchPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:glitchPath error:nil];
        [self.glitchPlayer prepareToPlay];
        [self.glitchPlayer play];
        [self performSelector:@selector(hideGlitch) withObject:nil afterDelay:.4];
        [self performSelector:@selector(showGlitch1) withObject:nil afterDelay:8];
    }

}

- (void)showGlitch3 {
//    if(!self.finished){
//        self.cameraOverlay.image = [UIImage imageNamed:@"glitch3"];
//        self.cameraOverlay.hidden = NO;
//        NSURL *glitchPath = [[NSBundle mainBundle] URLForResource:@"glitch3" withExtension:@"mp3"];
//        self.glitchPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:glitchPath error:nil];
//        [self.glitchPlayer prepareToPlay];
//        [self.glitchPlayer play];
//        [self performSelector:@selector(hideGlitch) withObject:nil afterDelay:.4];
//        [self performSelector:@selector(showGlitch1) withObject:nil afterDelay:6];
//    }
}
- (void)hideGlitch {
    self.cameraOverlay.hidden = YES;
}

#pragma mark - ARSCNViewDelegate

- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    if(self.allowPlanesToLoad){
        Plane *plane = [[Plane alloc] initWithAnchor: (ARPlaneAnchor *)anchor isHidden: YES];
        [self.planes setObject:plane forKey:anchor.identifier];
        [self.planesArrary addObject:plane];
        [node addChildNode:plane];
    }
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    Plane *plane = [self.planes objectForKey:anchor.identifier];
    if (plane == nil) {
        return;
    }
    [plane update:(ARPlaneAnchor *)anchor];
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
}

- (void)sessionWasInterrupted:(ARSession *)session {
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    
}

- (void)turnTorchOn:(bool) on {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            
            [device lockForConfiguration:nil];
            if (on) {
                [device setTorchMode:AVCaptureTorchModeOn];
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

- (void)showFirstARObject {
    if([self.planesArrary count] > 0){
        [self performSelector:@selector(showBedroomInstruction) withObject:nil afterDelay:20.0];

        NSLog(@"showing first AR");

        Plane *plane = [self.planesArrary lastObject];
        self.paperNode.position = SCNVector3Make(plane.anchor.transform.columns[3].x, plane.anchor.transform.columns[3].y, plane.anchor.transform.columns[3].z);
        self.paperNode.scale  = SCNVector3Make(.04, .04, .04);
        self.paperNode.eulerAngles = SCNVector3Make(0, -M_PI/3, 0);
        [self.sceneView.scene.rootNode addChildNode:self.paperNode];
    } else{
        NSLog(@"STILL SEARCHING");
        if(![self.instructionLabel.text isEqualToString:@"Look down"]){
            [self showFloorInstruction];
        }
        [self performSelector:@selector(showFirstARObject) withObject:nil afterDelay:2];
    }
}

- (void)showFloorInstruction {
    self.instructionLabel.text = @"Look down";
    self.instructionLabel.hidden = NO;
    
    self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:8.0
                                                         target:self
                                                       selector:@selector(hideInstruction)
                                                       userInfo:nil
                                                        repeats:NO];

    

}

- (void)showBedroomInstruction {
    self.instructionLabel.text = @"Go back to your bedroom.";
    self.instructionLabel.hidden = NO;
    
    self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:11.5
                                                       target:self
                                                     selector:@selector(videoTimerDone)
                                                     userInfo:nil
                                                      repeats:NO];
//    SCNScene *scene = [SCNScene new];
//    self.sceneView.scene = scene;
    
    
}

- (void)videoTimerDone {
    [self.audioPlayer pause];
    self.finished = YES;
    
    HRFaceTimeViewController *ftVC = [[HRFaceTimeViewController alloc] init];
    ftVC.trackingThem = YES;
    ftVC.noDecline = YES;
    if([self.postalCode hasPrefix:@"1"]){
        ftVC.location = @"NY";
    } else if([self.postalCode hasPrefix:@"90"]){
        ftVC.location = @"LA";
    } else if([self.postalCode hasPrefix:@"941"]){
        ftVC.location = @"SF";
    } else{
        ftVC.location = @"";
    }
    [self.navigationController pushViewController:ftVC animated:NO];
}

- (void)allowPlanes {
    self.allowPlanesToLoad = YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // this delegate method is constantly invoked every some miliseconds.
    // we only need to receive the first response, so we skip the others.
    if (self.locationFetchCounter > 0) return;
   self. locationFetchCounter++;
    
    // after we have current coordinates, we use this method to fetch the information data of fetched coordinate
    [self.geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placemark = [placemarks lastObject];
        
//        NSString *street = placemark.thoroughfare;
//        NSString *city = placemark.locality;
          NSString *posCode = placemark.postalCode;
//        NSString *country = placemark.country;
        
        self.postalCode = posCode;
        
        // stopping locationManager from fetching again
        [self.locationManager stopUpdatingLocation];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"failed to fetch current location : %@", error);
}
@end
