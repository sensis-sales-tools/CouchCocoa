//
//  CouchReplication.h
//  CouchCocoa
//
//  Created by Jens Alfke on 8/15/11.
//  Copyright (c) 2011 Couchbase, Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file
//  except in compliance with the License. You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//  Unless required by applicable law or agreed to in writing, software distributed under the
//  License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND,
//  either express or implied. See the License for the specific language governing permissions
//  and limitations under the License.
//

#import <Foundation/Foundation.h>
@class CouchDatabase, RESTOperation;


typedef enum {
    kCouchReplicationStopped,
    kCouchReplicationOffline,
    kCouchReplicationIdle,
    kCouchReplicationActive
} CouchReplicationMode;


/** Tracks a CouchDB replication. Can be used to observe its progress. */
@interface CouchReplication : NSObject
{
    CouchDatabase* _database;
    NSURL* _remote;
    bool _pull, _createTarget, _continuous;
    NSString* _filter;
    NSDictionary* _filterParams;
    NSDictionary* _options;
    NSDictionary* _headers;
    NSDictionary* _oauth;
    BOOL _running;
    NSString* _taskID;
    NSString* _status;
    unsigned _completed, _total;
    CouchReplicationMode _mode;
    NSError* _error;
    NSArray* _currentRequests;
}

/** The local database being replicated to/from. */
@property (nonatomic, readonly) CouchDatabase* localDatabase;

/** The URL of the remote database. */
@property (nonatomic, readonly) NSURL* remoteURL;

/** Does the replication pull from (as opposed to push to) the target? */
@property (nonatomic, readonly) bool pull;

/** Should the target database be created if it doesn't already exist? (Defaults to NO). */
@property (nonatomic) bool createTarget;

/** Should the replication operate continuously, copying changes as soon as the source database is modified? (Defaults to NO). */
@property (nonatomic) bool continuous;

/** Path of an optional filter function to run on the source server.
    Only documents for which the function returns true are replicated.
    The path looks like "designdocname/filtername". */
@property (nonatomic, copy) NSString* filter;

/** Parameters to pass to the filter function.
    Should be a JSON-compatible dictionary. */
@property (nonatomic, copy) NSDictionary* filterParams;

/** Extra HTTP headers to send in all requests to the remote server.
    Should map strings (header names) to strings. */
@property (nonatomic, copy) NSDictionary* headers;

/** OAuth parameters that the replicator should use when authenticating to the remote database.
    Keys in the dictionary should be "consumer_key", "consumer_secret", "token", "token_secret", and optionally "signature_method". */
@property (nonatomic, copy) NSDictionary* OAuth;

/** Other options to be provided to the replicator.
    These will be added to the JSON body of the POST to /_replicate. */
@property (nonatomic, copy) NSDictionary* options;


/** Starts the replication, asynchronously.
    @return  The operation to start replication, or nil if replication is already started. */
- (RESTOperation*) start;

/** Stops replication, asynchronously. */
- (void) stop;

@property (nonatomic, readonly) BOOL running;
@property (nonatomic, readonly, getter = wasManuallyStopped) BOOL manuallyStopped;

/** The current status string from the server, if active, else nil (observable).
    Usually of the form "Processed 123 / 123 changes". */
@property (nonatomic, readonly, copy) NSString* status;

/** The number of completed changes processed, if the task is active, else 0 (observable). */
@property (nonatomic, readonly) unsigned completed;

/** The total number of changes to be processed, if the task is active, else 0 (observable). */
@property (nonatomic, readonly) unsigned total;

@property (nonatomic, readonly, retain) NSError* error;

@property (nonatomic, readonly) CouchReplicationMode mode;

@property (nonatomic, readonly) NSArray* currentRequests;

@end
