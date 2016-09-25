//
//  Copyright (C) 2013-2016, Bromium Inc.
//
//  This software may be modified and distributed under the terms
//  of the BSD license.  See the LICENSE file for details.
//
//  Created by Jason Morley on 19/02/2015.
//

#import "BRUDispatchUtils.h"
#import "BRUAsserts.h"
#import "BRUDeferred.h"

typedef NS_ENUM(NSUInteger, BRUPromiseState) {
    BRUPromiseStatePending = 1,
    BRUPromiseStateResolved = 2,
};

typedef void (^BRUPromiseTaskBlock)(id __nullable value);

@interface BRUDeferred () <BRUPromise>

@property (nonatomic, strong, readonly) dispatch_queue_t syncQueue;
@property (nonatomic, strong, readonly) dispatch_queue_t completionQueue;

/**
 * Accessed on syncQueue.
 */
@property (nonatomic, strong, readonly) NSMutableArray<BRUPromiseTaskBlock> *taskBlocks;

/**
 * Accessed on syncQueue.
 */
@property (nonatomic, strong, readwrite) id value;

/**
 * Accessed on syncQueue.
 */
@property (nonatomic, assign, readwrite) BRUPromiseState state;

@end

@implementation BRUDeferred

+ (nonnull id<BRUPromise>)promiseWithValue:(nullable id)value
{
    return [BRUDeferred promiseWithTargetQueue:nil value:value];
}

+ (nonnull id<BRUPromise>)promiseWithTargetQueue:(nullable dispatch_queue_t)targetQueue value:(nullable id)value
{
    BRUDeferred *deferred = [BRUDeferred deferredWithTargetQueue:targetQueue];
    [deferred resolve:value];
    return deferred;
}

+ (nonnull instancetype)deferred
{
    return [self new];
}

+ (nonnull instancetype)deferredWithTargetQueue:(nullable dispatch_queue_t)targetQueue
{
    return [[self alloc] initWithTargetQueue:targetQueue];
}

- (nonnull instancetype)init
{
    return [self initWithTargetQueue:nil];
}

- (nonnull instancetype)initWithTargetQueue:(nullable dispatch_queue_t)targetQueue
{
    self = [super init];
    if (self) {

        _syncQueue = bru_dispatch_queue_create("com.bromium.BromiumUtils.BRUPromise.syncQueue",
                                               DISPATCH_QUEUE_SERIAL);
        if (targetQueue) {
            _completionQueue = targetQueue;
        } else {
            _completionQueue = bru_dispatch_queue_create("com.bromium.BromiumUtils.BRUPromise.completionQueue",
                                                         DISPATCH_QUEUE_CONCURRENT);
        }
        _taskBlocks = [NSMutableArray array];
        _value = nil;
        _state = BRUPromiseStatePending;
    }
    return self;
}

+ (NSString *)stringForState:(BRUPromiseState)state
{
    if (state == BRUPromiseStatePending) {
        return @"pending";
    } else if (state == BRUPromiseStateResolved) {
        return @"resolved";
    } else {
        return @"unknown";
    }
}

- (void)resolve:(nullable id)value
{
    dispatch_async(self.syncQueue, ^{

        BRUAssert(self.state == BRUPromiseStatePending,
                  @"Attempt to resolve a %@ promise", [BRUDeferred stringForState:self.state]);

        self.state = BRUPromiseStateResolved;
        self.value = value;
        [self processBlocks];

    });
}

- (nonnull id<BRUPromise>)promise
{
    return self;
}

#pragma mark - BRUPromise

- (nonnull id<BRUPromise>)then:(nonnull BRUPromiseThenBlock)block
{
    BRUParameterAssert(block);

    BRUDeferred *next = [BRUDeferred deferredWithTargetQueue:self.completionQueue];

    dispatch_async(self.syncQueue, ^{

        BRUPromiseThenBlock blockCopy = [block copy];
        BRUPromiseTaskBlock resolver = ^(id value) {
            blockCopy(value, ^(id<BRUPromise> promise) {
                if (promise) {
                    [promise then:^(id  _Nullable value, BRUPromiseContinuationBlock  _Nonnull continuationBlock) {
                        [next resolve:value];
                        continuationBlock(nil);
                    }];
                } else {
                    [next resolve:value];
                }
            });
        };

        [self.taskBlocks addObject:resolver];
        [self processBlocks];

    });

    return [next promise];
}

- (void)processBlocks
{
    BRU_ASSERT_ON_QUEUE(self.syncQueue);

    if (self.state == BRUPromiseStatePending) {

        return;

    } else if (self.state == BRUPromiseStateResolved) {

        for (BRUPromiseTaskBlock block in self.taskBlocks) {

            dispatch_async(self.completionQueue, ^{

                block(self.value);

            });

        }
        [self.taskBlocks removeAllObjects];

    } else {

        BRU_ASSERT_NOT_REACHED(@"Unknown state %ld", (unsigned long)self.state);

    }
}

@end
