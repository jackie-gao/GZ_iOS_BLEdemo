//
//  ViewController.m
//  7.13蓝牙
//
//  Created by computer on 16/7/13.
//  Copyright © 2016年 computer. All rights reserved.
//

#import "ViewController.h"
#import "BLEManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *colorView;
@property (weak, nonatomic) IBOutlet UIView *lightBg;
@property (nonatomic,readwrite,strong)UIView * tapView;
@property (nonatomic,readwrite,assign)int BRT;
@property (nonatomic,readwrite,assign)int red;
@property (nonatomic,readwrite,assign)int green;
@property (nonatomic,readwrite,assign)int blue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //创建滑块
    _tapView = [[UIView alloc]initWithFrame:(CGRect){0,0,30,30}];
    _tapView.center = CGPointMake(_colorView.frame.size.width / 2, 7.5);
    _tapView.backgroundColor = [UIColor clearColor];
    _tapView.layer.borderColor = [UIColor whiteColor].CGColor;
    _tapView.layer.cornerRadius = 15.f;
    _tapView.layer.borderWidth = 2.5f;
    [_colorView.superview addSubview:_tapView];
    //-------------------
    //给colorView 添加手势
    //-------------------
    //在加手势前 要开启交互
    _colorView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    [_colorView addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handleGesture:)];
    [_colorView addGestureRecognizer:pan];
    
//    对灯泡的背景view的处理
    self.lightBg.layer.cornerRadius = self.lightBg.layer.frame.size.width / 2;
    self.lightBg.layer.shadowColor = [UIColor whiteColor].CGColor;
    self.lightBg.layer.shadowOffset = CGSizeZero;
    self.lightBg.layer.shadowOpacity = 0.8;
    self.lightBg.layer.shadowRadius = self.lightBg.layer.frame.size.width / 2;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat R = self.lightBg.frame.size.width / 2.0;
    [path addArcWithCenter:(CGPoint){R,R} radius:R+20 startAngle:0 endAngle:2*M_PI clockwise:YES];
    self.lightBg.layer.shadowPath = path.CGPath;
    
//    _constraint1.constant = _constraint2.constant = (_bootonView.frame.size.width - _bootonBtn1.frame.size.width * 3) / 3;
}
#pragma mark 手势方法
- (void)handleGesture:(UIGestureRecognizer *)ges
{
    CGPoint touchPoint = [ges locationInView:_colorView];
//    中心点
    CGPoint center = _colorView.center;
//    根据中心点的位移
    CGPoint toCenter = CGPointMake(touchPoint.x - center.x, touchPoint.y - center.y);
    CGFloat X = (center.x-7.5) * toCenter.x / sqrt(toCenter.x * toCenter.x + toCenter.y * toCenter.y);
    
    CGFloat Y = (center.y-7.5) * toCenter.y / sqrt(toCenter.x * toCenter.x + toCenter.y * toCenter.y);
    NSLog(@"%f -- %f",X,Y);
//    加上参考系的中心点
    _tapView.center = CGPointMake(X+center.x, Y+center.y);
    
    [self getColorOfPoint:_tapView.center InView:_colorView];
}
/**
 *
 函数原型：
 CGContextRef CGBitmapContextCreate (
 void *data,
 size_t width,
 size_t height,
 size_t bitsPerComponent,
 size_t bytesPerRow,
 CGColorSpaceRef colorspace,
 CGBitmapInfo bitmapInfo
 );
 
 参数：
 data                指向要渲染的绘制内存的地址。这个内存块的大小至少是（bytesPerRow*height）个字节
 width               itmap的宽度,单位为像素
 height              bitmap的高度,单位为像素
 bitsPerComponent    内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
 bytesPerRow         bitmap的每一行在内存所占的比特数
 colorspace          bitmap上下文使用的颜色空间。
 bitmapInfo          指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
 
 描述：
 当你调用这个函数的时候，Quartz创建一个位图绘制环境，也就是位图上下文。当你向上下文中绘制信息时，Quartz把你要绘制的信息作为位图数据绘制到指定的内存块。一个新的位图上下文的像素格式由三个参数决定：每个组件的位数，颜色空间，alpha选项。alpha值决定了绘制像素的透明性。
 
 */
- (void) getColorOfPoint:(CGPoint)point InView:(UIView*)view
{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    [view.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    NSString *hexColor = [NSString stringWithFormat:@"#%02x%02x%02x",pixel[0],pixel[1],pixel[2]];
    int Red = (int)pixel[0];
    int green = (int)pixel[1];
    int blue = (int)pixel[2];
    NSLog(@"hex = %@ %d %d %d",hexColor,Red,green,blue);
    
    _tapView.backgroundColor = [UIColor colorWithRed:Red / 255.0 green:green / 255.0 blue:blue / 255.0 alpha:1];
    _lightBg.backgroundColor = _tapView.backgroundColor;
    _lightBg.layer.shadowColor = _tapView.backgroundColor.CGColor;
//    [KBLEManager ble07:Red green:green blue:blue];
    
    _red = Red;
    _green = green;
    _blue = blue;
    if (!_BRT) {
        _BRT = 255;
    }
    [KBLEManager ble07:Red green:green blue:blue BRT:_BRT];
}
- (IBAction)backAction:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)dynamic:(UIButton *)sender {
    [KBLEManager bleAnimation:BLEAnimationType_More];
}
- (IBAction)sevenColor:(UIButton *)sender {
    [KBLEManager bleAnimation:BLEAnimationType_Seven];
}
- (IBAction)threeColor:(UIButton *)sender {
    [KBLEManager bleAnimation:BLEAnimationType_Three];
}
- (IBAction)closeUp:(UIButton *)sender {
    [KBLEManager bleAnimation:BLEAnimationType_Stop];
}
- (IBAction)brtSliderAction:(UISlider *)sender {
    int brt = sender.value * 255;
    _BRT = brt;
    [KBLEManager ble07:_red green:_green blue:_blue BRT:brt];
    NSLog(@"%d,%d,%d,%d",_red,_green,_blue,brt);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
