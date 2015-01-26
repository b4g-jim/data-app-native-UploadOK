//
//  TestDetails.h
//  Balance4Good
//
//  Created by Hira Daud on 11/21/14.
//  Copyright (c) 2014 Hira Daud. All rights reserved.
//

// Class For Storing Test Data

#import <Foundation/Foundation.h>

@interface TestDetails : NSObject

@property (strong,nonatomic) NSMutableDictionary *testInfo;
@property (strong,nonatomic) NSMutableArray *dataPoints;
@property (strong,nonatomic) NSString *test_id;

+(TestDetails*)sharedInstance;

-(void)startTestWithShoeType:(NSString*)shoeType FloorType:(NSString*)floorType Sensors:(NSString*)sensors;
-(NSString*)endTest;
-(NSString*)getFormattedTimestamp:(BOOL)getMilliseconds;

-(NSString*)getDataFolderPath;
@end
