//
//  MainWindowController.m
//  SceneKraft
//
//  Created by Tom Irving on 08/09/2012.
//  Copyright (c) 2012 Tom Irving. All rights reserved.
//

#import "MainWindowController.h"
#import "PlayerNode.h"
#define DEG_TO_RAD(x) (x * 180 / M_PI)

// Standard units.
CGFloat const kGravityAcceleration = 9.80665;
CGFloat const kJumpHeight = 1.2;
CGFloat const kPlayerMovementSpeed = 1.4;

CGFloat const kBlockSize = 1;
CGFloat const kWorldSize = 10;

@interface MainWindowController () <NSWindowDelegate>
@property (nonatomic, retain) SCNHitTestResult * hitTestResult;
@property (nonatomic, assign) BOOL mouseControlActive;
- (void)setupScene;
- (void)generateWorld;
- (void)addNodeAtPosition:(SCNVector3)position;
- (void)deselectHighlightedBlock;
- (void)highlightBlockAtCenter;
- (void)setupGameLoop;
- (CVReturn)gameLoopAtTime:(CVTimeStamp)time;
@end

@implementation MainWindowController
@synthesize hitTestResult;

#pragma mark - Window Initialization
- (id)init {
	
	if ((self = [super init])){
		
		trackingArea = nil;
		mouseControlActive = NO;
		displayLinkRef = NULL;
		
		NSWindow * window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 400, 400)
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
		[self setupGameLoop];
		
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

- (void)windowDidResignKey:(NSNotification *)notification {
	[playerNode setMovement:SCNVector4Make(0, 0, 0, 0)];
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
	
	[sceneView setScene:[SCNScene scene]];
	
	playerNode = [PlayerNode node];
	[playerNode rotateByAmount:CGSizeMake(0, M_PI / 2)];
	[playerNode setPosition:SCNVector3Make(kWorldSize / 2, 0, kWorldSize * 2)];
	[sceneView.scene.rootNode addChildNode:playerNode];
	
	SCNNode * cameraNode = [SCNNode node];
	SCNCamera * camera = [SCNCamera camera];
	[camera setZNear:0.1];
	[cameraNode setCamera:camera];
	
	[cameraNode setPosition:SCNVector3Make(kWorldSize / 2, -1, kWorldSize)];
	[cameraNode setRotation:SCNVector4Make(1, 0, 0, M_PI / 2)];
	
	[sceneView.scene.rootNode addChildNode:cameraNode];
	
	SCNLight * worldLight = [SCNLight light];
	[worldLight setType:SCNLightTypeDirectional];
	[sceneView.scene.rootNode setLight:worldLight];
	
	[self setMouseControlActive:NO];
	[self generateWorld];
}

- (void)generateWorld {
	
	for (int x = 0; x < kWorldSize; x++){
		for (int y = 0; y < kWorldSize; y++){
			for (int z = 0; z < kWorldSize; z++){
				[self addNodeAtPosition:SCNVector3Make(x, y, z)];
			}
		}
	}
}

#pragma mark - Scene Helpers
- (void)addNodeAtPosition:(SCNVector3)position {
		
	SCNNode * blockNode = [SCNNode nodeWithGeometry:[SCNBox boxWithWidth:kBlockSize height:kBlockSize length:kBlockSize chamferRadius:0]];
	[blockNode setPosition:position];
	[sceneView.scene.rootNode addChildNode:blockNode];
	[blockNode.geometry.firstMaterial.diffuse setContents:(id)[[NSColor redColor] CGColor]];
}

- (void)highlightBlockAtCenter {
	
	[self deselectHighlightedBlock];
	
	if (mouseControlActive){
		CGPoint point = CGPointMake(sceneView.bounds.size.width / 2, sceneView.bounds.size.height / 2);
		NSArray * results = [sceneView hitTest:point options:@{SCNHitTestSortResultsKey:@YES}];
		[results enumerateObjectsUsingBlock:^(SCNHitTestResult *result, NSUInteger idx, BOOL *stop) {
			
			if (result.node != playerNode && [result.node.geometry isKindOfClass:[SCNBox class]]){
				[self setHitTestResult:result];
				*stop = YES;
			}
		}];
		
		[hitTestResult.node.geometry.firstMaterial.diffuse setContents:(id)[[NSColor yellowColor] CGColor]];
	}
}

- (void)deselectHighlightedBlock {
	
	[hitTestResult.node.geometry.firstMaterial.diffuse setContents:(id)[[NSColor redColor] CGColor]];
	[self setHitTestResult:nil];
}

#pragma mark - Game Loop
- (void)setupGameLoop {
	
	if (CVDisplayLinkCreateWithActiveCGDisplays(&displayLinkRef) == kCVReturnSuccess){
		CVDisplayLinkSetOutputCallback(displayLinkRef, DisplayLinkCallback, self);
		CVDisplayLinkStart(displayLinkRef);
	}
}

static CVReturn DisplayLinkCallback(CVDisplayLinkRef displayLink, const CVTimeStamp *inNow, const CVTimeStamp *inOutputTime,
									CVOptionFlags flagsIn, CVOptionFlags *flagsOut, void *displayLinkContext){
	return [(MainWindowController *)displayLinkContext gameLoopAtTime:*inOutputTime];
}

- (CVReturn)gameLoopAtTime:(CVTimeStamp)time {
	
	dispatch_async(dispatch_get_main_queue(), ^{
		
		CGFloat refreshPeriod = CVDisplayLinkGetActualOutputVideoRefreshPeriod(displayLinkRef);
		
		[playerNode setAcceleration:SCNVector3Make(0, 0, -kGravityAcceleration)];
		[playerNode updatePositionWithRefreshPeriod:refreshPeriod];
		[playerNode checkCollisionWithNodes:sceneView.scene.rootNode.childNodes];
		
		SCNVector3 playerNodePosition = playerNode.position;
		SCNVector3 playerNodeVelocity = playerNode.velocity;
		
		if (playerNodePosition.z < 0){
			playerNodePosition.z = kWorldSize * 2;
			playerNodeVelocity.z = 0;
		}
		
		[playerNode setPosition:playerNodePosition];
		[playerNode setVelocity:playerNodeVelocity];
		
		[self highlightBlockAtCenter];
		[self.window setTitle:[NSString stringWithFormat:@"SceneKraft - %.f FPS", (1 / refreshPeriod)]];
	});
	
	return kCVReturnSuccess;
}

#pragma mark - Event Handling
- (void)keyDown:(NSEvent *)theEvent {
	
	SCNVector4 movement = playerNode.movement;
	if (theEvent.keyCode == 126 || theEvent.keyCode == 13) movement.x = kPlayerMovementSpeed;
	if (theEvent.keyCode == 123 || theEvent.keyCode == 0) movement.y = kPlayerMovementSpeed;
	if (theEvent.keyCode == 125 || theEvent.keyCode == 1) movement.z = kPlayerMovementSpeed;
	if (theEvent.keyCode == 124 || theEvent.keyCode == 2) movement.w = kPlayerMovementSpeed;
	[playerNode setMovement:movement];
	
	if (theEvent.keyCode == 49 && playerNode.touchingGround){
		SCNVector3 playerNodeVelocity = playerNode.velocity;
		playerNodeVelocity.z = sqrtf(2 * kGravityAcceleration * kJumpHeight);
		[playerNode setVelocity:playerNodeVelocity];
	}
	
	if (theEvent.keyCode == 53) [self setMouseControlActive:!mouseControlActive];
}

- (void)keyUp:(NSEvent *)theEvent {
	
	SCNVector4 movement = playerNode.movement;
	if (theEvent.keyCode == 126 || theEvent.keyCode == 13) movement.x = 0;
	if (theEvent.keyCode == 123 || theEvent.keyCode == 0) movement.y = 0;
	if (theEvent.keyCode == 125 || theEvent.keyCode == 1) movement.z = 0;
	if (theEvent.keyCode == 124 || theEvent.keyCode == 2) movement.w = 0;
	[playerNode setMovement:movement];
}

- (void)mouseMoved:(NSEvent *)theEvent {
	if (mouseControlActive) [playerNode rotateByAmount:CGSizeMake(DEG_TO_RAD(-theEvent.deltaX / 10000), DEG_TO_RAD(-theEvent.deltaY / 10000))];
}

- (void)mouseDown:(NSEvent *)theEvent {
	[self setMouseControlActive:YES];
	
	[hitTestResult.node removeFromParentNode];
	[self setHitTestResult:nil];
}

- (void)rightMouseDown:(NSEvent *)theEvent {
	
	// TODO: New a more concrete way of determining new block location.
	// Just because a coordinate is exactly 0.5, doesn't mean it's the correct face.
	
	SCNVector3 newNodePosition = hitTestResult.node.position;
	SCNVector3 localCoordinates = hitTestResult.localCoordinates;
	
	if (localCoordinates.x == 0.5) newNodePosition.x += 1;
	else if (localCoordinates.x == -0.5) newNodePosition.x -= 1;
	if (localCoordinates.y == 0.5) newNodePosition.y += 1;
	else if (localCoordinates.y == -0.5) newNodePosition.y -= 1;
	if (localCoordinates.z == 0.5) newNodePosition.z += 1;
	else if (localCoordinates.z == -0.5) newNodePosition.z -= 1;
	
	[self addNodeAtPosition:newNodePosition];
}

#pragma mark - Memory Management
- (void)dealloc {
	[hitTestResult release];
	CVDisplayLinkRelease(displayLinkRef);
	[super dealloc];
}

@end
