//
//  BioAudioAppDelegate.m
//  BioAudio
//
//  Created by Brennon Bortz on 20/01/2011.
//  Copyright 2011 Brennon Bortz. All rights reserved.
//

#import "BioAudioAppDelegate.h"
#import "BioAudio.h"

@implementation BioAudioAppDelegate

@synthesize window;
@synthesize baViewController;

#pragma mark -
#pragma mark BioAudio
- (BioAudio *)bioAudio
{	
	// We want a singleton instance of BioAudio:
	if (!bioAudio) {
		bioAudio = [[BioAudio alloc] init];
	}
	
	NSAssert(bioAudio, @"couldn't instantiate BioAudio singleton");
	return bioAudio;
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
	
	// Initiate Dropbox session
	dbSession = 
	[[[DBSession alloc] initWithConsumerKey:@"c47y0gdndyrktxb" consumerSecret:@"ndmlc4pxcmtn3u2"] autorelease];
    [DBSession setSharedSession:dbSession]; 
    
	// Add view controller and view
	baViewController = [[BioAudioViewController alloc] init];
	[self.window addSubview:baViewController.view];
	
	// Instatiate BioAudio instance and begin setup
	[self.bioAudio setup];
    [self.window makeKeyAndVisible];
    return YES;
}

- (DBRestClient *)restClient {
	if (!restClient) {
		restClient = 
		[[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		restClient.delegate = self;
	}
	return restClient;
}

- (void)postFile
{
	NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *destinationFilePath = [[[NSString alloc] initWithFormat: @"%@/output.caf", documentsDirectory] autorelease];
	
	NSLog(@"%@", destinationFilePath);
	
	[[self restClient] uploadFile:@"uploaded.caf" toPath:@"/" fromPath:destinationFilePath];
	NSLog(@"-[BioAudioAppDelegate postFile]");
}

- (void)restClient:(DBRestClient*)client 
	loadedMetadata:(DBMetadata*)metadata {
	
	NSLog(@"Loaded metadata!");
}

- (void)restClient:(DBRestClient*)client 
metadataUnchangedAtPath:(NSString*)path {
	
	NSLog(@"Metadata unchanged!");
}

- (void)restClient:(DBRestClient*)client 
loadMetadataFailedWithError:(NSError*)error {
	
	NSLog(@"Error loading metadata: %@", error);
}

- (void)restClient:(DBRestClient*)client uploadProgress:(CGFloat)progress forFile:(NSString*)destPath from:(NSString*)srcPath;
{
	if (progress < 1.0) {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	} else {
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	}

	NSLog(@"Uploading file... %2.2f percent complete", progress * 100);
}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
{
    NSLog(@"File uploaded successfully.");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File Uploaded"
                                                    message:@"File uploaded successfully."
                                                   delegate:nil
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    NSString *info = [NSString stringWithFormat:@"Upload failed with the following error: %@", [error description]];
    NSLog(@"File upload failed.");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload Error"
                                                    message:info
                                                   delegate:nil
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[bioAudio release];
	bioAudio = nil;
	[baViewController release];
	baViewController = nil;
    [window release];
    [super dealloc];
}


@end
