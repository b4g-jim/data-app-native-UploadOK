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
    self.testInfo = [NSMutableArray array];
    self.dataPoints = [NSMutableArray array];

    NSDictionary *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"personalInfo"];
    
    NSString *test_date = [self getFormattedTimestamp:NO];
    NSString *tester_id = [data objectForKey:@"number"];
    self.test_id = [tester_id stringByAppendingString:test_date];
    int update_interval = [[[NSUserDefaults standardUserDefaults] objectForKey:@"updateRate"] intValue];
    
    [self.testInfo setValue:test_date forKey:@"test_date"];
    [self.testInfo setValue:tester_id forKey:@"tester_id"];
    [self.testInfo setValue:self.test_id forKey:@"test_id"];
    [self.testInfo setValue:[data objectForKey:@"name"] forKey:@"tester_name"];
//    [self.testInfo setValue:@"Smith" forKey:@"tester_lastname"];
    [self.testInfo setValue:[data objectForKey:@"gender"] forKey:@"gender"];
    [self.testInfo setValue:@"30" forKey:@"age"];
    [self.testInfo setValue:[data objectForKey:@"height"] forKey:@"height"];
    [self.testInfo setValue:[data objectForKey:@"hipHeight"] forKey:@"hip_height"];
    [self.testInfo setValue:[data objectForKey:@"weight"] forKey:@"weight"];
    [self.testInfo setValue:shoeType forKey:@"shoe_type"];
    [self.testInfo setValue:floorType forKey:@"floor_type"];
    [self.testInfo setValue:sensors forKey:@"sensor_location"];
    [self.testInfo setValue:@"1.0" forKey:@"sensor_sw"];
    [self.testInfo setValue:[NSString stringWithFormat:@"%d",1000/update_interval] forKey:@"sensor_frequency"];
}

-(NSString*)endTest
{
    NSMutableArray *allData = [NSMutableArray array];
    [self.testInfo setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[self.dataPoints count]] forKey:@"number_data_points"];
    
    NSDictionary *dataPointsDictInArray = [NSDictionary dictionaryWithObject:self.dataPoints forKey:@"data_points"];
    [allData addObject:self.testInfo];
    [allData addObject:dataPointsDictInArray];

    NSString *jsonStr = [[self getPrettyPrintedJSONforObject:allData] stringByReplacingOccurrencesOfString:@"-" withString:@"\""];
    return [self stripExtraQuotes:jsonStr];
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

-(NSString*)stripExtraQuotes:(NSString*)string
{
    return [string stringByReplacingOccurrencesOfString:@"\"\"" withString:@"\""];
}



@end
