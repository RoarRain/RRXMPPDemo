//
//  UserInfo.m
//  XmppTest
//
//  Created by roarrain on 15/12/22.
//  Copyright © 2015年 roarrain. All rights reserved.
//

#import "UserInfo.h"


#define USERID @"userName"
#define PASSWORDSTR @"passWordStr"
#define LOGINSTATUS @"loginStatus"


@implementation UserInfo



static UserInfo *_instance;

+(instancetype)sharedUserInfo{
    if (_instance == nil) {
        _instance = [[UserInfo alloc] init];
    }
    return _instance;

}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });

    return _instance;
}


- (void)loadUserInfoFromSandbox{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.userName = [defaults objectForKey:USERID];
    self.pwd = [defaults objectForKey:PASSWORDSTR];
    self.loginStatus = [defaults boolForKey:LOGINSTATUS];

}

- (void)saveUserInfoToSandbox{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.userName forKey:USERID];
    [defaults setObject:self.pwd forKey:PASSWORDSTR];
    [defaults setBool:self.loginStatus forKey:LOGINSTATUS];
    [defaults synchronize];

}

@end
