//
//  TestViewController.h
//  Balance4Good
//
//  Created by Hira Daud on 11/18/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BLEDevice.h"
#import "Sensors.h"

@interface TestViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate>
{
    __weak IBOutlet UILabel *accValueX,*accValueY,*accValueZ;
    __weak IBOutlet UILabel *gyroValueX,*gyroValueY,*gyroValueZ;

    __weak IBOutlet UILabel *d2_accValueX,*d2_accValueY,*d2_accValueZ;
    __weak IBOutlet UILabel *d2_gyroValueX,*d2_gyroValueY,*d2_gyroValueZ;

    __weak IBOutlet UILabel *lblDataPointsCount;
    UIAlertView* loader;
    __weak IBOutlet UILabel *lblTimeElapsed;
    
    int timeElapsed;
}

@property (strong,nonatomic) BLEDevice *devices;
@property (strong,nonatomic) NSMutableArray *gyroSensors;


@property NSMutableArray *sensorsEnabled;

//@property (strong,nonatomic) sensorIMU3000 *gyroSensor;
//
//@property (strong,nonatomic) sensorTagValues *currentVal;
@property (strong,nonatomic) NSTimer *logTimer;
@property (strong,nonatomic) NSTimer *countUpTimer;

//@property (strong,nonatomic) NSMutableArray *current_Values;
@property (strong,nonatomic) NSMutableDictionary *current_Values;
@property float logInterval;
@property int updateInterval;

- (IBAction)save:(UIButton *)sender;
- (IBAction)cancelTest:(UIButton *)sender;

@end
