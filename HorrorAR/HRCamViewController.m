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

@interface HRCamViewController () <ARSCNViewDelegate, ARSessionDelegate>

@end

@implementation HRCamViewController


- (void)viewDidLoad {
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        PHFetchResult *fetchResultForAssetCollection = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum
                                                                                                subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits
                                                                                                options:nil];
        PHAssetCollection *assetCollection = fetchResultForAssetCollection.firstObject;
        PHFetchResult *fetchResultForAsset = [PHAsset fetchAssetsInAssetCollection:assetCollection
                                                                           options:nil];
        
        PHAsset *asset = fetchResultForAsset.firstObject;
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * __nullable imageData, NSString * __nullable dataUTI, UIImageOrientation orientation, NSDictionary * __nullable info) {
            self.selfie = [UIImage imageWithData:imageData];
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
    
//  [self turnTorchOn:YES];
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
    [self performSelector:@selector(showFirstARObject) withObject:nil afterDelay:19.0];
    [self performSelector:@selector(showGlitch1) withObject:nil afterDelay:4.0];

    self.cameraOverlay = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"glitch"]];
    self.cameraOverlay.frame = self.view.frame;
    self.cameraOverlay.hidden = YES;
    [self.view addSubview:self.cameraOverlay];
    
    SCNScene *paperScene = [SCNScene sceneNamed:@"art.scnassets/paper.scn"];
    self.paperNode = [paperScene.rootNode childNodeWithName:@"paperSheet" recursively:YES];

    
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
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    Plane *plane = [[Plane alloc] initWithAnchor: (ARPlaneAnchor *)anchor isHidden: YES];
    [self.planes setObject:plane forKey:anchor.identifier];
    [self.planesArrary addObject:plane];
    [node addChildNode:plane];
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
        [self performSelector:@selector(showFirstARObject) withObject:nil afterDelay:2];
    }
}

- (void)showBedroomInstruction {
    self.instructionLabel.text = @"Go back to your bedroom.";
    self.instructionLabel.hidden = NO;
    
    self.videoTimer = [NSTimer scheduledTimerWithTimeInterval:10.0
                                                         target:self
                                                       selector:@selector(videoTimerDone)
                                                       userInfo:nil
                                                        repeats:NO];
    SCNScene *scene = [SCNScene new];
    self.sceneView.scene = scene;
    

}

- (void)videoTimerDone {
    [self.audioPlayer pause];
    
    HRFaceTimeViewController *ftVC = [[HRFaceTimeViewController alloc] init];
    ftVC.noDecline = YES;
    [self.navigationController pushViewController:ftVC animated:NO];
}


@end
