//
//  CameraNode.m
//  SceneKraft
//
//  Created by Tom Irving on 09/09/2012.
//  Copyright (c) 2012 Tom Irving. All rights reserved.
//

#import "CameraNode.h"

@interface CameraNode ()
@property (nonatomic, assign) CGFloat rotationUpDown;
@property (nonatomic, assign) CGFloat rotationLeftRight;
@end

@implementation CameraNode
@synthesize velocity;
@synthesize acceleration;
@synthesize movement;
@synthesize movementSpeed;
@synthesize rotationUpDown;
@synthesize rotationLeftRight;

+ (CameraNode *)node {
	CameraNode * node = (CameraNode *)[super node];
	[node setMovementSpeed:1.4];
	return node;
}

- (void)rotateByAmount:(CGSize)amount {
	
	rotationLeftRight += amount.width;
	if (rotationLeftRight > M_PI * 2) rotationLeftRight -= M_PI * 2;
	else if (rotationLeftRight < 0) rotationLeftRight += M_PI * 2;
	
	rotationUpDown += amount.height;
	if (rotationUpDown > M_PI * 2) rotationUpDown -= M_PI * 2;
	else if (rotationUpDown < 0) rotationUpDown += M_PI * 2;
	
	CATransform3D rotation = CATransform3DRotate(self.transform, amount.height, 1, 0, 0);
	[self setTransform:CATransform3DRotate(rotation, amount.width, 0, sinf(rotationUpDown), cosf(rotationUpDown))];
}

- (void)updatePositionWithRefreshPeriod:(CGFloat)refreshPeriod {
	
	acceleration.x *= refreshPeriod;
	acceleration.y *= refreshPeriod;
	acceleration.z *= refreshPeriod;
	
	velocity.x += acceleration.x;
	velocity.y += acceleration.y;
	velocity.z += acceleration.z;
	
	SCNVector3 position = self.position;
	position.x += velocity.x * refreshPeriod;
	position.y += velocity.y * refreshPeriod;
	position.z += velocity.z * refreshPeriod;
	
	CGFloat speed = movementSpeed * refreshPeriod;
	
	if (movement.x){ // Up
		position.x -= sinf(rotationLeftRight) * speed;
		position.y += cosf(rotationLeftRight) * speed;
	}
	
	if (movement.y){ // Left
		position.x -= cosf(rotationLeftRight) * speed;
		position.y -= sinf(rotationLeftRight) * speed;
	}
	
	if (movement.z){ // Down
		position.y -= cosf(rotationLeftRight) * speed;
		position.x += sinf(rotationLeftRight) * speed;
	}
	
	if (movement.w){ // Right
		position.x += cosf(rotationLeftRight) * speed;
		position.y += sinf(rotationLeftRight) * speed;
	}
	
	[self setPosition:position];
}

// TODO: Make this better, stupidly slow and unreliable.
- (void)checkCollisionWithNodes:(NSArray *)nodes {
	
	__block SCNVector3 selfPosition = self.position;
	[nodes enumerateObjectsUsingBlock:^(SCNNode * node, NSUInteger idx, BOOL *stop) {
		
		if (self != node){
			
			SCNVector3 nodePosition = node.position;
			SCNBox * boxGeometry = (SCNBox *)node.geometry;
			
			if (nodePosition.x <= selfPosition.x && (nodePosition.x + boxGeometry.width) > selfPosition.x){
				if (nodePosition.y <= selfPosition.y && (nodePosition.y + boxGeometry.length) > selfPosition.y){
					if (nodePosition.z <= selfPosition.z && (nodePosition.z + boxGeometry.height) > selfPosition.z){
						
						selfPosition.z = nodePosition.z + boxGeometry.height;
						velocity.z = 0;
						touchingGround = YES;
						*stop = YES;
					}
				}
			}
		}
	}];
	
	[self setPosition:selfPosition];
}

@end