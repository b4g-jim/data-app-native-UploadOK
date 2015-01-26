//
//  TestDetails.m
//  Balance4Good
//
//  Created by Hira Daud on 11/21/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import "TestDetails.h"

@implementation TestDetails

+(TestDetails*)sharedInstance
{
    static TestDetails *myDefaults = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        myDefaults = [[self alloc] init];
    });
    
    return myDefaults;
    
}

-(void)startTestWithShoeType:(NSString *)shoeType FloorType:(NSString *)floorType Sensors:(NSString *)sensors
{
    //testInfo stores information about the tester
    
    self.testInfo = [NSMutableDictionary dictionary];
    self.dataPoints = [NSMutableArray array];

    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"personalInfo"];
    
    NSString *test_date = [self getFormattedTimestamp:NO];
    NSString *tester_id = [data objectForKey:@"number"];
    self.test_id = [tester_id stringByAppendingString:test_date];
    int update_interval = [[[NSUserDefaults standardUserDefaults] objectForKey:@"updateRate"] intValue];

    [self.testInfo setObject:test_date forKey:@"test_date"];
    [self.testInfo setObject:tester_id forKey:@"tester_id"];
    [self.testInfo setObject:self.test_id forKey:@"test_id"];
    [self.testInfo setObject:[data objectForKey:@"name"] forKey:@"tester_name"];
    [self.testInfo setObject:[data objectForKey:@"gender"] forKey:@"gender"];
    [self.testInfo setObject:[data objectForKey:@"age"] forKey:@"age"];
    [self.testInfo setObject:[data objectForKey:@"height"] forKey:@"height"];
    [self.testInfo setObject:[data objectForKey:@"hipHeight"] forKey:@"hip_height"];
    [self.testInfo setObject:[data objectForKey:@"weight"] forKey:@"weight"];
    [self.testInfo setObject:shoeType forKey:@"shoe_type"];
    [self.testInfo setObject:floorType forKey:@"floor_type"];
    [self.testInfo setObject:sensors forKey:@"sensor_location"];
    [self.testInfo setObject:@"1.0" forKey:@"sensor_sw"];

    //If note exists, include it in the testInfo otherwise ignore it
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"note"])
        [self.testInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"note"] forKey:@"note"];
    
    //setting update frequency which is 1/(time in second) but since we are storing time as millisecond
    //so we have 1000/(time in seconds)
    
    [self.testInfo setObject:[NSString stringWithFormat:@"%d",1000/update_interval] forKey:@"sensor_frequency"];
}

-(NSString*)endTest
{
    //data points are added to testInfo
    NSMutableArray *allData = [NSMutableArray array];
    [self.testInfo setObject:[NSString stringWithFormat:@"%lu",(unsigned long)[self.dataPoints count]] forKey:@"number_data_points"];
    
    //Data points is inclosed in dictionary so that we can get the data_points label
    //both the data points dictionary and testinfo is added to the allData which is then converted to JSON
    
    NSDictionary *dataPointsDictInArray = [NSDictionary dictionaryWithObject:self.dataPoints forKey:@"data_points"];
    [allData addObject:self.testInfo];
    [allData addObject:dataPointsDictInArray];

    NSString *jsonStr = [self getPrettyPrintedJSONforObject:allData];
    return jsonStr;
}

-(NSString*) getPrettyPrintedJSONforObject:(id)obj
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:obj
                                                       options:(NSJSONWritingOptions)    (NSJSONWritingPrettyPrinted)
                                                         error:&error];
    
    if (! jsonData)
    {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}



-(NSString*)getFormattedTimestamp:(BOOL)getMilliseconds
{
    NSDate *date = [NSDate date];
    NSTimeInterval timeInterval = [date timeIntervalSince1970];
    int milliseconds = (timeInterval - (int)timeInterval) * 1000;
    int tenthOfMilliseconds = milliseconds;
    
    //Generating timestamp (TimeZone: GMT)
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    if(getMilliseconds)
    {
        NSString *timestamp = [[formatter stringFromDate:date] stringByAppendingFormat:@".%3d",tenthOfMilliseconds];
        return [timestamp stringByReplacingOccurrencesOfString:@" " withString:@"0"];
    }
    else
    {
        return [formatter stringFromDate:date];
    }
}

//To get the path for the Saved_Data folder which is used to store the saved JSON files on the phone
-(NSString*)getDataFolderPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/Saved_Data"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:nil];
    
    return dataPath;
}


@end
