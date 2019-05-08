//
//  SubViewController.m
//  PageControllerDemo
//
//  Created by visager on 2019/5/7.
//  Copyright © 2019 Visager. All rights reserved.
//
 
#import "SubViewController.h"

@interface SubViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation SubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellID"];

    // Do any additional setup after loading the view from its nib.
}

#pragma mark -------- FYX：UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellID" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"--------------------%ld",indexPath.row];
    return cell ;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arc4random()%20;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

@end
