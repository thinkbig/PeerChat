//
//  MPTChatDataSource.h
//  MultiPeerTest
//
//  Created by Wayne on 10/29/13.
//  Copyright (c) 2013 Wayne Hartman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *userChatCellID = @"userChatCell";
static NSString *peerChatCellID = @"peerChatCell";

static NSString *systemChateCellID = @"systemChatCell";

static NSString *userAttachmentChatCellID = @"userAttachmentChatCell";
static NSString *peerAttachmentChatCellID = @"peerAttachmentChatCell";

static NSString *userVoiceChatCellID = @"userVoiceChatCell";
static NSString *peerVoiceChatCellID = @"peerVoiceChatCell";

typedef void(^AttachmentPreviewHandler)(NSString *filePath, NSString *cellId);

@interface MPTChatDataSource : NSObject <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) AttachmentPreviewHandler attachmentPreviewHandler;

@end
