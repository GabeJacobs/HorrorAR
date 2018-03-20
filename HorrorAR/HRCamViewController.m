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
    self.arConfig.planeDetection = ARPlaneDetectionHorizontal;
    
    self.sceneView = [[ARSCNView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.sceneView];
    SCNScene *scene = [SCNScene new];
    self.sceneView.scene = scene;
    
    self.sceneView.delegate = self;
    self.sceneView.session.delegate = self;
    
    //[self turnTorchOn:YES];
    
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

-(void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
    if([anchor isKindOfClass:[ARPlaneAnchor class]]){
        ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
        SCNPlane *plane = [SCNPlane planeWithWidth:(CGFloat)planeAnchor.extent.x height:(CGFloat)planeAnchor.extent.z];
        
        SKTextureAtlas *textureAtlas = [SKTextureAtlas atlasNamed:@"PNG"];
        self.textureArray = [NSMutableArray array];
        
        int numImages = textureAtlas.textureNames.count;
        for (int i=0; i <= (numImages - 1); i++) {
            NSString *textureName;
            if(i>=0 && i<10){
                textureName = [NSString stringWithFormat:@"cricket_0000%d", i];
            } else if(i>=10 && i<100){
                textureName = [NSString stringWithFormat:@"cricket_000%d", i];
            } else if(i>=100 && i<1000){
                textureName = [NSString stringWithFormat:@"cricket_00%d", i];
            } else if(i>=1000 && i<10000){
                textureName = [NSString stringWithFormat:@"cricket_0%d", i];
            }
            [self.textureArray addObject:[SKTexture textureWithImageNamed:textureName]];
        }
        
        SKSpriteNode *videoSprite = [SKSpriteNode spriteNodeWithTexture:self.textureArray[0]];
        videoSprite.size = CGSizeMake(videoSprite.size.width, videoSprite.size.height);
        videoSprite.position = CGPointMake(videoSprite.size.width/2, videoSprite.size.height/2);
        videoSprite.yScale = videoSprite.yScale * -1;
        
        [videoSprite runAction:[SKAction repeatActionForever:[SKAction animateWithTextures:self.textureArray timePerFrame:(1.0/24.0)]]];
        
        SKScene *videoScene = [SKScene sceneWithSize:videoSprite.size];
        videoScene.scaleMode = SKSceneScaleModeAspectFill;
        videoScene.backgroundColor = [UIColor clearColor];
        [videoScene addChild:videoSprite];
        
        SCNScene *boxScene = [SCNScene sceneNamed:@"art.scnassets/box.scn"];
        SCNNode *planeNode = [boxScene.rootNode childNodeWithName:@"plane" recursively:true];
        planeNode.position =  SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
        SCNMaterial *material = [[SCNMaterial alloc] init];
        material.diffuse.contents = videoScene;
        planeNode.geometry.materials = @[material];
        SCNBillboardConstraint *aConstraint = [SCNBillboardConstraint billboardConstraint];
        planeNode.constraints = @[aConstraint];
        [node addChildNode:planeNode];

        
    }
}
/*
 // Override to create and configure nodes for anchors added to the view's session.
 - (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
     SCNNode *node = [SCNNode new];
//     if(self.planes.count > 0) {
//         return nil;
//     }
     
     SCNNode *arAnchorNode = [[SCNNode alloc] init];
     SCNNode *planeNode = [[SCNNode alloc] init];
     ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;

     planeNode.geometry = [SCNPlane planeWithWidth:planeAnchor.extent.x height:planeAnchor.extent.z];
     
     planeNode.position =  SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
     planeNode.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"mona+lisa+frame"];
    
     planeNode.eulerAngles = SCNVector3Make(-M_PI/2, 0, 0);

     
     // adding plane node as child to ARAnchorNode due to mandatory ARKit conventions
     [arAnchorNode addChildNode:planeNode];
     //returning ARAnchorNode (must return a node from this function to add it to the scene)
     [self.planes addObject:arAnchorNode];
     
     return arAnchorNode;
     
 }
*/
- (void)renderer:(id <SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor {
//    // converting the ARAnchor to an ARPlaneAnchor to get access to ARPlaneAnchor's extent and center values
//    ARPlaneAnchor *planeAnchor = (ARPlaneAnchor *)anchor;
//
//    SCNNode *updatedNode = [node.childNodes firstObject];
//
//    if (updatedNode == self.planes[0]){
//        // creating plane geometry
//        updatedNode.geometry = [SCNPlane planeWithWidth:planeAnchor.extent.x height:planeAnchor.extent.z];
//        updatedNode.position =  SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z);
//        updatedNode.geometry.firstMaterial.diffuse.contents = [UIImage imageNamed:@"mona+lisa+frame"];
//    }
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

@end
