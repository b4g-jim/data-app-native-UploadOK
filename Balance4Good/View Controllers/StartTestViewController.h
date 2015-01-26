//
//  StartTestViewController.h
//  Balance4Good
//
//  Created by Hira Daud on 12/9/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDevice.h"

@interface StartTestViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    __weak IBOutlet UILabel *lbltName;
    __weak IBOutlet UILabel *lbltNumber;
    __weak IBOutlet UILabel *lbltHeight;
    __weak IBOutlet UILabel *lbltHipHeight;
    __weak IBOutlet UILabel *lbltWeight;
    __weak IBOutlet UILabel *lbltGender;
    __weak IBOutlet UILabel *lblAge;
    
    
    __weak IBOutlet UITextField *txtShoeType;
    __weak IBOutlet UITextField *txtFloorType;
    __weak IBOutlet UITextField *txtSensorType;
    
    __weak IBOutlet UITextField *txtNote;
    BLEDevice *device;
    
    __weak IBOutlet UILabel *lblSensor1_status;
    __weak IBOutlet UILabel *lblSensor2_status;
    
    NSString *preferenceName;
    __weak IBOutlet UIScrollView *scrollView;
    
    NSMutableArray *shoeTypes,*floorTypes,*sensors;
}

- (IBAction)startTest:(UIButton *)sender;

@property (strong,nonatomic) CBCentralManager *manager;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *sensorTags;

@property (strong,nonatomic) NSMutableArray *current_Values;

-(NSMutableDictionary*) makeSensorTagConfiguration;

- (IBAction)cancel:(UIButton *)sender;
- (IBAction)showShowTypeDropDown:(UIButton *)sender;
- (IBAction)showFloorTypeDropDown:(UIButton *)sender;
- (IBAction)showSensorsDropDown:(UIButton *)sender;

@end
