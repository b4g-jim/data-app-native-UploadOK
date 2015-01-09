//
//  TestDetails.h
//  Balance4Good
//
//  Created by Hira Daud on 11/21/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSMutableArray+KeyValuePairs.h"
@interface TestDetails : NSObject

@property (strong,nonatomic) NSMutableArray *testInfo;
@property (strong,nonatomic) NSMutableArray *dataPoints;
@property (strong,nonatomic) NSString *test_id;

+(TestDetails*)sharedInstance;

-(void)startTestWithShoeType:(NSString*)shoeType FloorType:(NSString*)floorType Sensors:(NSString*)sensors;
-(NSString*)endTest;
-(NSString*)getFormattedTimestamp:(BOOL)getMilliseconds;

@end
