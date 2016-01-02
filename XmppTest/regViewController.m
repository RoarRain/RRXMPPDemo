//
//  regViewController.m
//  XmppTest
//
//  Created by roarrain on 15/12/21.
//  Copyright © 2015年 roarrain. All rights reserved.
//

#import "regViewController.h"
#import "AppDelegate.h"

@interface regViewController ()<UITextFieldDelegate>
{
    CGFloat _keyBoardHeight;
    int _offset;
    UITextField *_transferTextField;


}


@property(nonatomic, retain) CLProgressHUD *clprogress;

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UITextField *turePwdTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *TextFieldAndTopConstraint;

@end

@implementation regViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"registViewImage"]];
    
    self.userNameTextField.delegate = self;
    self.pwdTextField.delegate = self;
    self.turePwdTextField.delegate = self;
   
    
    _clprogress = [[CLProgressHUD alloc] initWithView:self.view];
    
    [self.view addSubview:_clprogress];
    _clprogress.shape = CLProgressHUDShapeCircle;
    _clprogress.type = CLProgressHUDTypeDarkBackground;

}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHied:) name:UIKeyboardWillHideNotification object:nil];
    
}

//注册按钮
- (IBAction)registBtnClicked:(id)sender {
    NSString *regUserNameStr = self.userNameTextField.text;
    NSString *regPwd = self.pwdTextField.text;
    NSString *regPwdTure = self.turePwdTextField.text;
    
    if (regUserNameStr.length > 0 && regPwd.length > 0 && regPwdTure.length > 0 ) {
        
        if([regPwd isEqualToString:regPwdTure]){
        
            _clprogress.text = @"注册中..";
            [_clprogress show];
            
            UserInfo *userInfo = [UserInfo sharedUserInfo];
            userInfo.regUserName = regUserNameStr;
            userInfo.regPassword = regPwd;
            
            AppDelegate *appdelegates = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appdelegates.ifRegist = YES;
            
            __weak typeof(self) selfVC = self;
            [appdelegates xmppUserRegistResult:^(XMPPResultType Rtype) {
                [selfVC handleLoginResultWithType:Rtype];
            }];

        }else{
        
            [self showAlertWithTitle:@"提示" AndMsgString:@"两次密码不同"];

        
        }
        
        
    }
    else{
        [self showAlertWithTitle:@"提示" AndMsgString:@"请输入用户名或密码"];

    }
    
}



- (void)handleLoginResultWithType:(XMPPResultType)resultType{
    dispatch_sync(dispatch_get_main_queue(), ^{
          [_clprogress dismiss];
        switch (resultType) {
            case XMPPResultRegistSuccess:
                [self showAlertWithTitle:@"注册完成" AndMsgString:@"注册成功,点击确定去登录"];

                break;
            case XMPPResultRegistFaile:
                [self showAlertWithTitle:@"提示" AndMsgString:@"注册失败"];
                break;
            case XMPPResultNetError:
                [self showAlertWithTitle:@"警告" AndMsgString:@"网络连接失败"];
                
                break;
                
            default:
                break;
        }

    });

}

- (void)showAlertWithTitle:(NSString *)msgTitle AndMsgString:(NSString *)msgString{
    
    UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:msgTitle message:msgString preferredStyle:UIAlertControllerStyleAlert];
    [alert1 addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if ([msgString isEqualToString:@"注册成功"]) {
            [self dismissViewControllerAnimated:YES completion:nil];

        }
    }]];
    
    [self presentViewController:alert1 animated:YES completion:nil];
    
}

//取消按钮
- (IBAction)cancelBtnClicked:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)keyboardWillShow:(NSNotification *)notify{
     CGRect begin = [[notify.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect end = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    //解决搜狗等第三方键盘通知多次问题
    if (begin.size.height>0 && (begin.origin.y - end.origin.y >= 0)) {
        _keyBoardHeight = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;

        CGFloat offs = (_transferTextField.frame.origin.y + _transferTextField.frame.size.height) - (self.view.frame.size.height - _keyBoardHeight);
        
         if (offs  > 0) {
                     offs += 30;
                      [UIView animateWithDuration:0.25 animations:^{
        
                          CGRect viewFrame = self.view.frame;
                          viewFrame.origin.y = viewFrame.origin.y - offs;
                          self.view.frame = viewFrame;
                          _offset = offs;
                          [self.view layoutIfNeeded];
                      }];
                }

        
        
    }
}


#pragma mark -- UITextFieldDelegate


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    NSLog(@"%@",textField);
    
    _transferTextField = textField;

    return YES;

}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    
    
    if(self.view.frame.origin.y != 0){
  
        [UIView animateWithDuration:0.25 animations:^{
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y = viewFrame.origin.y + _offset;
        self.view.frame = viewFrame;
        [self.view layoutIfNeeded];
        }];
    }

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
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
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
