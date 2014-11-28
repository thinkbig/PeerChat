//
//  PeerUnit.h
//  PeerChat
//
//  Created by taq on 11/27/14.
//  Copyright (c) 2014 Tradeshift. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

//typedef void (^successPeerBlock)(id);
//typedef void (^failurePeerBlock)(NSError*);

@interface PeerUnit : NSObject

@property (nonatomic, strong) NSMutableArray *                  msgQueue;
@property (nonatomic, strong) NSMutableArray *                  fileQueue;      // only for image right now

@property (strong, nonatomic) NSString *      serviceType;    // limit of 8
@property (strong, nonatomic) NSString *      dispName;

@property (strong, nonatomic) MCPeerID *                        peerID;

@property (strong, nonatomic) MCPeerID *                        adPeerID;
@property (strong, nonatomic) MCSession *                       adSession;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *       advertiser;

@property (strong, nonatomic) MCPeerID *                        brPeerID;
@property (strong, nonatomic) MCSession *                       brSession;
@property (strong, nonatomic) MCNearbyServiceBrowser *          browser;

@property (strong, nonatomic) NSString *      peerGroup;

- (id) initWithDisplayName:(NSString*)dispName andGroupName:(NSString*)groupName;

- (void) start;
- (void) sendMessage:(NSString*)message;
- (void) sendImage:(UIImage *)image;
- (void) stop;

@end
