//
//  PlayerNode.h
//  SceneKraft
//
//  Created by Tom Irving on 09/09/2012.
//  Copyright (c) 2012 Tom Irving. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface PlayerNode : SCNNode {
	
	SCNVector3 velocity;
	SCNVector3 acceleration;
	SCNVector4 movement;
	CGFloat movementSpeed;
	
	CGFloat rotationUpDown;
	CGFloat rotationLeftRight;
	
	BOOL touchingGround;
}

@property (nonatomic, assign) SCNVector3 velocity;
@property (nonatomic, assign) SCNVector3 acceleration;
@property (nonatomic, assign) SCNVector4 movement;
@property (nonatomic, assign) CGFloat movementSpeed;
@property (nonatomic, assign, readonly) CGFloat rotationUpDown;
@property (nonatomic, assign, readonly) CGFloat rotationLeftRight;
@property (nonatomic, readonly) BOOL touchingGround;

+ (PlayerNode *)node;
- (void)rotateByAmount:(CGSize)amount;

- (void)updatePositionWithRefreshPeriod:(CGFloat)refreshPeriod;
- (void)checkCollisionWithNodes:(NSArray *)nodes;

@end