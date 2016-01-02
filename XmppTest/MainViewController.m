//
//  MainViewController.m
//  XmppTest
//
//  Created by roarrain on 15/12/19.
//  Copyright © 2015年 roarrain. All rights reserved.
//

#import "MainViewController.h"
#import "LoginController.h"
#import "AppDelegate.h"
#import "myViewController.h"
#import "settingViewController.h"
#import "friendListCell.h"
#import "SendMSGController.h"

#define FRIENDCELLIDENTIFIER @"friendListCell"

@interface MainViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>
{
    
//    监听数据库数据改变
    NSFetchedResultsController *_resultsController;


}
@property (nonatomic,retain)UITableView *userListTableView;
@property (nonatomic, retain)NSArray *friendListArray;//在线用户数组
@property (nonatomic, retain) NSString *chatUserName;
@property (nonatomic, strong) UITextField *searchFriendTextField;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = @"好友列表";

    [self loadSelfView];
  
    
    
}


- (void)loadSelfView{

    _userListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    _userListTableView.delegate = self;
    _userListTableView.dataSource = self;
    [self.view addSubview:_userListTableView];
    [_userListTableView setTableFooterView:[[UIView alloc]init]];
    UIView *tableViewHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 70)];
    [_userListTableView setTableHeaderView:tableViewHeaderView];
    _searchFriendTextField = [[UITextField alloc] init];
    _searchFriendTextField.layer.masksToBounds = YES;
    _searchFriendTextField.layer.cornerRadius = 5.0f;
    _searchFriendTextField.layer.borderWidth = 0.8;
    _searchFriendTextField.layer.borderColor = [UIColor grayColor].CGColor;
    _searchFriendTextField.placeholder = @"请输入好友账号";
   
    
    UIButton *addFriendBtn = [[UIButton alloc] init];
    [addFriendBtn setTitle:@"添加" forState:UIControlStateNormal];
    [addFriendBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [addFriendBtn setBackgroundColor:[UIColor colorWithRed:0.722 green:0.864 blue:1.000 alpha:1.000]];
    addFriendBtn.layer.masksToBounds = YES;
    addFriendBtn.layer.cornerRadius = 5.0f;
    addFriendBtn.layer.borderWidth = 0.8;
    addFriendBtn.layer.borderColor = [UIColor grayColor].CGColor;


    [addFriendBtn addTarget:self action:@selector(addFriendBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    _searchFriendTextField.translatesAutoresizingMaskIntoConstraints = NO;
    addFriendBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    [tableViewHeaderView addSubview:_searchFriendTextField]; 
    [tableViewHeaderView addSubview:addFriendBtn];

    NSDictionary *headerViewDic = @{
      @"textField" : _searchFriendTextField,
      @"addBTn" : addFriendBtn
    };

    NSArray *headerViewV = [NSLayoutConstraint
        constraintsWithVisualFormat:@"V:|-15-[textField]-15-|"
                            options:0
                            metrics:nil
                              views:headerViewDic];

    NSArray *headerViewBtnV =
        [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[addBTn]-15-|"
                                                options:0
                                                metrics:nil
                                                  views:headerViewDic];
    NSArray *headerViewH = [NSLayoutConstraint
        constraintsWithVisualFormat:@"H:|-25-[textField]-10-[addBTn(50)]-20-|"
                            options:0
                            metrics:nil
                              views:headerViewDic];
    [tableViewHeaderView addConstraints:headerViewV];
    [tableViewHeaderView addConstraints:headerViewH];
    [tableViewHeaderView addConstraints:headerViewBtnV];

    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithTitle:@"设置"
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(goSetting:)];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc]initWithTitle:@"我的"
                                                             style:UIBarButtonItemStylePlain
                                                            target:self
                                                            action:@selector(goMyInfo:)];
    
    
    self.navigationItem.leftBarButtonItem = item2;
    self.navigationItem.rightBarButtonItem = item;
  
    
    [self loadFriendList];


}

//获取好友列表
- (void)loadFriendList{
//从数据库中获取
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSLog(@"form main%@",appDelegate.xmppStream);
    
    NSManagedObjectContext *context = appDelegate.rosterCoreData.mainThreadManagedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
//    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([XMPPUserCoreDataStorageObject class])];
    UserInfo *userInfo = [UserInfo sharedUserInfo];
    NSString *userJID = [NSString stringWithFormat:@"%@@52hzy.cn",userInfo.userName];
    NSPredicate *predicateSql = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@",userJID];
    NSPredicate *predicateSql1 = [NSPredicate predicateWithFormat:@"subscription = %@",@"both"];


    request.predicate = predicateSql;
     request.predicate = predicateSql1;
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:NO];
    
    request.sortDescriptors = @[sortDescriptor];
    
//    self.friendListArray = [context executeFetchRequest:request error:nil];
    
    _resultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _resultsController.delegate = self;
    
    NSError *err = nil;
    [_resultsController performFetch:&err];
    
    NSLog(@"好友列表++=====%@",self.friendListArray);

    
    
}

-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    NSLog(@"数据发生改变了");
    
    NSLog(@"%@",_resultsController.fetchedObjects);

    
    [_userListTableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _resultsController.fetchedObjects.count;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    friendListCell *friendCell = [tableView dequeueReusableCellWithIdentifier:FRIENDCELLIDENTIFIER];
    if (!friendCell) {
        friendCell = [[[NSBundle mainBundle] loadNibNamed:FRIENDCELLIDENTIFIER owner:nil options:nil] firstObject];
        friendCell.userImageView.layer.masksToBounds = YES;
        friendCell.userImageView.layer.cornerRadius = friendCell.userImageView.frame.size.height/2;
        friendCell.userImageView.layer.borderWidth = 0.5;
    }
    
    XMPPUserCoreDataStorageObject *userObj = _resultsController.fetchedObjects[indexPath.row];
    
    if ([userObj.subscription isEqualToString:@"both"]) {
        
        if (userObj.nickname != nil) {
             [friendCell.userNameLabel setText:userObj.nickname];
        }else{
            [friendCell.userNameLabel setText:userObj.jidStr];
      
        }
        
       
        switch ([userObj.sectionNum intValue]) {
            case 0:
            case 1:
//                friendCell.detailTextLabel.text = @"在线";
                [friendCell.userImageView setImage:userObj.photo];
                break;
            case 2:
//                friendCell.detailTextLabel.text = @"离线";
                [friendCell.userImageView setImage:[Tools grayImage:userObj.photo]];
                break;
                
            default:
                break;
        }
        
    }
    
    
    return friendCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    friendListCell *friendCell = [tableView dequeueReusableCellWithIdentifier:FRIENDCELLIDENTIFIER];
    return 80;
 

}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    XMPPUserCoreDataStorageObject *userObj = _resultsController.fetchedObjects[indexPath.row];
    
    SendMSGController *sendMsg = [[SendMSGController alloc] init];
    sendMsg.friendJID = userObj.jid;
    
    [self.navigationController pushViewController:sendMsg animated:YES];

    [self performSelector:@selector(cancleSelectBG) withObject:nil afterDelay:0.25];

}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        XMPPUserCoreDataStorageObject *userObj = _resultsController.fetchedObjects[indexPath.row];

        [app.roster removeUser:userObj.jid];
        
    }


}



- (void)cancleSelectBG{

    [_userListTableView deselectRowAtIndexPath:[self.userListTableView indexPathForSelectedRow] animated:nil];

}

-(void)goSetting:(id)sender{
    //直接调用 appdelegate的注销方法
//    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];;
//    
//    [app goOffLine];
    
    settingViewController *settingVC = [[settingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];


}

- (void)addFriendBtnClicked{
//    添加好友
    
    AppDelegate *appdelgate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    
    NSString *JIDStr = [NSString stringWithFormat:@"%@@52hzy.cn",_searchFriendTextField.text];
     XMPPJID *friendJid = [XMPPJID jidWithString:JIDStr];
    
    
    
    if ([_searchFriendTextField.text isEqualToString:[UserInfo sharedUserInfo].userName]) {
        UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"提示" message:@"不能添加自己为好友" preferredStyle:UIAlertControllerStyleAlert];
        [alert1 addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert1 animated:YES completion:nil];
        return;
    }
    
//    判断有没有好友
    if([appdelgate.rosterCoreData userExistsWithJID:friendJid xmppStream:appdelgate.xmppStream]){
    
        UIAlertController *alert1 = [UIAlertController alertControllerWithTitle:@"提示" message:@"已经是你的好友了" preferredStyle:UIAlertControllerStyleAlert];
        [alert1 addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [self presentViewController:alert1 animated:YES completion:nil];
      

    }else{
        [appdelgate.roster subscribePresenceToUser:friendJid];

  
    }
   
}

-(void)goMyInfo:(id)sender{
    
    myViewController *myvc = [[myViewController alloc] init];
    [self.navigationController pushViewController:myvc animated:YES];
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
