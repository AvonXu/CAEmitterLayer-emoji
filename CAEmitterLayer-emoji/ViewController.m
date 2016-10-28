//
//  ViewController.m
//  CAEmitterLayer-emoji
//
//  Created by F H on 2016/10/27.
//  Copyright © 2016年 F HXYF. All rights reserved.
//

#import "ViewController.h"

#import "EmojiView.h"
@interface ViewController ()
@property (strong, nonatomic) EmojiView *emojiView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emojiView = [[EmojiView alloc]init];
    self.emojiView.duration = 0;
    [self.view addSubview:self.emojiView];
    self.emojiView.frame = CGRectMake(0, 20, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.bounds) - 40);
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.emojiView start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
