//
//  MPTChatBar.h
//  MultiPeerTest
//
//  Created by Wayne on 10/30/13.
//  Copyright (c) 2013 Wayne Hartman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LCVoice.h"

typedef void(^ChatHandler)(NSString *message);
typedef void(^CameraHandler)(void);
typedef void(^VoiceHandler)(NSString *voicePath);

@interface MPTChatBar : UIToolbar 

@property (nonatomic, copy) ChatHandler                         chatHandler;
@property (nonatomic, copy) CameraHandler                       cameraHandler;
@property (nonatomic, copy) VoiceHandler                        voiceHandler;

@property (nonatomic, strong) LCVoice *                         recorder;

@property (weak, nonatomic) IBOutlet UITextField *inputField;

+ (instancetype)chatBarWithNibName:(NSString *)nibName;

@end
