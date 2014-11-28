//
//  UserWrapper.h
//  PeerChat
//
//  Created by taq on 11/27/14.
//  Copyright (c) 2014 Tradeshift. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserWrapper : NSObject

+ (instancetype)sharedInst;

- (NSString*) nameOfMine;

- (void) setUserName:(NSString*)name;

@end
