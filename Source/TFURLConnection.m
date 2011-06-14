//
//  TFURLConnection.m
//  TFUC
//
//  Created by Tomas Franzén on 2011-06-13.
//  Copyright 2011 Lighthead Software. All rights reserved.
//

#import "TFURLConnection.h"

@interface TFURLConnection ()
@property(retain) NSURLConnection *connection;
@property(retain) NSMutableData *buffer;
@property(copy) NSURLResponse *response;
@end


@implementation TFURLConnection
@synthesize connection, buffer, response;
@synthesize completionHandler, errorHandler, dataHandler, authenticationHandler;
@synthesize outputKind;


- (id)initWithURLRequest:(NSURLRequest*)req {
	if(!(self = [super init])) return nil;
	request = [req mutableCopy];
	self.buffer = [NSMutableData data];
	return self;
}


+ (id)connectionWithURL:(NSURL*)URL {
	if(!URL) return nil;
	return [[[self alloc] initWithURLRequest:[NSURLRequest requestWithURL:URL]] autorelease];
}


+ (id)connectionWithURLFormat:(NSString*)format, ... {
	va_list list;
	va_start(list, format);
	NSString *URLString = [[[NSString alloc] initWithFormat:format arguments:list] autorelease];
	va_end(list);
	return [self connectionWithURL:[NSURL URLWithString:URLString]];
}


- (void)dealloc {
	[request release];
	self.connection = nil;
	self.completionHandler = nil;
	self.errorHandler = nil;
	self.dataHandler = nil;
	self.authenticationHandler = nil;
	self.buffer = nil;
	self.response = nil;
	[super dealloc];
}

- (void)addValue:(NSString*)value forHTTPHeaderField:(NSString*)field {
	[request addValue:value forHTTPHeaderField:field];
}

- (void)setHTTPMethod:(NSString *)method {
	[request setHTTPMethod:method];
}

- (NSString*)HTTPMethod {
	return [request HTTPMethod];
}

- (void)setHTTPBody:(NSData *)body {
	[request setHTTPBody:body];
}

- (NSData*)HTTPBody {
	return [request HTTPBody];
}

- (void)startWithOutputKind:(Class)outputClass completionHandler:(void(^)(id output, NSURLResponse *response))block {
	self.outputKind = outputClass;
	self.completionHandler = block;
	[self start];
}

- (void)start {
	if(self.connection) return;
	self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)cancel {
	[self.connection cancel];
	self.connection = nil;
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	if(self.errorHandler) {
		self.errorHandler(error);
	}else{
		self.completionHandler(nil, nil);
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if(self.authenticationHandler) {
		self.authenticationHandler(challenge);
	}else{
		NSURLCredential *cred = [[NSURLCredentialStorage sharedCredentialStorage] defaultCredentialForProtectionSpace:[challenge protectionSpace]];
		if(cred) {
			[[challenge sender] useCredential:cred forAuthenticationChallenge:challenge];
		}else{
			[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
		}
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	if(self.dataHandler) {
		self.dataHandler(data);
	}else{
		[buffer appendData:data];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)resp {
	self.response = resp;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	id output = nil;
	
	if(!self.dataHandler) {	
		if(!outputKind) {
			output = self.buffer;
			
		}else if([outputKind respondsToSelector:@selector(TFUC_objectWithData:response:)]) {
			output = [outputKind TFUC_objectWithData:self.buffer response:self.response];
			
		}else if([outputKind instancesRespondToSelector:@selector(initWithData:encoding:)]) {
			NSStringEncoding enc = NSUTF8StringEncoding;
			if([response textEncodingName])
				enc = CFStringConvertEncodingToNSStringEncoding(CFStringConvertIANACharSetNameToEncoding((CFStringRef)[response textEncodingName]));
			
			output = [[[outputKind alloc] initWithData:self.buffer encoding:enc] autorelease];
		
		}else if([outputKind instancesRespondToSelector:@selector(initWithData:)]) {
			output = [[[outputKind alloc] initWithData:self.buffer] autorelease];
		}else{
			[NSException raise:NSInternalInconsistencyException format:@"Class %@ does not respond to -initWithData:, -initWithData:encoding: or +TFUC_objectWithData:response:."];
		}		
	}
	
	if(self.completionHandler)
		self.completionHandler(output, self.response);
}

@end