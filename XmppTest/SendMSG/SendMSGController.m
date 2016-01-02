//
//  SendMSGController.m
//  XmppTest
//
//  Created by roarrain on 15/12/30.
//  Copyright © 2015年 roarrain. All rights reserved.
//

#import "AppDelegate.h"
#import "SendMSGController.h"
#import "msgTableViewCell.h"

@interface SendMSGController ()<UITableViewDelegate,
                                UITableViewDataSource,
                                NSFetchedResultsControllerDelegate,
                                UITextViewDelegate,
                                UIImagePickerControllerDelegate,
                                UINavigationControllerDelegate> {
  NSFetchedResultsController* _fetchResultController;
}

@property(nonatomic, strong) NSLayoutConstraint* sendViewConstraintrBottom;
@property(nonatomic, strong) NSLayoutConstraint* sendViewConstraintrHeight;

@property(nonatomic, strong) UITableView* MSGTableView;

@end

@implementation SendMSGController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.

  [self loadMainView];
  [self loadMSG];
}

- (void)viewWillAppear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWillShow:)
             name:UIKeyboardWillShowNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(keyboardWillHied:)
             name:UIKeyboardWillHideNotification
           object:nil];
}

- (void)loadMainView {
  // AutoLayout
  _MSGTableView = [[UITableView alloc] init];
  _MSGTableView.delegate = self;
  _MSGTableView.dataSource = self;
  _MSGTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  UIView* SendView = [[UIView alloc] init];
  SendView.backgroundColor = [UIColor colorWithWhite:0.672 alpha:1.000];
  [self.view addSubview:_MSGTableView];
  [self.view addSubview:SendView];
  UITextView* msgTextView = [[UITextView alloc] init];
  msgTextView.returnKeyType = UIReturnKeySend;
  msgTextView.delegate = self;
  msgTextView.layer.masksToBounds = YES;
  msgTextView.layer.cornerRadius = 5.0;
  msgTextView.layer.borderWidth = 0.6f;
  msgTextView.layer.borderColor = [UIColor grayColor].CGColor;
  [SendView addSubview:msgTextView];
  UIButton* sendImageBtn = [[UIButton alloc] init];
  [sendImageBtn setTitle:@"照片" forState:UIControlStateNormal];
  [sendImageBtn setTitleColor:[UIColor blackColor]
                     forState:UIControlStateNormal];
  [sendImageBtn setBackgroundColor:[UIColor colorWithRed:1.000
                                                   green:0.922
                                                    blue:0.664
                                                   alpha:1.000]];
  sendImageBtn.layer.masksToBounds = YES;
  sendImageBtn.layer.cornerRadius = 5.0;
  sendImageBtn.layer.borderWidth = 0.6f;
  sendImageBtn.layer.borderColor = [UIColor grayColor].CGColor;
  [sendImageBtn addTarget:self
                   action:@selector(sendImagerbtnClicked)
         forControlEvents:UIControlEventTouchUpInside];
  [SendView addSubview:sendImageBtn];

  SendView.translatesAutoresizingMaskIntoConstraints = NO;
  _MSGTableView.translatesAutoresizingMaskIntoConstraints = NO;
  msgTextView.translatesAutoresizingMaskIntoConstraints = NO;
  sendImageBtn.translatesAutoresizingMaskIntoConstraints = NO;

  NSLayoutConstraint* tableViewConstraintLeft =
      [NSLayoutConstraint constraintWithItem:self.view
                                   attribute:NSLayoutAttributeLeft
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:_MSGTableView
                                   attribute:NSLayoutAttributeLeftMargin
                                  multiplier:1
                                    constant:0];

  NSLayoutConstraint* tableViewConstraintright =
      [NSLayoutConstraint constraintWithItem:self.view
                                   attribute:NSLayoutAttributeRight
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:_MSGTableView
                                   attribute:NSLayoutAttributeRightMargin
                                  multiplier:1.0
                                    constant:0];
  NSLayoutConstraint* tableViewConstraintrTop =
      [NSLayoutConstraint constraintWithItem:self.view
                                   attribute:NSLayoutAttributeTop
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:_MSGTableView
                                   attribute:NSLayoutAttributeTopMargin
                                  multiplier:1.0
                                    constant:0];
  NSLayoutConstraint* tableViewConstraintrBottom =
      [NSLayoutConstraint constraintWithItem:_MSGTableView
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:SendView
                                   attribute:NSLayoutAttributeTop
                                  multiplier:1.0
                                    constant:0];
  _sendViewConstraintrBottom =
      [NSLayoutConstraint constraintWithItem:self.view
                                   attribute:NSLayoutAttributeBottom
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:SendView
                                   attribute:NSLayoutAttributeBottom
                                  multiplier:1.0
                                    constant:0];
  NSLayoutConstraint* sendViewConstraintrLeft =
      [NSLayoutConstraint constraintWithItem:self.view
                                   attribute:NSLayoutAttributeLeft
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:SendView
                                   attribute:NSLayoutAttributeLeft
                                  multiplier:1.0
                                    constant:0];
  NSLayoutConstraint* sendViewConstraintrRight =
      [NSLayoutConstraint constraintWithItem:self.view
                                   attribute:NSLayoutAttributeRight
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:SendView
                                   attribute:NSLayoutAttributeRight
                                  multiplier:1.0
                                    constant:0];
  _sendViewConstraintrHeight =
      [NSLayoutConstraint constraintWithItem:SendView
                                   attribute:NSLayoutAttributeHeight
                                   relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                   attribute:NSLayoutAttributeHeight
                                  multiplier:0
                                    constant:60];

  [self.view addConstraints:@[
    tableViewConstraintLeft,
    tableViewConstraintright,
    tableViewConstraintrTop,
    tableViewConstraintrBottom,
    _sendViewConstraintrBottom,
    sendViewConstraintrLeft,
    sendViewConstraintrRight,
    _sendViewConstraintrHeight
  ]];

  //    VFL

  NSDictionary* viewDic = @{
    @"msgTextField" : msgTextView,
    @"sendImageBtn" : sendImageBtn
  };

  NSArray* msgTextFieldConstraintsV = [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|-15-[msgTextField]-15-|"
                          options:0
                          metrics:nil
                            views:viewDic];
  NSArray* senImageBtnConstraintsV = [NSLayoutConstraint
      constraintsWithVisualFormat:@"V:|-15-[sendImageBtn]-15-|"
                          options:0
                          metrics:nil
                            views:viewDic];
  NSArray* msgTextFieldConstraintsH =
      [NSLayoutConstraint constraintsWithVisualFormat:
                              @"H:|-10-[msgTextField]-20-[sendImageBtn(50)]-|"
                                              options:0
                                              metrics:nil
                                                views:viewDic];
  [SendView addConstraints:msgTextFieldConstraintsV];
  [SendView addConstraints:senImageBtnConstraintsV];
  [SendView addConstraints:msgTextFieldConstraintsH];
  //    [SendView addConstraints:msgTextFieldConstraintsV]
}

- (void)loadMSG {
  AppDelegate* appDelegate =
      (AppDelegate*)[UIApplication sharedApplication].delegate;

  NSManagedObjectContext* msgContext =
      appDelegate.msgArchCoreData.mainThreadManagedObjectContext;
  NSFetchRequest* msgRequest =
      [NSFetchRequest fetchRequestWithEntityName:
                          @"XMPPMessageArchiving_Message_CoreDataObject"];

  UserInfo* userInfo = [UserInfo sharedUserInfo];
  NSString* userJID =
      [NSString stringWithFormat:@"%@@52hzy.cn", userInfo.userName];
  NSPredicate* msgPredicate = [NSPredicate
      predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@", userJID,
                          _friendJID.bare];
  msgRequest.predicate = msgPredicate;
  NSSortDescriptor* msgTimeSort =
      [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];

  msgRequest.sortDescriptors = @[ msgTimeSort ];

  _fetchResultController =
      [[NSFetchedResultsController alloc] initWithFetchRequest:msgRequest
                                          managedObjectContext:msgContext
                                            sectionNameKeyPath:nil
                                                     cacheName:nil];
  _fetchResultController.delegate = self;
  NSError* err = nil;
  [_fetchResultController performFetch:&err];
  if (err) {
    NSLog(@"%@", err);
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
  NSLog(@"数据发生改变了");

  NSLog(@"%@", _fetchResultController.fetchedObjects);

  [_MSGTableView reloadData];
  [self scrollToBottom];
}

- (void)sendImagerbtnClicked {
  UIImagePickerController* imagePicker = [[UIImagePickerController alloc] init];
  imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  imagePicker.delegate = self;
  [self presentViewController:imagePicker animated:YES completion:nil];
}

- (UITableViewCell*)tableView:(UITableView*)tableView
        cellForRowAtIndexPath:(NSIndexPath*)indexPath {
  static NSString* CellID = @"msgTableViewCell";

  msgTableViewCell* msgCell =
      [tableView dequeueReusableCellWithIdentifier:CellID];
  if (!msgCell) {
    msgCell = [[[NSBundle mainBundle] loadNibNamed:CellID owner:nil options:nil]
        firstObject];
    //        msgCell.contentView.backgroundColor = [UIColor redColor];
  }
  XMPPMessageArchiving_Message_CoreDataObject* msg =
      _fetchResultController.fetchedObjects[indexPath.row];
    
    NSString *messageType = [msg.message attributeStringValueForName:@"messageType"];

  //   判断一下是不是自己发的
  if ([msg.outgoing boolValue]) {
      if ([messageType isEqualToString:@"image"]) {
          NSData *imagedata = [[NSData alloc] initWithBase64EncodedString:msg.body options:0];
          UIImage *msgimage = [[UIImage alloc] initWithData:imagedata];
          msgCell.imageView.image = msgimage;
          
      }else{
          msgCell.msgLabel.textColor = [UIColor greenColor];
          msgCell.msgLabel.text = [NSString stringWithFormat:@"我说:%@", msg.body];
      }
    
  } else {
      if ([messageType isEqualToString:@"image"]) {
          NSData *imagedata = [[NSData alloc] initWithBase64EncodedString:msg.body options:0];
          UIImage *msgimage = [[UIImage alloc] initWithData:imagedata];
          msgCell.imageView.image = msgimage;
          
      }else{
          msgCell.msgLabel.textColor = [UIColor redColor];
          msgCell.msgLabel.text =
          [NSString stringWithFormat:@"%@说:%@", _friendJID.user, msg.body];
      }

  }

  return msgCell;
}

- (NSInteger)tableView:(UITableView*)tableView
 numberOfRowsInSection:(NSInteger)section {
  return _fetchResultController.fetchedObjects.count;
}

- (CGFloat)tableView:(UITableView*)tableView
    heightForRowAtIndexPath:(NSIndexPath*)indexPath {
  return 80;
}

#pragma mark-- TextViewDelegate
- (void)textViewDidChange:(UITextView*)textView {
  //   CGFloat contentHeight = textView.contentSize.height;
  ////    _sendViewConstraintrHeight.constant = contentHeight;
  ////    NSLog(@"2222%@",size);

  NSString* textStr = textView.text;

  if ([textStr rangeOfString:@"\n"].length != 0) {
    [textStr
        stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]];  //取出换行符

    [self sendMSGWithString:textStr AndMsgType:@"text"];
    textView.text = nil;

  } else {
  }
}

- (void)sendMSGWithString:(NSString*)textStr AndMsgType:(NSString*)msgType {
  XMPPMessage* msg = [XMPPMessage messageWithType:@"chat" to:self.friendJID];

  [msg addAttributeWithName:@"messageType" stringValue:msgType];
  [msg addBody:textStr];
  AppDelegate* dlg = (AppDelegate*)[[UIApplication sharedApplication] delegate];

  [dlg.xmppStream sendElement:msg];
}

- (void)scrollToBottom {
  NSInteger lastRow = _fetchResultController.fetchedObjects.count - 1;
  if (lastRow < 0) {
    return;
  }

  NSIndexPath* lastPath = [NSIndexPath indexPathForRow:lastRow inSection:0];
  [self.MSGTableView scrollToRowAtIndexPath:lastPath
                           atScrollPosition:UITableViewScrollPositionBottom
                                   animated:YES];
}

- (void)imagePickerController:(UIImagePickerController*)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString*, id>*)info {
  UIImage* pickImage = info[UIImagePickerControllerOriginalImage];
  NSData* imageData = UIImagePNGRepresentation(pickImage);
  NSString* base64Str = [imageData base64EncodedStringWithOptions:0];
  [self sendMSGWithString:base64Str AndMsgType:@"image"];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)keyboardWillShow:(NSNotification*)notify {
  CGFloat keyBoardENDY =
      [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]
          .origin.y;
  CGRect begin = [[notify.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey]
      CGRectValue];
  CGRect end = [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey]
      CGRectValue];
  //解决搜狗等第三方键盘通知多次问题
  if (begin.size.height > 0 && (begin.origin.y - end.origin.y > 0)) {
    [UIView
        animateWithDuration:0.25
                 animations:^{

                   _sendViewConstraintrBottom.constant =
                       [UIScreen mainScreen].bounds.size.height - keyBoardENDY;

                   [self.view layoutIfNeeded];
                 }];
    //
  }
  [self scrollToBottom];
}

- (void)keyboardWillHied:(NSNotification*)notify {
  CGFloat keyBoardENDY =
      [[notify.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]
          .origin.y;
  [UIView
      animateWithDuration:0.25
               animations:^{

                 _sendViewConstraintrBottom.constant =
                     [UIScreen mainScreen].bounds.size.height - keyBoardENDY;
                 [self.view layoutIfNeeded];

               }];
}

- (void)viewWillDisappear:(BOOL)animated {
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardWillShowNotification
              object:nil];
  [[NSNotificationCenter defaultCenter]
      removeObserver:self
                name:UIKeyboardWillHideNotification
              object:nil];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
