//
//  ComposeViewController.h
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

@class ComposeViewController;
@class DataModel;
@class Message;

// The delegate protocol for the Compose screen
@protocol ComposeDelegate <NSObject>
- (void)didSaveMessage:(Message*)message atIndex:(int)index;
@end

// The Compose screen lets the user write a new message
@interface ComposeViewController : UIViewController <UITextViewDelegate>

@property (nonatomic, assign) id<ComposeDelegate> delegate;
@property (nonatomic, assign) DataModel* dataModel;
@property (nonatomic, strong) AFHTTPClient *client;
@end
