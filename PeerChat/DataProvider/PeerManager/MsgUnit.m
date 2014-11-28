//
//  MsgUnit.m
//  PeerChat
//
//  Created by taq on 11/28/14.
//  Copyright (c) 2014 Tradeshift. All rights reserved.
//

#import "MsgUnit.h"

@implementation MsgUnit

- (instancetype)init
{
    self = [super init];
    if ( nil != self ) {
        self.timestamp = [NSDate date];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if ( nil != self ) {
        self.msg = [decoder decodeObjectForKey:@"msg"];
        self.fromName = [decoder decodeObjectForKey:@"fromName"];
        self.toName = [decoder decodeObjectForKey:@"toName"];
        self.timestamp = [decoder decodeObjectForKey:@"timestamp"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:_msg forKey:@"msg"];
    [encoder encodeObject:_fromName forKey:@"fromName"];
    [encoder encodeObject:_toName forKey:@"toName"];
    [encoder encodeObject:_timestamp forKey:@"timestamp"];
}

- (id)copyWithZone:(NSZone *)zone
{
    MsgUnit *entry = [[[self class] allocWithZone:zone] init];
    entry.msg = [_msg copy];
    entry.fromName = [_fromName copy];
    entry.toName = [_toName copy];
    entry.timestamp = [_timestamp copy];
    return entry;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[MsgUnit class]]) {
        MsgUnit * anotherUnit = (MsgUnit*)object;
        if ([self.timestamp isEqualToDate:anotherUnit.timestamp] && [self.fromName isEqualToString:anotherUnit.fromName]) {
            if (self.msg && [self.msg isEqualToString:anotherUnit.msg]) {
                return YES;
            }
        }
    }
    return NO;
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation FileUnit

- (id) initWithPath:(NSString*)path andLength:(NSInteger)length
{
    self = [super init];
    if ( nil != self ) {
        self.filePath = path;
        self.fileLength = @(length);
        self.fileName = [path lastPathComponent];
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[FileUnit class]]) {
        FileUnit * anotherUnit = (FileUnit*)object;
        if ([self.fileName isEqualToString:anotherUnit.fileName] && [self.fileLength isEqualToNumber:anotherUnit.fileLength]) {
            return YES;
        }
    }
    return NO;
}

@end

