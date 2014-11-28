//
//  UserWrapper.m
//  PeerChat
//
//  Created by taq on 11/27/14.
//  Copyright (c) 2014 Tradeshift. All rights reserved.
//

#import "UserWrapper.h"

#define kUserName       @"kUserName"

@implementation UserWrapper

static UserWrapper * _sharedInst = nil;

+ (instancetype)sharedInst {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInst = [[UserWrapper alloc] init];
    });
    return _sharedInst;
}

+(NSString*)generateRandomString:(int)num {
    NSMutableString* string = [NSMutableString stringWithCapacity:num];
    for (int i = 0; i < num; i++) {
        [string appendFormat:@"%C", (unichar)('a' + arc4random_uniform(25))];
    }
    return string;
}

- (NSString*) nameOfMine
{
    NSString * name = [[NSUserDefaults standardUserDefaults] objectForKey:kUserName];
    if (nil == name) {
        name = [NSString stringWithFormat:@"Me_%@", [UserWrapper generateRandomString:8]];
        [self setUserName:name];
    }
    return name;
}

- (void) setUserName:(NSString*)name
{
    if (name) {
        [[NSUserDefaults standardUserDefaults] setObject:name forKey:kUserName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
