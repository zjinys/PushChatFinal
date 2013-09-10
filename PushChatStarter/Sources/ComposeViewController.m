//
//  ComposeViewController.m
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "ComposeViewController.h"
#import "DataModel.h"
#import "Message.h"

@interface ComposeViewController ()
@property (nonatomic, retain) IBOutlet UITextView* messageTextView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem* saveItem;
@property (nonatomic, retain) IBOutlet UINavigationBar* navigationBar;
- (void)updateBytesRemaining:(NSString*)text;
@end

@implementation ComposeViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self updateBytesRemaining:@""];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[_messageTextView becomeFirstResponder];
}

#pragma mark -
#pragma mark Actions

- (void)userDidCompose:(NSString*)text
{
	// Create a new Message object
	Message* message = [[Message alloc] init];
	message.senderName = nil;
	message.date = [NSDate date];
	message.text = text;

	// Add the Message to the data model's list of messages
	int index = [_dataModel addMessage:message];

	// Add a row for the Message to ChatViewController's table view.
	// Of course, ComposeViewController doesn't really know that the
	// delegate is the ChatViewController.
	[self.delegate didSaveMessage:message atIndex:index];

	// Close the Compose screen
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postMessageRequest
{
    [_messageTextView resignFirstResponder];
    
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = NSLocalizedString(@"Sending", nil);
    
    NSString* text = self.messageTextView.text;
    
    NSDictionary *params = @{@"cmd":@"message",
                             @"user_id":[_dataModel userId],
                             @"text":text};
    
    [_client
     postPath:@"/api.php"
     parameters:params
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         [MBProgressHUD hideHUDForView:self.view animated:YES];
         if (operation.response.statusCode != 200) {
             ShowErrorAlert(NSLocalizedString(@"Could not send the message to the server", nil));
         } else {
             [self userDidCompose:text];
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if ([self isViewLoaded]) {
             [MBProgressHUD hideHUDForView:self.view animated:YES];
             ShowErrorAlert([error localizedDescription]);
         }
     }];
}

- (IBAction)cancelAction
{
	[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAction
{
    [self postMessageRequest];
}

#pragma mark -
#pragma mark UITextViewDelegate

- (void)updateBytesRemaining:(NSString*)text
{
	// Calculate how many bytes long the text is. We will send the text as
	// UTF-8 characters to the server. Most common UTF-8 characters can be
	// encoded as a single byte, but multiple bytes as possible as well.
	const char* s = [text UTF8String];
	size_t numberOfBytes = strlen(s);

	// Calculate how many bytes are left
	int remaining = MaxMessageLength - numberOfBytes;

	// Show the number of remaining bytes in the navigation bar's title
	if (remaining >= 0)
		self.navigationBar.topItem.title = [NSString stringWithFormat:NSLocalizedString(@"%d Remaining", nil), remaining];
	else
		self.navigationBar.topItem.title = NSLocalizedString(@"Text Too Long", nil);

	// Disable the Save button if no text is entered, or if it is too long
	self.saveItem.enabled = (remaining >= 0) && (text.length != 0);
}

- (BOOL)textView:(UITextView*)theTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString*)text
{
	NSString* newText = [theTextView.text stringByReplacingCharactersInRange:range withString:text];
	[self updateBytesRemaining:newText];
	return YES;
}
@end
