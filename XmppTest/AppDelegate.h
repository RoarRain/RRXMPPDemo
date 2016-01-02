//
//  AppDelegate.h
//  XmppTest
//
//  Created by roarrain on 15/12/19.
//  Copyright © 2015年 roarrain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"



typedef enum {
    XMPPResultLoginSuccess,//登录成功
    XMPPResultLoginFaile,//登录失败
    XMPPResultNetError, //网络问题
    XMPPResultRegistSuccess,//注册成功
    XMPPResultRegistFaile//注册失败
}XMPPResultType;


typedef void (^XMPPResultBlock)(XMPPResultType Rtype);

@interface AppDelegate : UIResponder <UIApplicationDelegate,XMPPStreamDelegate>{
    XMPPStream *xmppStream;
    BOOL isOpen;

}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly)XMPPStream *xmppStream;
@property (nonatomic, assign, getter=isRegist)BOOL ifRegist;
@property (nonatomic, strong)XMPPvCardTempModule *vCard;
@property (nonatomic, strong)XMPPvCardCoreDataStorage *vCardDataStorage;
@property (nonatomic, strong)XMPPvCardAvatarModule *vCardAvata;
@property (nonatomic, strong)XMPPRosterCoreDataStorage *rosterCoreData;
@property (nonatomic, strong)XMPPRoster *roster;
@property (nonatomic, strong)XMPPMessageArchiving *messageArchiving;
@property (nonatomic, strong)XMPPMessageArchivingCoreDataStorage *msgArchCoreData;




//是否连接
-(BOOL)connect;
//断开连接
-(void)disConnect;
//设置xmppStream
-(void)setupStream;
//上线
-(void)goOnLine;
//下线
-(void)goOffLine;

//登录返回结果
- (void)xmppLoginResult:(XMPPResultBlock)loginResultBlock;

//注册
- (void)xmppUserRegistResult:(XMPPResultBlock)registResultBlock;

@end

