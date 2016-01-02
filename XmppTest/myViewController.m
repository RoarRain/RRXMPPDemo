//
//  ViewController.m
//  XmppTest
//
//  Created by roarrain on 15/12/24.
//  Copyright © 2015年 roarrain. All rights reserved.
//

#import "myViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
#import "UserInfo.h"


@interface myViewController ()

@end

@implementation myViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
   
//    获取个人信息
    XMPPvCardTemp *myVcard = app.vCard.myvCardTemp;
//    设置头像
    if(!myVcard.photo){
    
       
    
    }
    
//    昵称
    NSLog(@"昵称: %@",myVcard.nickname) ;
//    账号
    NSLog(@"账号: %@",[UserInfo sharedUserInfo].userName);

////    更新上传服务器
//    [app.vCard updateMyvCardTemp:myVcard];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
