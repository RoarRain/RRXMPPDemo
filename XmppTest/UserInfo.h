//
//  UserInfo.h
//  XmppTest
//
//  Created by roarrain on 15/12/22.
//  Copyright © 2015年 roarrain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *pwd;
@property (nonatomic, assign) BOOL loginStatus;
@property (nonatomic, copy) NSString *regUserName;
@property (nonatomic, copy) NSString *regPassword;


+ (instancetype)sharedUserInfo;

/**
 *  从沙盒里获取用户数据
 */
-(void)loadUserInfoFromSandbox;

/**
 *  保存用户数据到沙盒
 
 */
-(void)saveUserInfoToSandbox;




@end
