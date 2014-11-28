//
//  MsgUnit.h
//  PeerChat
//
//  Created by taq on 11/28/14.
//  Copyright (c) 2014 Tradeshift. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MsgUnit : NSObject

@property (nonatomic, strong) NSString *        msg;
@property (nonatomic, strong) NSString *        fromName;
@property (nonatomic, strong) NSString *        toName;
@property (nonatomic, strong) NSDate *          timestamp;

@end

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface FileUnit : NSObject

@property (nonatomic, strong) NSString *        filePath;
@property (nonatomic, strong) NSString *        fileName;
@property (nonatomic, strong) NSNumber *        fileLength;

- (id) initWithPath:(NSString*)path andLength:(NSInteger)length;

@end
