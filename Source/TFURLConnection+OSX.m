//
//  TFURLConnection+OSX.m
//  TFUC
//
//  Created by Tomas Franzén on 2011-06-14.
//  Copyright 2011 Lighthead Software. All rights reserved.
//

#import "TFURLConnection+OSX.h"


@implementation NSXMLDocument (TFURLConnectionOutput)

+ (id)TFUC_objectWithData:(NSData*)data response:(NSURLResponse*)response {
	NSUInteger options = 0;
	if([[response MIMEType] isEqual:@"text/html"])
		options = NSXMLDocumentTidyHTML;
	
	return [[[NSXMLDocument alloc] initWithData:data options:options error:NULL] autorelease];
}

@end
