//
//  DeviceCell.h
//  7.13蓝牙
//
//  Created by computer on 16/7/14.
//  Copyright © 2016年 computer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEManager.h"
@interface DeviceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *deviceIcon;
@property (weak, nonatomic) IBOutlet UILabel *lbtitle;
@property (weak, nonatomic) IBOutlet UISwitch *sw;
@property (nonatomic,readwrite,strong)CBPeripheral * peripheral;
@end
