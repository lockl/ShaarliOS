//
// ShaarliMTest.m
// ShaarliOS
//
// Created by Marcus Rohrmoser on 19.07.15.
// Copyright (c) 2015 Marcus Rohrmoser. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XCTestCase+Tools.h"
#import "ShaarliM.h"

#define M_FORM @"form"
#define F_TOKEN @"token"
#define M_HAS_LOGOUT @"has_logout"

NSDictionary *parseShaarliHtml(NSData *data, NSError **error);

@interface ShaarliM() <NSURLSessionDataDelegate>
@property (strong, nonatomic) NSURL *endpointUrl;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *passWord;
@property (assign, nonatomic) BOOL privateDefault;
@end


@interface ShaarliMTest : XCTestCase
@end

@implementation ShaarliMTest


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


-(void)_testPostData
{
    NSDictionary *d = @ {
        @"key0" : @"val ue",
        @"key1" : @"val?ue",
        @"key2" : @"val&ue",
    };
    XCTAssertEqualObjects(@"key2=val%26ue&key1=val%3Fue&key0=val%20ue", [[NSString alloc] initWithData:[d postData] encoding:NSUTF8StringEncoding], @"");
}


-(void)testStringByStrippingTags
{
    NSMutableArray *a = [NSMutableArray arrayWithCapacity:10];
    {
        [a removeAllObjects];
        XCTAssertEqualObjects(@"", [@"" stringByStrippingTags:a], @"");
        XCTAssertEqual(0, a.count, @"");
    }
    {
        [a removeAllObjects];
        XCTAssertEqualObjects(@" \n ", [@" \n " stringByStrippingTags:a], @"");
        XCTAssertEqual(0, a.count, @"");
    }
    {
        [a removeAllObjects];
        XCTAssertEqualObjects(@"", [@"  #ShaarliOS  " stringByStrippingTags:a], @"");
        XCTAssertEqual(1, a.count, @"");
        XCTAssertEqualObjects(@"ShaarliOS", a[0], @"");
    }
    {
        [a removeAllObjects];
        XCTAssertEqualObjects(@" foo", [@" foo #ShaarliOS #b  #c ##d " stringByStrippingTags:a], @"");
        XCTAssertEqual(4, a.count, @"");
        XCTAssertEqualObjects(@"ShaarliOS", a[0], @"");
        XCTAssertEqualObjects(@"b", a[1], @"");
        XCTAssertEqualObjects(@"c", a[2], @"");
        XCTAssertEqualObjects(@"#d", a[3], @"");
    }
}


-(void)testHttpGetParams
{
    NSURL *url = [NSURL URLWithString:@"http://links.mro.name/?post=http%3A%2F%2Fww.heise.de%2Fa&title=Ti+tle&description=Des%20crip%20tio=n&source=http%3A%2F%2Fapp.mro.name%2FShaarliOS"];
    NSDictionary *p = [url dictionaryWithHttpFormUrl];
    XCTAssertEqual(4, p.count, @"");
    XCTAssertEqualObjects(@"http://ww.heise.de/a", p[@"post"], @"");
    XCTAssertEqualObjects(@"Ti tle", p[@"title"], @"");
    XCTAssertEqualObjects(@"Des crip tio=n", p[@"description"], @"");
    XCTAssertEqualObjects(@"http://app.mro.name/ShaarliOS", p[@"source"], @"");

    XCTAssertEqualObjects(@"Des%20crip%20tion", [@"Des crip tion" stringByAddingPercentEscapesForHttpFormUrl], @"hu");

    p = @ {
        @"descr=iption" : @"Des crip tion"
    };
    XCTAssertEqualObjects(@"descr%3Diption=Des%20crip%20tion", [p stringByAddingPercentEscapesForHttpFormUrl], @"hu");
}


-(void)testParseShaarliHtml
{
    {
        NSDictionary *ret = parseShaarliHtml([self dataWithContentsOfFixture:@"testLogin.ok" withExtension:@"html"], nil);
        // MRLogD(@"%@", ret, nil);
        XCTAssertEqual(4, ret.count, @"entries' count");
        XCTAssertEqualObjects(@ (1), ret[M_HAS_LOGOUT], @"");
        XCTAssertEqualObjects(@"links.mro", ret[@"title"], @"");
        XCTAssertNotNil(ret[@"headerform"], @"");
        XCTAssertEqual(5, [ret[M_FORM] count], @"entries' count");
        XCTAssertEqualObjects(@"20150715_200440", ret[M_FORM][@"edit_link"], @"");
        XCTAssertEqualObjects(@"20150715_200440", ret[M_FORM][@"lf_linkdate"], @"");
        XCTAssertEqualObjects(@"", ret[M_FORM][@"searchtags"], @"");
        XCTAssertEqualObjects(@"", ret[M_FORM][@"searchterm"], @"");
        XCTAssertEqualObjects(@"6ff77552e09da9ef31e0e9d0b717da8933f68975", ret[M_FORM][@"token"], @"");
    }
    {
        NSDictionary *ret = parseShaarliHtml([self dataWithContentsOfFixture:@"testLogin.0" withExtension:@"html"], nil);
        // MRLogD(@"%@", ret, nil);
        XCTAssertEqual(3, ret.count, @"entries' count");
        XCTAssertEqualObjects(@"links.mro", ret[@"title"], @"");
        XCTAssertNotNil(ret[@"headerform"], @"");
        XCTAssertEqual(2, [ret[M_FORM] count], @"entries' count");
        XCTAssertEqualObjects(@"http://links.mro.name/", ret[M_FORM][@"returnurl"], @"");
        XCTAssertEqualObjects(@"20119241badf78a3dcfa55ae58eab429a5d24bad", ret[M_FORM][@"token"], @"");
    }
    {
        NSDictionary *ret = parseShaarliHtml([self dataWithContentsOfFixture:@"05.addlink-1" withExtension:@"html"], nil);
        // MRLogD(@"%@", ret, nil);
        XCTAssertEqual(4, ret.count, @"entries' count");
        XCTAssertEqualObjects(@"links.mro", ret[@"title"], @"");
        XCTAssertEqualObjects(@ (YES), ret[M_HAS_LOGOUT], @"");
        XCTAssertNotNil(ret[@"headerform"], @"");
        XCTAssertEqual(0, [ret[M_FORM] count], @"entries' count");
    }
    {
        NSDictionary *ret = parseShaarliHtml([self dataWithContentsOfFixture:@"05.addlink-2" withExtension:@"html"], nil);
        // MRLogD(@"%@", ret, nil);
        XCTAssertEqual(3, ret.count, @"entries' count");
        XCTAssertEqualObjects(@"links.mro", ret[@"title"], @"");
        XCTAssertEqualObjects(@ (YES), ret[M_HAS_LOGOUT], @"");
        XCTAssertEqual(8, [ret[M_FORM] count], @"entries' count");
        XCTAssertEqualObjects(@"Cancel", ret[M_FORM][@"cancel_edit"], @"");
        XCTAssertEqualObjects(@"20150719_173950", ret[M_FORM][@"lf_linkdate"], @"");
        XCTAssertEqualObjects(@"", ret[M_FORM][@"lf_tags"], @"");
        XCTAssertEqualObjects(@"Note: ", ret[M_FORM][@"lf_title"], @"");
        XCTAssertEqualObjects(@"?tgI8rw", ret[M_FORM][@"lf_url"], @"");
        XCTAssertEqualObjects(@"http://links.mro.name/?do=login&post=", ret[M_FORM][@"returnurl"], @"");
        XCTAssertEqualObjects(@"Save", ret[M_FORM][@"save_edit"], @"");
        XCTAssertEqualObjects(@"e90b4ab4846c221880872003ba47859183da4e6e", ret[M_FORM][@"token"], @"");
    }
    {
        NSDictionary *ret = parseShaarliHtml([self dataWithContentsOfFixture:@"banned" withExtension:@"html"], nil);
        // MRLogD(@"%@", ret, nil);
        XCTAssertEqual(2, ret.count, @"entries' count");
        XCTAssertEqualObjects(@"links.mro", ret[@"title"], @"");
        XCTAssertEqualObjects(@"You have been banned from login after too many failed attempts. Try later.", ret[@"headerform"], @"");
        XCTAssertEqual(0, [ret[M_FORM] count], @"entries' count");
    }
}


-(void)testParseHtmlTags
{
    NSDictionary *ret = parseShaarliHtml([self dataWithContentsOfFixture:@"03.tagcloud" withExtension:@"html"], nil);
    // MRLogD(@"%@", ret, nil);
    XCTAssertEqual(2, ret.count, @"entries' count");
    XCTAssertEqualObjects(@"links.mro", ret[@"title"], @"");
    NSArray *tags = ret[@"tags"];
    MRLogD(@"%@", tags, nil);
    XCTAssertEqual(1794, tags.count, @"");
    {
        NSArray *sorted = [tags sortedArrayUsingComparator:^NSComparisonResult (NSDictionary * t1, NSDictionary * t2) {
                               const NSComparisonResult r0 = [t2[@"count"] compare:t1[@"count"]];
                               if( r0 != NSOrderedSame )
                                   return r0;
                               return [t1[@"label"] compare:t2[@"label"] options:0];
                           }
                          ];
        XCTAssertEqualObjects (@"Software", [sorted firstObject][@"label"], @"");
        XCTAssertEqualObjects (@ (170), [sorted firstObject][@"count"], @"");

        XCTAssertEqualObjects (@"§99StGB", [sorted lastObject][@"label"], @"");
        XCTAssertEqualObjects (@ (1), [sorted lastObject][@"count"], @"");
    }
}


@end
