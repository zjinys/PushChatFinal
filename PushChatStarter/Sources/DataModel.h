//
//  DataModel.h
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

@class Message;

// The main data model object
@interface DataModel : NSObject

// The complete history of messages this user has sent and received, in
// chronological order (oldest first).
@property (nonatomic, strong) NSMutableArray* messages;

// Loads the list of messages from a file.
- (void)loadMessages;

// Saves the list of messages to a file.
- (void)saveMessages;

// Adds a message that the user composed himself or that we received through
// a push notification. Returns the index of the new message in the list of
// messages.
- (int)addMessage:(Message*)message;

// Get and set the user's nickname.
- (NSString*)nickname;
- (void)setNickname:(NSString*)name;

// Get and set the secret code that the user is registered for.
- (NSString*)secretCode;
- (void)setSecretCode:(NSString*)string;

// Determines whether the user has successfully joined a chat.
- (BOOL)joinedChat;
- (void)setJoinedChat:(BOOL)value;

- (NSString*)userId;
- (NSString*)deviceToken;
- (void)setDeviceToken:(NSString*)token;
@end
