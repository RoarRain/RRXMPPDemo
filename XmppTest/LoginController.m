//
//  LoginController.m
//  XmppTest
//
//  Created by roarrain on 15/12/19.
//  Copyright © 2015年 roarrain. All rights reserved.
//

#import "LoginController.h"
#import "AppDelegate.h"
#import "MainViewController.h"
#import "regViewController.h"

@interface LoginController ()<UITextFieldDelegate>{

    int _offset;

}
//@property (weak, nonatomic) IBOutlet UIView *userNamePwdView;
@property(nonatomic, retain) CLProgressHUD *clprogress;
@property (weak, nonatomic) IBOutlet UIView *userNamePwdView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewAndLoginBtn;


@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    AppDelegate *appDelegate = [self appDelegate];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"loginViewImage"]];
    
    self.userNamePwdView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pwdViewImage"]];
    [self.view endEditing:YES];
    
    self.userIDTextField.delegate = self;
    self.pwdTextField.delegate = self;

}


-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHied:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)LoginBtn:(id)sender {
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    NSString *userId = [defaults stringForKey:USERID];
//    NSString *pass = [defaults stringForKey:PASSWORD];
//    NSString *server = [defaults stringForKey:SERVER];
    
    
    NSString *userIdText = self.userIDTextField.text;
    NSString *pwdText = self.pwdTextField.text;
    _clprogress = [[CLProgressHUD alloc] initWithView: self.view ];
    [self.view addSubview: _clprogress];
    _clprogress.shape = CLProgressHUDShapeCircle;
    _clprogress.type = CLProgressHUDTypeDarkBackground;
    _clprogress.text = @"正在登录...";

    
    if (userIdText.length>0 && pwdText.length>0 ) {
            [_clprogress show];
//        [NSThread sleepForTimeInterval:3.0f];
//        [NSThread sleepForTimeInterval:3.0f];
//        [_clprogress dismiss];
        UserInfo *userinfo = [UserInfo sharedUserInfo];
        userinfo.userName = userIdText;
        userinfo.pwd = pwdText;
        
        
        [self appDelegate].ifRegist = NO;
        __weak typeof(self) selfVC = self;
        
        [[self appDelegate] xmppLoginResult:^(XMPPResultType Rtype) {
            [selfVC handleLoginResultWithType:Rtype];
        }];

    }else{
       
        [self showAlertWithTitle:@"提示" AndMsgString:@"请输入正确的账号密码"];
    }
    
  
}


- (AppDelegate *)appDelegate{

    return (AppDelegate *)[[UIApplication sharedApplication] delegate];

}

- (void)handleLoginResultWithType:(XMPPResultType)resultType{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        switch (resultType) {
            case XMPPResultLoginSuccess:
                _clprogress.text = @"登录成功";
                [_clprogress dismiss];
                [self enterMainPage];
                break;
            case XMPPResultLoginFaile:
                  [_clprogress dismiss];
                [self showAlertWithTitle:@"提示" AndMsgString:@"用户名或密码不正确"];
                break;
            case XMPPResultNetError:
                  [_clprogress dismiss];
                [self showAlertWithTitle:@"警告" AndMsgString:@"网络连接失败"];
                break;
                
            default:
                break;
        }

    });
    
}

- (void)enterMainPage{

    [UserInfo sharedUserInfo].loginStatus = YES;
    [[UserInfo sharedUserInfo]saveUserInfoToSandbox];
  
    MainViewController *mainView = [[MainViewController alloc] init];
     UINavigationController *navigat = [[UINavigationController alloc] initWithRootViewController:mainView];
    self.view.window.rootViewController = navigat;
    


}


- (void)showAlertWithTitle:(NSString *)msgTitle AndMsgString:(NSString *)msgString{

    UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:msgTitle message:msgString preferredStyle:UIAlertControllerStyleAlert];
    [alert1 addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [self presentViewController:alert1 animated:YES completion:nil];

}
- (IBAction)registBtn:(id)sender {
    
    regViewController *registVC = [[regViewController alloc] init];
    [self presentViewController:registVC animated:YES completion:nil];
    
}


- (void)keyboardWillShow:(NSNotification *)notify{

    
    CGFloat keyBoardHeight = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGRect begin = [[notify.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect end = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
   //解决搜狗等第三方键盘通知多次问题
    if (begin.size.height>0 && (begin.origin.y - end.origin.y > 0)) {
        
         [UIView animateWithDuration:0.25 animations:^{
        
          CGFloat offs = (self.userNamePwdView.frame.origin.y + self.userNamePwdView.frame.size.height) - (self.view.frame.size.height - keyBoardHeight);
             
          
             if (offs  > 0) {
                    offs += 30;
                 self.viewAndLoginBtn.constant = self.viewAndLoginBtn.constant + offs;
                 _offset = offs;
                 NSLog(@" constant %f",self.viewAndLoginBtn.constant);
                 [self.view layoutIfNeeded];
          
                }
         }];
        
    }
}

- (void)keyboardWillHied:(NSNotification *)notify{
 
        [UIView animateWithDuration:0.25 animations:^{
         
                self.viewAndLoginBtn.constant = self.viewAndLoginBtn.constant - _offset;
                NSLog(@" constant %f",self.viewAndLoginBtn.constant);
                [self.view layoutIfNeeded];
        
        }];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{


    [self.view endEditing:YES];

    
    
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];

}



-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

}


-(void)dealloc{


    NSLog(@"%s 销毁",__func__);
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
