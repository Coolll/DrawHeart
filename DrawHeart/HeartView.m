//
//  HeartView.m
//  DrawHeart
//
//  Created by WQL on 16/3/1.
//  Copyright © 2016年 WQL. All rights reserved.
//

#import "HeartView.h"
//间距
NSInteger const spaceWidth = 5;
//波浪的振幅
NSInteger const waveAmplitude = 5;
@interface HeartView ()
{
    CGFloat t;
}
@end

@implementation HeartView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self loadTimer];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //上面的两个半圆 半径为整个frame的四分之一
    CGFloat radius = MIN((self.frame.size.width-spaceWidth*2)/4, (self.frame.size.height-spaceWidth*2)/4);
    
    //左侧圆心 位于左侧边距＋半径宽度
    CGPoint leftCenter = CGPointMake(spaceWidth+radius, spaceWidth+radius);
    //右侧圆心  位于左侧圆心的右侧 距离为两倍半径
    CGPoint rightCenter = CGPointMake(spaceWidth+radius*3, spaceWidth+radius);
    
    //左侧半圆
    UIBezierPath *heartLine = [UIBezierPath bezierPathWithArcCenter:leftCenter radius:radius startAngle:M_PI endAngle:0 clockwise:YES];

    //右侧半圆
    [heartLine addArcWithCenter:rightCenter radius:radius startAngle:M_PI endAngle:0 clockwise:YES];
    
    //曲线连接到新的底部顶点  为了弧线的效果，控制点，坐标x为总宽度减spaceWidth，刚好可以相切，平滑过度 y可以根据需要进行调整，y越大，所画出来的线越接近内切圆弧
    [heartLine addQuadCurveToPoint:CGPointMake((self.frame.size.width/2), self.frame.size.height-spaceWidth*2) controlPoint:CGPointMake(self.frame.size.width-spaceWidth, self.frame.size.height*0.6)];
    
    //用曲线 底部的顶点连接到左侧半圆的左起点 为了弧线的效果，控制点，坐标x为spaceWidth，刚好可以相切，平滑过度。y可以根据需要进行调整，y越大，所画出来的线越接近内切圆弧（效果是越胖）
    [heartLine addQuadCurveToPoint:CGPointMake(spaceWidth, spaceWidth+radius) controlPoint:CGPointMake(spaceWidth, self.frame.size.height*0.6)];
    
    //线条处理
    [heartLine setLineCapStyle:kCGLineCapRound];
    //线宽
    [self setHeartLineWidthWithPath:heartLine];
    //线条的颜色
    [self setHeartStrokeColor];
    
    //根据坐标点连线
    [heartLine stroke];
    //clipToBounds 切掉多余的部分
    [heartLine addClip];
    
    
    //初始化波浪的构成
    UIBezierPath *waves = [UIBezierPath bezierPath];
    
    //首先 把起始点设置为左侧 x坐标为spaceWidth 心形从下往上填充,y坐标需要满足一定的函数关系式，当rate为0时，位置为总高度－2倍的留白距离（spaceWidth）＋波浪的振幅；当rate为1时，位置为留白距离（spaceWidth）－振幅。由这两个状态构建函数表达式，即可得到如下表达式
    CGPoint startPoint = CGPointMake(spaceWidth, (self.frame.size.height-3*spaceWidth+waveAmplitude*2)*(1-self.rate)+spaceWidth-waveAmplitude);
    [waves moveToPoint:startPoint];
    
    //关键的地方来了 波浪线怎么画？
    //首先，x坐标是从左往右连续的  y坐标是起始的高度加上一定的波动 这里选择了cos函数。5是波动的幅度大小，50控制的是波峰的间距，t是为了让其动起来，随时间发生波动
    for (int i = 0; i<self.frame.size.width-spaceWidth*2+self.lineWidth*2; i++) {
        //x是要考虑线宽的 不然的话，会导致填充的宽度不够 y就是在某个值附近波动
        CGPoint middlePoint = CGPointMake(spaceWidth+i-self.lineWidth, startPoint.y+waveAmplitude*cos(M_PI/50*i+t));
        
        [waves addLineToPoint:middlePoint];
    }
    
    //画波浪线的右端 到底部的垂直线
    [waves addLineToPoint:CGPointMake(self.frame.size.width-spaceWidth*2, self.frame.size.height-spaceWidth*2)];
    //画右侧底部的点 到达左侧底部的点之间的横线
    [waves addLineToPoint:CGPointMake(spaceWidth, self.frame.size.height-spaceWidth*2)];
    //设置填充颜色
    [self setHeartFillColor];
    //填充
    [waves fill];
    
}
//设置线条宽度 默认为1
- (void)setHeartLineWidthWithPath:(UIBezierPath*)path
{
    CGFloat lineW;
    if (self.lineWidth) {
        lineW = self.lineWidth;
    }else{
        lineW = 1;
    }
    
    [path setLineWidth:lineW];
}

//设置线条颜色
- (void)setHeartStrokeColor
{
    UIColor *strokColor;
    if (self.strokeColor) {
        strokColor = self.strokeColor;
    }else{
        strokColor = [UIColor blackColor];
    }
    
    [strokColor set];
}
//设置填充的颜色
- (void)setHeartFillColor
{
    UIColor *fillColor;
    if (self.fillColor) {
        fillColor = self.fillColor;
    }else{
        fillColor = [UIColor orangeColor];
    }
    
    [fillColor set];

}

//为了实现动态的效果，加一个Timer
- (void)loadTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [timer fire];
}
//t 是一个影响波浪线的参数，每次修改之，再画，则每次的都不一样，则有动态的效果
- (void)timerAction
{
    t += M_PI/50;
    
    if (t == M_PI) {
        t = 0;
    }
    //修改了t之后 要调用draw方法
    [self setNeedsDisplay];
}

@end
