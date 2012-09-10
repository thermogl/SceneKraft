//
//  PlayerNode.m
//  SceneKraft
//
//  Created by Tom Irving on 09/09/2012.
//  Copyright (c) 2012 Tom Irving. All rights reserved.
//

#import "PlayerNode.h"

@interface PlayerNode ()
@property (nonatomic, assign) CGFloat rotationUpDown;
@property (nonatomic, assign) CGFloat rotationLeftRight;
@end

@interface PlayerNode (Private)
- (void)buildPlayer;
@end

@implementation PlayerNode
@synthesize movement;
@synthesize rotationUpDown;
@synthesize rotationLeftRight;

+ (PlayerNode *)node {
	PlayerNode * node = (PlayerNode *)[super node];
	[node setMass:70];
	
	SCNCamera * camera = [SCNCamera camera];
	[camera setZNear:0.1];
	[node setCamera:camera];
	
	SCNLight * light = [SCNLight light];
	[light setType:SCNLightTypeOmni];
	[node setLight:light];
	
	[node buildPlayer];
	
	return node;
}

- (void)buildPlayer {
	[self setGeometry:[SCNBox boxWithWidth:0.3 height:0.3 length:0.3 chamferRadius:0]];
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
	[super updatePositionWithRefreshPeriod:refreshPeriod];
	
	SCNVector3 position = self.position;
	position.x -= sinf(rotationLeftRight) * (movement.x - movement.z) * refreshPeriod;
	position.y += cosf(rotationLeftRight) * (movement.x - movement.z) * refreshPeriod;
	
	position.x -= cosf(rotationLeftRight) * (movement.y - movement.w) * refreshPeriod;
	position.y -= sinf(rotationLeftRight) * (movement.y - movement.w) * refreshPeriod;
	[self setPosition:position];
}

@end