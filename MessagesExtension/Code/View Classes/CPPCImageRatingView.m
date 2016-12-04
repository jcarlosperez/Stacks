//
//  CPPCImageRatingView.m
//  PicChoose
//
//  Created by Juan Carlos Perez on 10/24/16.
//  Copyright © 2016 CP Digital Darkroom. All rights reserved.
//

#import "CPPCImageRatingView.h"

static NSString *DefaultFullRatingImage = @"fullHeart";
static NSString *DefaultEmptyRatingImage = @"emptyHeart";

@interface CPPCImageRatingView ()

- (void)commonSetup;

@end

@implementation CPPCImageRatingView

- (CPPCImageRatingView *)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame fullImage:[UIImage imageNamed:DefaultFullRatingImage] emptyImage:[UIImage imageNamed:DefaultEmptyRatingImage]];
}

- (CPPCImageRatingView *)initWithFrame:(CGRect)frame fullImage:(UIImage *)fullImage emptyImage:(UIImage *)emptyImage {
    self = [super initWithFrame:frame];
    if (self) { 
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        _fullRatingImage = fullImage;
        _emptyRatingImage = emptyImage;
        
        [self commonSetup];
    }
    return self;
}

- (void)commonSetup {
    
    _padding = 4;
    self.editable = NO;
}

- (void)drawRect:(CGRect)rect {
    _origin = CGPointMake(self.frame.size.width / 2 - ((1.75 * _emptyRatingImage.size.width) + (1.5 * _padding)), 0);
    for (int i = 0; i < 4; i++) {
        CGFloat x = _origin.x + (_emptyRatingImage.size.width + _padding) * i;
        [_rate > i ? _fullRatingImage : _emptyRatingImage  drawAtPoint:CGPointMake(x, _origin.y)];
    }
}

- (void)setRate:(NSInteger)rate {
    // getting very large values???
    if (rate > 4) {
        return;
    }
    _rate = rate;
    [self setNeedsDisplay];
    [self notifyDelegate];
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    self.userInteractionEnabled = _editable;
}

- (void)setFullRatingImage:(UIImage *)fullRatingImage {
    if (fullRatingImage != _fullRatingImage) {
        _fullRatingImage = fullRatingImage;
        [self setNeedsDisplay];
    }
}

- (void)setEmptyRatingImage:(UIImage *)emptyRatingImage
{
    if (emptyRatingImage != _emptyRatingImage) {
        _emptyRatingImage = emptyRatingImage;
        [self setNeedsDisplay];
    }
}

- (void)handleTouchAtLocation:(CGPoint)location {
    NSLog(@"handle touch at location");
    for(int i = 4 - 1; i > -1; i--) {
        if (location.x > _origin.x + i * (_fullRatingImage.size.width + _padding) - _padding / 2) {
            self.rate = i + 1;
            return;
        }
    }
    self.rate = 0;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    [self handleTouchAtLocation:touchLocation];
}

- (void)notifyDelegate {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rateView:changedToNewRate:)]) {
        [self.delegate performSelector:@selector(rateView:changedToNewRate:)
                            withObject:self withObject:[NSNumber numberWithInteger:self.rate]];
    }
}

@end
