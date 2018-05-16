//
//  HRFinalCamViewController.m
//  HorrorAR
//
//  Created by Gabe Jacobs on 3/27/18.
//  Copyright © 2018 Gabe Jacobs. All rights reserved.
//

#import "HRFinalCamViewController.h"
#import <Photos/Photos.h>
@interface HRFinalCamViewController () <ARSCNViewDelegate, ARSessionDelegate, CLLocationManagerDelegate>

@end

@implementation HRFinalCamViewController


- (void)viewDidLoad {
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        
        
        PHFetchResult *fetchResultForAssetCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits options:nil];
        
        
        PHAssetCollection *assetCollection = fetchResultForAssetCollection.firstObject;
        PHFetchResult *fetchResultForAsset = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        
        PHAsset *asset = fetchResultForAsset.lastObject;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        options.networkAccessAllowed = YES;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
            self.selfie = result;
        
        }];
    }];
    
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
    
    NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"strings" withExtension:@"mp3"];
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
    [self performSelector:@selector(allowPlanes) withObject:nil afterDelay:8.0];
    [self performSelector:@selector(showFirstARObject) withObject:nil afterDelay:15.0];
    
    self.cameraOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"scare1"]];
    self.cameraOverlay.frame = self.view.frame;
    self.cameraOverlay.hidden = YES;
    [self.view addSubview:self.cameraOverlay];
    
    self.maskOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Mask"]];
    self.maskOverlay.frame = self.view.frame;
    [self.view addSubview:self.maskOverlay];
    
    
    SCNScene *paperScene = [SCNScene sceneNamed:@"art.scnassets/paper2.scn"];
    self.paperNode = [paperScene.rootNode childNodeWithName:@"paperSheet" recursively:YES];
    self.zombie = [paperScene.rootNode childNodeWithName:@"zombie" recursively:YES];

    

    [super viewDidLoad];
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.geocoder = [[CLGeocoder alloc] init];
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
    
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

- (void)showScare1 {
    if(!self.finished){
        self.finished = YES;
        NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"scream" withExtension:@"mp3"];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioPath error:nil];
        //    self.audioPlayer.delegate = self;
        [self.audioPlayer play];
        
        
        self.cameraOverlay.image = [UIImage imageNamed:@"scare1"];
        self.cameraOverlay.hidden = NO;
        //        NSURL *glitchPath = [[NSBundle mainBundle] URLForResource:@"glitch1" withExtension:@"mp3"];
        //        self.glitchPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:glitchPath error:nil];
        //        [self.glitchPlayer prepareToPlay];
        //        [self.glitchPlayer play];
        //    [self performSelector:@selector(hideScare) withObject:nil afterDelay:.35];
        //    [self performSelector:@selector(showScare2) withObject:nil afterDelay:8];
    }

}

- (void)showScare2 {
    if(!self.finished){
        self.cameraOverlay.image = [UIImage imageNamed:@"scare2"];
        self.cameraOverlay.hidden = NO;
//        NSURL *glitchPath = [[NSBundle mainBundle] URLForResource:@"glitch2" withExtension:@"mp3"];
//        self.glitchPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:glitchPath error:nil];
//        [self.glitchPlayer prepareToPlay];
//        [self.glitchPlayer play];
        [self performSelector:@selector(hideScare) withObject:nil afterDelay:.35];
        [self performSelector:@selector(showScare1) withObject:nil afterDelay:5];
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
//        [self performSelector:@selector(hideGlitch) withObject:nil afterDelay:.75];
//        [self performSelector:@selector(showGlitch1) withObject:nil afterDelay:6];
//    }
}
- (void)hideScare {
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

- (void)showZombie {
    NSLog(@"showing Zombie");
    
    Plane *plane = [self.planesArrary lastObject];
    
    self.zombie.position = SCNVector3Make(plane.anchor.transform.columns[3].x, plane.anchor.transform.columns[3].y, plane.anchor.transform.columns[3].z + 1.5);
    
    
    self.zombie.scale  = SCNVector3Make(.009, .009, .009);
    self.zombie.eulerAngles = SCNVector3Make(0, -M_PI, 0);
    
    [self.sceneView.scene.rootNode addChildNode:self.zombie];
}


- (void)showFirstARObject {
    if([self.planesArrary count] > 0){

        NSLog(@"showing first AR");
        [self performSelector:@selector(lookingAtNote) withObject:nil afterDelay:3.0];
//        [self performSelector:@selector(lookingAtZombie) withObject:nil afterDelay:3.0];

        Plane *plane = [self.planesArrary lastObject];
        self.paperNode.position = SCNVector3Make(plane.anchor.transform.columns[3].x, plane.anchor.transform.columns[3].y, plane.anchor.transform.columns[3].z);
        self.paperNode.scale  = SCNVector3Make(.04, .04, .04);
//        self.paperNode.eulerAngles = SCNVector3Make(0, -M_PI/4, 0);
        [self.sceneView.scene.rootNode addChildNode:self.paperNode];
   
////
        self.allowPlanesToLoad = NO;

//        [self performSelector:@selector(showScare1) withObject:nil afterDelay:6.0];

        
    } else{
        NSLog(@"STILL SEARCHING");
        if(![self.instructionLabel.text isEqualToString:@"Look down"]){
//            [self showFloorInstruction];
        }
        [self performSelector:@selector(showFirstARObject) withObject:nil afterDelay:2];
    }
}

- (void)showFloorInstruction {
    self.instructionLabel.text = @"AHHSDFHSDLJFHSDJKF";
    self.instructionLabel.hidden = NO;

    self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:8.0
                                                       target:self
                                                     selector:@selector(hideInstruction)
                                                     userInfo:nil
                                                      repeats:NO];



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
//
//
}

- (void)videoTimerDone {
    [self.audioPlayer pause];
    self.finished = YES;
    
}

- (void)allowPlanes {
    self.allowPlanesToLoad = YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if(self.seesNote == YES){

        float heading = newHeading.magneticHeading; //in degrees
//        float headingDegrees = (heading*M_PI/180); //assuming needle points to top of iphone. convert to radians
//        self.bearingView.transform = CGAffineTransformMakeRotation(headingDegrees);

        if(!self.firstRecordedHeading){
             self.firstRecordedHeading = heading;
        }
        self.newHeading = heading;

        NSLog(@"%f", self.firstRecordedHeading);
        NSLog(@"%f",  self.newHeading);

        float desired180 = self.firstRecordedHeading + 180;
        if(desired180 > 360){
            desired180-=360;
        }
        NSLog(@"%f",  desired180);

        if( ((self.newHeading <= desired180 + 30) && (self.newHeading >= desired180 - 30)) ){
            [self performSelector:@selector(showScare1) withObject:nil afterDelay:2.0f];
        }

    }
}


- (void)lookingAtNote {
    SCNNode *pov = self.sceneView.pointOfView;
    if([self.sceneView isNodeInsideFrustum:self.paperNode withPointOfView:pov]){
        self.seesNote = YES;
        [self performSelector:@selector(showZombie) withObject:nil afterDelay:1.0f];

    } else{
        NSLog(@"Waiting to see it");
        [self performSelector:@selector(lookingAtNote) withObject:nil afterDelay:2.0];
    }
}

- (void)lookingAtZombie {
    SCNNode *pov = self.sceneView.pointOfView;
    if([self.sceneView isNodeInsideFrustum:self.zombie withPointOfView:pov]){
//       [self performSelector:@selector(showScare1) withObject:nil afterDelay:4.0f];
        
    } else{
        NSLog(@"Waiting to see it");
        [self performSelector:@selector(lookingAtZombie) withObject:nil afterDelay:2.0];
    }
}

@end
