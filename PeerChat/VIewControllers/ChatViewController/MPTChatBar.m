//
//  MPTChatBar.m
//  MultiPeerTest
//
//  Created by Wayne on 10/30/13.
//  Copyright (c) 2013 Wayne Hartman. All rights reserved.
//

#import "MPTChatBar.h"

@interface MPTChatBar () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *cameraButton;

@end

@implementation MPTChatBar

+ (instancetype)chatBarWithNibName:(NSString *)nibName {
    NSArray *objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];

    MPTChatBar *chatBar = nil;

    for (id object in objects) {
        if ([object isKindOfClass:[MPTChatBar class]]) {
            chatBar = object;
            break;
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:chatBar
                                             selector:@selector(textFieldTextDidChange:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:chatBar.inputField];

    return chatBar;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)resignFirstResponder {
    return [self.inputField resignFirstResponder];
}

- (BOOL)becomeFirstResponder {
    BOOL becameFirstResponder = [self.inputField becomeFirstResponder];

    return becameFirstResponder;
}

- (BOOL)isValidMessage {
    BOOL isValid = YES;

    NSString *message = [self.inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    isValid = message.length > 0;

    return isValid;
}

#pragma mark - Actions

- (IBAction)didSelectSendButton:(id)sender {
    if (self.chatHandler) {
        self.chatHandler([self.inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
    }

    self.inputField.text = @"";
    self.sendButton.enabled = NO;
}

- (IBAction)didSelectCameraButton:(id)sender {
    if (self.cameraHandler) {
        self.cameraHandler();
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self isValidMessage]) {
        [self didSelectSendButton:textField];
    }

    return NO;
}

#pragma mark - Notifications

- (void)textFieldTextDidChange:(NSNotification *)notification {
    self.sendButton.enabled = [self isValidMessage];
}

#pragma mark - Memory Management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
