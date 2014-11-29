//
//  PeerManager.m
//  PeerChat
//
//  Created by taq on 11/27/14.
//  Copyright (c) 2014 Tradeshift. All rights reserved.
//

#import "PeerManager.h"
#import "PeerUnit.h"

@interface PeerManager ()

@property (nonatomic, retain) NSMutableDictionary *         peerDict;

@end

@implementation PeerManager

static PeerManager * _sharedInst = nil;

+ (instancetype)sharedInst {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInst = [[PeerManager alloc] init];
    });
    return _sharedInst;
}

- (id)init {
    self = [super init];
    if (self) {
        _peerDict = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return self;
}

- (void) joinOrCreateRoom:(NSString*)roomName withDisplayName:(NSString *)displayName
{
    PeerUnit * unit = self.peerDict[roomName];
    if (nil == unit) {
        unit = [[PeerUnit alloc] initWithDisplayName:displayName andGroupName:roomName];
        self.peerDict[roomName] = unit;
    } else {
        unit.dispName = displayName;
    }
    
    [unit start];
}

- (void) leaveRoom:(NSString*)roomName
{
    //PeerUnit * unit = self.peerDict[roomName];
}

- (void) sendMessage:(NSString*)message toGroup:(NSString*)groupName
{
    PeerUnit * unit = self.peerDict[groupName];
    [unit sendMessage:message];
}

- (void) sendImage:(UIImage *)image toGroup:(NSString*)groupName
{
    PeerUnit * unit = self.peerDict[groupName];
    [unit sendImage:image];
}

- (void) sendVoiceForPath:(NSString *)path toGroup:(NSString*)groupName
{
    PeerUnit * unit = self.peerDict[groupName];
    [unit sendFileWithPath:path];
}

-(NSArray *) getOutPeersByRoom:(NSString*)roomName {
    PeerUnit * unit = self.peerDict[roomName];
    return [unit getOutPeers];
}
-(NSArray *) getInPeersByRoom:(NSString *)roomName{
    PeerUnit * unit = self.peerDict[roomName];
    return [unit getInPeers];
}
@end
