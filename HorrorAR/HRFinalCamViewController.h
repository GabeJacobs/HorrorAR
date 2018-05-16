//
//  HRFinalCamViewController.h
//  HorrorAR
//
//  Created by Gabe Jacobs on 3/27/18.
//  Copyright © 2018 Gabe Jacobs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>
#import "Plane.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HRFinalCamViewController : UIViewController

@property (nonatomic) BOOL seesNote;
@property (nonatomic, strong) NSTimer *ropeTimer;
@property (nonatomic, strong) NSTimer *bedroomTimer;
@property (nonatomic) BOOL canShowNextVideo;
@property (nonatomic, strong) NSTimer *videoTimer;

@property (nonatomic, strong) ARSCNView *sceneView;
@property (nonatomic, strong) NSMutableDictionary *planes;
@property (nonatomic, strong) NSMutableArray *planesArrary;
@property (nonatomic, strong) ARAnchor *bathroomAnchor;
@property (nonatomic, strong) NSMutableArray *anchors;

@property (nonatomic) ARTrackingState currentTrackingState;
@property (nonatomic, retain) ARWorldTrackingConfiguration *arConfig;
@property (nonatomic, retain) NSMutableArray *videos;
@property (nonatomic) BOOL touchedOnce;
@property (nonatomic, strong) SKSpriteNode *videoNode;
@property (nonatomic, strong) SKAction *group;
@property (nonatomic, strong) NSMutableArray *textureArray;

@property (nonatomic,strong) UILabel *instructionLabel;

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,strong) AVAudioPlayer *glitchPlayer;
@property (nonatomic,strong) UIImageView *cameraOverlay;
@property (nonatomic,strong) UIImageView *maskOverlay;


@property (nonatomic, strong) SCNNode *paperNode;
@property (nonatomic, strong) SCNNode *zombie;

@property (nonatomic, strong) UIImage *selfie;

@property (nonatomic) BOOL allowPlanesToLoad;
@property (nonatomic) BOOL finished;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong)  CLGeocoder *geocoder;
@property (nonatomic)  int locationFetchCounter;

@property (nonatomic)  float firstRecordedHeading;
@property (nonatomic)  float newHeading;

@end
