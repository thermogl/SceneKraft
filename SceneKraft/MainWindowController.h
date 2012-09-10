//
//  MainWindowController.h
//  SceneKraft
//
//  Created by Tom Irving on 08/09/2012.
//  Copyright (c) 2012 Tom Irving. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CameraNode;
@interface MainWindowController : NSWindowController {
	
	SCNView * sceneView;
	CVDisplayLinkRef displayLinkRef;
	
	CameraNode * cameraNode;
	SCNHitTestResult * hitTestResult;
	
	NSTrackingArea * trackingArea;
	BOOL mouseControlActive;
}

@end