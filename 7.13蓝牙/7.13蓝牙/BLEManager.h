//
//  BLEManager.h
//  7.13蓝牙
//
//  Created by computer on 16/7/13.
//  Copyright © 2016年 computer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#define KBLEManager [BLEManager manager]
typedef enum :NSUInteger{
    BLEAnimationType_Three = 0x26,
    BLEAnimationType_Seven = 0x27,
    BLEAnimationType_More  = 0x28,
    BLEAnimationType_Stop  = 0x29,
}BLEAnimationType;
@protocol BLEManagerDelegate<NSObject>
//周边对象列表更新
- (void)bleManagerUpdateDeviceList;
@end
@interface BLEManager : NSObject
@property (nonatomic,readwrite,strong)NSMutableArray * peripheralArr;
@property (nonatomic,readwrite,strong)CBPeripheral * peripheral;
@property (nonatomic,readwrite,weak)id<BLEManagerDelegate>delegate;
+ (instancetype)manager;
//开始扫描
- (void)startScan;
//停止扫描
- (void)stopScan;
//连接某个周边对象
- (void)connect:(CBPeripheral *)peripheral;
//断开与某个对象的连接
- (void)disconnect:(CBPeripheral *)peripheral;
//指令方法
- (void)ble07:(int)red green:(int)green blue:(int)blue;
- (void)bleAnimation:(BLEAnimationType)animationType;
- (void)ble07:(int)red green:(int)green blue:(int)blue BRT:(int)BRT;

@end
