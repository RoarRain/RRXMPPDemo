//
//  settingViewController.m
//  XmppTest
//
//  Created by roarrain on 15/12/25.
//  Copyright © 2015年 roarrain. All rights reserved.
//

#import "settingViewController.h"
#import "AppDelegate.h"

@interface settingViewController ()<UIGestureRecognizerDelegate>

@end

@implementation settingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    // Do any additional setup after loading the view.
    self.view.backgroundColor = [ UIColor whiteColor];
    self.title = @"设置";
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(120, 100,120 , 60)];
    [btn setTitle:@"退出登录" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithRed:0.444 green:0.589 blue:1.000 alpha:1.000] forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor colorWithRed:0.948 green:0.745 blue:1.000 alpha:1.000]];
    btn.layer.masksToBounds =YES;
    btn.layer.cornerRadius = 5.0f;
    btn.layer.borderWidth = 0.5f;
    btn.layer.borderColor = [UIColor grayColor].CGColor;
    [btn addTarget:self action:@selector(logOut) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(70, CGRectGetMaxY(btn.frame)+100, 230, 60)];
    [imageview setImage:[UIImage imageNamed:@"logo1"]];
    imageview.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goSafari)];
    [imageview addGestureRecognizer:imageGR];
    
    [self.view addSubview:btn];
    [self.view addSubview:imageview];

   
   }


-(void)logOut{

    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];;
    //
        [app goOffLine];
    
}

- (void)goSafari{
    NSLog(@"eqweqwe");
    [[UIApplication sharedApplication ] openURL:[NSURL URLWithString:@"http://www.52hzy.cn"]];


}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
