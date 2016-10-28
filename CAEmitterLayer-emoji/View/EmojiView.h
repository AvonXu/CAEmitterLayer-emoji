//
//  EmojiView.h
//  CAEmitterLayer-emoji
//
//  Created by F H on 2016/10/27.
//  Copyright © 2016年 F HXYF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojiView : UIView
@property (assign, nonatomic) NSUInteger emojiEmitterCount;// default 5
@property (assign, nonatomic) CGFloat duration;//default 5s ; 0 forever
@property (strong, nonatomic) UIView *content;// if set image Will use Content
@property (strong, nonatomic) UIImage *image;
- (void)start;
- (void)stop;
@end
