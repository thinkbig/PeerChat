//
//  MPTChatBar.m
//  MultiPeerTest
//
//  Created by Wayne on 10/30/13.
//  Copyright (c) 2013 Wayne Hartman. All rights reserved.
//

#import "MPTChatBar.h"

@interface MPTChatBar () <UITextFieldDelegate>

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

- (void)awakeFromNib
{
    if (nil == self.recorder) {
        self.recorder = [[LCVoice alloc] init];
    }
}

#pragma mark - Actions

- (IBAction)holdRecordBtn:(id)sender {
    NSString *trimmedAudioFileBaseName = [NSString stringWithFormat:@"recordingConverted%x.caf", arc4random()];
    NSString *trimmedAudioFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:trimmedAudioFileBaseName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:trimmedAudioFilePath]) {
        NSError *error;
        if ([fileManager removeItemAtPath:trimmedAudioFilePath error:&error] == NO) {
            NSLog(@"removeItemAtPath %@ error:%@", trimmedAudioFilePath, error);
        }
    }
    [self.recorder startRecordWithPath:trimmedAudioFilePath];
}

- (IBAction)didReleaseRecordBtn:(id)sender {
    __block MPTChatBar * weakSelf = self;
    [self.recorder stopRecordWithCompletionBlock:^{
        if (self.voiceHandler) {
            self.voiceHandler(weakSelf.recorder.recordPath);
        }
    }];
}

- (IBAction)cancelRecord:(id)sender {
    [self.recorder cancelled];
}

- (IBAction)didSelectCameraButton:(id)sender {
    if (self.cameraHandler) {
        self.cameraHandler();
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self isValidMessage]) {
        if (self.chatHandler) {
            self.chatHandler([self.inputField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
        }
        
        self.inputField.text = @"";
    }

    return NO;
}

#pragma mark - Notifications

- (void)textFieldTextDidChange:(NSNotification *)notification {
}

#pragma mark - Memory Management

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
