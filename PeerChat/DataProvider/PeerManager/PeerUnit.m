//
//  PeerUnit.m
//  PeerChat
//
//  Created by taq on 11/27/14.
//  Copyright (c) 2014 Tradeshift. All rights reserved.
//

#import "PeerUnit.h"
#import "MPTDataController.h"
#import "MsgUnit.h"
#import "UIImage+Resize.h"
#import "NSString+MD5.h"

#define kRECYCLED_PEER_ID               @"kRECYCLED_PEER_ID"

@interface PeerUnit () <MCNearbyServiceAdvertiserDelegate, MCSessionDelegate, MCNearbyServiceBrowserDelegate>

@property (nonatomic, strong) dispatch_semaphore_t        sem;
@property (nonatomic, strong) NSTimer *                   retryTimer;

@end

@implementation PeerUnit

+ (MCPeerID *)getRecycledPeerIDForName:(NSString*)dispName
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString * peerKey = [NSString stringWithFormat:@"%@_%@", kRECYCLED_PEER_ID, dispName];
    // if peer id exists, use that; else create one
    if ([defaults objectForKey:peerKey]) {
        NSData *peerIDData = [defaults dataForKey:peerKey];
        return [NSKeyedUnarchiver unarchiveObjectWithData:peerIDData];
    }
    else {
        return [[MCPeerID alloc] initWithDisplayName:dispName];
    }
}


- (id) initWithDisplayName:(NSString*)dispName andGroupName:(NSString*)groupName;
{
    self = [super init];
    if (self) {
        self.dispName = dispName;
        self.peerGroup = groupName;
        self.serviceType = [[groupName MD5] substringToIndex:15];
        self.msgQueue = [NSMutableArray array];
        self.fileQueue = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    [self.adSession disconnect];
    [self.brSession disconnect];
    [self.advertiser stopAdvertisingPeer];
    [self.browser stopBrowsingForPeers];
}

- (void)setDispName:(NSString *)dispName
{
    _dispName = dispName;
    MPTChatUser *currentUser = [[MPTDataController sharedController] chatUserWithPeerID:self.dispName inManagedObjectContext:nil];
    
    if (!currentUser) {
        currentUser = [[MPTDataController sharedController] createChatUserWithMapping:^(MPTChatUser *chatUser) {
            chatUser.username = dispName;
            chatUser.isLocalUser = @(YES);
        } inManagedObjectContext:nil];
        [currentUser.managedObjectContext save:nil];
    }
}

- (MCPeerID *)peerID {
    if (!_peerID) {
        _peerID = [PeerUnit getRecycledPeerIDForName:self.dispName];
    }
    return _peerID;
}

- (MCPeerID *)adPeerID {
    return self.peerID;
//    if (!_adPeerID) {
//        _adPeerID = [PeerUnit getRecycledPeerIDForName:self.dispName];
//    }
//    return _adPeerID;
}

- (MCPeerID *)brPeerID {
    return self.peerID;
//    if (!_brPeerID) {
//        _brPeerID = [PeerUnit getRecycledPeerIDForName:self.dispName];
//    }
//    return _brPeerID;
}

- (void) start
{
    [self advertiseSelf];
    
    self.sem = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC));
        dispatch_semaphore_wait(self.sem, timeout);
        [self searchingForExisting];
    });
}

- (void) stop
{
    [self.brSession disconnect];
    [self.browser stopBrowsingForPeers];
    [self.adSession disconnect];
    [self.advertiser stopAdvertisingPeer];
    self.peerID = nil;
    self.brPeerID = nil;
    self.adPeerID = nil;
}

- (void) searchingForExisting
{    
    [self.brSession disconnect];
    [self.browser stopBrowsingForPeers];

    //if (nil == self.brSession || ![self.brPeerID.displayName isEqualToString:self.dispName])
    {
        self.brSession = [[MCSession alloc] initWithPeer:self.brPeerID];
        self.brSession.delegate = self;
        self.browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.brPeerID serviceType:self.serviceType];
        self.browser.delegate = self;
    }
    
    [self.browser startBrowsingForPeers];
    
    [self ingestMessage:@"browse existing session..." attachmentURL:nil thumbnailURL:nil fromPeer:nil];
}

- (void) advertiseSelf
{
    [self.adSession disconnect];
    [self.advertiser stopAdvertisingPeer];
    
    //if (nil == self.adSession || ![self.brPeerID.displayName isEqualToString:self.dispName])
    {
        self.adSession = [[MCSession alloc] initWithPeer:self.adPeerID];
        self.adSession.delegate = self;
        self.advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.adPeerID discoveryInfo:nil serviceType:self.serviceType];
        self.advertiser.delegate = self;
    }
    
    [self.advertiser startAdvertisingPeer];
    
    [self ingestMessage:@"Waiting to be invited to a session..." attachmentURL:nil thumbnailURL:nil fromPeer:nil];
}

- (NSURL *)createFileURL:(NSString*)fileName {
    if (fileName.length == 0) {
        fileName = [[[NSUUID UUID] UUIDString] stringByAppendingPathExtension:@"jpg"];
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", NSTemporaryDirectory(), fileName];
    
    return [NSURL fileURLWithPath:filePath];
}

- (void)ingestMessage:(NSString *)message attachmentURL:(NSURL *)attachmentURL thumbnailURL:(NSURL *)thumbnailURL fromPeer:(MCPeerID *)peerID
{
    NSManagedObjectContext *context = [[MPTDataController sharedController] createManagedObjectContextForBackgroundThread];
    
    [context performBlock:^{
        MPTChatUser *user = nil;
        
        if (peerID != nil) {
            user = [[MPTDataController sharedController] chatUserWithPeerID:peerID.displayName inManagedObjectContext:context];
            
            if (user == nil) {
                user = [[MPTDataController sharedController] createChatUserWithMapping:^(MPTChatUser *chatUser) {
                    chatUser.username = peerID.displayName;
                } inManagedObjectContext:context];
            }
        }
        
        [[MPTDataController sharedController] createChatMessageWithMapping:^(MPTChatMessage *chatMessage) {
            chatMessage.user = user;
            chatMessage.messageText = message;
            chatMessage.receivedTime = [NSDate date];
            chatMessage.attachmentUri = attachmentURL.path;
            chatMessage.attachmentThumbnailUri = thumbnailURL.path;
        } inManagedObjectContext:context];
        
        NSError *error = nil;
        BOOL saved = [context save:&error];
        
        if (!saved) {
            NSLog(@"error ingesting message! %@", error);
        }
    }];
}

- (void) sendMessage:(NSString*)message
{
    if (message == nil) {
        return;
    }
    
    [self ingestMessage:message attachmentURL:nil thumbnailURL:nil fromPeer:self.brPeerID];
    
    MsgUnit * unit = [[MsgUnit alloc] init];
    unit.msg = message;
    unit.fromName = self.dispName;
    [self __realSendMessageUnit:unit exceptionPeer:nil];
}

- (BOOL) __realSendMessageUnit:(MsgUnit*)unit exceptionPeer:(MCPeerID*)expPeer
{
    if (nil == unit || [self.msgQueue containsObject:unit]) {
        return NO;
    }
    [self.msgQueue addObject:unit];
    
    NSData *messageData = [NSKeyedArchiver archivedDataWithRootObject:unit];
    
    NSMutableSet * peerSet = [NSMutableSet set];
    if (expPeer) {
        [peerSet addObject:expPeer.displayName];
    }
    if (self.brSession.connectedPeers.count > 0) {
        NSMutableArray * sendArr = [NSMutableArray array];
        NSArray * subArr = self.brSession.connectedPeers;
        for (MCPeerID * peer in subArr) {
            if (![peerSet containsObject:peer.displayName]) {
                [peerSet addObject:peer.displayName];
                [sendArr addObject:peer];
            }
        }
        
        if (sendArr.count > 0) {
            NSError *error = nil;
            BOOL queued = [self.brSession sendData:messageData
                                           toPeers:sendArr
                                          withMode:MCSessionSendDataReliable
                                             error:&error];
            
            if (!queued) {
                NSLog(@"Error enqueuing the message! %@", error);
            }
        }
    }
    if (self.adSession.connectedPeers.count > 0) {
        NSMutableArray * sendArr = [NSMutableArray array];
        NSArray * subArr = self.adSession.connectedPeers;
        for (MCPeerID * peer in subArr) {
            if (![peerSet containsObject:peer.displayName]) {
                [peerSet addObject:peer.displayName];
                [sendArr addObject:peer];
            }
        }
        
        if (sendArr.count > 0) {
            NSError *error = nil;
            BOOL queued = [self.adSession sendData:messageData
                                           toPeers:sendArr
                                          withMode:MCSessionSendDataReliable
                                             error:&error];
            
            if (!queued) {
                NSLog(@"Error enqueuing the message! %@", error);
            }
        }
    }
    
    return YES;
}

- (void) sendImage:(UIImage *)image
{
    //  Do all our work on a background thread
    dispatch_async(dispatch_queue_create("com.tradeshift.imageprocessing", NULL), ^{
        NSURL *thumbnailURL = [self createFileURL:nil];
        NSURL *scaledURL = [self createFileURL:nil];
        
        CGFloat scaleFactor = 0.33f;
        
        NSData *thumbnailData = nil;
        NSData *scaledImageData = nil;
        
        //  Using an autorelease pool to flush memory we don't need anymore
        @autoreleasepool {
            UIImage *scaledImage = [image resizedImage:CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor)
                                  interpolationQuality:kCGInterpolationHigh];
            UIImage *thumbnail = [image thumbnailImage:150
                                     transparentBorder:0
                                          cornerRadius:0
                                  interpolationQuality:kCGInterpolationMedium];
            thumbnailData = UIImageJPEGRepresentation(thumbnail, 0.75f);
            scaledImageData = UIImageJPEGRepresentation(scaledImage, 0.75f);
        }
        
        //  Write everything to disk so we can reference it later
        NSFileManager *fm = [NSFileManager defaultManager];
        
        [fm createFileAtPath:scaledURL.path
                    contents:scaledImageData
                  attributes:nil];
        [fm createFileAtPath:thumbnailURL.path
                    contents:thumbnailData
                  attributes:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self ingestMessage:nil attachmentURL:scaledURL thumbnailURL:thumbnailURL fromPeer:self.peerID];
            FileUnit * unit = [[FileUnit alloc] initWithPath:scaledURL.path];
            [self __realSendFile:unit exceptionPeer:nil];
        });
    });
}

- (void) sendFileWithPath:(NSString *)path
{
    if (path.length > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self ingestMessage:nil attachmentURL:[NSURL fileURLWithPath:path] thumbnailURL:nil fromPeer:self.peerID];
            FileUnit * unit = [[FileUnit alloc] initWithPath:path];
            [self __realSendFile:unit exceptionPeer:nil];
        });
    }
}

- (BOOL) __realSendFile:(FileUnit*)unit exceptionPeer:(MCPeerID*)expPeer
{
    __block BOOL exist = NO;
    __block BOOL shouldReturn = NO;
    [self.fileQueue enumerateObjectsUsingBlock:^(FileUnit * obj, NSUInteger idx, BOOL *stop) {
        if ([unit isEqual:obj]) {
            if (obj.haveSend) {
                shouldReturn = YES;
            }
            exist = YES;
            obj.haveSend = YES;
            *stop = YES;
        }
    }];
    if (shouldReturn) {
        return NO;
    } else if (!exist) {
        unit.haveSend = YES;
        [self.fileQueue addObject:unit];
    }
    
    NSURL * fileUrl = [NSURL fileURLWithPath:unit.filePath];
    NSString * fileName = unit.fileName;

    NSMutableSet * peerSet = [NSMutableSet set];
    if (expPeer) {
        [peerSet addObject:expPeer.displayName];
    }
    NSArray * subArr = self.brSession.connectedPeers;
    for (MCPeerID * peer in subArr) {
        if (![peerSet containsObject:peer.displayName]) {
            [peerSet addObject:peer.displayName];
            [self.brSession sendResourceAtURL:fileUrl
                                     withName:fileName
                                       toPeer:peer
                        withCompletionHandler:^(NSError *error) {
                            if (error) {
                                NSLog(@"Error sending image! %@", error);
                            }
                        }];
        }
    }
    subArr = self.adSession.connectedPeers;
    for (MCPeerID * peer in subArr) {
        if (![peerSet containsObject:peer.displayName]) {
            [peerSet addObject:peer.displayName];
            [self.brSession sendResourceAtURL:fileUrl
                                     withName:fileName
                                       toPeer:peer
                        withCompletionHandler:^(NSError *error) {
                            if (error) {
                                NSLog(@"Error sending image! %@", error);
                            }
                        }];
        }
    }
    return YES;
}

- (BOOL) isExistingPeer:(MCPeerID*)peerID
{
    return [peerID.displayName isEqualToString:self.dispName] || [self.brSession.connectedPeers containsObject:peerID] || [self.adSession.connectedPeers containsObject:peerID];
    
//    return [peerID.displayName isEqualToString:self.dispName] ||
//    [self.brSession.connectedPeers indexesOfObjectsPassingTest:^BOOL(MCPeerID * obj, NSUInteger idx, BOOL *stop) {
//        return [peerID.displayName isEqualToString:obj.displayName];
//    }].count > 0 ||
//    [self.adSession.connectedPeers indexesOfObjectsPassingTest:^BOOL(MCPeerID * obj, NSUInteger idx, BOOL *stop) {
//        return [peerID.displayName isEqualToString:obj.displayName];
//    }] > 0;
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    if ([self isExistingPeer:peerID]) {
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"Received invitation from %@. Joining...", peerID.displayName];
    [self ingestMessage:message attachmentURL:nil thumbnailURL:nil fromPeer:nil];
    
    invitationHandler(YES, self.adSession);    // In most cases you might want to give users an option to connect or not.
    //[self.advertiser stopAdvertisingPeer];  //  Once invited, stop advertising
    
    if (self.sem) {
        dispatch_semaphore_signal(self.sem);
        self.sem = nil;
    }
}

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error {
    NSLog(@"unable to advertise! %@", error);
}


#pragma mark - MCNearbyServiceBrowserDelegate

- (void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    if ([self isExistingPeer:peerID]) {
        return;
    }
    
    NSString *message = [NSString stringWithFormat:@"Sending an invitation to %@ to join the chat...", peerID.displayName];
    [self ingestMessage:message attachmentURL:nil thumbnailURL:nil fromPeer:nil];
    
    [browser invitePeer:peerID toSession:self.brSession withContext:nil timeout:10.0];
}

// A nearby peer has stopped advertising
- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    if ([self isExistingPeer:peerID]) {
        return;
    }
    NSString *message = [NSString stringWithFormat:@"%@ was disconnected...", peerID.displayName];
    [self ingestMessage:message attachmentURL:nil thumbnailURL:nil fromPeer:nil];
}

- (void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error {
    NSLog(@"error browsing!!! %@", error);
}


#pragma mark - MCSessionDelegate

// Remote peer changed state
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state {
    NSLog(@"Peer did change state: %i", state);
    NSString *action = nil;
    switch (state) {
        case MCSessionStateConnected: {
            action = @"is now connected";
            [self.retryTimer invalidate];
            self.retryTimer = nil;
            if (self.sem) {
                dispatch_semaphore_signal(self.sem);
                self.sem = nil;
            }
        }
            break;
        case MCSessionStateConnecting: {
            [self.retryTimer invalidate];
            self.retryTimer = nil;
            action = @"is connecting";
        }
            break;
        case MCSessionStateNotConnected: {
            action = @"disconnected";
        }
            break;
    }
    
    if ([self isExistingPeer:peerID]) {
        //[session disconnect];
    } else {
        if (state == MCSessionStateNotConnected && self.adSession.connectedPeers.count == 0 && self.brSession.connectedPeers.count == 0)
        {
            NSLog(@"retry reconect");
            //self.retryTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(start) userInfo:nil repeats:NO];
        }
    }
    NSString *message = [NSString stringWithFormat:@"%@ %@...", peerID.displayName, action];
    [self ingestMessage:message attachmentURL:nil thumbnailURL:nil fromPeer:nil];
    NSLog(@"adsession count = %lu, brsession count = %lu", (unsigned long)self.adSession.connectedPeers.count, (unsigned long)self.brSession.connectedPeers.count);
}

// Received data from remote peer
- (void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID {
    NSLog(@"Received Message...");
    NSError *error = nil;
    
    MsgUnit * unit = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    if (!unit) {
        NSLog(@"error decoding message! %@", error);
    } else if ([self __realSendMessageUnit:unit exceptionPeer:peerID]) {
        [self ingestMessage:unit.msg
              attachmentURL:nil
               thumbnailURL:nil
                   fromPeer:peerID];
    }
}

// Received a byte stream from remote peer
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID {
    
}

// Start receiving a resource from remote peer
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress {
    NSLog(@"downloading file: %f%%", progress.fractionCompleted);
}

// Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error {
    NSLog(@"finished receiving file...");
    
    if (error) {
        NSLog(@"Error when receiving file! %@", error);
    } else {
        FileUnit * unit = [[FileUnit alloc] initWithPath:localURL.path];
        unit.fileName = resourceName;
        __block BOOL exist = NO;
        __block BOOL shouldReturn = NO;
        [self.fileQueue enumerateObjectsUsingBlock:^(FileUnit * obj, NSUInteger idx, BOOL *stop) {
            if ([unit isEqual:obj]) {
                if ((obj.haveReceived || obj.haveSend)) {
                    shouldReturn = YES;
                }
                exist = YES;
                obj.haveReceived = YES;
                *stop = YES;
            }
        }];
        if (shouldReturn) {
            return ;
        } else if (!exist) {
            unit.haveReceived = YES;
            [self.fileQueue addObject:unit];
        }
        
        NSString * extention = [resourceName pathExtension];
        if ([extention isEqualToString:@"caf"]) {
            [self ingestMessage:nil attachmentURL:localURL thumbnailURL:nil fromPeer:peerID];
            [self __realSendFile:unit exceptionPeer:peerID];
        } else {
            dispatch_async(dispatch_queue_create("com.tradeshift.imagereception", NULL), ^{
                NSData *imageData = nil;
                NSData *thumbnailData = nil;
                
                @autoreleasepool {
                    UIImage *image = [UIImage imageWithContentsOfFile:localURL.path];
                    UIImage *thumbnail = [image thumbnailImage:150
                                             transparentBorder:0
                                                  cornerRadius:0
                                          interpolationQuality:kCGInterpolationMedium];
                    imageData = UIImageJPEGRepresentation(image, 1.0f);
                    thumbnailData = UIImageJPEGRepresentation(thumbnail, 1.0f);
                }
                
                NSURL *imageURL = [self createFileURL:resourceName];
                NSURL *thumbnailURL = [self createFileURL:nil];
                
                NSFileManager *fm = [NSFileManager defaultManager];
                [fm createFileAtPath:imageURL.path contents:imageData attributes:nil];
                [fm createFileAtPath:thumbnailURL.path contents:thumbnailData attributes:nil];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self ingestMessage:nil attachmentURL:imageURL thumbnailURL:thumbnailURL fromPeer:peerID];
                    unit.filePath = imageURL.path;
                    unit.fileName = resourceName;
                    [self __realSendFile:unit exceptionPeer:peerID];
                });
            });
        }
    }
}


-(NSArray *)getOutPeers{
    NSMutableArray * peerNames = [NSMutableArray arrayWithCapacity:8];
    NSArray * peers = [self.adSession.connectedPeers copy];
    for (MCPeerID * peer in peers) {
        [peerNames addObject:peer.displayName];
    }
    return peerNames;
}

-(NSArray *) getInPeers{
    NSMutableArray *peerNames = [NSMutableArray arrayWithCapacity:8];
    NSArray *peers = [self.brSession.connectedPeers copy];
    for(MCPeerID * peer in peers){
       [peerNames addObject:peer.displayName];
    }
    return peerNames;
}

@end
