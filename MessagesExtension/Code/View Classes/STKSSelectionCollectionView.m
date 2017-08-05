//
//  STKSSelectionCollectionView.m
//  Stacks
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 Juan Carlos Perez & Ben Rosen. All rights reserved.
//

#import "STKSImageRatingView.h"
#import "STKSSelectionCollectionView.h"
#import "STKSSelectionCollectionViewCell.h"
#import "STKSServerManager.h"
#import "STKSStackManager.h"
#import "STKSCarouselFlowLayout.h"
#import "RXPromise.h"

static NSString *const kPCChoiceSelectionCell = @"STKSChoiceSeletionCell";

@interface STKSSelectionCollectionView () <STKSImageRatingDelegate> {
    CGSize cellSize;
    STKSCarouselFlowLayout *_flowLayout;
}

@property (strong, nonatomic) NSArray *fileURLs;

@end

@implementation STKSSelectionCollectionView

- (instancetype)init {
    
    
    _flowLayout = [[STKSCarouselFlowLayout alloc] init];
    _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _flowLayout.sideItemAlpha = 0.6;
    _flowLayout.sideItemScale = 0.8;
    _flowLayout.spacing = -20;
    _flowLayout.spacingMode = FixedMode;
    
    if (self = [super initWithFrame:CGRectZero collectionViewLayout:_flowLayout]) {
        
        //_choiceImageKeys = [NSMutableArray array];
        [STKSStackManager sharedInstance].imageKeys = [NSMutableArray array];
        [STKSStackManager sharedInstance].imageRatings = [NSMutableDictionary dictionary];
        _fileURLs = [NSArray array];
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = YES;
        self.pagingEnabled = NO;
        [self registerClass:[STKSSelectionCollectionViewCell class] forCellWithReuseIdentifier:kPCChoiceSelectionCell];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setChoiceImageKeys:(NSArray *)choiceImageKeys {
    NSLog(@"The choice image keys are %@", choiceImageKeys);
    [[STKSStackManager sharedInstance] setImageKeys:[choiceImageKeys mutableCopy]];
    
    
    //if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.jpg", [NSTemporaryDirectory() stringByAppendingPathComponent:@"download"], imageKey]]) {
    
    RXPromise *promise = [[RXPromise alloc] init];
    promise.thenOnMain(^id(id result) {
        _fileURLs = result;

        [self reloadData];
        [self setContentOffset:CGPointMake(0, 0)];
        return nil;
    }, nil);
    
    [[STKSServerManager sharedInstance] downloadImagesWithImageKeys:choiceImageKeys promise:promise];
    
    
}

- (void)updateWithImageKeys:(NSArray *)keys andRatings:(NSDictionary *)ratings {
    if (ratings) {
        [[STKSStackManager sharedInstance] setImageRatings:[ratings mutableCopy]];
    }
    if (keys) {
        [[STKSStackManager sharedInstance] setImageKeys:[keys mutableCopy]];
    }
    NSLog(@"WE JUST SET THEM TO %@", [STKSStackManager sharedInstance].imageKeys);
    
    //if(![[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.jpg", [NSTemporaryDirectory() stringByAppendingPathComponent:@"download"], imageKey]]) {
    
    RXPromise *promise = [[RXPromise alloc] init];
    promise.thenOnMain(^id(id result) {
        _fileURLs = result;
        
        [self reloadData];
        [self setContentOffset:CGPointMake(0, 0)];
        return nil;
    }, nil);
    
    [[STKSServerManager sharedInstance] downloadImagesWithImageKeys:keys promise:promise];
}

#pragma mark - STKSRatingDelegate

- (void)rateView:(STKSImageRatingView *)rateView changedToNewRate:(NSNumber *)rate {
    NSLog(@"BEFORE: %@", [STKSStackManager sharedInstance].imageRatings);

    int ratedImage = (int)rateView.tag;
    [[STKSStackManager sharedInstance].imageRatings setValue:rate forKey:[NSString stringWithFormat:@"image%d", ratedImage]];
    NSLog(@"AFTER: %@", [STKSStackManager sharedInstance].imageRatings);
    
    if (self.selectionDelegate && [self.selectionDelegate respondsToSelector:@selector(imageHasBeenRated)]) {
        [self.selectionDelegate performSelector:@selector(imageHasBeenRated) withObject:nil];
    }
}

#pragma mark - scrollview delegate

// Ultimately this piece of code isn't even required.

/*        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
 let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
 let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
 currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)*/

/*- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{ // for custom paging
    CGFloat movingX = velocity.x * scrollView.frame.size.width;
    CGFloat newOffsetX = scrollView.contentOffset.x + movingX;
    
    int page = floor((newOffsetX - cellSize.width / 2) / cellSize.width) + 1;
    
    newOffsetX = page * cellSize.width;
    
    NSLog(@"New Offset: %f", newOffsetX);
    
    targetContentOffset->x = newOffsetX;
}*/

- (void)layoutSubviews {
    
    [super layoutSubviews];
    if(self.frame.size.width > 0){
        cellSize = CGSizeMake(self.frame.size.width-60, self.frame.size.width-40);
        _flowLayout.itemSize = cellSize;
    }
    
    [super layoutSubviews];
}
#pragma mark - UICollectionViewDelegate

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    STKSSelectionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPCChoiceSelectionCell forIndexPath:indexPath];
    
   
    NSString *imageURL = _fileURLs[indexPath.row];
    cell.choiceImageView.image = [UIImage imageWithContentsOfFile:imageURL];
    //cell.choiceImageView.backgroundColor = [UIColor greenColor];
    cell.ratingView.delegate = self;
    cell.ratingView.tag = [indexPath row];
    
    NSNumber *rate = [[STKSStackManager sharedInstance].imageRatings objectForKey:[NSString stringWithFormat:@"image%d", (int)indexPath.row]];
    if (rate) {
        [cell.ratingView setRate:[rate integerValue]];
    }
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"%@ the thing is ", _fileURLs);
    return _fileURLs.count;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat gap = (self.frame.size.width - cellSize.width)/2.0f;
    return UIEdgeInsetsMake(0, gap, 0, gap);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return -20;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return cellSize;
}

@end
