//
//  HRIntroViewController.h
//  HorrorAR
//
//  Created by Gabe Jacobs on 3/12/18.
//  Copyright © 2018 Gabe Jacobs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface HRIntroViewController : UIViewController

@property (nonatomic, strong) UIButton *mainAction;
@property (nonatomic, strong) UILabel  *instructionLabel;
@property (nonatomic) int  instructionStep;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end
