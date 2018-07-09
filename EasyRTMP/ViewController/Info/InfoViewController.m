//
//  EasyDarwinInfoViewController.m
//  EasyPusher
//
//  Created by yingengyue on 2017/3/4.
//  Copyright © 2017年 phylony. All rights reserved.
//

#import "InfoViewController.h"
#import "WebViewController.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (instancetype) initWithStoryboard {
    return [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"InfoViewController"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"关于";
}

- (IBAction)easyDSS:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    WebViewController *controller = [[WebViewController alloc] init];
    controller.title = @"EasyDSS";
    controller.url = btn.titleLabel.text;
    [self basePushViewController:controller];
}

- (IBAction)github:(id)sender {
    UIButton *btn = (UIButton *)sender;
    
    WebViewController *controller = [[WebViewController alloc] init];
    controller.title = @"EasyPlayPro";
    controller.url = btn.titleLabel.text;
    [self basePushViewController:controller];
}


@end
