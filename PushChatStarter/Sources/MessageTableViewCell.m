//
//  MessageTableViewCell.m
//  PushChatStarter
//
//  Created by Kauserali on 28/03/13.
//  Copyright (c) 2013 Ray Wenderlich. All rights reserved.
//

#import "MessageTableViewCell.h"
#import "Message.h"
#import "SpeechBubbleView.h"

static UIColor* color = nil;

@interface MessageTableViewCell() {
    SpeechBubbleView *_bubbleView;
	UILabel *_label;
}
@end

@implementation MessageTableViewCell

+ (void)initialize
{
	if (self == [MessageTableViewCell class])
	{
		color = [UIColor colorWithRed:219/255.0 green:226/255.0 blue:237/255.0 alpha:1.0];
	}
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
	if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
	{
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		// Create the speech bubble view
		_bubbleView = [[SpeechBubbleView alloc] initWithFrame:CGRectZero];
		_bubbleView.backgroundColor = color;
		_bubbleView.opaque = YES;
		_bubbleView.clearsContextBeforeDrawing = NO;
		_bubbleView.contentMode = UIViewContentModeRedraw;
		_bubbleView.autoresizingMask = 0;
		[self.contentView addSubview:_bubbleView];

		// Create the label
		_label = [[UILabel alloc] initWithFrame:CGRectZero];
		_label.backgroundColor = color;
		_label.opaque = YES;
		_label.clearsContextBeforeDrawing = NO;
		_label.contentMode = UIViewContentModeRedraw;
		_label.autoresizingMask = 0;
		_label.font = [UIFont systemFontOfSize:13];
		_label.textColor = [UIColor colorWithRed:64/255.0 green:64/255.0 blue:64/255.0 alpha:1.0];
		[self.contentView addSubview:_label];
	}
	return self;
}

- (void)layoutSubviews
{
	// This is a little trick to set the background color of a table view cell.
	[super layoutSubviews];
	self.backgroundColor = color;
}

- (void)setMessage:(Message*)message
{
	CGPoint point = CGPointZero;

	// We display messages that are sent by the user on the right-hand side of
	// the screen. Incoming messages are displayed on the left-hand side.
	NSString* senderName;
	BubbleType bubbleType;
	if ([message isSentByUser])
	{
		bubbleType = BubbleTypeRighthand;
		senderName = NSLocalizedString(@"You", nil);
		point.x = self.bounds.size.width - message.bubbleSize.width;
		_label.textAlignment = NSTextAlignmentLeft;
	}
	else
	{
		bubbleType = BubbleTypeLefthand;
		senderName = message.senderName;
		_label.textAlignment = NSTextAlignmentRight;
	}

	// Resize the bubble view and tell it to display the message text
	CGRect rect;
	rect.origin = point;
	rect.size = message.bubbleSize;
	_bubbleView.frame = rect;
	[_bubbleView setText:message.text bubbleType:bubbleType];

	// Format the message date
	NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterShortStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDoesRelativeDateFormatting:YES];
	NSString* dateString = [formatter stringFromDate:message.date];

	// Set the sender's name and date on the label
	_label.text = [NSString stringWithFormat:@"%@ @ %@", senderName, dateString];
	[_label sizeToFit];
	_label.frame = CGRectMake(8, message.bubbleSize.height, self.contentView.bounds.size.width - 16, 16);
}

@end
