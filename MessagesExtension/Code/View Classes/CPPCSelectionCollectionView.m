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
#import "CPPCCarouselFlowLayout.h"
#import "RXPromise.h"

static NSString *const kPCChoiceSelectionCell = @"CPPCChoiceSeletionCell";

@interface CPPCSelectionCollectionView () <CPPCImageRatingDelegate> {
    CGSize cellSize;
}

@property (strong, nonatomic) NSArray *fileURLs;

@end

@implementation CPPCSelectionCollectionView

- (instancetype)init {
    
    
    CPPCCarouselFlowLayout *flowLayout = [[CPPCCarouselFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.sideItemAlpha = 0.6;
    flowLayout.sideItemScale = 0.8;
    flowLayout.spacing = 10;
    flowLayout.spacingMode = FixedMode;
    flowLayout.visibleOffset = 40;
    
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
    
        
        RXPromise *promise = [[RXPromise alloc] init];
        promise.thenOnMain(^id(id result) {
            _fileURLs = result;
            [self reloadData];
            
            return nil;
        }, ^id(NSError *error) {
            NSLog(@"THE ERROR IS %@", error);
            
            return nil;
        });
        
    [[CPPCServerManager sharedInstance] downloadImagesWithImageKeys:_choiceImageKeys promise:promise];
    
    
}


#pragma mark - CPPCRatingDelegate

- (void)rateView:(CPPCImageRatingView *)rateView changedToNewRate:(NSNumber *)rate {
    
}

#pragma mark - scrollview delegate
/*        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
 let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
 let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
 currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)*/

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    CGFloat movingX = velocity.x * scrollView.frame.size.width;
    CGFloat newOffsetX = scrollView.contentOffset.x + movingX;
    
    CPPCCarouselFlowLayout *carouselFlowLayout = (CPPCCarouselFlowLayout *)self.collectionViewLayout;
    
    CGSize pageSize = carouselFlowLayout.itemSize;
    if (carouselFlowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        pageSize.width += carouselFlowLayout.minimumLineSpacing;
    } else {
        pageSize.height += carouselFlowLayout.minimumLineSpacing;
    }
    
    
        NSUInteger newPage = floor((scrollView.contentOffset.x - pageSize.width / 2) / pageSize.width) + 1;
        newOffsetX = newPage*pageSize.width;
    
    
    NSLog(@"New Offset: %f", newOffsetX);
    targetContentOffset->x = newOffsetX;
}

#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CPPCSelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPCChoiceSelectionCell forIndexPath:indexPath];
   
    //NSLog(@"we atually got ere %@", _choiceImageKeys[indexPath.row]);
    NSString *fileURL = _fileURLs[indexPath.row];
    cell.choiceImageView.image = [UIImage imageWithContentsOfFile:fileURL];
    cell.choiceImageView.backgroundColor = [UIColor greenColor];
    cell.ratingView.delegate = self;
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%@ the thing is ", _fileURLs);
    return _choiceImageKeys.count;
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.frame.size.width, self.frame.size.width + 50);
}

@end
