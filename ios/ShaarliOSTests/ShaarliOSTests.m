//
// ShaarliOSTests.m
// ShaarliOSTests
//
// Created by Marcus Rohrmoser on 18.03.15.
// Copyright (c) 2015 Marcus Rohrmoser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface ShaarliOSTests : XCTestCase

@end

@implementation ShaarliOSTests

-(void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}


-(void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


-(void)testExample
{
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}


-(void)testPerformanceExample
{
    // This is an example of a performance test case.
    [self measureBlock:^{
         // Put the code you want to measure the time of here.
     }
    ];
}


@end
