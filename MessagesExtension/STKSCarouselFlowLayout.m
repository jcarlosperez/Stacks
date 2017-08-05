//
//  STKSCarouselFlowLayout.m
//  SongShift
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import "STKSCarouselFlowLayout.h"
#import <math.h>

@interface STKSCarouselFlowLayout ()

- (void)prepareCollectionView;
@end

@implementation STKSCarouselFlowLayout

- (void)prepareLayout {
    
    [super prepareLayout];
    [self prepareCollectionView];
    [self updateLayout];
}

- (void)prepareCollectionView {
    
    UICollectionView *collectionView = self.collectionView;
    
    if(collectionView.decelerationRate != UIScrollViewDecelerationRateFast) {
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
}

- (void)updateLayout {
    
    UICollectionView *collectionView = self.collectionView;
    
    BOOL isHorizontal = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal);
    
    CGSize collectionSize = collectionView.bounds.size;
    
    CGFloat yInset = (collectionSize.height - self.itemSize.height) / 2;
    CGFloat xInset = (collectionSize.width - self.itemSize.width) / 2;
    
    self.sectionInset = UIEdgeInsetsMake(yInset, xInset, yInset, xInset);
    
    
    CGFloat side = isHorizontal ? self.itemSize.width : self.itemSize.height;
    CGFloat scaledItemOffset = (side - (side * self.sideItemScale)) / 2;
    
    if(self.spacingMode == FixedMode) {
        self.minimumLineSpacing = _spacing - scaledItemOffset;
    } else if(self.spacingMode == OverlapMode) {
        CGFloat fullSizeSideItemOverlap = _visibleOffset + scaledItemOffset;
        CGFloat inset = isHorizontal ? xInset : yInset;
        self.minimumLineSpacing = inset - fullSizeSideItemOverlap;
    }
}

- (UICollectionViewLayoutAttributes *)transformedLayoutAttributesForAttributes:(UICollectionViewLayoutAttributes *)attributes {
    
    UICollectionView *collectionView = self.collectionView;
    
    BOOL isHorizontal = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal);
    
    CGFloat collectionCenter = isHorizontal ? collectionView.frame.size.width/2 : collectionView.frame.size.height/2;
    CGFloat offset = isHorizontal ? collectionView.contentOffset.x : collectionView.contentOffset.y;
    CGFloat normalizedCenter = (isHorizontal ? attributes.center.x : attributes.center.y) - offset;
    
    
    CGFloat maxDistance = (isHorizontal ? self.itemSize.width : self.itemSize.height) + self.minimumLineSpacing;
    CGFloat distance = (abs(collectionCenter - normalizedCenter) > maxDistance) ? maxDistance : abs((collectionCenter - normalizedCenter));
    CGFloat ratio = (maxDistance - distance)/maxDistance;
    
    CGFloat alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha;
    CGFloat scale = ratio * (1 - self.sideItemScale) + self.sideItemScale;
    
    attributes.alpha = alpha;
    attributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1);
    attributes.zIndex = (int)(alpha * 10);
    return attributes;
    
}

#pragma mark - Override UICollectionViewLayoutFlow functions

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *superAttributes = [super layoutAttributesForElementsInRect:rect];
    NSArray<__kindof UICollectionViewLayoutAttributes *> *attributes = [superAttributes copy];
    
    NSMutableArray *newAttributes = [NSMutableArray new];
    
    for(UICollectionViewLayoutAttributes *attribute in attributes) {
        
        UICollectionViewLayoutAttributes *transformedAttributes = [self transformedLayoutAttributesForAttributes:attribute];
        [newAttributes addObject:transformedAttributes];
    }
    
    return newAttributes;
    
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    UICollectionView *collectionView = self.collectionView;
    
    NSArray *layoutAttributes;
    
    if(collectionView.pagingEnabled == NO) {
        layoutAttributes = [self layoutAttributesForElementsInRect:collectionView.bounds];
    } else {
        collectionView.pagingEnabled = NO;
        return [super targetContentOffsetForProposedContentOffset:proposedContentOffset];
    }
    
    BOOL isHorizontal = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal);
    
    CGFloat midSide = (isHorizontal ? collectionView.bounds.size.width : collectionView.bounds.size.height) / 2;
    CGFloat proposedContentOffsetCenterOrigin = (isHorizontal ? proposedContentOffset.x : proposedContentOffset.y) + midSide;
    
    CGPoint targetContentOffset;
    
    if(isHorizontal) {
        NSArray *sortedArray = [layoutAttributes sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber *first = [NSNumber numberWithDouble:fabs(((UICollectionViewLayoutAttributes *)obj1).center.x - proposedContentOffsetCenterOrigin)];
            NSNumber *second = [NSNumber numberWithDouble:fabs(((UICollectionViewLayoutAttributes *)obj2).center.x - proposedContentOffsetCenterOrigin)];
            return [first compare:second];
        }];
        
        UICollectionViewLayoutAttributes *closest = sortedArray[0];
        targetContentOffset = CGPointMake(floor(closest.center.x - midSide), proposedContentOffset.y);
    } else {
        
        NSArray *sortedArray = [layoutAttributes sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSNumber *first = [NSNumber numberWithDouble:fabs(((UICollectionViewLayoutAttributes *)obj1).center.y - proposedContentOffsetCenterOrigin)];
            NSNumber *second = [NSNumber numberWithDouble:fabs(((UICollectionViewLayoutAttributes *)obj2).center.y - proposedContentOffsetCenterOrigin)];
            return [first compare:second];
        }];
        
        UICollectionViewLayoutAttributes *closest = sortedArray[0];
        targetContentOffset = CGPointMake(proposedContentOffset.x, floor(closest.center.y - midSide));
    }
    return targetContentOffset;
}

@end
