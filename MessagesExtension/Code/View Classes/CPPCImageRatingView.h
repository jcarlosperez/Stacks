//
//  CPPCImageRatingView.h
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CPPCImageRatingDelegate;

@interface CPPCImageRatingView : UIView {
    CGPoint _origin;
    NSInteger _ratingLimit;
}

@property(nonatomic, assign) CGFloat rate;
@property(nonatomic, assign) CGFloat padding;
@property(nonatomic, assign) BOOL editable;
@property(nonatomic, retain) UIImage *emptyRatingImage;
@property(nonatomic, retain) UIImage *fullRatingImage;
@property(nonatomic, assign) NSObject<CPPCImageRatingDelegate> *delegate;

- (CPPCImageRatingView *)initWithFrame:(CGRect)frame;
- (CPPCImageRatingView *)initWithFrame:(CGRect)rect fullImage:(UIImage *)fullImage emptyImage:(UIImage *)emptyImage;
- (void)setRate:(CGFloat)rate;
@end

@protocol CPPCImageRatingDelegate

- (void)rateView:(CPPCImageRatingView *)rateView changedToNewRate:(NSNumber *)rate;

@end
