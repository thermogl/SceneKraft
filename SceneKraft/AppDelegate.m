//
//  AppDelegate.m
//  SceneKraft
//
//  Created by Tom Irving on 08/09/2012.
//  Copyright (c) 2012 Tom Irving. All rights reserved.
//

#import "AppDelegate.h"
#import "MainWindowController.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	
	mainWindowController = [[MainWindowController alloc] init];
	[mainWindowController showWindow:self];
}

- (void)dealloc {
	[mainWindowController release];
    [super dealloc];
}

@end
