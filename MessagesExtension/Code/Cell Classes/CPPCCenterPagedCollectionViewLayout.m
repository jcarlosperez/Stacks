//
//  CPPCCenterPagedCollectionViewLayout.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/26/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCCenterPagedCollectionViewLayout.h"

@implementation CPPCCenterPagedCollectionViewLayout

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    CGRect cvBounds = self.collectionView.bounds;
    CGFloat halfWidth = cvBounds.size.width * 0.5f;
    CGFloat proposedContentOffsetCenterX = proposedContentOffset.x + halfWidth;
    
    NSArray* attributesArray = [self layoutAttributesForElementsInRect:cvBounds];
    
    UICollectionViewLayoutAttributes* candidateAttributes;
    for (UICollectionViewLayoutAttributes* attributes in attributesArray) {
        
        // == Skip comparison with non-cell items (headers and footers) == //
        if (attributes.representedElementCategory !=
            UICollectionElementCategoryCell) {
            continue;
        }
        
        // == First time in the loop == //
        if(!candidateAttributes) {
            candidateAttributes = attributes;
            continue;
        }
        
        if (fabsf(attributes.center.x - proposedContentOffsetCenterX) <
            fabsf(candidateAttributes.center.x - proposedContentOffsetCenterX)) {
            candidateAttributes = attributes;
        }
    }
    
    return CGPointMake(candidateAttributes.center.x - halfWidth, proposedContentOffset.y);
    
}

@end
