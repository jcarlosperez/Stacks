//
//  CPPCSelectionCollectionView.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCImageRatingView.h"
#import "CPPCSelectionCollectionView.h"
#import "CPPCSelectionCollectionViewCell.h"
#import "CPPCServerManager.h"

static NSString *const kPCChoiceSelectionCell = @"CPPCChoiceSeletionCell";

@interface CPPCSelectionCollectionView () <CPPCImageRatingDelegate> {
    CGSize cellSize;
}
@end

@implementation CPPCSelectionCollectionView

- (instancetype)init {
    
    cellSize = CGSizeMake(self.frame.size.width, self.frame.size.width + 50);
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    
    if (self = [super initWithFrame:CGRectZero collectionViewLayout:flowLayout]) {
        
        _choiceImageKeys = [NSMutableArray array];
        
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = YES;
        self.bounces = YES;
        [self registerClass:[CPPCSelectionCollectionViewCell class] forCellWithReuseIdentifier:kPCChoiceSelectionCell];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setChoiceImageKeys:(NSArray *)choiceImageKeys {
    
    _choiceImageKeys = choiceImageKeys;
    
    for(NSString *imageKey in choiceImageKeys) {
        
        if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.jpg", [NSTemporaryDirectory() stringByAppendingPathComponent:@"download"], imageKey]]) {
            
            [[CPPCServerManager sharedInstance] downloadImageWithKey:imageKey withSuccessBlock:^(AWSTask *responseTask) {
                
            } failureBlock:^(NSError *error) {
                NSLog(@"Failure: %@", error);
            }];
            
        }
    }
}

#pragma mark - CPPCRatingDelegate

- (void)rateView:(CPPCImageRatingView *)rateView changedToNewRate:(NSNumber *)rate {
    
}

#pragma mark - scrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(_choiceImageKeys.count > 0) {
        const CGFloat centerX = self.center.x;
        
        for(UICollectionViewCell * cell in [self visibleCells]) {
            CGPoint pos = [cell convertPoint:CGPointZero toView:self];
            pos.x += cellSize.width/2.0f;
            CGFloat distance = fabs(centerX - pos.x);
            CGFloat scale = 1.0f - (distance/centerX)*0.1f;
            [cell setTransform:CGAffineTransformMakeScale(scale, scale)];
        }
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGFloat movingX = velocity.x * scrollView.frame.size.width;
    CGFloat newOffsetX = scrollView.contentOffset.x + movingX;
    
    if(newOffsetX < 0) {
        newOffsetX = 0;
    } else if(newOffsetX > cellSize.width * (_choiceImageKeys.count-1)) {
        newOffsetX = cellSize.width * (_choiceImageKeys.count-1);
    } else {
        NSUInteger newPage = newOffsetX/cellSize.width + ((int)newOffsetX%(int)cellSize.width > cellSize.width/2.0f ? 1 : 0);
        newOffsetX = newPage*cellSize.width;
    }
    
    NSLog(@"New Offset: %f", newOffsetX);
    targetContentOffset->x = newOffsetX;
}

#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPCSelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPCChoiceSelectionCell forIndexPath:indexPath];
    
    NSString *imagePath = [NSString stringWithFormat:@"%@/%@.jpg", [NSTemporaryDirectory() stringByAppendingPathComponent:@"download"], _choiceImageKeys[indexPath.row]];
    cell.choiceImageView.image = [UIImage imageWithContentsOfFile:imagePath];
    cell.choiceImageView.backgroundColor = [UIColor greenColor];
    cell.ratingView.delegate = self;
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _choiceImageKeys.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return cellSize;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat gap = (self.frame.size.width - cellSize.width)/2.0f;
    return UIEdgeInsetsMake(0, gap, 0, gap);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}
@end
