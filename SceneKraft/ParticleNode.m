//
//  ParticleNode.m
//  SceneKraft
//
//  Created by Tom Irving on 10/09/2012.
//  Copyright (c) 2012 Tom Irving. All rights reserved.
//

#import "ParticleNode.h"

@implementation ParticleNode
@synthesize velocity;
@synthesize acceleration;
@synthesize mass;
@synthesize touchingGround;

- (void)updatePositionWithRefreshPeriod:(CGFloat)refreshPeriod {
	
	velocity.x += acceleration.x * refreshPeriod;
	velocity.y += acceleration.y * refreshPeriod;
	velocity.z += acceleration.z * refreshPeriod;
	
	SCNVector3 position = self.position;
	position.x += velocity.x * refreshPeriod;
	position.y += velocity.y * refreshPeriod;
	position.z += velocity.z * refreshPeriod;
	[self setPosition:position];
}

// TODO: Make this better, stupidly slow and unreliable.
- (void)checkCollisionWithNodes:(NSArray *)nodes {
	
	touchingGround = NO;
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
