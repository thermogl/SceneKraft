//
//  BlockNode.m
//  SceneKraft
//
//  Created by Tom Irving on 11/09/2012.
//  Copyright (c) 2012 Tom Irving. All rights reserved.
//

#import "BlockNode.h"

@implementation BlockNode
@synthesize type;

+ (BlockNode *)blockNodeWithType:(BlockNodeType)type {
	
	BlockNode * node = (BlockNode *)[super node];
	[node setGeometry:[SCNBox boxWithWidth:1 height:1 length:1 chamferRadius:0]];
	[node setType:type];
	
	return node;
}

- (void)setType:(BlockNodeType)newType {
	
	type = newType;
	[self.geometry.firstMaterial.diffuse setContents:[NSImage imageNamed:(type == BlockNodeTypeDirt ? @"Dirt" : @"Stone")]];
	[self.geometry.firstMaterial.diffuse setMagnificationFilter:SCNNoFiltering];
}

@end
