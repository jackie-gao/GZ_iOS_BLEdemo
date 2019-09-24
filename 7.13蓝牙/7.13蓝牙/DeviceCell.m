//
//  DeviceCell.m
//  7.13蓝牙
//
//  Created by computer on 16/7/14.
//  Copyright © 2016年 computer. All rights reserved.
//

#import "DeviceCell.h"

@implementation DeviceCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)setPeripheral:(CBPeripheral *)peripheral
{
    _peripheral = peripheral;
    if ([peripheral.name isEqualToString:@"KQX-BL1000"]) {
        self.deviceIcon.image = [UIImage imageNamed:@"light"];
    }else
        self.deviceIcon.image = [UIImage imageNamed:@"question"];
    self.lbtitle.text = peripheral.name;
    self.sw.on = peripheral.state == CBPeripheralStateConnected?YES:NO;
}
- (IBAction)switchAction:(UISwitch *)sender {
    if (sender.on) {
        [KBLEManager connect:_peripheral];
    }else
        [KBLEManager disconnect:_peripheral];
}

@end
