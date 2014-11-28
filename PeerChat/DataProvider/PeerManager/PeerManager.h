//
//  PeerManager.h
//  PeerChat
//
//  Created by taq on 11/27/14.
//  Copyright (c) 2014 Tradeshift. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PeerUnit.h"

@interface PeerManager : NSObject

+ (instancetype)sharedInst;

// groupName equal with serviceType right now
- (void) joinOrCreateRoom:(NSString*)roomName withDisplayName:(NSString *)displayName;
- (void) leaveRoom:(NSString*)roomName;

- (void) sendMessage:(NSString*)message toGroup:(NSString*)groupName;
- (void) sendImage:(UIImage *)image  toGroup:(NSString*)groupName;

@end
