//
//  HRCamViewController.h
//  
//
//  Created by Gabe Jacobs on 3/15/18.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface HRCamViewController : UIViewController

@property (nonatomic, strong) ARSCNView *sceneView;
@property (nonatomic, strong) NSMutableArray *planes;

@property (nonatomic) ARTrackingState currentTrackingState;
@property (nonatomic, retain) ARWorldTrackingConfiguration *arConfig;
@property (nonatomic, retain) NSMutableArray *videos;
@property (nonatomic) BOOL touchedOnce;
@property (nonatomic, strong) SKSpriteNode *videoNode;
@property (nonatomic, strong) SKAction *group;
@property (nonatomic, strong) NSMutableArray *textureArray;


@end
