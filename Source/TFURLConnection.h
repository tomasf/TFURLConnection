//
//  TFURLConnection.h
//  TFUC
//
//  Created by Tomas Franzén on 2011-06-13.
//  Copyright 2011 Lighthead Software. All rights reserved.
//

@interface TFURLConnection : NSObject {
	NSMutableURLRequest *request;
}

- (id)initWithURLRequest:(NSURLRequest*)req;

+ (id)connectionWithURL:(NSURL*)URL;
+ (id)connectionWithURLFormat:(NSString*)format, ...;

- (void)addValue:(NSString*)value forHTTPHeaderField:(NSString*)field;

- (void)startWithOutputKind:(Class)outputClass completionHandler:(void(^)(id output, NSURLResponse *response))block;
- (void)start;
- (void)cancel;


@property(copy) void(^completionHandler)(id output, NSURLResponse *response);
@property(copy) void(^errorHandler)(NSError *error); // optional. if nil, completionHandler gets a nil output and response
@property(copy) void(^dataHandler)(NSData *chunk); // optional. if set, completionHandler gets a nil output (collect data manually)
@property(copy) void(^authenticationHandler)(NSURLAuthenticationChallenge *challenge); // optional

@property(assign) Class outputKind; // class of output passed to completionHandler. nil = NSData. must respond to -initWithData:, -initWithData:encoding: or +TFUC_objectWithData:response:

@property(copy) NSString *HTTPMethod;
@property(copy) NSData *HTTPBody;
@end


@protocol TFURLConnectionOutput
+ (id)TFUC_objectWithData:(NSData*)data response:(NSURLResponse*)response;
@end