//
//  CouchServer.h
//  CouchCocoa
//
//  Created by Jens Alfke on 5/26/11.
//  Copyright 2011 Couchbase, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.

#import "CouchResource.h"
@class CouchDatabase, RESTCache;


/** The top level of a CouchDB server. Contains CouchDatabases. */
@interface CouchServer : CouchResource
{
    @private
    RESTCache* _dbCache;
}

/** Initialize given a server URL. */
- (id) initWithURL: (NSURL*)url;

/** Without a URL, connects to localhost on default port 5984. */
- (id) init;

/** Fetches the server's current version string. (Synchronous) */
- (NSString*) getVersion: (NSError**)outError;

/** Returns an array of unique-ID strings generated by the server. (Synchronous) */
- (NSArray*) generateUUIDs: (NSUInteger)count;

/** Returns array of CouchDatabase objects representing all the databases on the server. (Synchronous) */
- (NSArray*) getDatabases;

/** Just creates a CouchDatabase object; makes no calls to the server.
    The database doesn't need to exist (you can call -create on it afterwards to create it.)
    Multiple calls with the same name will return the same CouchDatabase instance. */
- (CouchDatabase*) databaseNamed: (NSString*)name;

@end
