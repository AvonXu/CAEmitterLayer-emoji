//
//  EmojiView.m
//  CAEmitterLayer-emoji
//
//  Created by F H on 2016/10/27.
//  Copyright © 2016年 F HXYF. All rights reserved.
//

#import "EmojiView.h"
#import <QuartzCore/QuartzCore.h>
//#include <math.h>

//0000 0000 0000 0000 0000 0000 0000 0000
#define ARC4RANDOM_MAX      0x100000000
#define DEF_RANDOM ((double)arc4random() / ARC4RANDOM_MAX)

@interface EmojiView ()
@property (strong, nonatomic) UIImage *emojiImage;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) dispatch_source_t stopTimer;

@property (strong, nonatomic) NSMutableArray<CAEmitterLayer*> *emitterLayerArr;
@end

@implementation EmojiView


#pragma mark - lifeCycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setUp];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUp];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUp];
}

#pragma mark - setter/getter
- (NSMutableArray<CAEmitterLayer *> *)emitterLayerArr
{
    if (!_emitterLayerArr) {
        _emitterLayerArr = [NSMutableArray array];
    }
    return _emitterLayerArr;
}

#pragma mark - setUp
- (void)setUp
{
    self.duration = 5.0f;
    self.emojiEmitterCount = 5;
    [self startTimer];
}

- (void)startTimer
{
    __block CGFloat count = 0;
    __block CGFloat msec = 0.1;
    // 获得队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 创建一个定时器(dispatch_source_t本质还是个OC对象)
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
    // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
    // 何时开始执行第一个任务
    // dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC) 比当前时间晚1秒
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC));
    
    uint64_t interval = (uint64_t)(msec * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    
    // 设置回调
    dispatch_source_set_event_handler(self.timer, ^{
        
        [self.emitterLayerArr enumerateObjectsUsingBlock:^(CAEmitterLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CGFloat width = CGRectGetWidth(self.bounds);
            CGFloat x_ = DEF_RANDOM * (width * 4 /5.0) + width/10.0;
            obj.emitterPosition = CGPointMake( x_, -10.0);
            obj.birthRate = DEF_RANDOM * 1 + 1;

        }];
        count += msec;
        if (count >= ((self.duration > 0.0)? self.duration : CGFLOAT_MAX)) {
            dispatch_cancel(self.timer);
            self.timer = nil;
            [self stop];
        }
        
    });
    
      
}



- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
}

- (UIImage *)emojiImage
{
    if (self.content){
        _emojiImage = [self getImageFromView:self.content];
        return _emojiImage;
    }
    if (!_emojiImage) {
        _emojiImage = [UIImage imageNamed:@"1"];
    }
    return _emojiImage;
}


- (void)start
{
    for (int i = 0; i< self.emojiEmitterCount; i ++) {
        CAEmitterLayer *layer = [self getLayer];
        [self.emitterLayerArr addObject:layer];
        [self.layer addSublayer:layer];
    }
    
    if (!self.timer) {
        [self startTimer];
    }
    // 启动定时器
    dispatch_resume(self.timer);
}


- (CAEmitterLayer *)getLayer
{
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    [self.layer addSublayer:emitter];
    emitter.emitterPosition = CGPointMake(CGRectGetWidth(self.frame)/2.0, -10.0);
    emitter.frame = self.bounds;
    emitter.emitterSize = CGSizeMake(CGRectGetWidth(self.frame)/4.0, 0.0);
    emitter.emitterShape = kCAEmitterLayerLine;
    emitter.emitterMode = kCAEmitterLayerOutline;
    
    emitter.shadowOpacity = 1.0;
    emitter.shadowRadius  = 0.0;
    emitter.shadowOffset  = CGSizeMake(0.0, 1.0);
    emitter.shadowColor   = [[UIColor whiteColor] CGColor];
    emitter.seed = (arc4random()%100)+1;
    
    
    //        CAEmitterCell * emitterCell = [CAEmitterCell emitterCell];
    //         emitterCell.contents= (__bridge id)[self imageWithColor:[UIColor greenColor] andSize:CGSizeMake(40, 40)].CGImage;;
    //        emitterCell.birthRate = 5.0;
    //        emitterCell.lifetime = 20;
    //    #define ARC4RANDOM_MAX      0x100000000
    //         emitterCell.emissionLongitude =  //
    ////    emitterCell.emissionLongitude =  floorf(((double)arc4random() / ARC4RANDOM_MAX) * M_PI_4);
    
    CAEmitterCell * emitterCell = [CAEmitterCell emitterCell];
    emitterCell.contents= (__bridge id)self.emojiImage.CGImage;;
    emitterCell.birthRate		= 1;//5.0;
    emitterCell.lifetime		= 20;
    
    emitterCell.velocity		= -100;				// falling down slowly
    emitterCell.velocityRange = 0;
    emitterCell.yAcceleration = 2;
    emitterCell.emissionRange = 0.25 * M_PI;		// some variation in angle
    emitterCell.spinRange		= 0.25 * M_PI;		// slow spin
    emitterCell.scale = 1.5;
    
    
    emitter.emitterCells = @[emitterCell] ;
    return emitter;
}



- (void)stop
{
    __block CGFloat time = 5;
    
    [self.emitterLayerArr enumerateObjectsUsingBlock:^(CAEmitterLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.birthRate = 0;
        time = MAX(time, obj.lifetime);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.emitterLayerArr enumerateObjectsUsingBlock:^(CAEmitterLayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperlayer];
        }];
        [self.emitterLayerArr removeAllObjects];
        
    });

}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - api
-(UIImage *)getImageFromView:(UIView *)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage*)imageWithColor:(UIColor*)color andSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGRect rect=CGRectMake(0, 0, size.width, size.height);
    UIBezierPath*bezierPath=[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:size.width/2.0];
    
    CGContextAddPath(context, bezierPath.CGPath);
    CGContextFillPath(context);
    CGContextSetFillColorWithColor(context, color.CGColor);
    UIImage*theImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - 暂无用
- (CAEmitterLayer *)getLayer1
{
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat pointX = DEF_RANDOM * width;
    CAEmitterLayer * emitterLayer = [[CAEmitterLayer alloc]init];
    emitterLayer.emitterPosition = CGPointMake(pointX, 0);
    emitterLayer.emitterSize = CGSizeMake(20, 20);
    emitterLayer.renderMode = kCAEmitterLayerAdditive;
    //    emitterLayer.emitterShape =kCAEmitterLayerLine;
    
    CAEmitterCell * fire = [CAEmitterCell emitterCell];
    fire.birthRate = 1/4.0f;
    fire.lifetime= 4.0;
    fire.lifetimeRange=0.1;
    fire.color=[[UIColor lightGrayColor]CGColor];
    
    
    fire.contents = (__bridge id)self.emojiImage.CGImage;
    [fire setName:@"emoji"];
    
    fire.velocity= CGRectGetHeight(self.bounds)/fire.lifetime;
    fire.velocityRange = 20;
    fire.emissionLatitude = 0;//M_PI_2;//M_PI + M_PI_2;
    fire.emissionLongitude= M_PI_2;
    fire.emissionRange= floorf(((double)arc4random() / ARC4RANDOM_MAX) * M_PI_2);
    fire.scale = 1;
    fire.scaleSpeed = 0;//0.3;
    
    fire.spin = 0;//M_PI_2;
    fire.spinRange = DEF_RANDOM *M_PI_2;
    emitterLayer.emitterCells=[NSArray arrayWithObjects:fire,nil];
    return emitterLayer;
    
    
}

- (CAEmitterLayer *)getLayer3
//- (void)getAnimation
{
    //创建一个CAEmitterLayer
    CAEmitterLayer *snowEmitter = [CAEmitterLayer layer];
    //降落区域的方位
    snowEmitter.frame = self.bounds;
    //添加到父视图Layer上
    [self.layer addSublayer:snowEmitter];
    //指定发射源的位置
    snowEmitter.emitterPosition = CGPointMake(self.bounds.size.width / 2.0, -10);
    //指定发射源的大小
    snowEmitter.emitterSize  = CGSizeMake(self.bounds.size.width, 0.0);
    //指定发射源的形状和模式
    snowEmitter.emitterShape = kCAEmitterLayerLine;
    snowEmitter.emitterMode  = kCAEmitterLayerOutline;
    //创建CAEmitterCell
    CAEmitterCell *snowflake = [CAEmitterCell emitterCell];
    //每秒多少个
    snowflake.birthRate = 3.0;
    //存活时间
    snowflake.lifetime = 50.0;
    //初速度，因为动画属于落体效果，所以我们只需要设置它在y方向上的加速度就行了。
    snowflake.velocity = 10;
    //初速度范围
    snowflake.velocityRange = 5;
    //y轴方向的加速度
    snowflake.yAcceleration = 30;
    //以锥形分布开的发射角度。角度用弧度制。粒子均匀分布在这个锥形范围内。
    snowflake.emissionRange = 5;
    //设置降落的图片
    snowflake.contents  = (__bridge id)[self imageWithColor:[UIColor greenColor] andSize:CGSizeMake(40, 40)].CGImage;//(id) [[UIImage imageNamed:@"2"] CGImage];
    //图片缩放比例
    snowflake.scale = 0.5;
    //开始动画
    snowEmitter.emitterCells = [NSArray arrayWithObject:snowflake];
    return snowEmitter;
}


@end
