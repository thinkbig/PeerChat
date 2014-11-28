//
//  MPTChatViewController.m
//  MultiPeerTest
//
//  Created by Wayne on 10/29/13.
//  Copyright (c) 2013 Wayne Hartman. All rights reserved.
//

#import "MPTChatViewController.h"
#import "MPTImageViewController.h"
#import "MPTChatDataSource.h"
#import "MPTChatBar.h"
#import "MPTDataController.h"
#import "PeerManager.h"
#import "UserWrapper.h"

#import "UIActionSheet+Blocks.h"

@interface MPTChatViewController () <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet MPTChatDataSource *dataSource;
@property (strong, nonatomic) IBOutlet UITextField *firstResponderField;
@property (nonatomic, strong) MPTChatBar *chatBar;

@end

#define SEGUE_IMAGE_PREVIEW @"SEGUE_IMAGE_PREVIEW"

@implementation MPTChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataSource.tableView = self.tableView;
    self.chatBar = [MPTChatBar chatBarWithNibName:@"MPTChatBar"];
    self.firstResponderField.inputAccessoryView = self.chatBar;

    __weak MPTChatViewController *weakSelf = self;
    self.chatBar.chatHandler = ^(NSString *message) {
        [[PeerManager sharedInst] sendMessage:message toGroup:weakSelf.serviceType];
    };

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
    
    self.dataSource.attachmentPreviewHandler = ^(NSString *path) {
        [weakSelf performSegueWithIdentifier:SEGUE_IMAGE_PREVIEW sender:path];
    };
    
    [[PeerManager sharedInst] joinOrCreateRoom:self.serviceType withDisplayName:[[UserWrapper sharedInst] nameOfMine]];
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:SEGUE_IMAGE_PREVIEW]) {
        MPTImageViewController *imageVC = segue.destinationViewController;
        imageVC.image = [UIImage imageWithContentsOfFile:sender];
    }
}

- (void)setServiceType:(NSString *)serviceType
{
    _serviceType = serviceType;
    self.title = serviceType;
}

#pragma mark - Actions

- (IBAction)didSelectClearButton:(id)sender {
    [[MPTDataController sharedController] deleteAllChatMessagesInManagedObjectContext:nil];
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

    [[PeerManager sharedInst] sendImage:info[UIImagePickerControllerEditedImage] toGroup:self.serviceType];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //[self.chatBar resignFirstResponder];
}

@end
