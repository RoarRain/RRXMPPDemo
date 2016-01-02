//
//  AppDelegate.m
//  XmppTest
//
//  Created by roarrain on 15/12/19.
//  Copyright © 2015年 roarrain. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginController.h"
#import "MainViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "XMPPFramework.h"
#import "XMPPvCardTemp.h"



@interface AppDelegate (){

    
    XMPPResultBlock _resultBlock;
    XMPPReconnect *_reconnect;

//    XMPPRosterCoreDataStorage *_rosterCoreData;

}



@end

@implementation AppDelegate

@synthesize xmppStream;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    NSString *path =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"沙盒路径 %@",path);
    
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
   
    [[UserInfo sharedUserInfo]loadUserInfoFromSandbox];
    if ([UserInfo sharedUserInfo].loginStatus) {
     
        MainViewController *mainView = [[MainViewController alloc] init];
        UINavigationController *navigat = [[UINavigationController alloc] initWithRootViewController:mainView];
        
        self.window.rootViewController = navigat;
        [self xmppLoginResult:nil];//如果上次登录了  那么直接进入好友界面并连接服务器
    }else{
   
        LoginController *loginVc = [[LoginController alloc] init];
        //    navigat.navigationBar.tintColor = [UIColor greenColor];
        self.window.rootViewController = loginVc;
    }
   
    [self.window makeKeyAndVisible];
    return YES;
}



//设置xmppStream
-(void)setupStream{
     xmppStream = [[XMPPStream alloc] init];
    
//    自动连接
    _reconnect = [[XMPPReconnect alloc] init];
    [_reconnect activate:xmppStream];

    //    开启电子名片功能
    _vCardDataStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardDataStorage];
    [_vCard activate:xmppStream];
//    头像
    _vCardAvata = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    [_vCardAvata activate:xmppStream];
    
//    获取好友列表
    _rosterCoreData = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterCoreData];
    [_roster activate:xmppStream];
//    消息
    _msgArchCoreData = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _messageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_msgArchCoreData];
    [_messageArchiving activate:xmppStream];
    
    
    
    [xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    //    [xmppStream addDelegate:self delegateQueue:dispatch_get_current_queue()];

    NSLog(@"form delegate%@",xmppStream);

}

//连接
-(BOOL)connect{
    NSLog(@"正在连接服务器...");
    if (!xmppStream) {
         [self setupStream];
    }
   
    NSString *userId = nil;

    if (self.isRegist) {
        userId = [UserInfo sharedUserInfo].regUserName;
    }else{
    
        userId = [UserInfo sharedUserInfo].userName;

    }
    
    if (![xmppStream isDisconnected]) {
        return YES;
    }
    if (userId == nil) {
        return NO;
    }
    
    
//    设置用户
    [xmppStream setMyJID:[XMPPJID jidWithUser:userId domain:@"52hzy.cn" resource:@"IPHONE"]];


//    设置服务器
    [xmppStream setHostName:@"52hzy.cn"];
//    [xmppStream setHostName:@"52hzy.cn"];

    
//    连接服务器
    NSError *error = nil;
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"账号或密码为空");
        return NO;
    }
    
    return YES;
  
}


//上线
-(void)goOnLine{
    NSLog(@"发送上线信息");

    XMPPPresence *presence = [XMPPPresence presence];
    [[self xmppStream] sendElement:presence];
}
//下线
-(void)goOffLine{
    NSLog(@"发送离线信息");
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
    [[self xmppStream] sendElement:presence];
     [self disConnect];
}

//断开连接
-(void)disConnect{
    
    
    
    
    NSLog(@"正在断开连接");
   
    [xmppStream disconnect];
    
    [UserInfo sharedUserInfo].loginStatus = NO;
    [[UserInfo sharedUserInfo]saveUserInfoToSandbox];
    LoginController *loginVc = [[LoginController alloc] init];
    //    navigat.navigationBar.tintColor = [UIColor greenColor];
    self.window.rootViewController = loginVc;
    
}



#pragma mark - -XMPPStreamDelegate
//与主机连接成功后验证密码
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"与主机连接成功！");
    
    
     NSError *error = nil;
    if (self.ifRegist) {
    
        NSString *pwd = [UserInfo sharedUserInfo].regPassword;
        [[self xmppStream] registerWithPassword:pwd error:&error];
        
    }else{
        
        NSString *passwordStr = [UserInfo sharedUserInfo].pwd;
        [[self xmppStream] authenticateWithPassword:passwordStr error:&error];

    }
       if (error) {
        NSLog(@"");
    }
}
//连接失败
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
//        如果err为空表示正常断开连接
    NSLog(@"连接失败 %@",error);
    
    if (error && _resultBlock) {
        _resultBlock(XMPPResultNetError);
    }

}
//验证通过
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    NSLog(@"密码验证成功!");
    [self goOnLine];
    
    if (_resultBlock) {
        _resultBlock(XMPPResultLoginSuccess);
    }

}

-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{

    NSLog(@"密码验证失败");
    
    if (_resultBlock) {
        _resultBlock(XMPPResultLoginFaile);
    }

}
//注册成功

-(void)xmppStreamDidRegister:(XMPPStream *)sender{

    NSLog(@"注册成功");
    
    if (_resultBlock) {
        _resultBlock(XMPPResultRegistSuccess);
    }

}

//注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{

    NSLog(@"注册失败 %@",error);
    if (_resultBlock) {
        _resultBlock(XMPPResultRegistFaile);
    }

}
-(void)xmppLoginResult:(XMPPResultBlock)loginResultBlock{
    
    _resultBlock = loginResultBlock;
    [xmppStream disconnect];
    [self connect];
}

//注册
- (void)xmppUserRegistResult:(XMPPResultBlock)registResultBlock{

    _resultBlock = registResultBlock;
    [xmppStream disconnect];
    [self connect];


}

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{

    NSLog(@"=======================================================/n%@",presence);


}
- (void)applicationWillResignActive:(UIApplication *)application {

//    [self disConnect];
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
//    [self connect];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
