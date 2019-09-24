//
//  BLEManager.m
//  7.13蓝牙
//
//  Created by computer on 16/7/13.
//  Copyright © 2016年 computer. All rights reserved.
//

#import "BLEManager.h"
#define TIME 0.2
static BLEManager *manager = nil;
@interface BLEManager ()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic,readwrite,strong)CBCentralManager * cbManager;
@property (nonatomic,readwrite,strong)CBCharacteristic * writeCharacteristic;
@property (nonatomic,readwrite,strong)CBCharacteristic * readCharacteristic;

@property (nonatomic,readwrite,getter = isBusy)BOOL busy;
//定时复位 将isbusy设置成NO  Yes代表繁忙 No 代表空闲
@property (nonatomic,readwrite,strong)NSTimer * timer;
@end
@implementation BLEManager
+ (instancetype)manager
{
    if (manager == nil) {
        static dispatch_once_t once;
        dispatch_once(&once,^{
            manager = [[super alloc]init];
        });
    }
    return manager;
}
- (instancetype)init
{
    if (self == [super init]) {
        _cbManager = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)];
        _peripheralArr = [NSMutableArray array];
        [self timer];
    }
    return self;
}
- (NSTimer *)timer
{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:TIME target:self selector:@selector(reSetState) userInfo:nil repeats:YES];
    }
    return _timer;
}
- (void)reSetState
{
    _busy = NO;
}
#pragma mark 开始扫描
- (void)startScan
{
    if (_cbManager.state == CBCentralManagerStatePoweredOn) {//判断蓝牙是否打开
        //填nil 代表搜索所有的对象 不做过滤
        [_cbManager scanForPeripheralsWithServices:nil options:nil];
        // 特定UUID搜索
        // [_cbManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:@"1000"]] options:nil];
    }
}
#pragma mark 停止扫描
- (void)stopScan
{
    if ([_cbManager isScanning]) {
        [_cbManager stopScan];
    }
}
#pragma mark 连接某个周边对象
- (void)connect:(CBPeripheral *)peripheral
{
    [_cbManager connectPeripheral:peripheral options:nil];
}
#pragma mark 断开与某个对象的连接
- (void)disconnect:(CBPeripheral *)peripheral
{
    [_cbManager cancelPeripheralConnection:peripheral];
}
#pragma mark - CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"状态改变了 %ld",(long)central.state);
    [self startScan];
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"%@ ",peripheral.name);
    // 一个周边可能会被多次发现
    if (![_peripheralArr containsObject:peripheral]) {
        [_peripheralArr addObject:peripheral];
        if ([self.delegate respondsToSelector:@selector(bleManagerUpdateDeviceList)]) {
            [self.delegate bleManagerUpdateDeviceList];
        }
    }
}
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"连接成功");
    [self stopScan];
    _peripheral = peripheral;
//    更新列表
    if ([self.delegate respondsToSelector:@selector(bleManagerUpdateDeviceList)]) {
        [self.delegate bleManagerUpdateDeviceList];
    }
//    查看服务nil -->全部
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"断开连接");
}
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
     NSLog(@"连接失败");
}
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict
{
    NSLog(@"恢复状态");
}
#pragma mark - CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error
{
    NSLog(@"%@ -- %@",peripheral.name,RSSI);
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    // 遍历服务
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[CBUUID UUIDWithString:@"1000"]]) {//找到我们需要的服务
            // 查看该服务里面的特征
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic * characteristic in service.characteristics) {
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"1001"]]) {
            _writeCharacteristic = characteristic;
        }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"1002"]]){
            _readCharacteristic = characteristic;
//            监听这个值
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    [self ble31];
    [self ble30];
}
//接到通知
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"接到通知 %@",characteristic.value);
}
#pragma mark - 自定义发送数据
// 55 AA 31 + 6位密码 + 补0 == 17位
// 55 AA 30 + 6位密码 + 补0 == 17位
// 55 AA 07 R G B W lightValue + 补0 == 17位
- (void)ble31
{
    // 1. 编辑指令数组
    int i = 0;
    char dataArr[17] = {0x00};
    dataArr[i++] = 0x55;
    dataArr[i++] = 0xAA;
    dataArr[i++] = 0x31;
    // 2. 打包成data
    NSData *data = [NSData dataWithBytes:dataArr length:17];
    // 3. 发送
    [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}
- (void)ble30
{
    // 1. 编辑指令数组
    int i = 0;
    char dataArr[17] = {0x00};
    dataArr[i++] = 0x55;
    dataArr[i++] = 0xAA;
    dataArr[i++] = 0x30;
    // 2. 打包成data
    NSData * data = [NSData dataWithBytes:dataArr length:17];
    // 3. 发送
    [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}
- (void)ble07:(int)red green:(int)green blue:(int)blue
{
    //编辑指令
    int i = 0;
    char dataArr[17] = {0x00};
    dataArr[i++] = 0x55;
    dataArr[i++] = 0xAA;
    dataArr[i++] = 0x07;// 指令位 0x07 == 7
    dataArr[i++] = red;
    dataArr[i++] = green;
    dataArr[i++] = blue;
    dataArr[i++] = 0xFF;
    dataArr[i++] = 0xFF;
    //打包成data
    NSData * data = [NSData dataWithBytes:dataArr length:17];
    // 发送
    _busy = YES;
    [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}
- (void)ble07:(int)red green:(int)green blue:(int)blue BRT:(int)BRT
{
    int i = 0;
    char dataArr[17] = {0x00};
    dataArr[i++] = 0x55;
    dataArr[i++] = 0xAA;
    dataArr[i++] = 0x07;
    dataArr[i++] = red;
    dataArr[i++] = green;
    dataArr[i++] = blue;
    dataArr[i++] = 0x00;
    dataArr[i++] = BRT;
    NSLog(@"%d",BRT);
    NSData *data = [NSData dataWithBytes:dataArr length:17];
    _busy = YES;
    [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
    
}
- (void)bleAnimation:(BLEAnimationType)animationType
{
    if (self.isBusy) {
        NSLog(@"忙");
        return;
    }
    int i = 0;
    char dataArr[17] = {0x00};
    dataArr[i++] = 0x55;
    dataArr[i++] = 0xAA;
    dataArr[i++] = animationType;
    NSData *data = [NSData dataWithBytes:dataArr length:17];
    [_peripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"已写入");
}
@end
