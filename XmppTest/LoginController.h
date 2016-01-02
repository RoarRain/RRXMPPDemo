//
//  LoginController.h
//  XmppTest
//
//  Created by roarrain on 15/12/19.
//  Copyright © 2015年 roarrain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *userIDTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end
