//
//  HRCamViewController.m
//  
//
//  Created by Gabe Jacobs on 3/15/18.
//

#import "HRCamViewController.h"
#import <math.h>

@interface HRCamViewController () <ARSCNViewDelegate, ARSessionDelegate>

@end

@implementation HRCamViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.planes = [NSMutableArray array];
    [UIApplication.sharedApplication setIdleTimerDisabled:YES];
    
    self.arConfig = [ARWorldTrackingConfiguration new];
    self.arConfig.planeDetection = ARPlaneDetectionHorizontal | ARPlaneDetectionVertical;
    
    self.sceneView = [[ARSCNView alloc] initWithFrame:self.view.frame];
    self.sceneView. debugOptions = ARSCNDebugOptionShowFeaturePoints;
    [self.view addSubview:self.sceneView];
    SCNScene *scene = [SCNScene new];
    self.sceneView.scene = scene;
    
    self.sceneView.delegate = self;
    self.sceneView.session.delegate = self;
    
    //[self turnTorchOn:YES];
    
    self.ropeTimer = [NSTimer scheduledTimerWithTimeInterval:15.0
                                                      target:self
                                                    selector:@selector(timerDone)
                                                    userInfo:nil
                                                     repeats:NO];
    
    self.planes = [NSMutableDictionary new];

    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.sceneView.session runWithConfiguration:self.arConfig];
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

#pragma mark - ARSCNViewDelegate

- (void)renderer:(id <SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if (![anchor isKindOfClass:[ARPlaneAnchor class]]) {
        return;
    }
    if(!self.canShowRope) {
        return;
    }
    
    // When a new plane is detected we create a new SceneKit plane to visualize it in 3D
    Plane *plane = [[Plane alloc] initWithAnchor: (ARPlaneAnchor *)anchor];
    [self.planes setObject:plane forKey:anchor.identifier];
    [node addChildNode:plane];
}

- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    Plane *plane = [self.planes objectForKey:anchor.identifier];
    if (plane == nil) {
        return;
    }
    
    // When an anchor is updated we need to also update our 3D geometry too. For example
    // the width and height of the plane detection may have changed so we need to update
    // our SceneKit geometry to match that
    [plane update:(ARPlaneAnchor *)anchor];
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
                [device setFlashMode:AVCaptureFlashModeOn];
                //torchIsOn = YES; //define as a variable/property if you need to know status
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
                [device setFlashMode:AVCaptureFlashModeOff];
                //torchIsOn = NO;
            }
            [device unlockForConfiguration];
        }
    }
    
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
//    NSArray *touchesArray = [touches allObjects];
//    UITouch *touch = (UITouch *)[touchesArray objectAtIndex:0];
//    CGPoint point = [touch locationInView:self.sceneView];
//    NSArray *results = [self.sceneView hitTest:point types:ARHitTestResultTypeExistingPlaneUsingExtent];
//    ARHitTestResult *hitResult = [results firstObject];
//
//    SKTextureAtlas *textureAtlas = [SKTextureAtlas atlasNamed:@"PNG"];
//    self.textureArray = [NSMutableArray array];
//
//    int numImages = textureAtlas.textureNames.count;
//    for (int i=0; i <= (numImages - 1); i++) {
//        NSString *textureName;
//        if(i>=0 && i<10){
//            textureName = [NSString stringWithFormat:@"cricket_0000%d", i];
//        } else if(i>=10 && i<100){
//            textureName = [NSString stringWithFormat:@"cricket_000%d", i];
//        } else if(i>=100 && i<1000){
//            textureName = [NSString stringWithFormat:@"cricket_00%d", i];
//        } else if(i>=1000 && i<10000){
//            textureName = [NSString stringWithFormat:@"cricket_0%d", i];
//        }
//        [self.textureArray addObject:[SKTexture textureWithImageNamed:textureName]];
//    }
//
//    SKSpriteNode *videoSprite = [SKSpriteNode spriteNodeWithTexture:self.textureArray[0]];
//    videoSprite.size = CGSizeMake(videoSprite.size.width, videoSprite.size.height);
//    videoSprite.position = CGPointMake(videoSprite.size.width/2, videoSprite.size.height/2);
//    videoSprite.yScale = videoSprite.yScale * -1;
//
//    [videoSprite runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:self.textureArray timePerFrame:(1.0/24.0)]]];
//
//    SKScene *videoScene = [SKScene sceneWithSize:videoSprite.size];
//    videoScene.scaleMode = SKSceneScaleModeAspectFill;
//    videoScene.backgroundColor = [UIColor clearColor];
//    [videoScene addChild:videoSprite];
//
//    SCNScene *boxScene = [SCNScene sceneNamed:@"art.scnassets/box.scn"];
//    SCNNode *planeNode = [boxScene.rootNode childNodeWithName:@"plane" recursively:true];
//    planeNode.position = SCNVector3Make(hitResult.worldTransform.columns[3].x, hitResult.worldTransform.columns[3].y, hitResult.worldTransform.columns[3].z);
//    SCNMaterial *material = [[SCNMaterial alloc] init];
//    material.diffuse.contents = videoScene;
//    planeNode.geometry.materials = @[material];
//    SCNBillboardConstraint *aConstraint = [SCNBillboardConstraint billboardConstraint];
//    planeNode.constraints = @[aConstraint];
//    [self.sceneView.scene.rootNode addChildNode:planeNode];
//
}

- (void)timerDone {
    self.canShowRope = YES;
}

@end
