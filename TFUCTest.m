#import <Foundation/Foundation.h>
#import "TFURLConnection.h"

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

	NSString *country = @"Sweden";
	NSString *region = @"Östergötland";
	NSString *city = @"Linköping";
	
	country = [country stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	region = [region stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	city = [city stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	
	TFURLConnection *connection = [TFURLConnection connectionWithURLFormat:@"http://www.yr.no/place/%@/%@/%@/forecast.xml", country, region, city];

	connection.errorHandler = ^(NSError *error) {
		NSLog(@"Failure: %@", error);
	};
	
	[connection startWithOutputKind:[NSXMLDocument class] completionHandler:^(id output, NSURLResponse *response) {
		NSXMLElement *forecast = [[output nodesForXPath:@"/weatherdata/forecast/tabular/time[1]" error:NULL] lastObject];
		NSString *description = [[[forecast nodesForXPath:@"symbol/@name" error:NULL] lastObject] stringValue];
		NSString *temperature = [[[forecast nodesForXPath:@"temperature/@value" error:NULL] lastObject] stringValue];
		
		NSLog(@"Weather forecast: %@, %@°C", description, temperature);
	}];
	
	
	for(;;) [[NSRunLoop currentRunLoop] run];
    [pool drain];
    return 0;
}