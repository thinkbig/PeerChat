//
//  MPTChatViewController.m
//  MultiPeerTest
//
//  Created by Wayne on 10/29/13.
//  Copyright (c) 2013 Wayne Hartman. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MPTChatViewController.h"
#import "MPTImageViewController.h"
#import "MPTChatDataSource.h"
#import "MPTChatBar.h"
#import "MPTDataController.h"
#import "PeerManager.h"
#import "UserWrapper.h"
#import "PeerStatViewController.h"

#import "UIActionSheet+Blocks.h"

@interface MPTChatViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet MPTChatDataSource *dataSource;
@property (strong, nonatomic) IBOutlet UITextField *firstResponderField;
@property (nonatomic, strong) MPTChatBar *chatBar;
@property (nonatomic, strong) AVAudioPlayer *player;

@end

#define SEGUE_IMAGE_PREVIEW @"SEGUE_IMAGE_PREVIEW"

@implementation MPTChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource.tableView = self.tableView;
    self.chatBar = [MPTChatBar chatBarWithNibName:@"MPTChatBar"];
    self.firstResponderField.inputAccessoryView = self.chatBar;
    self.dataSource.tabBar = self.chatBar;
    
    
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chat_bg_default"]];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;

    __weak MPTChatViewController *weakSelf = self;
    self.chatBar.chatHandler = ^(NSString *message) {
        [[PeerManager sharedInst] sendMessage:message toGroup:weakSelf.roomName];
    };
    
    //==========camer handler======
    self.chatBar.cameraHandler = ^{
        
        void(^selectImage)(BOOL) = ^(BOOL fromCamera) {
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if (!fromCamera) {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
            UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
            pickerController.delegate = weakSelf;
            pickerController.allowsEditing = YES;
            pickerController.sourceType = sourceType;
            
            [weakSelf.navigationController presentViewController:pickerController animated:YES completion:NULL];
        };
        
        UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Select Image Source" cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel" action:nil] destructiveButtonItem:nil otherButtonItems:[RIButtonItem itemWithLabel:@"Camera" action:^{
            selectImage(YES);
        }], [RIButtonItem itemWithLabel:@"Album" action:^{
            selectImage(NO);
        }], nil];
        [sheet showInView:[UIApplication sharedApplication].keyWindow];

    };
    
    //==========voice handler========
    
    self.chatBar.voiceHandler = ^(NSString * voicePath) {
        [[PeerManager sharedInst] sendVoiceForPath:voicePath toGroup:weakSelf.roomName];
    };
    
    self.dataSource.attachmentPreviewHandler = ^(NSString *path, NSString *cellId) {
        if ([cellId isEqualToString:userAttachmentChatCellID] || [cellId isEqualToString:peerAttachmentChatCellID]) {
            MPTImageViewController * imgVC = [weakSelf.storyboard instantiateViewControllerWithIdentifier:@"ImageVC"];
            imgVC.image = [UIImage imageWithContentsOfFile:path];
            [weakSelf.navigationController pushViewController:imgVC animated:YES];
        } else if ([cellId isEqualToString:userVoiceChatCellID] || [cellId isEqualToString:peerVoiceChatCellID]) {
            NSURL * soundUrl = [NSURL fileURLWithPath:path];
            weakSelf.player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
            weakSelf.player.numberOfLoops = 0;
            [weakSelf.player play];
        }
    };
    
    [[PeerManager sharedInst] joinOrCreateRoom:self.roomName withDisplayName:[[UserWrapper sharedInst] nameOfMine]];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [self.navigationController.view insertSubview:self.firstResponderField atIndex:0];
    [self.firstResponderField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.chatBar resignFirstResponder];
}

- (void)setRoomName:(NSString *)serviceType
{
    _roomName = serviceType;
    self.title = serviceType;
}

#pragma mark - Actions
- (IBAction)didSelectClearButton:(id)sender {
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"Select" cancelButtonItem:[RIButtonItem itemWithLabel:@"Cancel" action:nil] destructiveButtonItem:nil otherButtonItems:
                            [RIButtonItem itemWithLabel:@"Clear" action:^{
        [[MPTDataController sharedController] deleteAllChatMessagesInManagedObjectContext:nil];
    }], [RIButtonItem itemWithLabel:@"Show Peer Stat" action:^{
        PeerStatViewController * peerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PeerStatVC"];
        peerVC.inPeersArray = [[PeerManager sharedInst] getOutPeersByRoom:self.roomName];
        peerVC.outPeersArray = [[PeerManager sharedInst] getInPeersByRoom:self.roomName];
        peerVC.selfNameArray = @[[[UserWrapper sharedInst] nameOfMine]];

        NSLog(@"%@,%@,%@",peerVC.inPeersArray,peerVC.outPeersArray,peerVC.selfNameArray);
        
        [self.navigationController pushViewController:peerVC animated:YES];
    }], nil];
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
    
}



#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.firstResponderField.hidden = YES;
        [self.chatBar becomeFirstResponder];
    });
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:NULL];

    [[PeerManager sharedInst] sendImage:info[UIImagePickerControllerEditedImage] toGroup:self.roomName];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
