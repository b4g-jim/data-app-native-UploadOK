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
#import "selectorPickerViewController.h"
#import "TypeClass.h"

@interface StartTestViewController ()

@end

@implementation StartTestViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.navigationItem setHidesBackButton:YES animated:NO];

    [self initialize];
}

//Initialize ShoeTypes, FloorTypes and Sensors. If you want to add more shoe types, you can add them here. name is what appear in the dropdown list while abbreviation appears in JSON

-(void)initialize
{
    shoeTypes = [NSMutableArray array];
    [shoeTypes addObject:[[TypeClass alloc] initWithAbbreviation:@"BRFT" name:@"barefoot"]];
    [shoeTypes addObject:[[TypeClass alloc] initWithAbbreviation:@"TRNR" name:@"trainers/jogging shoes"]];
    [shoeTypes addObject:[[TypeClass alloc] initWithAbbreviation:@"LEAT" name:@"leather sole shoes"]];
    [shoeTypes addObject:[[TypeClass alloc] initWithAbbreviation:@"HIHL" name:@"high heal shoes"]];

    floorTypes = [NSMutableArray array];
    [floorTypes addObject:[[TypeClass alloc] initWithAbbreviation:@"CARP" name:@"carpet"]];
    [floorTypes addObject:[[TypeClass alloc] initWithAbbreviation:@"WOOD" name:@"wooden floor"]];
    [floorTypes addObject:[[TypeClass alloc] initWithAbbreviation:@"HARD" name:@"tile, concrete, pavement"]];
    [floorTypes addObject:[[TypeClass alloc] initWithAbbreviation:@"EART" name:@"earth, ground"]];

    sensors = [NSMutableArray array];
    [sensors addObject:[[TypeClass alloc] initWithAbbreviation:@"ANK1" name:@"sensor on one ankle only"]];
    [sensors addObject:[[TypeClass alloc] initWithAbbreviation:@"ANK2" name:@"sensor on both ankles"]];
    [sensors addObject:[[TypeClass alloc] initWithAbbreviation:@"WST1" name:@"1 sensor at the waist"]];
    
    //load already entered note and show it in the note field
    [txtNote setText:[[NSUserDefaults standardUserDefaults] objectForKey:@"note"]];
}

// This function takes a TypeClass (defined in TypeClass.h) Array and convert it to string array (by extracting only the full name)
// This function is required for showing the names in the drop down list.

-(NSArray*)getStringArrayFromTypeClassArray:(NSArray*)array
{
    NSMutableArray *strArray = [NSMutableArray array];
    for(TypeClass *obj in array)
    {
        [strArray addObject:obj.full_name];
    }
    return strArray;
}

//Initialize Data when view appears. This means start searching for the bluetooth devices and remove the already discovered devices (and research)

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.nDevices = [[NSMutableArray alloc]init];
    self.sensorTags = [[NSMutableArray alloc]init];
    [self loadData];

    //This is required for the dropdown as it will update the selected value whenever it is changed.
    [self update];
}

//load already saved personal data and display in the corresponding labels.
-(void)loadData
{
    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"personalInfo"];
    [lbltName setText:[data objectForKey:@"name"]];
    [lbltNumber setText:[data objectForKey:@"number"]];
    [lbltHeight setText:[data objectForKey:@"height"]];
    [lbltHipHeight setText:[data objectForKey:@"hipHeight"]];
    [lblAge setText:[data objectForKey:@"age"]];
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
    //A few conditions needs to be met in case a test is started. Do not start test if any of the following conditions are met
    //1. If sensor counts is less than two and sensor type is (on both ankles (index == 1))
    //2. If sensor count is less than 1 (No sensor connected)
    //3. If all the personal info is not added
    
    if(self.sensorTags.count<2 && [[NSUserDefaults standardUserDefaults] integerForKey:@"sensors"] == 1)
    {
        [[[UIAlertView alloc] initWithTitle:@"Balance4Good" message:@"Please make sure both the sensors are connected!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    else if(self.sensorTags.count<1)
    {
        [[[UIAlertView alloc] initWithTitle:@"Balance4Good" message:@"Please make sure the sensor is connected!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
        return;
    }
    else
        if([self validatePersonalInfo])
      {
    
          //Device is to be passed to the Testing Screen (TestViewController)
          //device.peripherals have the connected sensor Tags
          //device.manager is also transferred ahead (manager is used to connect to Bluetooth Smart Devices)
          //and similarly the other data is based to startTest of TestDetails (which stores all of it for writing to JSON file at end of the exercise
          
          device = [[BLEDevice alloc] init];
          device.peripherals = self.sensorTags;
          device.manager = self.manager;
          device.setupData = [self makeSensorTagConfiguration];
          
          TypeClass *shoeType = [shoeTypes objectAtIndex:[[[NSUserDefaults standardUserDefaults] objectForKey:@"shoe_type"] intValue]];
          TypeClass *floorType = [floorTypes objectAtIndex:[[[NSUserDefaults standardUserDefaults] objectForKey:@"floor_type"] intValue]];
          TypeClass *sensor = [sensors objectAtIndex:[[[NSUserDefaults standardUserDefaults] objectForKey:@"sensors"] intValue]];

          //If we have note entered, it will be saved and stored in the JSON file as well
          
          if([[[txtNote text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] >0)
          {
              [[NSUserDefaults standardUserDefaults] setObject:[txtNote text] forKey:@"note"];
              [[NSUserDefaults standardUserDefaults] synchronize];
          }
          
          [[TestDetails sharedInstance] startTestWithShoeType:shoeType.abbreviation FloorType:floorType.abbreviation Sensors:sensor.abbreviation];
          [self performSegueWithIdentifier:@"startTest" sender:nil];
      }
}

-(BOOL)validatePersonalInfo
{
    // If Name exists, all the data will exist (We dont allow saving only 1 info on the personal settings screen
    // Either enter all the information or nothing
    NSDictionary *personalInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"personalInfo"];
    if([[personalInfo objectForKey:@"name"] length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Balance4Good" message:@"Please Fill Personal Info first" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];

        return NO;
    }

    return YES;
}

-(int)getLengthForUserDefault:(NSString*)userDefault
{
    return (unsigned int)[[[[NSUserDefaults standardUserDefaults] objectForKey:userDefault] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet] ] length];
}

#pragma mark - CBCentralManager Delegate
//Called when the Manager is initialized. It tell us whether BLE is support or not or whether it is authorized, powered on or off etc.

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
        //scan for all the devices providing any types of services
        [central scanForPeripheralsWithServices:nil options:nil];
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //Called when device is discovered
    //Connect to that device
    peripheral.delegate = self;
    [central connectPeripheral:peripheral options:nil];
    
    //add the discovered peripheral to nDevices as we currently don't know if
    [self.nDevices addObject:peripheral];
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    //Once peripheral is connected, search for its services so that we can know if it is a sensorTag or not
    [peripheral discoverServices:nil];
}

#pragma mark - CBPeripheral Delegate

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    //Once services are discovered, we need to check if it is a SensorTag and if it is a sensorTag is it already added
    //If already added it is replaced else it is added to sensorTags array
    
    BOOL replace = NO;
    BOOL found = NO;
    NSLog(@"Services Scanned");
    
    [self.manager cancelPeripheralConnection:peripheral];
    for(CBService *s in peripheral.services)
    {
        NSLog(@"Service found: %@",s.UUID);
        //This is the service UUID that tells us that the device is sensor Tag
        //We check all of the services of the peripheral/bluetooth device.
        
        if([s.UUID isEqual:[CBUUID UUIDWithString:@"F000AA00-0451-4000-B000-000000000000"]])
        {
            NSLog(@"This is SensorTag!");
            found = YES;
        }
    }
    
    if(found)
    {
        //Match if we have this device from before
        //If yes, just replace it else add it.
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
        
        //If no sensor tags are connected, both the status labels are OFF
        //If one is connected, first sensor status is ON and second is OFF
        //If both are connectd, both the sensors status are ON
        if([self.sensorTags count]==0)
        {
            [lblSensor1_status setText:@"OFF"];
            [lblSensor2_status setText:@"OFF"];
        }
        else if([self.sensorTags count] == 1)
        {
            [lblSensor1_status setText:@"ON"];
            [lblSensor2_status setText:@"OFF"];
        }
        else
        {
            [lblSensor1_status setText:@"ON"];
            [lblSensor2_status setText:@"ON"];
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
//Configuring SensorTag Device. Taken from The TI Sample Code
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

- (IBAction)cancel:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showShowTypeDropDown:(UIButton *)sender
{
    //name which is used to save/retreive the values of this dropdown
    preferenceName = @"shoe_type";
    
    [self showLister:sender names:[self getStringArrayFromTypeClassArray:shoeTypes]];

}

- (IBAction)showFloorTypeDropDown:(UIButton *)sender
{
    //name which is used to save/retreive the values of this dropdown
    preferenceName = @"floor_type";
    
    [self showLister:sender names:[self getStringArrayFromTypeClassArray:floorTypes]];

}

- (IBAction)showSensorsDropDown:(UIButton *)sender
{
    //name which is used to save/retreive the values of this dropdown
    preferenceName = @"sensors";
    
    [self showLister:sender names:[self getStringArrayFromTypeClassArray:sensors]];

}

#pragma mark - DropDown

//Shows dropdown
-(void)showLister:(id)sender names:(NSArray*)names
{
    selectorPickerViewController* selectorPVController = [[selectorPickerViewController alloc] initWithSource:names parentName:preferenceName parent:self];
    [selectorPVController.view setFrame:self.view.bounds];
    [self addChildViewController:selectorPVController];
    [self.view addSubview:selectorPVController.view];
}

//Called when the values of a dropdown are changed to reflect for the changes
-(void)update
{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"shoe_type"])
    {
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"shoe_type"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"floor_type"];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"sensors"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    int type = [[[NSUserDefaults standardUserDefaults] objectForKey:@"shoe_type"] intValue];
    TypeClass *shoeType = [shoeTypes objectAtIndex:type];
    [txtShoeType setText:shoeType.full_name];
    
    type = [[[NSUserDefaults standardUserDefaults] objectForKey:@"floor_type"] intValue];
    TypeClass *floorType = [floorTypes objectAtIndex:type];
    [txtFloorType setText:floorType.full_name];
    
    type = [[[NSUserDefaults standardUserDefaults] objectForKey:@"sensors"] intValue];
    TypeClass *sensor = [sensors objectAtIndex:type];
    [txtSensorType setText:sensor.full_name];
}


-(IBAction)keyboardDidAppear
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
}


-(void)done
{
    if([[[txtNote text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] >0)
    {
        [[NSUserDefaults standardUserDefaults] setObject:[txtNote text] forKey:@"note"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self.view endEditing:YES];
    self.navigationItem.rightBarButtonItem = nil;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
// Called when a segue is called to switch from current view controller to the next one
// we are passing the device data (sensorTags, manager etc.) to the TestViewController devices so that they can be used there

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
