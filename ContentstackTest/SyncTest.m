//
//  SyncTest.m
//  ContentstackTest
//
//  Created by Uttam Ukkoji on 04/07/18.
//  Copyright © 2018 Contentstack. All rights reserved.
//

#import "SyncTest.h"
#import <Contentstack/Contentstack.h>
#import <XCTest/XCTest.h>

static NSInteger kRequestTimeOutInSeconds = 400;

@interface SyncTest() {
    Stack *csStack;
    Config *config;
}
@end

@implementation SyncTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
//    config = [[Config alloc] init];
//    config.host = /*@"cdn.contentstack.io";//@"stagcontentstack.global.ssl.fastly.net";//*/@"dev-cdn.contentstack.io";
//    csStack = [Contentstack stackWithAPIKey:@"blt12c8ad610ff4ddc2" accessToken:@"blt43359585f471685188b2e1ba" environmentName:@"env1" config:config];
    Config *_config = [[Config alloc] init];
    _config.host = @"dev-new-api.contentstack.io";//@"stagcontentstack.global.ssl.fastly.net";//@"dev-cdn.contentstack.io";
    
    csStack = [Contentstack stackWithAPIKey:@"blt3095c4e04a3d69e6" accessToken:@"bltd4c70163cb65d8e2" environmentName:@"web" config:_config];

//    _productUid = @"blt04fe803db48a65a3";
}

- (void)waitForRequest {
    [self waitForExpectationsWithTimeout:kRequestTimeOutInSeconds handler:^(NSError *error) {
        if (error) {
            XCTFail(@"Could not perform operation (Timed out) ~ ERR: %@", error.userInfo);
        }
    }];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSync {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Sync"];
    [csStack sync:^(SyncStack * _Nullable syncResult, NSError * _Nullable error) {
        if (syncResult.syncToken != nil) {
            [expectation fulfill];
        }
    }];
    
    [self waitForRequest];
}

- (void)testSyncToken {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Sync"];
    [csStack syncToken:@"blt5c2acb07cc97a34231bbb0" completion:^(SyncStack * _Nullable syncStack, NSError * _Nullable error) {
        if (syncStack.syncToken != nil) {
            [expectation fulfill];
        }
    }];
    [self waitForRequest];
}

- (void)testSyncFromDate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncFromDate"];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1534617000];
    
    [csStack syncFrom:date completion:^(SyncStack * _Nullable syncResult, NSError * _Nullable error) {
        for (NSDictionary *item in syncResult.items) {
            if ([[item objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = [item objectForKey:@"data"];
                ContentType *contentType = [csStack contentTypeWithName:[data objectForKey:@"content_type_uid"]];
                if ([data objectForKey:@"uid"] != nil && [[data objectForKey:@"uid"] isKindOfClass:[NSString class]]) {
                    Entry *entry = [contentType entryWithUID:[data objectForKey:@"uid"]];
                    [entry configureWithDictionary:data];
                    XCTAssertLessThanOrEqual(date, entry.updatedAt);
                }
            }
        }
        [expectation fulfill];
    }];
    [self waitForRequest];
}

- (void)testSyncPublishType {
    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncOnlyClass"];
    [csStack syncPublishType:(ENTRY_DELETED) completion:^(SyncStack * _Nullable syncStack, NSError * _Nullable error) {
        [expectation fulfill];
    }];
    [self waitForRequest];
}

- (void)testSyncOnlyClass {
    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncOnlyClass"];
    [csStack syncOnly:@"session" completion:^(SyncStack * _Nullable syncResult, NSError * _Nullable error) {
        [expectation fulfill];
    }];
    [self waitForRequest];
}

-(void)testSyncOnlyWithLocale {
    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncOnlyWithLocale"];
    [csStack syncOnly:@"session" locale:ENGLISH_UNITED_STATES from:nil completion:^(SyncStack * _Nullable syncStack, NSError * _Nullable error) {
        [expectation fulfill];
        
    }];
    [self waitForRequest];
}

- (void)testSyncOnlyClassAndDate {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:1534617000];

    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncOnlyClassAndDate"];
    [csStack syncOnly:@"session" from:date completion:^(SyncStack * _Nullable syncResult, NSError * _Nullable error) {
        for (NSDictionary *item in syncResult.items) {
            if ([[item objectForKey:@"data"] isKindOfClass:[NSDictionary class]]) {
                NSDictionary *data = [item objectForKey:@"data"];
                ContentType *contentType = [csStack contentTypeWithName:[data objectForKey:@"content_type_uid"]];
                if ([data objectForKey:@"uid"] != nil && [[data objectForKey:@"uid"] isKindOfClass:[NSString class]]) {
                    Entry *entry = [contentType entryWithUID:[data objectForKey:@"uid"]];
                    [entry configureWithDictionary:data];
                    XCTAssertLessThanOrEqual(date, entry.updatedAt);
                }
            }
        }
        [expectation fulfill];
    }];
    [self waitForRequest];
}

-(void)testSyncLocal {
    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncLocal"];
    [csStack syncLocale:GERMEN_SWITZERLAND completion:^(SyncStack * _Nullable syncResult, NSError * _Nullable error) {
        [expectation fulfill];
    }];
    [self waitForRequest];
}


-(void)testSyncLocaleWithDate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"SyncLocaleWithDate"];
    [csStack syncLocale:GERMEN_SWITZERLAND from:[NSDate date] completion:^(SyncStack * _Nullable syncResult, NSError * _Nullable error) {
        [expectation fulfill];
    }];
    [self waitForRequest];
}



@end