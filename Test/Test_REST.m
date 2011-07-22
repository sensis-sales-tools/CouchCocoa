//
//  Test_REST.m
//  Test REST
//
//  Created by Jens Alfke on 6/10/11.
//  Copyright 2011 Couchbase, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import "RESTResource.h"
#import "RESTBody.h"
#import "RESTInternal.h"

#import <SenTestingKit/SenTestingKit.h>


// HTTP resources to test GETs of. These assume a CouchDB server is running on localhost. */
static NSString* const kParentURL = @"http://127.0.0.1:5984/_utils";
static NSString* const kChildPath = @"image/logo.png";
static NSString* const kChildURL = @"http://127.0.0.1:5984/_utils/image/logo.png";


@interface Test_REST : SenTestCase
@end


@implementation Test_REST

- (void)setUp
{
    [super setUp];
    
    gRESTWarnRaisesException = YES;
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testBasicGet
{
    // Test a root resource:
    NSURL* url = [NSURL URLWithString: kParentURL];
    RESTResource* parent = [[[RESTResource alloc] initWithURL: url] autorelease];
    STAssertEqualObjects(parent.URL, url, @"Server URL property is wrong");
    STAssertEqualObjects(parent.parent, nil, @"Server parent property is wrong");
    STAssertEqualObjects(parent.relativePath, nil, @"Server relativePath property is wrong");
    
    // Test child resource:
    RESTResource* child = [[[RESTResource alloc] initWithParent: parent relativePath: kChildPath] autorelease];
    STAssertEqualObjects(child.parent, parent, @"Child parent property is wrong");
    STAssertEqualObjects(child.relativePath, kChildPath, @"Child relativePath property is wrong");
    STAssertEqualObjects(child.URL, [NSURL URLWithString: kChildURL], nil);

    // Test GET:
    RESTOperation* op = [child GET];
    STAssertNotNil(op, @"Failed to create RESTOperation");
    NSLog(@"Created %@:\n%@", op, op.dump);
    __block BOOL completeBlockCalled = NO;
    [op onCompletion: ^{ completeBlockCalled = YES; NSLog(@"Oncompletion!!"); }];
    NSLog(@"About to wait...");
    STAssertTrue([op wait], @"Failed to GET: %@", op.error);
    NSLog(@"Got it: %@\n%@", op, op.dump);
    STAssertTrue(completeBlockCalled, @"onComplete block was not called");
    
    // Test caching:
    STAssertTrue([child cacheResponse: op], @"Should be cacheable");
    NSLog(@"ETag = %@, lastModified = %@", child.eTag, child.lastModified);
    //STAssertNotNil(child.eTag, @"Failed to get eTag");
    STAssertNotNil(child.lastModified, @"Failed to get lastModified");
}

- (void) testEntityHeaders {
    NSDictionary* headers = [NSDictionary dictionaryWithObjectsAndKeys:
                             @"FooServ", @"Server",
                             @"image/jpeg", @"Content-Type",
                             @"abcdefg", @"Etag", nil];
    NSDictionary* expectedEntityHeaders = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"image/jpeg", @"Content-Type",
                                           @"abcdefg", @"Etag", nil];
    NSDictionary* emptyHeaders = [NSDictionary dictionary];
    
    STAssertEqualObjects([RESTBody entityHeadersFrom: headers], expectedEntityHeaders, nil);
    STAssertEqualObjects([RESTBody entityHeadersFrom: expectedEntityHeaders], expectedEntityHeaders, nil);
    
    STAssertEqualObjects([RESTBody entityHeadersFrom: emptyHeaders], emptyHeaders, nil);
    
    headers = [NSDictionary dictionaryWithObjectsAndKeys:
               @"FooServ", @"Server", nil];
    STAssertEqualObjects([RESTBody entityHeadersFrom: headers], emptyHeaders, nil);
}

- (void) testEmptyBody {
    RESTBody* body = [[RESTBody alloc] init];
    STAssertEqualObjects(body.content, [NSData data], nil);
    STAssertEqualObjects(body.headers, [NSDictionary dictionary], nil);
    STAssertEqualObjects(body.contentType, nil, nil);
    STAssertEqualObjects(body.eTag, nil, nil);
    STAssertEqualObjects(body.lastModified, nil, nil);
    [body release];
}

- (void) testEmptyMutableBody {
    RESTMutableBody* body = [[RESTMutableBody alloc] init];
    STAssertEqualObjects(body.content, [NSData data], nil);
    STAssertEqualObjects(body.headers, [NSDictionary dictionary], nil);
    STAssertEqualObjects(body.contentType, nil, nil);
    STAssertEqualObjects(body.eTag, nil, nil);
    STAssertEqualObjects(body.lastModified, nil, nil);
    [body release];
}

- (void) testMutateEmptyBody {
    RESTMutableBody* body = [[RESTMutableBody alloc] init];
    NSData* data = [@"foo" dataUsingEncoding: NSUTF8StringEncoding];
    body.content = data;
    body.contentType = @"text/plain; charset=utf-8";
    STAssertEqualObjects(body.content, data, nil);
    STAssertEqualObjects(body.headers, [NSDictionary dictionaryWithObject: @"text/plain; charset=utf-8" forKey: @"Content-Type"], nil);
    STAssertEqualObjects(body.contentType, @"text/plain; charset=utf-8", nil);
    [body release];
}

@end
