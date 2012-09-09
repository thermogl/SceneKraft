//
//  MainWindowController.h
//  SceneKraft
//
//  Created by Tom Irving on 08/09/2012.
//  Copyright (c) 2012 Tom Irving. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MainWindowController : NSWindowController {
	
	SCNView * sceneView;
	
	SCNNode * cameraNode;
	SCNNode * highlightedNode;
	
	CGFloat cameraRotUpDown;
	CGFloat cameraRotLeftRight;
	
	NSTrackingArea * trackingArea;
	BOOL mouseControlActive;
}

@end
