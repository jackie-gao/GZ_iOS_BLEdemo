//
//  ScanfVC.m
//  7.13蓝牙
//
//  Created by computer on 16/7/13.
//  Copyright © 2016年 computer. All rights reserved.
//

#import "ScanfVC.h"
#import "ATRadarAnimationView.h"
#import "BLEManager.h"
#import "DeviceCell.h"
@interface ScanfVC ()<UITableViewDataSource,UITableViewDelegate,BLEManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ScanfVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KBLEManager.delegate = self;
    [KBLEManager startScan];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"DeviceCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"DeviceCell"];
    //刷新-控制器
    UIRefreshControl *refresh = [[UIRefreshControl alloc]init];
    UIColor * refreshColor = [UIColor colorWithRed:16/255.0 green:17/255.0 blue:58/255.0 alpha:1];
    refresh.tintColor =  refreshColor;
    refresh.attributedTitle = [[NSAttributedString alloc]initWithString:@"搜索设备" attributes:@{NSForegroundColorAttributeName:refreshColor}];
    self.tableView.tableHeaderView = refresh;
    [refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    NSLog(@"%@",NSStringFromCGRect([refresh.subviews[0]frame]));
    self.tableView.contentInset = UIEdgeInsetsMake(-81, 0, 0, 0);
}
- (void)refresh:(UIRefreshControl *)refresh
{
    [KBLEManager startScan];
    [refresh performSelector:@selector(endRefreshing) withObject:nil afterDelay:3.f];
    [self.tableView reloadData];
}
#pragma mark tableView - delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return KBLEManager.peripheralArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DeviceCell"];
    cell.peripheral = KBLEManager.peripheralArr[indexPath.row];

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CBPeripheral *per = KBLEManager.peripheralArr[indexPath.row];
    if (per.state == CBPeripheralStateConnected) {
        [self performSegueWithIdentifier:@"goColorPicker" sender:self];
        KBLEManager.peripheral = per;
    }
//    [KBLEManager stopScan];
}
#pragma mark - BLEManagerDelegate

- (void)bleManagerUpdateDeviceList
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}
@end
