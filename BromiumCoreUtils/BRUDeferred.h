//
//  Copyright (C) 2013-2016, Bromium Inc.
//
//  This software may be modified and distributed under the terms
//  of the BSD license.  See the LICENSE file for details.
//
//  Created by Jason Morley on 19/02/2015.
//

#import <Foundation/Foundation.h>

@protocol BRUPromise;

typedef void (^BRUPromiseContinuationBlock)(id<BRUPromise> __nullable promise);
typedef void (^BRUPromiseThenBlock)(id __nullable value, BRUPromiseContinuationBlock __nonnull continuationBlock);

@protocol BRUPromise <NSObject>

- (nonnull id<BRUPromise>)then:(nonnull BRUPromiseThenBlock)block;

@end

@interface BRUDeferred : NSObject

+ (nonnull id<BRUPromise>)promiseWithValue:(nullable id)value;
+ (nonnull id<BRUPromise>)promiseWithTargetQueue:(nullable dispatch_queue_t)targetQueue value:(nullable id)value;

+ (nonnull instancetype)deferred;
+ (nonnull instancetype)deferredWithTargetQueue:(nullable dispatch_queue_t)targetQueue;
- (nonnull instancetype)initWithTargetQueue:(nullable dispatch_queue_t)targetQueue;
- (void)resolve:(nullable id)value;
- (nonnull id<BRUPromise>)promise;

@end
