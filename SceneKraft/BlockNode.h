//
//  BlockNode.h
//  SceneKraft
//
//  Created by Tom Irving on 11/09/2012.
//  Copyright (c) 2012 Tom Irving. All rights reserved.
//

#import <SceneKit/SceneKit.h>

typedef enum {
	BlockNodeTypeDirt = 0,
	BlockNodeTypeStone = 1,
} BlockNodeType;

@interface BlockNode : SCNNode {
	BlockNodeType type;
}

@property (nonatomic, assign) BlockNodeType type;

+ (BlockNode *)blockNodeWithType:(BlockNodeType)type;

@end
