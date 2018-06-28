//
//  DataKeeper.m
//  testNetwork
//
//  Created by sgcy on 2018/6/26.
//  Copyright © 2018年 sgcy. All rights reserved.
//

#import "DataKeeper.h"

//typedef struct {
//    BOOL fin;
//    uint8_t opcode;
//    BOOL masked;
//    uint64_t payload_length;
//} frame_header;

@interface DataKeeper()

@property (nonatomic,strong) NSMutableDictionary *keeper;
@property (nullable, nonatomic, assign) CFHTTPMessageRef receivedHTTPHeaders;

@end

//
//size_t SRDefaultBufferSize(void) {
//    static size_t size;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        size = getpagesize();
//    });
//    return size;
//}

@implementation DataKeeper{
    
    dispatch_queue_t _workQueue;
//    NSMutableArray<SRIOConsumer *> *_consumers;
    
    dispatch_data_t _readBuffer;
    NSUInteger _readBufferOffset;
    
    dispatch_data_t _outputBuffer;
    NSUInteger _outputBufferOffset;
    
    uint8_t _currentFrameOpcode;
    size_t _currentFrameCount;
    size_t _readOpCount;
    uint32_t _currentStringScanPosition;
    NSMutableData *_currentFrameData;
    
    NSString *_closeReason;
    
    NSString *_secKey;

    
    uint8_t _currentReadMaskKey[4];
    size_t _currentReadMaskOffset;
    
    BOOL _closeWhenFinishedWriting;
    BOOL _failed;
    
    NSURLRequest *_urlRequest;
    
    BOOL _sentClose;
    BOOL _didFail;
    BOOL _cleanupScheduled;
    int _closeCode;
    BOOL _isPumping;

    NSMutableSet<NSArray *> *_scheduledRunloops; // Set<[RunLoop, Mode]>. TODO: (nlutsenko) Fix clowntown

    NSArray<NSString *> *_requestedProtocols;
//    SRIOConsumerPool *_consumerPool;
    
    NSMutableArray<NSData *> *_inputQueue;
}

+ (instancetype)shareInstance
{
    static dispatch_once_t once;
    static DataKeeper* sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[DataKeeper alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    if (self = [super init]) {
        _workQueue = dispatch_queue_create("com.DataKeeperQueue", DISPATCH_QUEUE_SERIAL);
        
//        // Going to set a specific on the queue so we can validate we're on the work queue
//        dispatch_queue_set_specific(_workQueue, (__bridge void *)self, (__bridge void *)(_workQueue), NULL);
//
        _readBuffer = dispatch_data_empty;
        _outputBuffer = dispatch_data_empty;
        
        _currentFrameData = [[NSMutableData alloc] init];
//
//        _consumers = [[NSMutableArray alloc] init];
//
//        _consumerPool = [[SRIOConsumerPool alloc] init];
        
        _scheduledRunloops = [[NSMutableSet alloc] init];
//
//        data_callback dataHandler = ^(NSData *data){
//            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSLog(@"----------------%@----------------%d",str,data.length);
//            });
//
//        };
//
//        dispatch_async(_workQueue, ^{
//           [self _readUntilBytes:CRLFCRLFBytes length:sizeof(CRLFCRLFBytes) callback:dataHandler];
//        });

    }
    return self;
}


- (NSString *)getDataForUrl:(NSString *)url
{
    NSData *data = [self.keeper objectForKey:url];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void)appendData:(const void *)buffer length:(size_t)length ForUrl:(NSString *)url
{
    
    if (length <= 0) {
        return;
    }
    
//    dispatch_async(_workQueue, ^{
//    if ([url isEqualToString:@"www.sina.com.cn:80"]) {
        dispatch_data_t data = dispatch_data_create(buffer, length, nil, DISPATCH_DATA_DESTRUCTOR_DEFAULT);
        self->_readBuffer = dispatch_data_create_concat(_readBuffer, data);
        
        NSString *str = [[NSString alloc] initWithData:_readBuffer encoding:NSUTF8StringEncoding];
        NSLog(@"");
//        if (str.length > 100) {
//            NSLog(@"-----------------------------------------------------------------------------------%@---------",str);
//        }else{
//            NSLog(@"========================================================================================%@==---------",str);
//        }
    
//        [self _pumpScanner];
//        }
    
//    });
    

 
}

//static const char CRLFCRLFBytes[] = {'\r', '\n', '\r', '\n'};
//
//- (void)_readUntilHeaderCompleteWithCallback:(data_callback)dataHandler;
//{
//    [self _readUntilBytes:CRLFCRLFBytes length:sizeof(CRLFCRLFBytes) callback:dataHandler];
//}
//
//- (void)_readUntilBytes:(const void *)bytes length:(size_t)length callback:(data_callback)dataHandler;
//{
//    // TODO optimize so this can continue from where we last searched
//    stream_scanner consumer = ^size_t(NSData *data) {
//        __block size_t found_size = 0;
//        __block size_t match_count = 0;
//
//        size_t size = data.length;
//        const unsigned char *buffer = data.bytes;
//        for (size_t i = 0; i < size; i++ ) {
//            if (((const unsigned char *)buffer)[i] == ((const unsigned char *)bytes)[match_count]) {
//                match_count += 1;
//                if (match_count == length) {
//                    found_size = i + 1;
//                    break;
//                }
//            } else {
//                match_count = 0;
//            }
//        }
//        return found_size;
//    };
//    [self _addConsumerWithScanner:consumer callback:dataHandler];
//}
//
//- (void)_addConsumerWithScanner:(stream_scanner)consumer callback:(data_callback)callback;
//{
//    [self _addConsumerWithScanner:consumer callback:callback dataLength:0];
//}
//
//- (void)_addConsumerWithScanner:(stream_scanner)consumer callback:(data_callback)callback dataLength:(size_t)dataLength;
//{
//    [_consumers addObject:[_consumerPool consumerWithScanner:consumer handler:callback bytesNeeded:dataLength readToCurrentFrame:NO unmaskBytes:NO]];
//    [self _pumpScanner];
//}
//
//-(void)_pumpScanner;
//{
//    if (!_isPumping) {
//        _isPumping = YES;
//    } else {
//        return;
//    }
//
//    while ([self _innerPumpScanner]) {
//
//    }
//    _isPumping = NO;
//}
//
//
//
//// Returns true if did work
//- (BOOL)_innerPumpScanner {
//
//    BOOL didWork = NO;
//
//
//    if (!_consumers.count) {
//        return didWork;
//    }
//
//    size_t readBufferSize = dispatch_data_get_size(_readBuffer);
//
//    size_t curSize = readBufferSize - _readBufferOffset;
//    if (!curSize) {
//        return didWork;
//    }
//
//    SRIOConsumer *consumer = [_consumers objectAtIndex:0];
//
//    size_t bytesNeeded = consumer.bytesNeeded;
//
//    size_t foundSize = 0;
//    if (consumer.consumer) {
//        NSData *subdata = (NSData *)dispatch_data_create_subrange(_readBuffer, _readBufferOffset, readBufferSize - _readBufferOffset);
//        foundSize = consumer.consumer(subdata);
//    } else {
//        assert(consumer.bytesNeeded);
//        if (curSize >= bytesNeeded) {
//            foundSize = bytesNeeded;
//        }
//    }
//
//    if (consumer.readToCurrentFrame || foundSize) {
//        dispatch_data_t slice = dispatch_data_create_subrange(_readBuffer, _readBufferOffset, foundSize);
//
//        _readBufferOffset += foundSize;
//
//        if (_readBufferOffset > SRDefaultBufferSize() && _readBufferOffset > readBufferSize / 2) {
//            _readBuffer = dispatch_data_create_subrange(_readBuffer, _readBufferOffset, readBufferSize - _readBufferOffset);
//            _readBufferOffset = 0;
//        }
//
//        if (foundSize) {
//
////            [_consumers removeObjectAtIndex:0];
//            consumer.handler((NSData *)slice);
//            [_consumerPool returnConsumer:consumer];
//            didWork = YES;
//        }
//    }
//    return didWork;
//}


//static inline int32_t validate_dispatch_data_partial_string(NSData *data) {
//    static const int maxCodepointSize = 3;
//
//    for (int i = 0; i < maxCodepointSize; i++) {
//        NSString *str = [[NSString alloc] initWithBytesNoCopy:(char *)data.bytes length:data.length - i encoding:NSUTF8StringEncoding freeWhenDone:NO];
//        if (str) {
//            return (int32_t)data.length - i;
//        }
//    }
//
//    return -1;
//}

@end
