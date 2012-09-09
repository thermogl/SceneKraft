//
//  MainWindowController.m
//  SceneKraft
//
//  Created by Tom Irving on 08/09/2012.
//  Copyright (c) 2012 Tom Irving. All rights reserved.
//

#import "MainWindowController.h"
#define DEG_TO_RAD(x) (x * 180 / M_PI)

@interface MainWindowController () <NSWindowDelegate>
@property (nonatomic, assign) BOOL mouseControlActive;
- (void)setupScene;
- (void)generateWorld;
- (void)deselectHighlightedBlock;
- (void)highlightBlockAtCenter;
@end

@implementation MainWindowController

#pragma mark - Window Initialization
- (id)init {
	
	if ((self = [super init])){
		
		trackingArea = nil;
		mouseControlActive = NO;
		
		NSWindow * window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 200, 200)
														styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask) backing:NSBackingStoreBuffered defer:YES];
		[window setFrameAutosaveName:@"MainWindow"];
		[window setTitle:@"SceneKraft"];
		[window setDelegate:self];
		[self setWindow:window];
		[window release];
		
		sceneView = [[SCNView alloc] initWithFrame:[window.contentView bounds]];
		[sceneView setAutoresizingMask:(NSViewHeightSizable | NSViewWidthSizable)];
		[sceneView setBackgroundColor:[NSColor blueColor]];
		[window.contentView addSubview:sceneView];
		[sceneView release];
		
		[sceneView setNextResponder:self];
		[self setupScene];
		
		[self windowDidResize:nil];
	}
	
	return self;
}

#pragma mark - Window Delegate
- (void)windowDidResize:(NSNotification *)notification {
	
	[sceneView removeTrackingArea:trackingArea];
	trackingArea = [[NSTrackingArea alloc] initWithRect:sceneView.bounds
												options:(NSTrackingActiveInKeyWindow | NSTrackingMouseMoved) owner:self userInfo:nil];
	[sceneView addTrackingArea:trackingArea];
	[trackingArea release];
}

#pragma mark - Property Overrides
- (void)setMouseControlActive:(BOOL)active {
	
	if (mouseControlActive != active){
		mouseControlActive = active;
		
		CGAssociateMouseAndMouseCursorPosition(mouseControlActive ? FALSE : TRUE);
		if (mouseControlActive) [NSCursor hide];
		else [NSCursor unhide];
	}
}

#pragma mark - Scene Initialization
- (void)setupScene {
	
	cameraRotUpDown = M_PI / 2;
	cameraRotLeftRight = 0;
	
	[sceneView setScene:[SCNScene scene]];
	
	SCNCamera * camera = [SCNCamera camera];
	[camera setZNear:0.1];
	
	cameraNode = [SCNNode node];
	[cameraNode setCamera:camera];
	[cameraNode setRotation:SCNVector4Make(1, 0, 0, cameraRotUpDown)];
	[cameraNode setPosition:SCNVector3Make(5, 0, 10.1)];
	[sceneView.scene.rootNode addChildNode:cameraNode];
	
	SCNLight * cameraLight = [SCNLight light];
	[cameraLight setType:SCNLightTypeOmni];
	[cameraNode setLight:cameraLight];
	
	SCNLight * worldLight = [SCNLight light];
	[worldLight setType:SCNLightTypeDirectional];
	[sceneView.scene.rootNode setLight:worldLight];
	
	[self setMouseControlActive:NO];
	[self generateWorld];
}

#pragma mark - Scene Helpers
- (void)generateWorld {
	
	for (int x = 0; x < 10; x++){
		for (int y = 0; y < 10; y++){
			for (int z = 0; z < 10; z++){
				SCNNode * blockNode = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0]];
				[blockNode setPosition:SCNVector3Make(x, y, z)];
				[sceneView.scene.rootNode addChildNode:blockNode];
				[blockNode.geometry.firstMaterial.diffuse setContents:(id)[[NSColor redColor] CGColor]];
			}
		}
	}
}

- (void)highlightBlockAtCenter {
	
	[self deselectHighlightedBlock];
	
	CGPoint point = CGPointMake(sceneView.bounds.size.width / 2, sceneView.bounds.size.height / 2);
    NSArray * results = [sceneView hitTest:point options:@{SCNHitTestSortResultsKey:@YES}];
	[results enumerateObjectsUsingBlock:^(SCNHitTestResult *result, NSUInteger idx, BOOL *stop) {
		
		if ([result.node.geometry isKindOfClass:[SCNBox class]]){
			highlightedNode = result.node;
			*stop = YES;
		}
	}];
	
	[highlightedNode.geometry.firstMaterial.diffuse setContents:(id)[[NSColor yellowColor] CGColor]];
}

- (void)deselectHighlightedBlock {
	
	[highlightedNode.geometry.firstMaterial.diffuse setContents:(id)[[NSColor redColor] CGColor]];
	highlightedNode = nil;
}

#pragma mark - Event Handling
- (void)keyDown:(NSEvent *)theEvent {
	
	CGFloat movementSpeed = 0.5;
	
	SCNVector3 cameraNodePosition = cameraNode.position;
	if (theEvent.keyCode == 126 || theEvent.keyCode == 13){ // Up
		cameraNodePosition.y += cosf(cameraRotLeftRight) * movementSpeed;
		cameraNodePosition.x -= sinf(cameraRotLeftRight) * movementSpeed;
	}
	
	if (theEvent.keyCode == 125 || theEvent.keyCode == 1){ // Down
		cameraNodePosition.y -= cosf(cameraRotLeftRight) * movementSpeed;
		cameraNodePosition.x += sinf(cameraRotLeftRight) * movementSpeed;
	}
	
	if (theEvent.keyCode == 123 || theEvent.keyCode == 0){ // Left
		cameraNodePosition.x -= cosf(cameraRotLeftRight) * movementSpeed;
		cameraNodePosition.y -= sinf(cameraRotLeftRight) * movementSpeed;
	}
	
	if (theEvent.keyCode == 124 || theEvent.keyCode == 2){ // Right
		cameraNodePosition.x += cosf(cameraRotLeftRight) * movementSpeed;
		cameraNodePosition.y += sinf(cameraRotLeftRight) * movementSpeed;
	}
	
	if (theEvent.keyCode == 53) [self setMouseControlActive:!mouseControlActive];
	
	[cameraNode setPosition:cameraNodePosition];
	[self highlightBlockAtCenter];
}

- (void)mouseMoved:(NSEvent *)theEvent {
	
	if (mouseControlActive){
		
		CGFloat upDownAngle = DEG_TO_RAD(-theEvent.deltaY / 10000);
		CGFloat leftRightAngle = DEG_TO_RAD(-theEvent.deltaX / 10000);
		
		cameraRotUpDown += upDownAngle;
		if (cameraRotUpDown > M_PI * 2) cameraRotUpDown -= M_PI * 2;
		else if (cameraRotUpDown < 0) cameraRotUpDown += M_PI * 2;
		
		cameraRotLeftRight += leftRightAngle;
		if (cameraRotLeftRight > M_PI * 2) cameraRotLeftRight -= M_PI * 2;
		else if (cameraRotLeftRight < 0) cameraRotLeftRight += M_PI * 2;
		
		[cameraNode setTransform:CATransform3DRotate(cameraNode.transform, upDownAngle, 1, 0, 0)];
		[cameraNode setTransform:CATransform3DRotate(cameraNode.transform, leftRightAngle, 0, sinf(cameraRotUpDown), cosf(cameraRotUpDown))];
		
		[self highlightBlockAtCenter];
	}
}

- (void)mouseDown:(NSEvent *)theEvent {
	[self setMouseControlActive:YES];
	
	[highlightedNode removeFromParentNode];
	highlightedNode = nil;
}

- (void)rightMouseDown:(NSEvent *)theEvent {
	//TODO: Add code for adding nodes
}

- (void)mouseUp:(NSEvent *)theEvent {
	[self highlightBlockAtCenter];
}

@end
