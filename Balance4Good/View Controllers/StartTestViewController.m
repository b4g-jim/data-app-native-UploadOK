//
//  StartTestViewController.m
//  Balance4Good
//
//  Created by Hira Daud on 12/9/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "StartTestViewController.h"
#import "TestDetails.h"
#import "TestViewController.h"

@interface StartTestViewController ()

@end

@implementation StartTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.nDevices = [[NSMutableArray alloc]init];
    self.sensorTags = [[NSMutableArray alloc]init];
    [self loadData];
}

-(void)loadData
{
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"personalInfo"];
    [lbltName setText:[data objectForKey:@"name"]];
    [lbltNumber setText:[data objectForKey:@"number"]];
    [lbltHeight setText:[data objectForKey:@"height"]];
    [lbltHipHeight setText:[data objectForKey:@"hipHeight"]];
    [lbltWeight setText:[data objectForKey:@"weight"]];
    [lbltGender setText:[data objectForKey:@"gender"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)startTest:(UIButton *)sender
{
    if(self.sensorTags.count<1)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"No Sensor Detected Yet!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    
    device = [[BLEDevice alloc] init];
    device.peripherals = self.sensorTags;
    device.manager = self.manager;
    device.setupData = [self makeSensorTagConfiguration];
    [[TestDetails sharedInstance] startTestWithShoeType:[scShoeType titleForSegmentAtIndex:[scShoeType selectedSegmentIndex]] FloorType:[scFloorType titleForSegmentAtIndex:[scFloorType selectedSegmentIndex]] Sensors:[scSensors titleForSegmentAtIndex:[scSensors selectedSegmentIndex]]];
    [self performSegueWithIdentifier:@"startTest" sender:nil];
}

#pragma mark - CBCentralManager Delegate
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if(central.state == CBCentralManagerStateUnsupported)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth Smart Not Supported!" message:@"Your Device does not support Bluetooth Smart. Please switch to iPhone 4S or a later model." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        
    }
    else if(central.state == CBCentralManagerStateUnauthorized)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth Smart Not Authorized!" message:@"App not authoirzed to use Bluetooth Smart. Please Enable App's Bluetooh Access in 'Settings'." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else if(central.state != CBCentralManagerStatePoweredOn)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Bluetooth Issues!" message:@"Please turn on Bluetooth" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    else
    {
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Found a BLE Device: %@",peripheral);
    
    /* iOS 6.0 bug workaround : connect to device before displaying UUID !
     The reason for this is that the CFUUID .UUID property of CBPeripheral
     here is null the first time an unkown (never connected before in any app)
     peripheral is connected. So therefore we connect to all peripherals we find.
     */
    
    peripheral.delegate = self;
    [central connectPeripheral:peripheral options:nil];
    
    [self.nDevices addObject:peripheral];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [peripheral discoverServices:nil];
}

#pragma mark - CBPeripheral Delegate

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    BOOL replace = NO;
    BOOL found = NO;
    NSLog(@"Services Scanned");
    
    [self.manager cancelPeripheralConnection:peripheral];
    for(CBService *s in peripheral.services)
    {
        NSLog(@"Service found: %@",s.UUID);
        if([s.UUID isEqual:[CBUUID UUIDWithString:@"F000AA00-0451-4000-B000-000000000000"]])
        {
            NSLog(@"This is SensorTag!");
            found = YES;
        }
    }
    
    if(found)
    {
        //Match if we have this device from before
        for(int ii=0;ii<self.sensorTags.count;ii++)
        {
            CBPeripheral *p = [self.sensorTags objectAtIndexedSubscript:ii];
            if([p isEqual:peripheral])
            {
                [self.sensorTags replaceObjectAtIndex:ii withObject:peripheral];
                replace = YES;
            }
        }
        if(!replace)
        {
            [self.sensorTags addObject:peripheral];
        }
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didUpdateNotificationStateForCharacteristic %@ error = %@",characteristic,error);
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"didWriteValueForCharacteristic %@ error = %@",characteristic,error);
}

#pragma mark - SensorTag configuration
-(NSMutableDictionary *) makeSensorTagConfiguration
{
    //We only need accelerometer and Gyroscope so only set up these two and make the other inactive (active = 0)
    
    NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
    // First we set ambient temperature
    [d setValue:@"0" forKey:@"Ambient temperature active"];
    // Then we set IR temperature
    [d setValue:@"0" forKey:@"IR temperature active"];
    
    // Then we setup the accelerometer
    
    [d setValue:@"1" forKey:@"Accelerometer active"];
    [d setValue:@"F000AA10-0451-4000-B000-000000000000"  forKey:@"Accelerometer service UUID"];
    [d setValue:@"F000AA11-0451-4000-B000-000000000000"  forKey:@"Accelerometer data UUID"];
    [d setValue:@"F000AA12-0451-4000-B000-000000000000"  forKey:@"Accelerometer config UUID"];
    [d setValue:@"F000AA13-0451-4000-B000-000000000000"  forKey:@"Accelerometer period UUID"];
    
    //Then we setup the rH sensor
    [d setValue:@"0" forKey:@"Humidity active"];
    
    //Then we setup the magnetometer
    [d setValue:@"0" forKey:@"Magnetometer active"];
    [d setValue:@"500" forKey:@"Magnetometer period"];
    
    //Then we setup the barometric sensor
    [d setValue:@"0" forKey:@"Barometer active"];
    
    [d setValue:@"1" forKey:@"Gyroscope active"];
    [d setValue:@"F000AA50-0451-4000-B000-000000000000" forKey:@"Gyroscope service UUID"];
    [d setValue:@"F000AA51-0451-4000-B000-000000000000" forKey:@"Gyroscope data UUID"];
    [d setValue:@"F000AA52-0451-4000-B000-000000000000" forKey:@"Gyroscope config UUID"];
    [d setValue:@"F000AA53-0451-4000-B000-000000000000" forKey:@"Gyroscope period UUID"];
    
    NSLog(@"%@",d);
    
    return d;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue destinationViewController] isKindOfClass:[TestViewController class]])
    {
        TestViewController *testController = [segue destinationViewController];
        testController.devices = device;
    }
}

@end
