//
//  ChatViewController.h
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "ComposeViewController.h"

@class DataModel;

// The main screen of the app. It shows the history of all messages that
// this user has sent and received. It also opens the Compose screen when
// the user wants to send a new message.
@interface ChatViewController : UITableViewController <ComposeDelegate>

@property (nonatomic, strong, readonly) DataModel* dataModel;

@end
